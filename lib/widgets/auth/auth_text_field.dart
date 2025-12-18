import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const AuthTextField({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}