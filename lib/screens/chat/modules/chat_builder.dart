import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/screens/chat/modules/chat_cubit.dart';
import 'package:facility/screens/chat/modules/chat_message_model.dart';

typedef MessageWidgetBuilder = Widget Function(BuildContext, MessageModel);
typedef TimeWidgetBuilder = Widget Function(BuildContext, DateTime dateTime);

class ChatBuilder extends StatefulWidget {
  const ChatBuilder({
    required this.itemBuilder,
    this.timeBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.postWidget,
    this.preWidget,
    super.key,
  });

  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? loadingWidget;

  final Widget? preWidget;
  final Widget? postWidget;

  final MessageWidgetBuilder itemBuilder;
  final TimeWidgetBuilder? timeBuilder;

  @override
  State<ChatBuilder> createState() => _ChatBuilderState();
}

class _ChatBuilderState extends State<ChatBuilder> {
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;

  @override
  void initState() {
    context.read<ChatCubit>().markCurrentChatSeen();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        // Rebuild when messages change or status changes
        return previous.messages.length != current.messages.length ||
            previous.status != current.status ||
            previous.selectedChat?.id != current.selectedChat?.id;
      },
      builder: (context, state) {
        if (state.status == ChatStatusEnum.loadingMessages &&
            state.messages.isEmpty) {
          return widget.loadingWidget ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }

        if (state.status == ChatStatusEnum.failure) {
          return widget.errorWidget ??
              const Center(child: Text('Something went wrong'));
        }

        final messages = state.messages;

        if (messages.isEmpty) {
          return widget.emptyWidget ?? const Center(child: Text('No messages'));
        }

        // Auto-scroll to bottom when new message is added
        if (messages.length > _previousMessageCount && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0.0, // reverse: true means 0 is bottom
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
        _previousMessageCount = messages.length;

        final totalItems = <dynamic>[];
        DateTime? lastDate;

        for (final message in messages) {
          final msgDate = message.createdAt;
          // Allow messages without date (optimistic messages) - use current date
          final msgDay = msgDate != null 
              ? DateTime(msgDate.year, msgDate.month, msgDate.day)
              : DateTime.now();

          if (lastDate == null || lastDate != msgDay) {
            if (widget.timeBuilder != null) {
              totalItems.add(widget.timeBuilder!(context, msgDay));
            }
            lastDate = msgDay;
          }

          totalItems.add(message);
        }

        final totalCount = totalItems.length +
            (widget.preWidget != null ? 1 : 0) +
            (widget.postWidget != null ? 1 : 0);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels ==
                notification.metrics.maxScrollExtent) {
              context.read<ChatCubit>().loadOlderMessages();
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: totalCount,
            itemBuilder: (context, index) {
              if (widget.postWidget != null && index == 0) {
                return widget.postWidget!;
              }

              if (widget.preWidget != null && index == totalCount - 1) {
                return widget.preWidget!;
              }

              final hasPost = widget.postWidget != null ? 1 : 0;
              final itemIndex = index - hasPost;

              final reversedItems = totalItems.reversed.toList();
              final item = reversedItems[itemIndex];

              if (item is Widget) {
                return item;
              } else if (item is MessageModel) {
                return widget.itemBuilder(context, item);
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

