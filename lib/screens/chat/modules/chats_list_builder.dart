import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/screens/chat/modules/chat_cubit.dart';
import 'package:facility/screens/chat/modules/chat_model.dart';

typedef ChatWidgetBuilder = Widget Function(
  BuildContext context,
  ChatModel chat,
  int index,
);
typedef ChatLoadingWidgetBuilder = Widget Function(BuildContext context, int index);

class ChatsListView extends StatelessWidget {
  const ChatsListView({
    super.key,
    this.itemBuilder,
    this.loadingItemBuilder,
    this.loadingItemCount = 5,
  });

  final ChatWidgetBuilder? itemBuilder;
  final ChatLoadingWidgetBuilder? loadingItemBuilder;
  final int loadingItemCount;

  bool _isNearBottom(ScrollMetrics metrics) =>
      metrics.pixels >= (metrics.maxScrollExtent - 200);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final chats = state.chats;
        final status = state.status;

        if (status == ChatStatusEnum.failure) {
          return const Center(
            child: Text('Failed to load chats.'),
          );
        }

        if (chats.isEmpty && status != ChatStatusEnum.loadingChats) {
          return const Center(
            child: Text('No chats to display.'),
          );
        }

        final itemCount = status == ChatStatusEnum.loadingChats
            ? chats.length + loadingItemCount
            : chats.length;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification &&
                _isNearBottom(notification.metrics) &&
                status != ChatStatusEnum.loadingChats) {
              context.read<ChatCubit>().loadMore();
            }
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: itemCount,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= chats.length) {
                // Show loading placeholders
                if (loadingItemBuilder != null) {
                  return loadingItemBuilder!(context, index - chats.length);
                }
                return const _DefaultLoadingItem();
              }

              final chat = chats[index];
              if (itemBuilder != null) {
                return itemBuilder!(context, chat, index);
              }

              // Default chat item UI
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    chat.otherUserName?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(chat.otherUserName ?? 'Unknown'),
                subtitle: Text(
                  chat.lastMessageContent ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (chat.lastMessageCreatedAt != null)
                      Text(
                        _formatDate(chat.lastMessageCreatedAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.seen ? Colors.grey : Colors.blue,
                          fontWeight:
                              chat.seen ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    if (!chat.seen)
                      const Icon(Icons.mark_chat_unread,
                          color: Colors.blue, size: 18),
                  ],
                ),
                onTap: () {
                  context.read<ChatCubit>().selectChat(chat);
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

class _DefaultLoadingItem extends StatelessWidget {
  const _DefaultLoadingItem();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
      ),
      title: Container(
        height: 14,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      subtitle: Container(
        height: 12,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(vertical: 2),
      ),
    );
  }
}

