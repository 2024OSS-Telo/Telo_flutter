import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../../const/colors.dart';

class TextFieldSection extends StatelessWidget {
  final String label;
  final String hintText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const TextFieldSection({
    super.key,
    required this.label,
    required this.hintText,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.onSaved,
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

class PhotoSection extends StatefulWidget {
  final List<XFile> pickedImages;
  final ImagePicker picker;
  final Function(List<XFile>) onImagesChanged;

  const PhotoSection({
    super.key,
    required this.pickedImages,
    required this.picker,
    required this.onImagesChanged,
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
        Text("사진", style: TextStyle(fontSize: 15)),
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
                              widget.pickedImages.removeWhere(
                                      (img) => img.path == image.path);
                              widget.onImagesChanged(widget.pickedImages);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (widget.pickedImages.length < 5)
                _buildAddPhotoButton(),
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
            List<XFile> newImages = images.where(
                    (image) => !widget.pickedImages.any((pickedImage) =>
                pickedImage.path == image.path)).toList();
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
