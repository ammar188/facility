import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/screens/chat/modules/chat_cubit.dart';

typedef ChatsBadgeWidgetBuilder = Widget Function(bool allSeen);

class ChatsBadgeBuilder extends StatelessWidget {
  const ChatsBadgeBuilder({
    super.key,
    required this.builder,
  });

  final ChatsBadgeWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) =>
          previous.chats != current.chats || previous.status != current.status,
      builder: (context, state) {
        final chats = state.chats;

        // If there are no chats, we consider "all seen" true.
        final allSeen = chats.isEmpty || chats.every((chat) => chat.seen);

        return builder(allSeen);
      },
    );
  }
}

