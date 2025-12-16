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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phone', style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(248, 248, 248, 1.0),
            borderRadius: BorderRadius.circular(8),
            border: hasError
                ? Border.all(color: Colors.red)
                : Border.all(color: Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Image.asset(
                flagAssetPath,
                height: 20,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(width: 8),
              const Text('+92', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hintText,
                    border: InputBorder.none,
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

