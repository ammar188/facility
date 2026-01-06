import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.hintText,
    required this.flagAssetPath,
    this.controller,
    this.hasError = false,
    this.onChanged,
  });

  final String hintText;
  final String flagAssetPath;
  final TextEditingController? controller;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError 
                  ? Colors.red 
                  : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB)),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                child: Image.asset(
                  flagAssetPath,
                  height: 20,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+92',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey[400] : const Color(0xFF70737D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 20,
                color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : const Color(0xFF70737D),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
