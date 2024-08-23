import 'package:flutter/material.dart';

import '../../../const/colors.dart';

class InitialInputSectionWidget extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool isEditable;
  final ValueChanged<String?>? onSaved;
  final String hintText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String counterText;

  const InitialInputSectionWidget({
    super.key,
    required this.label,
    required this.initialValue,
    required this.isEditable,
    this.onSaved,
    required this.hintText,
    this.maxLength,
    this.keyboardType,
    this.validator,
    required this.counterText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15)),
        SizedBox(height: 10),
        TextFormField(
          initialValue: initialValue,
          enabled: isEditable,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
            counterText: counterText,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            filled: true,
            fillColor: isEditable ? Colors.white : LIGHT_GRAY_COLOR,
            border: OutlineInputBorder(),
          ),
          onSaved: isEditable ? onSaved : null,
        ),
      ],
    );
  }
}
