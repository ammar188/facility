import 'package:flutter/material.dart';

/// Lightweight wrapper to keep the API used by the screens.
class ErrorBoundary extends StatelessWidget {
  const ErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

