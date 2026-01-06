import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding,
  });

  final String label;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark 
              ? Theme.of(context).colorScheme.primary 
              : const Color(0xFF2D403C),
          foregroundColor: Colors.white,
          padding: padding ?? EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          alignment: Alignment.center,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

