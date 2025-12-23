import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageModel {
  MessageModel({
    required this.chatId,
    required this.content,
    this.id,
    this.senderId,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int?,
      senderId: json['sender_id'] as String,
      chatId: json['chat_id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory MessageModel.fromChat(int chatId, String message) {
    return MessageModel(
      chatId: chatId,
      content: message,
      createdAt: DateTime.now(),
    );
  }

  final int? id;
  final String? senderId;
  final int chatId;
  final String content;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender_id': senderId,
      'chat_id': chatId,
    };
  }

  static Future<List<MessageModel>> fetchMessages(
    int chatId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final jsonList = await Supabase.instance.client
          .from('ConversationMessage')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      return jsonList.map(MessageModel.fromJson).toList();
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  static Future<MessageModel> sendMessage({
    required int chatId,
    required String message,
  }) async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;

    if (currentUser == null) {
      throw Exception('User not authenticated. Cannot send message.');
    }

    try {
      final messageData = {
        'chat_id': chatId,
        'sender_id': currentUser.id,
        'content': message.trim(),
        // Add created_at if the table requires it
        'created_at': DateTime.now().toIso8601String(),
      };

      print('MessageModel: Sending message with data: $messageData');

      final response = await client
          .from('ConversationMessage')
          .insert(messageData)
          .select()
          .single();

      print('MessageModel: Message sent successfully: $response');
      return MessageModel.fromJson(response);
    } catch (e) {
      print('MessageModel: Error sending message: $e');
      final errorStr = e.toString();
      
      // Provide more helpful error messages
      if (errorStr.contains('null value') || errorStr.contains('violates not-null')) {
        throw Exception('Missing required fields. Please check that all required columns are provided.');
      } else if (errorStr.contains('foreign key') || errorStr.contains('violates foreign key')) {
        throw Exception('Invalid chat_id. The conversation does not exist.');
      } else if (errorStr.contains('400') || errorStr.contains('Bad Request')) {
        throw Exception('Bad Request: Invalid data format. Please check the message data.');
      }
      throw Exception('Failed to send message: $e');
    }
  }

  static Stream<MessageModel> streamMessages(List<int> chatIds) {
    final client = Supabase.instance.client;
    final controller = StreamController<MessageModel>();

    final subscription = client
        .channel('public:ConversationMessage')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'ConversationMessage',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.inFilter,
            column: 'chat_id',
            value: chatIds,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            try {
              final message = MessageModel.fromJson(newRecord);
              controller.add(message);
            } catch (e) {
              controller.addError('Error parsing message: $e');
            }
          },
        )
        .subscribe();

    controller.onCancel = () async {
      await subscription.unsubscribe();
      await controller.close();
    };

    return controller.stream;
  }
}