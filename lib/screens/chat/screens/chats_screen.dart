import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/l10n/l10n.dart';
import 'package:facility/extensions/context_extensions.dart';
import 'package:facility/widgets/custom_tile.dart';
import 'package:facility/widgets/avatar.dart';
import 'package:facility/screens/chat/modules/chat_cubit.dart';
import 'package:facility/screens/chat/modules/chats_list_builder.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile();

    final body = ChatsListView(
      itemBuilder: (context, chat, _) {
        return CustomTile(
          title: chat.otherUserName ?? '',
          subtitle: chat.lastMessageContent ?? '',
          seen: chat.seen,
          leadingWidget: Avatar(name: chat.otherUserName, size: 58),
          onTap: () {
            context.read<ChatCubit>().selectChat(chat);

            if (isMobile) {
              // TODO: Navigate to messages screen
              // Navigator.pushNamed(context, AppRoutes.messages.name);
            }
          },
        );
      },
    );

    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.chatCenter),
          automaticallyImplyLeading: isMobile,
        ),
        body: body,
      );
    }

    return body;
  }
}

