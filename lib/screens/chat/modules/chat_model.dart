import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatModel {
  ChatModel({
    required this.id,
    required this.otherUserId,
    required this.createdAt,
    required this.seen,
    this.requestId,
    this.otherUserName,
    this.lastMessageContent,
    this.lastMessageCreatedAt,
    this.user1Id,
    this.user2Id,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final userId = json['user_id'] as String?;
    final vendorId = json['vendor_id'] as String?;
    final isUser = currentUserId != null && userId == currentUserId;

    return ChatModel(
      id: json['id'] as int,
      requestId: json['request_id'] as int?,
      user1Id: userId,
      user2Id: vendorId,
      otherUserId: isUser ? (vendorId ?? '') : (userId ?? ''),
      otherUserName: json['vendor_name'] as String? ?? json['user_name'] as String?,
      lastMessageContent: json['last_message'] as String?,
      lastMessageCreatedAt: json['last_message_created_at'] != null
          ? DateTime.tryParse(json['last_message_created_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      seen: json['seen'] as bool? ?? false,
    );
  }

  factory ChatModel.fromChatView(Map<String, dynamic> json) {
    return ChatModel.fromJson(json);
  }

  final int id;
  final int? requestId;
  final String? user1Id;
  final String? user2Id;
  final String otherUserId;
  final String? otherUserName;
  final String? lastMessageContent;
  final DateTime? lastMessageCreatedAt;
  final DateTime createdAt;
  final bool seen;

  static Future<List<ChatModel>> fetchChats({
    int limit = 10,
    int offset = 0,
  }) async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    try {
      if (currentUser != null) {
        print('ChatModel: Attempting to fetch chats from "Conversation" table');
        print('ChatModel: Fetching conversations for user_id: ${currentUser.id}');
        final jsonList = await client
            .from('Conversation')
            .select()
            .eq('user_id', currentUser.id)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);

        print('ChatModel: Successfully fetched ${jsonList.length} chats');
        return jsonList.map(ChatModel.fromJson).toList();
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      // If table doesn't exist (404) or permission denied, return empty list
      final errorStr = e.toString();
      print('ChatModel: Error fetching chats: $e');
      if (errorStr.contains('404') || 
          errorStr.contains('does not exist') ||
          errorStr.contains('relation') && errorStr.contains('not found') ||
          errorStr.contains('permission denied') ||
          errorStr.contains('42501')) {
        return [];
      }
      throw Exception('Failed to load chats: $e');
    }
  }

  /// Create a new chat/conversation
  /// Creates a conversation between a user and a vendor
  static Future<ChatModel> createChat({String? vendorId}) async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    try {
      // Create a conversation between user and vendor
      // If vendorId is not provided, you might want to handle this differently
      // For now, we'll require a vendorId or use a default
      // Prepare chat data - only include required fields
      // Let the database handle ID (auto-increment) and timestamps (if they have defaults)
      final chatData = <String, dynamic>{
        'user_id': currentUser.id,
        'vendor_id': vendorId ?? currentUser.id, // Default to user's own ID if no vendor specified
      };
      
      // Only add timestamps if they don't have DEFAULT in the database
      // If your table has DEFAULT NOW() for created_at/updated_at, remove these lines
      // chatData['created_at'] = DateTime.now().toIso8601String();
      // chatData['updated_at'] = DateTime.now().toIso8601String();

      print('ChatModel: Attempting to create chat in "Conversation" table');
      print('ChatModel: User ID: ${currentUser.id}');
      print('ChatModel: Vendor ID: ${vendorId ?? currentUser.id}');
      print('ChatModel: Chat data: $chatData');
      
      // Insert and explicitly select the id column to ensure it's returned
      final response = await client
          .from('Conversation')
          .insert(chatData)
          .select('id, user_id, vendor_id, created_at, updated_at')
          .single();

      print('ChatModel: Insert response received');
      print('ChatModel: Response type: ${response.runtimeType}');
      print('ChatModel: Response keys: ${response.keys}');
      print('ChatModel: Full response: $response');
      
      // Check if ID exists in response
      if (!response.containsKey('id') || response['id'] == null) {
        throw Exception('Conversation created but ID was not returned. Response: $response');
      }
      
      final conversationId = response['id'];
      print('ChatModel: Successfully created chat with ID: $conversationId');
      print('ChatModel: User ID from response: ${response['user_id']}');
      print('ChatModel: Vendor ID from response: ${response['vendor_id']}');
      
      final chat = ChatModel.fromJson(response);
      print('ChatModel: Parsed chat model - ID: ${chat.id}, User: ${chat.user1Id}, Vendor: ${chat.user2Id}');
      
      // Verify the conversation exists in database
      try {
        final verifyResponse = await client
            .from('Conversation')
            .select('id, user_id, vendor_id')
            .eq('id', conversationId as Object)
            .single();
        print('ChatModel: Verified conversation exists in DB: $verifyResponse');
      } catch (e) {
        print('ChatModel: WARNING - Could not verify conversation in DB: $e');
      }
      
      return chat;
    } catch (e) {
      final errorStr = e.toString();
      print('ChatModel: Error creating chat: $e');
      print('ChatModel: Error string: $errorStr');
      
      // Provide more helpful error messages
      if (errorStr.contains('404') || 
          errorStr.contains('does not exist') ||
          (errorStr.contains('relation') && errorStr.contains('not found'))) {
        throw Exception('Conversation table not found. Please check the table name in Supabase (should be "Conversation").');
      } else if (errorStr.contains('permission denied') || errorStr.contains('42501')) {
        throw Exception('Permission denied. Please check Row Level Security policies. Make sure you have INSERT policy enabled for authenticated users.');
      } else if (errorStr.contains('null value') || errorStr.contains('violates not-null')) {
        throw Exception('Missing required fields. Please check that user_id and vendor_id are provided.');
      } else if (errorStr.contains('400') || errorStr.contains('Bad Request')) {
        throw Exception('Bad Request: Invalid data format. Please check the conversation data structure.');
      }
      throw Exception('Failed to create chat: $e');
    }
  }

  static Future<void> markSeen(ChatModel chat) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('ConversationMessage')
          .update({'seen': true})
          .eq('chat_id', chat.id)
          .neq('sender_id', currentUserId);
    } catch (e) {
      throw Exception('Failed to mark messages as seen');
    }
  }

  static Stream<ChatModel> streamNewChatsForUser() {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    final controller = StreamController<ChatModel>();

    if (userId == null) {
      return controller.stream;
    }

    Future<void> handlePayload(Map<String, dynamic> newRecord) async {
      try {
        final chatId = newRecord['id'] as int;
        final chatList = await client
            .from('Conversation')
            .select()
            .eq('id', chatId)
            .limit(1);

        if (chatList.isNotEmpty) {
          final chat = ChatModel.fromJson(chatList.first);
          controller.add(chat);
        }
      } catch (e) {
        controller.addError('Error fetching chat from view: $e');
      }
    }

    final subscription = client
        .channel('public:Conversation_user_$userId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'Conversation',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) => handlePayload(payload.newRecord),
    )
        .subscribe();

    controller.onCancel = () async {
      await subscription.unsubscribe();
      await controller.close();
    };

    return controller.stream;
  }

  ChatModel copyWith({
    String? otherUserId,
    String? otherUserName,
    String? lastMessageContent,
    DateTime? lastMessageCreatedAt,
    DateTime? createdAt,
    bool? seen,
    String? user1Id,
    String? user2Id,
  }) {
    return ChatModel(
      id: id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageCreatedAt: lastMessageCreatedAt ?? this.lastMessageCreatedAt,
      createdAt: createdAt ?? this.createdAt,
      seen: seen ?? this.seen,
    );
  }
}