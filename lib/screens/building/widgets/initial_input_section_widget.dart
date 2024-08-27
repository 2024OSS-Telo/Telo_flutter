import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../const/colors.dart';

class InitialInputSectionWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLength;
  final String counterText;
  final String? Function(String?)? validator;
  final String initialValue;
  final bool isEditable;
  final void Function(String?)? onSaved;

  const InitialInputSectionWidget({
    super.key,
    required this.label,
    required this.hintText,
    required this.maxLength,
    required this.counterText,
    required this.validator,
    required this.initialValue,
    required this.isEditable,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15)),
        SizedBox(height: 10),
        TextFormField(
          controller: TextEditingController(text: initialValue),
          readOnly: !isEditable,
          keyboardType: TextInputType.text,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
            counterText: counterText,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: LIGHT_GRAY_COLOR,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: LIGHT_GRAY_COLOR,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            filled: true,
            fillColor: isEditable ? Colors.white : Colors.grey[300],
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: LIGHT_GRAY_COLOR,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          style: TextStyle(
            color: Colors.black,
          ),
          onSaved: onSaved,
        )
      ],
    );
  }
}

class InitialPhoneNumberSection extends StatelessWidget {
  final String? Function(String?)? validator;
  final String initialValue;
  final bool isEditable;
  final FormFieldSetter<String>? onSaved;

  InitialPhoneNumberSection({
    super.key,
    required this.initialValue,
    required this.isEditable,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '전화번호',
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller, // TextEditingController를 사용하여 값 설정
          decoration: InputDecoration(
            hintText: '010-xxxx-xxxx',
            hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            filled: true,
            fillColor: isEditable ? Colors.white : Colors.grey[300], // 배경색 설정
            border: OutlineInputBorder(
              borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          keyboardType: TextInputType.phone,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _InitialPhoneNumberFormatter(),
          ],
          readOnly: !isEditable, // 입력 불가능하지만 값 표시
          onSaved: isEditable
              ? (value) => onSaved?.call(_formatNumber(value ?? ''))
              : null,
        ),
      ],
    );
  }

  String _formatNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= 3) return digitsOnly;
    if (digitsOnly.length <= 7) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    }
    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
  }
}

class _InitialPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formattedText = _formatNumber(digitsOnly);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatNumber(String digitsOnly) {
    if (digitsOnly.length <= 3) return digitsOnly;
    if (digitsOnly.length <= 7) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    }
    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
  }
}

