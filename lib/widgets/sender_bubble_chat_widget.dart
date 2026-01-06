import 'package:flutter/material.dart';

class SenderBubbleChatWidget extends StatelessWidget {
  final String chat;
  final String time;

  const SenderBubbleChatWidget({
    super.key,
    required this.chat,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[700] 
              : Colors.grey[300],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chat,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87, 
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400] 
                    : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

