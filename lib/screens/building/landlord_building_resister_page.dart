import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/building/widgets/form_section_widget.dart';
import 'package:telo/screens/building/widgets/initial_input_section_widget.dart';

import '../../const/backend_url.dart';
import '../../services/member_service.dart';

class BuildingResisterPage extends StatefulWidget {
  const BuildingResisterPage({super.key});

  @override
  State<BuildingResisterPage> createState() => _BuildingResisterPage();
}

class _BuildingResisterPage extends State<BuildingResisterPage> {
  MemberService memberService = MemberService();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  String _buildingNameValue = "";
  String _addressValue = "";
  String _landlordRealName = "";
  String _landlordPhoneNumber = "";

  List<XFile> _pickedImages = [];
  int _householdsNumber = 1;
  late String memberID;

  bool _isLandlordNameEditable = true;
  bool _isLandlordPhoneEditable = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      memberID = await memberService.findMemberID();
      await _fetchLandlordDetails();
    } catch (error) {
      print('멤버아이디 에러: $error');
    }
  }

  Future<void> _fetchLandlordDetails() async {
    try {
      final response = await _dio.get( "$backendURL/api/members/$memberID");

      if (response.statusCode == 200) {
        setState(() {
          _landlordRealName = response.data['memberRealName'] ?? "";
          _landlordPhoneNumber = response.data['phoneNumber'] ?? "";
          _isLandlordNameEditable = _landlordRealName.isEmpty;
          _isLandlordPhoneEditable = _landlordPhoneNumber.isEmpty;
        });
      }
    } catch (error) {
      print('임대인 정보 조회 에러: $error');
    }
  }

  Future<bool> _submitRequest() async {
    if (_pickedImages.isEmpty) {
      Fluttertoast.showToast(msg: "사진을 한 장 이상 등록해야 합니다.");
      return false;
    }
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return false;
    }
    _formKey.currentState!.save();

    List<String> imageURLs = [];
    for (XFile image in _pickedImages) {
      final imageURL = await uploadImage(image);
      imageURLs.add(imageURL);
    }

    final requestPayload = {
      'buildingName': _buildingNameValue,
      'buildingAddress': _addressValue,
      'numberOfHouseholds': _householdsNumber,
      'landlordID': memberID,
      'memberRealName': _landlordRealName,
      'phoneNumber': _landlordPhoneNumber,
      'imageURL': imageURLs,
    };

    final response = await _dio.post(
      "$backendURL/api/buildings/landlord/building-resister",
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
                    title: '건물 사진',
                    pickedImages: _pickedImages,
                    picker: _picker,
                    onImagesChanged: (images) {
                      setState(() {
                        _pickedImages = images;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InitialInputSectionWidget(
                    label: "임대인 이름",
                    hintText: "최초 1회 입력",
                    maxLength: 15,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    initialValue: _landlordRealName,
                    isEditable: _isLandlordNameEditable,
                      onSaved: (value) {
                        _landlordRealName = value ?? _landlordRealName;
                      }
                  ),
                  SizedBox(height: 30),
                  InitialInputSectionWidget(
                    label: "임대인 전화번호",
                    hintText: "최초 1회 입력",
                    maxLength: 15,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    initialValue: _landlordPhoneNumber,
                    isEditable: _isLandlordPhoneEditable,
                      onSaved: (value) {
                        _landlordPhoneNumber = value ?? _landlordPhoneNumber;
                      }
                  ),
                  SizedBox(height: 30),
                  TextFieldSection(
                    label: "건물명",
                    hintText: "건물명",
                    maxLength: 15,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _buildingNameValue = value!,
                  ),
                  SizedBox(height: 30),
                  TextFieldSection(
                    label: "도로명 주소",
                    hintText: "도로명 주소",
                    maxLength: 30,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _addressValue = value!,
                  ),
                  SizedBox(height: 30),
                  TextFieldSection(
                    label: "총 세대수",
                    hintText: "총 세대수",
                    maxLength: 5,
                    counterText: "",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "필수 입력값입니다.";
                      }
                      final intValue = int.tryParse(value);
                      return intValue == null ? "유효한 숫자를 입력해 주세요." : null;
                    },
                    onSaved: (value) => _householdsNumber = int.parse(value!),
                  ),
                  SizedBox(height: 30),
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
      title: Text("건물 등록하기"),
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