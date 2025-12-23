import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? name;
  final double size;

  const Avatar({
    super.key,
    this.name,
    this.size = 40,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      child: Text(
        _getInitials(name),
        style: TextStyle(fontSize: size * 0.4),
      ),
    );
  }
}

