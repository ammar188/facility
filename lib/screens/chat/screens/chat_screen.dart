import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:facility/l10n/l10n.dart';
import 'package:facility/screens/chat/modules/chat_cubit.dart';
import 'package:facility/screens/chat/modules/chat_model.dart';
import 'package:facility/app/user/user_cubit.dart';
import 'package:facility/screens/chat/modules/chat_builder.dart';
import 'package:facility/widgets/my_bubble_chat_widget.dart';
import 'package:facility/widgets/sender_bubble_chat_widget.dart';
import 'package:facility/constants/app_colors.dart';
import 'package:facility/constants/app_text_styles.dart';
import 'package:facility/extensions/date_time_extensions.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
    
    // Ensure a default chat exists when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ChatCubit>();
      cubit.ensureDefaultChat().catchError((Object error) {
        debugPrint('Failed to ensure default chat: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to initialize chat: $error'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context, ChatModel? selectedChat) {
    final text = _messageController.text.trim();
    debugPrint('_sendMessage called. Text: "$text", Selected chat: ${selectedChat?.id}');
    
    if (text.isEmpty) {
      debugPrint('Text is empty, not sending');
      return;
    }

    // Clear the field first for immediate feedback
    _messageController.clear();
    debugPrint('Sending message...');
    
    // Send message asynchronously - it will create a chat if needed
    context.read<ChatCubit>().sendMessage(text: text).then((_) {
      debugPrint('Message sent successfully');
    }).catchError((Object error) {
      debugPrint('Error sending message: $error');
      // Show error to user if send fails
      if (mounted) {
        final errorMessage = error.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _messageController.text = text;
                _sendMessage(context, selectedChat);
              },
            ),
          ),
        );
        // Restore the text if send failed
        _messageController.text = text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.session?.user.id;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final selectedChat = state.selectedChat;

        final body = Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: ChatBuilder(
                  preWidget: const SizedBox(height: 16),
                  emptyWidget: Center(
                    child: Text(
                      context.l10n.noMessages,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400] 
                            : Colors.grey,
                      ),
                    ),
                  ),
                  loadingWidget: const Center(child: CircularProgressIndicator()),
                  errorWidget: Center(
                    child: Text(
                      context.l10n.somethingWentWrong,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  itemBuilder: (context, message) {
                    final isMe = message.senderId == userId;
                    final time = message.createdAt != null 
                        ? message.createdAt!.toTimeString() 
                        : '';

                    if (isMe) {
                      return MyBubbleChatWidget(
                        chat: message.content,
                        time: time,
                      );
                    } else {
                      return SenderBubbleChatWidget(
                        chat: message.content,
                        time: time,
                      );
                    }
                  },
                  timeBuilder: _defaultTimeBuilder,
                ),
              ),
              // Input bar
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              _sendMessage(context, selectedChat);
                            },
                            decoration: InputDecoration(
                              hintText: context.l10n.messageHint,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsetsDirectional.only(
                            start: 16,
                            bottom: 4,
                          ),
                          width: 42,
                          height: 42,
                          child: Material(
                            color: _hasText 
                                ? Theme.of(context).colorScheme.primary 
                                : (Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey[700] 
                                    : Colors.grey[300]),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _hasText
                                  ? () {
                                      debugPrint('Send button tapped! Has text: $_hasText, Selected chat: ${selectedChat?.id}');
                                      _sendMessage(context, selectedChat);
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.send_rounded,
                                  color: _hasText 
                                      ? Colors.white 
                                      : (Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.grey[400] 
                                          : Colors.grey[600]),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.warning,
                      style: AppTextStyles.labelSmallNormalLight(context),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).viewInsets.bottom,
                color: Colors.transparent,
              ),
            ],
          );

        if (widget.showAppBar) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: !kIsWeb,
              centerTitle: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(selectedChat?.otherUserName ?? ''),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : AppColors.primarySoft,
                  ),
              ),
            ),
            body: body,
          );
        }

        return body;
      },
    );
  }

  Widget _defaultTimeBuilder(BuildContext context, DateTime dateTime) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDate(dateTime),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return 'Today';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return intl.DateFormat('d MMM yyyy').format(dateTime);
    }
  }
}

