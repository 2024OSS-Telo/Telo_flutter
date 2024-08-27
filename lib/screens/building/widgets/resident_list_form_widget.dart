import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telo/const/colors.dart';

class DateNumberSection extends StatelessWidget {
  final FormFieldSetter<String>? onSaved;
  final String label;

  DateNumberSection({super.key, this.onSaved, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            hintText: '2024-12-25',
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
          ),
          keyboardType: TextInputType.datetime,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _DateNumberFormatter(),
          ],
          onSaved: (value) => onSaved?.call(_formatNumber(value ?? '')),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  String _formatNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= 4) return digitsOnly;
    if (digitsOnly.length <= 6) return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4)}';
    return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 6)}-${digitsOnly.substring(6)}';
  }
}

class _DateNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    String formattedText;
    if (digitsOnly.length <= 4) {
      formattedText = digitsOnly;
    } else if (digitsOnly.length <= 6) {
      formattedText = '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4)}';
    } else {
      formattedText = '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 6)}-${digitsOnly.substring(6)}';
    }

    final newSelectionIndex = formattedText.length;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}

class MonthlyDateSection extends StatelessWidget {
  final FormFieldSetter<String>? onSaved;
  final String label;

  MonthlyDateSection({super.key, this.onSaved, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            hintText: '25 (일 생략)',
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
          ),
          keyboardType: TextInputType.datetime,
          maxLength: 2,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _MonthlyDateFormatter(),
          ],
          onSaved: (value) => onSaved?.call(_formatNumber(value ?? '')),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  String _formatNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= 2) return digitsOnly;
    return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2)}';
  }
}

class _MonthlyDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    String formattedText;
    if (digitsOnly.length <= 2) {
      formattedText = digitsOnly;
    } else {
      formattedText = '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2)}';
    }

    final newSelectionIndex = formattedText.length;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}