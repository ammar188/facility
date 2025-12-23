import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  bool isMobile() {
    final width = MediaQuery.of(this).size.width;
    return width < 600; // Mobile breakpoint
  }
}

