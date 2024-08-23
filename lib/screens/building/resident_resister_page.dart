import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/building/widgets/form_section_widget.dart';
import 'package:telo/screens/building/widgets/resident_list_form_widget.dart';

import '../../const/backend_url.dart';
import '../../services/member_service.dart';

class ResidentResisterPage extends StatefulWidget {
  final String buildingID;
  final String buildingName;
  //TODO: 임시 아이디 수정
  final String tenantID = '3';

  const ResidentResisterPage({super.key, required this.buildingID, required this.buildingName,});

  @override
  State<ResidentResisterPage> createState() => _ResidentResisterPage();
}

class _ResidentResisterPage extends State<ResidentResisterPage> {
  final MemberService _memberService = MemberService();
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  String _residentNameValue = "";
  String _phoneNumberValue = "";
  String _apartmentNumber = "";
  String _rentType = "월세";

  String _monthlyRentAmount = "";
  String _monthlyRentPaymentDate = "";

  String _deposit = "";
  String _contractExpirationDate = "";

  String _buildingID = "";
  List<XFile> _pickedImages = [];

  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();

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
      'monthlyRentAmount' : _monthlyRentAmount,
      'monthlyRentPaymentDate': _monthlyRentPaymentDate,

      'deposit' : _deposit,
      'contractExpirationDate': _contractExpirationDate,

      'imageURL': imageURLs,
    };

    final response = await _dio.post(
      //TODO: url에 buildingID, tenantID 전달
      "$backendURL/api/residents/resident-resister/${widget.buildingID}/${widget.tenantID}",
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
      "$backendURL/upload-image",
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
                    title: '계약서 사진',
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
                    maxLength: 10,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _residentNameValue = value!,
                  ),
                  SizedBox(height: 20),

                  PhoneNumberSection(
                    onSaved: (value) => _phoneNumberValue = value!,
                  ),
                  SizedBox(height: 20),
                  TextFieldSection(
                    label: "상세 주소",
                    hintText: "123동 45호",
                    maxLength: 30,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _apartmentNumber = value!,
                  ),
                  SizedBox(height: 20),
                  RentTypeSelector(
                    initialValue: _rentType,
                    onChanged: (value) {
                      setState(() {
                        _rentType = value;
                      });
                    },
                    onSaved: (value) {
                      _rentType = value ?? '월세';
                    },
                  ),
                  SizedBox(height: 20),
                  RentDetails(
                    rentType: _rentType,
                    rentAmountController: _rentAmountController,
                    paymentDateController: _paymentDateController,
                    onSavedRentAmount: (value) => _monthlyRentAmount = value!,
                    onSavedPaymentDate: (value) => _monthlyRentPaymentDate = value!,
                  ),
                  SizedBox(height: 20),
                  TextFieldSection(
                    label: "보증금",
                    hintText: "n.n억 혹은 n.n만",
                    maxLength: 10,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _deposit = value!,
                  ),
                  SizedBox(height: 20),
                  DateNumberSection(
                    label: "계약 만료일",
                    onSaved: (value) => _contractExpirationDate = value!,
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
      title: Text(widget.buildingName),
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
            Navigator.pop(context, true);
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