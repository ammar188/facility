import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:facility/screens/chat/modules/chat_message_model.dart';
import 'package:facility/screens/chat/modules/chat_model.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState.initial());

  int chatOffset = 0;
  final int chatLimit = 10;
  bool isLoadingChats = false;

  int messageOffset = 0;
  final int messageLimit = 20;
  bool isLoadingMessages = false;
  bool hasMoreMessages = true;

  StreamSubscription<ChatModel>? _chatsSubscription;
  StreamSubscription<MessageModel>? _messagesSubscription;

  // Use LinkedHashMap to maintain insertion order for LRU eviction
  final LinkedHashMap<int, List<MessageModel>> _cachedMessages =
      LinkedHashMap();

  Future<void> fetchChats({bool reset = false}) async {
    if (isLoadingChats) return;
    if (!reset && !state.hasMoreChats) return;

    try {
      _prepareForChatFetch(reset);

      isLoadingChats = true;

      final fetched = await _fetchChatsFromServer();

      await _handleFetchedChats(fetched, reset);

      _subscribeToIncomingChats();
      _subscribeToIncomingMessages();
    } catch (e) {
      log('Failed to fetch chats: $e');
      emit(
        state.copyWith(
          status: ChatStatusEnum.failure,
          hasMoreChats: false,
        ),
      );
    } finally {
      isLoadingChats = false;
    }
  }

  /// Create or get a default chat for the user
  /// This ensures there's always a chat available
  Future<void> ensureDefaultChat() async {
    try {
      // If already have a selected chat, return
      if (state.selectedChat != null) {
        log('Chat already selected: ${state.selectedChat!.id}');
        return;
      }

      // If have chats but none selected, select the first one
      if (state.chats.isNotEmpty) {
        log('Selecting first existing chat: ${state.chats.first.id}');
        await selectChat(state.chats.first);
        return;
      }

      // Try to fetch existing chats first (but don't fail if table doesn't exist)
      try {
        final fetched = await _fetchChatsFromServer();
        if (fetched.isNotEmpty) {
          log('Found ${fetched.length} existing chats');
          await _handleFetchedChats(fetched, true);
          if (state.chats.isNotEmpty) {
            await selectChat(state.chats.first);
            return;
          }
        } else {
          log('No existing chats found in database');
        }
      } catch (e) {
        // If table doesn't exist (404) or other error, create a virtual chat
        final errorStr = e.toString();
        if (errorStr.contains('404') || 
            errorStr.contains('does not exist') ||
            (errorStr.contains('relation') && errorStr.contains('not found'))) {
          log('Conversation table does not exist. Using default chat ID.');
          // Create a virtual chat with default ID
          _createVirtualChat();
          return;
        }
        log('Failed to fetch existing chats: $e');
        // Continue to try creating a new chat
      }

      // If no chats exist, try to create a new one
      try {
        log('Creating default chat...');
        final newChat = await ChatModel.createChat();
        log('Created default chat with ID: ${newChat.id}');

        // Update state with the new chat
        emit(state.copyWith(
          chats: [newChat],
          selectedChat: newChat,
          status: ChatStatusEnum.success,
          messages: [], // Start with empty messages
        ));

        // Load messages for the new chat (but don't fail if messages table is empty)
        try {
          await selectChat(newChat);
        } catch (e) {
          log('Failed to load messages for new chat (this is OK): $e');
          // Still keep the chat selected even if messages fail to load
          // Subscribe to real-time updates anyway
          _subscribeToIncomingMessages();
        }
      } catch (e) {
        // If chat creation fails (table doesn't exist), use virtual chat
        final errorStr = e.toString();
        if (errorStr.contains('404') || 
            errorStr.contains('does not exist') ||
            (errorStr.contains('relation') && errorStr.contains('not found'))) {
          log('Cannot create chat (table missing). Using default virtual chat.');
          _createVirtualChat();
        } else {
          rethrow;
        }
      }
    } catch (e) {
      log('Failed to ensure default chat: $e');
      // Create virtual chat as last resort
      _createVirtualChat();
    }
  }

  /// Create a virtual chat when conversation table doesn't exist
  /// Uses a default chat ID (1) for messages
  void _createVirtualChat() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      log('Cannot create virtual chat: user not logged in');
      return;
    }

    // Create a virtual chat model with default ID
    final virtualChat = ChatModel(
      id: 1, // Default chat ID
      otherUserId: currentUser.id,
      createdAt: DateTime.now(),
      seen: true,
      otherUserName: 'Default Chat',
      user1Id: currentUser.id,
      user2Id: currentUser.id,
    );

    log('Created virtual chat with ID: ${virtualChat.id}');

    // Update state with the virtual chat
    emit(state.copyWith(
      chats: [virtualChat],
      selectedChat: virtualChat,
      status: ChatStatusEnum.success,
      messages: [], // Start with empty messages
    ));
    
    // Try to load messages for virtual chat
    try {
      selectChat(virtualChat);
    } catch (e) {
      log('Failed to load messages for virtual chat: $e');
      // Subscribe to real-time updates anyway
      _subscribeToIncomingMessages();
    }
  }

  void _prepareForChatFetch(bool reset) {
    if (reset) {
      emit(
        state.copyWith(
          status: ChatStatusEnum.loadingChats,
          chats: [],
          hasMoreChats: true,
        ),
      );
      chatOffset = 0;
    } else {
      emit(state.copyWith(status: ChatStatusEnum.loadingChats));
    }
  }

  Future<List<ChatModel>> _fetchChatsFromServer() async {
    return ChatModel.fetchChats(
      limit: chatLimit,
      offset: chatOffset,
    );
  }

  Future<void> _handleFetchedChats(
    List<ChatModel> fetched,
    bool reset,
  ) async {
    final newHasMore = fetched.length == chatLimit;
    chatOffset += fetched.length;

    final existing = <int>{};
    final allChats = <ChatModel>[];

    if (!reset) {
      for (final chat in state.chats) {
        existing.add(chat.id); // assuming chatId is the unique field
        allChats.add(chat);
      }
    }

    for (final chat in fetched) {
      if (!existing.contains(chat.id)) {
        existing.add(chat.id);
        allChats.add(chat);
      }
    }

    final shouldSelectFirstChat =
        state.selectedChat == null && allChats.isNotEmpty;
    final newSelectedChat =
        shouldSelectFirstChat ? allChats.first : state.selectedChat;

    emit(
      state.copyWith(
        status: ChatStatusEnum.success,
        chats: allChats,
        hasMoreChats: newHasMore,
        selectedChat: newSelectedChat,
      ),
    );

    if (shouldSelectFirstChat) {
      await selectChat(newSelectedChat!);
    }
  }

  void _subscribeToIncomingMessages() {
    final chatIds = state.chats.map((chat) => chat.id).toList();
    _messagesSubscription?.cancel();

    _messagesSubscription = MessageModel.streamMessages(chatIds).listen(
      (newMessage) {
        log('Real-time: Received new message. ID: ${newMessage.id}, Content: ${newMessage.content}, ChatId: ${newMessage.chatId}');
        final currentState = state; // Capture current state
        final chatId = newMessage.chatId;

        // Get current messages for this chat from cache OR from state if it's the selected chat
        final isSelectedChatForRealTime = currentState.selectedChat?.id == chatId;
        final currentCached = _cachedMessages[chatId] ?? [];
        
        // If this is the selected chat and we have messages in state, use those instead of cache
        final currentMessages = isSelectedChatForRealTime && currentState.messages.isNotEmpty
            ? List<MessageModel>.from(currentState.messages)
            : List<MessageModel>.from(currentCached);

        log('Real-time: Current messages count: ${currentMessages.length}, Is selected chat: $isSelectedChatForRealTime');

        // Check if message already exists by ID
        final newMessageId = newMessage.id;
        if (newMessageId != null) {
          final alreadyExists = currentMessages.any((m) {
            final messageId = m.id;
            return messageId != null && messageId == newMessageId;
          });
          if (alreadyExists) {
            log('Real-time: Message already exists, skipping');
            return;
          }
        }

        // Check if there's an optimistic message (null ID) with same content that we should replace
        final optimisticIndex = currentMessages.indexWhere(
          (m) {
            final messageId = m.id;
            return messageId == null && 
                   m.content == newMessage.content && 
                   m.chatId == chatId &&
                   m.senderId == newMessage.senderId;
          }
        );

        final updatedMessages = List<MessageModel>.from(currentMessages);
        if (optimisticIndex != -1) {
          // Replace optimistic message with real one
          updatedMessages[optimisticIndex] = newMessage;
          log('Real-time: Replaced optimistic message at index $optimisticIndex with real message');
        } else {
          // Add new message
          updatedMessages.add(newMessage);
          log('Real-time: Added new message. Total: ${updatedMessages.length}');
        }
        
        // Update cache
        _addToCache(chatId, updatedMessages);

        // Update chats list (lastMessageContent, timestamp, seen = false)
        final updatedChats = List<ChatModel>.from(currentState.chats).map((chat) {
          if (chat.id == chatId) {
            return chat.copyWith(
              lastMessageContent: newMessage.content,
              lastMessageCreatedAt: newMessage.createdAt,
              seen: false, // newly arrived message = not seen
            );
          }
          return chat;
        }).toList();

        // Only update messages if this is the currently selected chat
        if (isSelectedChatForRealTime) {
          emit(
            currentState.copyWith(
              status: ChatStatusEnum.success,
              chats: updatedChats,
              messages: updatedMessages, // Use the updated messages
              selectedChat: currentState.selectedChat?.copyWith(seen: false),
            ),
          );
          log('Real-time: Updated messages for selected chat. Count: ${updatedMessages.length}');
        } else {
          // Only update chats list, not messages (different chat is selected)
          emit(
            currentState.copyWith(
              status: ChatStatusEnum.success,
              chats: updatedChats,
              // Don't update messages - keep current chat's messages
            ),
          );
          log('Real-time: Updated chats list only (different chat selected)');
        }
      },
      onError: (Object error) {
        log('Message stream error: $error');
      },
      onDone: () {
        log('Message stream closed.');
      },
      cancelOnError: true,
    );
  }

  void _subscribeToIncomingChats() {
    // Cancel previous subscription if exists
    _chatsSubscription?.cancel();

    _chatsSubscription = ChatModel.streamNewChatsForUser().listen(
      (newChat) {
        final exists = state.chats.any((chat) => chat.id == newChat.id);
        if (exists) return; // avoid duplicates

        final updatedChats = [newChat, ...state.chats];
        emit(state.copyWith(chats: updatedChats));
        _subscribeToIncomingMessages();
      },
      onError: (Object e) {
        log('Error streaming new chats: $e');
      },
      onDone: () {
        log('New chat stream closed.');
      },
      cancelOnError: true,
    );
  }

  Future<void> markCurrentChatSeen() async {
    final selectedChat = state.selectedChat;
    if (selectedChat == null || selectedChat.seen == true) return;

    try {
      await ChatModel.markSeen(selectedChat);

      final updatedChats = state.chats.map((chat) {
        if (chat.id == selectedChat.id) {
          return chat.copyWith(seen: true);
        }
        return chat;
      }).toList();

      emit(
        state.copyWith(
          chats: updatedChats,
          selectedChat: selectedChat.copyWith(seen: true),
        ),
      );
    } catch (e) {
      log('Failed to mark chat seen: $e');
    }
  }

  Future<void> loadMore() async => fetchChats();
  Future<void> refresh() async => fetchChats(reset: true);

  Future<void> selectChat(ChatModel chat) async {
    emit(state.copyWith(status: ChatStatusEnum.loadingMessages));

    try {
      messageOffset = 0;
      hasMoreMessages = true;

      List<MessageModel> messages;
      if (_cachedMessages.containsKey(chat.id)) {
        final cached = _cachedMessages.remove(chat.id)!;
        _cachedMessages[chat.id] = cached;
        messages = cached;
      } else {
        messages = await MessageModel.fetchMessages(
          chat.id,
          limit: messageLimit,
          offset: messageOffset,
        );
        _addToCache(chat.id, messages);
      }

      messageOffset += messages.length;
      hasMoreMessages = messages.length == messageLimit;

      emit(
        state.copyWith(
          status: ChatStatusEnum.success,
          selectedChat: chat,
          messages: messages,
        ),
      );

      // Ensure real-time subscription is active for this chat
      _subscribeToIncomingMessages();
    } catch (e) {
      log('Failed to load messages: $e');
      emit(state.copyWith(status: ChatStatusEnum.failure));
    }
  }

  Future<void> loadOlderMessages() async {
    if (isLoadingMessages || !hasMoreMessages || state.selectedChat == null) {
      return;
    }

    isLoadingMessages = true;

    try {
      final chatId = state.selectedChat!.id;
      final olderMessages = await MessageModel.fetchMessages(
        chatId,
        limit: messageLimit,
        offset: messageOffset,
      );

      messageOffset += olderMessages.length;
      hasMoreMessages = olderMessages.length == messageLimit;

      final updatedMessages = List<MessageModel>.from(olderMessages)
        ..addAll(state.messages);

      _addToCache(chatId, updatedMessages);

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      log('Failed to load older messages: $e');
    } finally {
      isLoadingMessages = false;
    }
  }

  void _addToCache(int chatId, List<MessageModel> messages) {
    if (_cachedMessages.containsKey(chatId)) {
      _cachedMessages.remove(chatId);
    }

    _cachedMessages[chatId] = messages;

    if (_cachedMessages.length > 5) {
      _cachedMessages.remove(_cachedMessages.keys.first);
    }
  }

  void clear() {
    emit(ChatState.initial());
    chatOffset = 0;
    messageOffset = 0;
    hasMoreMessages = true;
    isLoadingChats = false;
    isLoadingMessages = false;
    _cachedMessages.clear();
  }

  Future<void> sendMessage({required String text}) async {
    try {
      ChatModel? chatToUse = state.selectedChat;
      
      // If no chat is selected, ensure we have a default chat
      if (chatToUse == null) {
        log('No chat selected. Ensuring default chat exists...');
        await ensureDefaultChat();
        chatToUse = state.selectedChat;
        
        if (chatToUse == null) {
          log('Failed to get or create chat');
          throw Exception('Unable to create chat. Please try again.');
        }
        
        log('Using chat with ID: ${chatToUse.id}');
      }

      // Verify the conversation exists in Supabase before sending message
      // This ensures the conversation record is properly created with user IDs
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in first.');
      }

      log('Verifying conversation exists in Supabase...');
      log('Conversation ID: ${chatToUse.id}');
      log('User ID: ${currentUser.id}');
      
      // Store currentUser for later use
      final userId = currentUser.id;

      // Check if this is a virtual chat (ID = 1, but might not exist in DB)
      // If user1Id or user2Id are null, it means the chat wasn't properly created
      if (chatToUse.user1Id == null || chatToUse.user2Id == null) {
        log('Chat missing user IDs, creating new conversation in Supabase...');
        final newChat = await ChatModel.createChat();
        log('Created new conversation with ID: ${newChat.id}');
        
        // Update state with the new chat
        emit(state.copyWith(
          chats: [newChat, ...state.chats],
          selectedChat: newChat,
        ));
        
        chatToUse = newChat;
      } else {
        // Try to verify the conversation exists by fetching it
        try {
          final conversation = await Supabase.instance.client
              .from('Conversation')
              .select()
              .eq('id', chatToUse.id)
              .single();
          log('Conversation verified in Supabase: ID=${conversation['id']}, User=${conversation['user_id']}, Vendor=${conversation['vendor_id']}');
        } catch (e) {
          // If conversation doesn't exist in DB, create it
          log('Conversation not found in Supabase, creating new one...');
          final newChat = await ChatModel.createChat();
          log('Created new conversation with ID: ${newChat.id}');
          
          // Update state with the new chat
          emit(state.copyWith(
            chats: [newChat, ...state.chats],
            selectedChat: newChat,
          ));
          
          chatToUse = newChat;
        }
      }

      // Store chatId to avoid null safety issues
      final chatId = chatToUse.id;
      
      // Create optimistic message first (show immediately on screen)
      final optimisticMessage = MessageModel(
        id: null, // Will be set when saved to DB
        chatId: chatId,
        senderId: userId,
        content: text,
        createdAt: DateTime.now(),
      );

      // Update local state IMMEDIATELY for instant UI feedback
      final currentState = state;
      final currentMessages = List<MessageModel>.from(currentState.messages);
      currentMessages.add(optimisticMessage);
      
      log('Before adding optimistic: ${currentState.messages.length} messages');
      log('After adding optimistic: ${currentMessages.length} messages');
      log('Optimistic message: content="${optimisticMessage.content}", id=${optimisticMessage.id}, createdAt=${optimisticMessage.createdAt}');
      
      // Update cache
      _addToCache(chatId, currentMessages);

      // Update state with optimistic message immediately (shows on screen right away)
      // Make sure we preserve the selectedChat
      emit(currentState.copyWith(
        status: ChatStatusEnum.success,
        messages: currentMessages,
        selectedChat: currentState.selectedChat, // Preserve selected chat
      ));

      log('State emitted with optimistic message. Message count: ${currentMessages.length}');
      log('Selected chat ID: ${currentState.selectedChat?.id}');

      // Now send message to Supabase
      try {
        log('Sending message to conversation $chatId...');
        final sentMessage = await MessageModel.sendMessage(
          chatId: chatId,
          message: text,
        );

        log('Message sent successfully: ${sentMessage.id ?? 'no ID'}');

        // Replace optimistic message with real message from server
        // Get the current state (might have changed)
        final currentState = state;
        final updatedMessages = List<MessageModel>.from(currentState.messages);
        
        // Find and replace the optimistic message
        final optimisticIndex = updatedMessages.indexWhere(
          (m) {
            final messageId = m.id;
            return messageId == null && m.content == text && m.chatId == chatId;
          }
        );
        
        if (optimisticIndex != -1) {
          // Replace optimistic message with real one
          updatedMessages[optimisticIndex] = sentMessage;
          log('Replaced optimistic message with real message from server');
        } else {
          // If optimistic message not found, check if real message already exists
          final sentMessageId = sentMessage.id;
          if (sentMessageId != null) {
            final alreadyExists = updatedMessages.any((m) {
              final messageId = m.id;
              return messageId != null && messageId == sentMessageId;
            });
            if (!alreadyExists) {
              // Add the real message if it doesn't exist
              updatedMessages.add(sentMessage);
              log('Added real message to state');
            } else {
              log('Real message already exists in state');
            }
          } else {
            // If sentMessage has no ID, just add it
            updatedMessages.add(sentMessage);
            log('Added message without ID to state');
          }
        }
        
        // Update cache
        _addToCache(chatId, updatedMessages);

        // Only update state if we still have the same chat selected
        if (currentState.selectedChat?.id == chatId) {
          emit(currentState.copyWith(
            status: ChatStatusEnum.success,
            messages: updatedMessages,
          ));
          log('State updated with real message. Message count: ${updatedMessages.length}');
        } else {
          log('Chat changed, not updating messages state');
        }
      } catch (sendError) {
        log('Failed to send message to server: $sendError');
        // Keep the optimistic message on screen, but mark it as failed
        // You could add a visual indicator here if needed
        rethrow; // Re-throw so the UI can show an error
      }

      // Don't refresh from server - let real-time subscription handle new messages
      // The real-time subscription will automatically add the message when it arrives
      // This prevents the message from disappearing
      log('Message send complete. Real-time subscription will handle updates.');
    } catch (e) {
      log('Failed to send message: $e');
      emit(state.copyWith(status: ChatStatusEnum.failure));
    }
  }
}

enum ChatStatusEnum {
  initial,
  loadingChats,
  loadingMessages,
  incomingMessage,
  success,
  failure,
}

class ChatState {
  const ChatState({
    required this.status,
    required this.chats,
    required this.hasMoreChats,
    this.selectedChat,
    this.messages = const [],
  });

  factory ChatState.initial() {
    return const ChatState(
      status: ChatStatusEnum.initial,
      chats: [],
      hasMoreChats: true,
    );
  }

  final ChatStatusEnum status;
  final List<ChatModel> chats;
  final bool hasMoreChats;
  final ChatModel? selectedChat;
  final List<MessageModel> messages;

  ChatState copyWith({
    ChatStatusEnum? status,
    List<ChatModel>? chats,
    bool? hasMoreChats,
    ChatModel? selectedChat,
    List<MessageModel>? messages,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      hasMoreChats: hasMoreChats ?? this.hasMoreChats,
      selectedChat: selectedChat ?? this.selectedChat,
      messages: messages ?? this.messages,
    );
  }
}

