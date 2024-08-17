import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/building/widgets/FormSection.dart';

import '../../const/backend_url.dart';
import '../../services/member_service.dart';

class ResidentResisterPage extends StatefulWidget {
  const ResidentResisterPage({super.key});

  @override
  State<ResidentResisterPage> createState() => _ResidentResisterPage();
}

class _ResidentResisterPage extends State<ResidentResisterPage> {
  final MemberService _memberService = MemberService();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  String _residentNameValue = "";
  String _phoneNumberValue = "";
  String _apartmentNumber = "";
  int _rentType = 0;
  String _rentPaymentDate = "";
  String _buildingID = "550e8400-e29b-41d4-a716-446655440000";
  List<XFile> _pickedImages = [];

  Future<bool> _submitRequest() async {
    if (_pickedImages.isEmpty) {
      Fluttertoast.showToast(msg: "사진을 한 장 이상 등록해야 합니다.");
      return false;
    }
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    _formKey.currentState!.save();

    List<String> imageURLs = [];
    for (XFile image in _pickedImages) {
      final imageURL = await uploadImage(image);
      imageURLs.add(imageURL);
    }

    final requestPayload = {
      'residentName': _residentNameValue,
      'phoneNumber': _phoneNumberValue,
      'apartmentNumber': _apartmentNumber,
      'rentType': _rentType,
      'rentPaymentDate': _rentPaymentDate,
      'buildingID': _buildingID,
      'imageURL': imageURLs,
    };

    final response = await _dio.post(
      backendURL + "/resident-resister",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
      data: jsonEncode(requestPayload),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('요청 전송에 실패했습니다.: ${response.statusMessage}');
      print(response.statusCode);
      return false;
    }
    return true;
  }

  Future<String> uploadImage(XFile image) async {
    String fileName = image.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final response = await _dio.post(
      backendURL + "/upload-image",
      data: formData,
    );

    if (response.statusCode == 200) {
      return response.data['imageURL'];
    } else {
      throw Exception('이미지 업로드에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PhotoSection(
                    pickedImages: _pickedImages,
                    picker: _picker,
                    onImagesChanged: (images) {
                      setState(() {
                        _pickedImages = images;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFieldSection(
                    label: "세대주 명",
                    hintText: "세대주 명",
                    maxLength: 15,
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _residentNameValue = value!,
                  ),
                  SizedBox(height: 20),
                  TextFieldSection(
                    label: "전화 번호",
                    hintText: "전화 번호",
                    maxLength: 30,
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _phoneNumberValue = value!,
                  ),
                  SizedBox(height: 20),
                  TextFieldSection(
                    label: "호 수",
                    hintText: "호 수",
                    maxLength: 30,
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _apartmentNumber = value!,
                  ),
                  SizedBox(height: 20),
                  TextFieldSection(
                    label: "월세 전세",
                    hintText: "월세 전세",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "이거는 나중에 목록형으로";
                      }
                      final intValue = int.tryParse(value);
                      return intValue == null ? "유효한 숫자를 입력해 주세요." : null;
                    },
                    onSaved: (value) => _rentType = int.parse(value!),
                  ),
                  SizedBox(height: 20),
                  TextFieldSection(
                    label: "월세 납부일",
                    hintText: "YYMMDD 예시)251102",
                    maxLength: 30,
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _apartmentNumber = value!,
                  ),
                  SizedBox(height: 20),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text("이것도 빌딩이름 가져와야함"),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        style: TextButton.styleFrom(
          fixedSize: Size(350, 20),
          backgroundColor: MAIN_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        onPressed: () async {
          if (await _submitRequest()) {
            Fluttertoast.showToast(msg: "등록되었습니다.");
            Navigator.pop(context);
          }
        },
        child: Text(
          '등록하기',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}