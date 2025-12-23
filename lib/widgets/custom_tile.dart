import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool seen;
  final Widget? leadingWidget;
  final VoidCallback? onTap;

  const CustomTile({
    super.key,
    required this.title,
    this.subtitle,
    this.seen = false,
    this.leadingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingWidget,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: seen ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: seen ? FontWeight.normal : FontWeight.w500,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

