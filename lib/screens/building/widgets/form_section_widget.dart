import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telo/screens/building/widgets/resident_list_form_widget.dart';

import '../../../const/colors.dart';

class TextFieldSection extends StatelessWidget {
  final String label;
  final String hintText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  final String counterText;

  const TextFieldSection({
    super.key,
    required this.label,
    required this.hintText,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.onSaved, required this.counterText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15)),
        SizedBox(height: 10),
        TextFormField(
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          onSaved: onSaved,
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
          ),
        ),
      ],
    );
  }
}

class PhoneNumberSection extends StatelessWidget {
  final FormFieldSetter<String>? onSaved;

  PhoneNumberSection({super.key, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          '전화번호',
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(height: 10),
        TextFormField(
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
          ),
          keyboardType: TextInputType.phone,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _PhoneNumberFormatter(),
          ],
          onSaved: (value) => onSaved?.call(_formatNumber(value ?? '')),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  String _formatNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= 3) return digitsOnly;
    if (digitsOnly.length <= 7) return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formattedText = _formatNumber(digitsOnly);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatNumber(String digitsOnly) {
    if (digitsOnly.length <= 3) return digitsOnly;
    if (digitsOnly.length <= 7) return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
  }
}

class RentTypeSelector extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final FormFieldSetter<String>? onSaved;

  RentTypeSelector({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.onSaved,
  });

  @override
  RentTypeSelectorState createState() => RentTypeSelectorState();
}

class RentTypeSelectorState extends State<RentTypeSelector> {
  late String selectedRentType;

  @override
  void initState() {
    super.initState();
    selectedRentType = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text("임대 유형", style: TextStyle(fontSize: 15)),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedRentType,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          items: [
            DropdownMenuItem(
                value: '월세',
                child: Text('월세',
                    style: TextStyle(fontSize: 15, color: GRAY_COLOR))),
            DropdownMenuItem(
                value: '전세',
                child: Text('전세',
                    style: TextStyle(fontSize: 15, color: GRAY_COLOR))),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedRentType = value;
                widget.onChanged(value);
              });
            }
          },
          onSaved: (value) {
            if (widget.onSaved != null) {
              widget.onSaved!(value);
            }
          },
        ),
      ],
    );
  }
}

class RentDetails extends StatelessWidget {
  final String rentType;
  final TextEditingController rentAmountController;
  final TextEditingController paymentDateController;
  final FormFieldSetter<String>? onSavedRentAmount;
  final FormFieldSetter<String>? onSavedPaymentDate;

  RentDetails({
    super.key,
    required this.rentType,
    required this.rentAmountController,
    required this.paymentDateController,
    this.onSavedRentAmount,
    this.onSavedPaymentDate,
  });

  @override
  Widget build(BuildContext context) {
    bool isMonthlyRent = rentType == '월세';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMonthlyRent) ...[
          SizedBox(height: 10),
          Text("월세 금액", style: TextStyle(fontSize: 15)),
          SizedBox(height: 10),
          TextFormField(
            controller: rentAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "n.n (만원)",
              hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onSaved: (value) {
              if (onSavedRentAmount != null) {
                onSavedRentAmount!(value ?? '');
              }
            },
          ),
          SizedBox(height: 30),
          TextFieldSection(
            label: "월세 납부일",
            hintText: "05 (일 생략)",
            maxLength: 2,
            counterText: "",
            validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
            onSaved: onSavedPaymentDate,
          ),
          SizedBox(height: 30),
        ],
      ],
    );
  }
}

class PhotoSection extends StatefulWidget {
  final List<XFile> pickedImages;
  final ImagePicker picker;
  final Function(List<XFile>) onImagesChanged;
  final String title;

  const PhotoSection({
    super.key,
    required this.pickedImages,
    required this.picker,
    required this.onImagesChanged,
    required this.title,
  });

  @override
  PhotoSectionState createState() => PhotoSectionState();
}

class PhotoSectionState extends State<PhotoSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: TextStyle(fontSize: 15)),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widget.pickedImages.map(
                (image) => Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.file(
                          File(image.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          icon: Icon(Icons.cancel),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              widget.pickedImages
                                  .removeWhere((img) => img.path == image.path);
                              widget.onImagesChanged(widget.pickedImages);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (widget.pickedImages.length < 5) _buildAddPhotoButton(),
            ],
          ),
        ),
      ],
    );
  }

  ElevatedButton _buildAddPhotoButton() {
    return ElevatedButton(
      onPressed: () async {
        final List<XFile>? images = await widget.picker.pickMultiImage(
          limit: 5,
          maxHeight: 500,
          maxWidth: 500,
        );
        if (images != null) {
          setState(() {
            List<XFile> newImages = images
                .where((image) => !widget.pickedImages
                    .any((pickedImage) => pickedImage.path == image.path))
                .toList();
            if (widget.pickedImages.length + newImages.length <= 5) {
              widget.pickedImages.addAll(newImages);
              widget.onImagesChanged(widget.pickedImages);
            } else {
              Fluttertoast.showToast(msg: "사진은 최대 5장까지 등록 가능합니다.");
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: LIGHT_GRAY_COLOR,
        fixedSize: Size(80, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Icon(Icons.image, color: GRAY_COLOR),
    );
  }
}