import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hint;

  const CustomInput({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(hintText: hint, border: OutlineInputBorder()),
    );
  }
}
