import 'package:flutter/material.dart';

import '../../../services/address_service.dart';

class AddressSearchField extends StatefulWidget {
  final void Function(String)? onSaved;

  const AddressSearchField({super.key, this.onSaved});

  @override
  AddressSearchFieldState createState() => AddressSearchFieldState();
}

class AddressSearchFieldState extends State<AddressSearchField> {
  final AddressService _addressService = AddressService();
  List<String> _addressSuggestions = [];

  void _onTextChanged(String query) async {
    if (query.isNotEmpty) {
      final suggestions = await _addressService.fetchAddressSuggestions(query);
      setState(() {
        _addressSuggestions = suggestions;
      });
    } else {
      setState(() {
        _addressSuggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _addressSuggestions.where((String option) {
          return option.contains(textEditingValue.text);
        });
      },
      onSelected: (String selection) {
        if (widget.onSaved != null) {
          widget.onSaved!(selection);
        }
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: '도로명 주소를 입력하세요',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      },
    );
  }
}