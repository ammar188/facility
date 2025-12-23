import 'dart:async';
import 'dart:developer';
import 'package:facility/screens/chat/modules/chat_message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ChatService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  // Get all messages from Supabase, optionally filtered by chat_id
  Future<List<MessageModel>> getMessages({int? chatId}) async {
    try {
      log('ChatService: Fetching messages, chatId: $chatId', name: 'ChatService');
      
      var query = _supabase.from('ConversationMessage').select();
      
      // Filter by chat_id if provided (chat_id is INTEGER)
      if (chatId != null) {
        log('ChatService: Filtering by chat_id = $chatId', name: 'ChatService');
        query = query.eq('chat_id', chatId);
      }
      
      final response = await query
          .order('created_at', ascending: false) // Get newest first, then reverse
          .limit(100);

      log('ChatService: Raw response type: ${response.runtimeType}', name: 'ChatService');
      log('ChatService: Raw response: $response', name: 'ChatService');

      final messages = (response as List)
          .map((json) {
            try {
              return MessageModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              log('ChatService: Error parsing message: $e, JSON: $json', name: 'ChatService');
              rethrow;
            }
          })
          .toList();
      
      log('ChatService: Parsed ${messages.length} messages', name: 'ChatService');
      
      // Reverse to show oldest first
      return messages.reversed.toList();
    } catch (e) {
      log('ChatService: Error fetching messages: $e', name: 'ChatService');
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Send a message
  Future<void> sendMessage(String content, {int? chatId}) async {
    try {
      final user = _supabase.auth.currentUser;
      log('ChatService: Attempting to send message', name: 'ChatService');
      log('ChatService: User authenticated: ${user != null}', name: 'ChatService');
      
      if (user == null) {
        log('ChatService: User is null - not authenticated', name: 'ChatService');
        throw Exception('User not authenticated. Please log in first.');
      }

      log('ChatService: User ID: ${user.id}', name: 'ChatService');
      log('ChatService: Content: ${content.trim()}', name: 'ChatService');

      // Use provided chatId or default to 1 (you can customize this)
      // chat_id is an INTEGER in your database
      // If chatId is null, we need to handle it - for now use 1 as default
      final messageChatId = chatId ?? 1;
      log('ChatService: Using chat_id: $messageChatId', name: 'ChatService');
      // Prepare the message data matching ConversationMessages table
      final messageData = {
        'chat_id': messageChatId,
        'sender_id': user.id,
        'content': content.trim(),
      };

      log('ChatService: Inserting message data: $messageData', name: 'ChatService');
      
      // Check authentication status
      final session = _supabase.auth.currentSession;
      log('ChatService: Current session: ${session != null}', name: 'ChatService');
      log('ChatService: User role: ${session?.user.role}', name: 'ChatService');
      log('ChatService: Access token exists: ${session?.accessToken != null}', name: 'ChatService');

      // Insert the message
      final response = await _supabase
          .from('ConversationMessage')
          .insert(messageData)
          .select();

      log('ChatService: Insert response: $response', name: 'ChatService');

      // Check if insert was successful
      if (response.isEmpty) {
        log('ChatService: Response is empty - message not saved', name: 'ChatService');
        throw Exception('Message was not saved. Please check database permissions.');
      }
      
      log('ChatService: Message sent successfully', name: 'ChatService');
    } on PostgrestException catch (e) {
      // Handle Supabase Postgres errors specifically
      log('ChatService: PostgrestException caught', name: 'ChatService');
      log('ChatService: Error code: ${e.code}', name: 'ChatService');
      log('ChatService: Error message: ${e.message}', name: 'ChatService');
      log('ChatService: Error details: ${e.details}', name: 'ChatService');
      log('ChatService: Error hint: ${e.hint}', name: 'ChatService');
      
      String errorMessage = 'Failed to send message';
      
      if (e.code == 'PGRST116' || 
          (e.message.contains('relation') && e.message.contains('does not exist')) ||
          e.message.contains('ChatMessage') ||
          e.message.contains('chat_messages')) {
        errorMessage = 'Chat table "ChatMessage" not found or column names don\'t match. Please check your table structure.';
      } else if (e.code == '42501' || 
                 e.message.contains('permission denied') || 
                 e.message.contains('policy') ||
                 e.message.contains('new row violates row-level security') ||
                 e.message.contains('row-level security')) {
        errorMessage = 'Permission denied (Code: ${e.code}). Details: ${e.message}. Hint: ${e.hint ?? 'No hint'}. Please check: 1) RLS is enabled, 2) INSERT policy exists for authenticated role, 3) You are logged in.';
      } else if (e.message.contains('null value') || 
                 e.message.contains('violates not-null') ||
                 e.message.contains('column') && e.message.contains('violates')) {
        errorMessage = 'Database schema error: ${e.message}';
      } else {
        errorMessage = 'Database error (${e.code ?? 'unknown'}): ${e.message}. Details: ${e.details ?? 'No details'}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      // Handle other errors
      final errorStr = e.toString();
      String errorMessage = 'Failed to send message';
      
      if (errorStr.contains('relation') && errorStr.contains('does not exist')) {
        errorMessage = 'Chat table "ChatMessage" not found. Please check the table name in Supabase.';
      } else if (errorStr.contains('permission denied') || 
                 errorStr.contains('policy') ||
                 errorStr.contains('row-level security')) {
        errorMessage = 'Permission denied. Check RLS policies in Supabase Dashboard → Authentication → Policies';
      } else if (errorStr.contains('not authenticated')) {
        errorMessage = 'You are not logged in. Please log in first.';
      } else {
        errorMessage = 'Error: ${errorStr}';
      }
      
      throw Exception(errorMessage);
    }
  }

  // Subscribe to real-time message updates
  Stream<List<MessageModel>> subscribeToMessages({int? chatId}) {
    final controller = StreamController<List<MessageModel>>.broadcast();

    // Get initial messages
    getMessages(chatId: chatId).then((messages) {
      if (!controller.isClosed) {
        controller.add(messages);
      }
    }).catchError((Object error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });

    // Set up realtime subscription
    _channel = _supabase.channel('ConversationMessage_${chatId ?? 'all'}');
    
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ConversationMessage',
          callback: (payload) async {
            log('ChatService: Realtime event received: ${payload.eventType}', name: 'ChatService');
            
            // Fetch updated messages when a change occurs
            // getMessages will filter by chatId if provided
            if (!controller.isClosed) {
              try {
                final messages = await getMessages(chatId: chatId);
                log('ChatService: Refreshed messages count: ${messages.length}', name: 'ChatService');
                controller.add(messages);
              } catch (e) {
                log('ChatService: Error refreshing messages: $e', name: 'ChatService');
                if (!controller.isClosed) {
                  controller.addError(e);
                }
              }
            }
          },
        )
        .subscribe((RealtimeSubscribeStatus status, [Object? error]) {
          log('ChatService: Realtime subscription status: $status', name: 'ChatService');
          if (error != null) {
            log('ChatService: Realtime subscription error: $error', name: 'ChatService');
          }
        });

    return controller.stream;
  }

  // Clean up resources
  void dispose() {
    _channel?.unsubscribe();
  }
}

