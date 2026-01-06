import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle labelSmallNormalLight(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
      fontWeight: FontWeight.normal,
    );
  }
  
  // Styles for product tags
  static const TextStyle tagStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFFF75555),
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle tagSelectedStyle = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );
}

