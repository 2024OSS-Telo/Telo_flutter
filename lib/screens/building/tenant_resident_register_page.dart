import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/building/widgets/form_section_widget.dart';
import 'package:telo/screens/building/widgets/initial_input_section_widget.dart';
import 'package:telo/screens/building/widgets/resident_list_form_widget.dart';

import '../../const/backend_url.dart';
import '../../services/image_service.dart';
import '../../services/member_service.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'building_list_page.dart';

class AddressComparePage extends StatefulWidget {
  const AddressComparePage({
    super.key,});


  @override
  State<AddressComparePage> createState() => _AddressComparePageState();
}

class _AddressComparePageState extends State<AddressComparePage> {
  String? _buildingName;
  late String _buildingID = "";
  bool _isLandlordMatching = false;
  List<String> _addressSuggestions = [];

  final Dio _dio = Dio();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landlordNameController = TextEditingController();

  Future<void> fetchBuildingAddresses(String query) async {
    if (query.isEmpty) {
      setState(() {
        _addressSuggestions = [];
      });
      return;
    }

    setState(() {
    });

    try {
      final response = await _dio.get(
        '$backendURL/api/buildings/autocomplete',
        queryParameters: {'address': query},
      );

      if (response.statusCode == 200) {
        setState(() {
          _addressSuggestions = List<String>.from(response.data);
        });
      } else {
        print('응답 오류: ${response.statusCode}');
        setState(() {
          _addressSuggestions = [];
        });
      }
    } catch (e) {
      print('API 호출 오류: $e');
      setState(() {
        _addressSuggestions = [];
      });
    }
  }

  Future<void> fetchBuildingInfo(String buildingAddress) async {
    try {
      final response = await _dio.get(
          '$backendURL/api/buildings/address-compare?buildingAddress=$buildingAddress');
      print('API 호출 성공: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('응답 데이터: ${response.data}');
        Map<String, dynamic> data = response.data;
        setState(() {
          _buildingName = data['buildingName'];
          _isLandlordMatching =
              data['memberRealName'] == _landlordNameController.text;
          _buildingID = data['buildingID'];
          print('member Real Name : ${data['memberRealName']}');
          print('buildingID : ${data['buildingID']}');
          print(
              '_landlordNameController.text : ${_landlordNameController.text}');
        });
      } else {
        print('응답 오류: ${response.statusCode}');
        setState(() {
          _buildingName = null;
          _isLandlordMatching = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        print('DioException 발생: ${e.message}');
        if (e.response != null) {
          print('응답 상태 코드: ${e.response?.statusCode}');
          print('응답 데이터: ${e.response?.data}');
        }
      } else {
        print('API 호출 오류: $e');
      }
      setState(() {
        _buildingName = null;
        _isLandlordMatching = false;
      });
    }
  }

  Future<void> _submit() async {
    await fetchBuildingInfo(_addressController.text);

    if (_isLandlordMatching) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('임대인이 일치합니다!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResidentRegisterPage(
            buildingID: _buildingID,
          ),
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('임대인이 일치하지 않습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('건물 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('도로명 주소', style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            TextField(
              maxLength: 100,
              controller: _addressController,
              onChanged: (value) {
                fetchBuildingAddresses(value);
              },
              decoration: InputDecoration(
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
            ),
            if (_addressSuggestions.isNotEmpty)
              SizedBox(
                height: 150.0,
                child: ListView.builder(
                  itemCount: _addressSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_addressSuggestions[index]),
                      onTap: () {
                        setState(() {
                          _addressController.text = _addressSuggestions[index];
                          _addressSuggestions.clear();
                        });
                        fetchBuildingInfo(_addressController.text);
                      },
                    );
                  },
                ),
              ),
            if (_buildingName != null) ...[
              SizedBox(height: 30),
              Text('건물 이름', style: TextStyle(fontSize: 15)),
              SizedBox(height: 10),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: _buildingName,
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: LIGHT_GRAY_COLOR,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: LIGHT_GRAY_COLOR),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ],
            SizedBox(height: 30),
            Text('임대인 이름', style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            TextField(
              maxLength: 10,
              controller: _landlordNameController,
              decoration: InputDecoration(
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
            ),
            SizedBox(height: 30),
            Align(
                alignment: Alignment.center,
                child: TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: Size(350, 20),
                    backgroundColor: MAIN_COLOR,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text('다음 단계로', style: TextStyle(color: Colors.white)),
                )),
          ],
        ),
      ),
    );
  }
}

class ResidentRegisterPage extends StatefulWidget {
  final String buildingID;

  const ResidentRegisterPage({super.key, required this.buildingID});

  @override
  State<ResidentRegisterPage> createState() => _ResidentRegisterPage();
}

class _ResidentRegisterPage extends State<ResidentRegisterPage> {
  final MemberService memberService = MemberService();
  final ImageService imageService = ImageService();

  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  String _tenantRealName = "";
  String _tenantPhoneNumber = "";
  String _apartmentNumber = "";
  String _rentType = "월세";

  String _monthlyRentAmount = "";
  String _monthlyRentPaymentDate = "";

  String _deposit = "";
  String _contractExpirationDate = "";

  late String memberID;

  bool _isTenantNameEditable = true;
  bool _isTenantPhoneEditable = true;

  List<XFile> _pickedImages = [];

  bool _isLoading = false;

  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      memberID = await memberService.findMemberID();
      final tenantName = await _fetchTenantDetails();

      await _fetchTenantDetails();
    } catch (error) {
      print('멤버아이디 에러: $error');
    }
  }

  Future<void> _fetchTenantDetails() async {
    try {
      final response = await _dio.get("$backendURL/api/members/$memberID");

      if (response.statusCode == 200) {
        setState(() {
          _tenantRealName = response.data['memberRealName'] ?? "";
          _tenantPhoneNumber = response.data['phoneNumber'] ?? "";
          _isTenantNameEditable = _tenantRealName.isEmpty;
          _isTenantPhoneEditable = _tenantPhoneNumber.isEmpty;
        });
      }
    } catch (error) {
      print('임대인 정보 조회 에러: $error');
    }
  }

  Future<bool> _submitRequest() async {
    if (_isLoading) return false;

    setState(() {
      _isLoading = true;
    });

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
      final imageURL = await imageService.uploadImage(image);
      imageURLs.add(imageURL);
    }

    final requestPayload = {
      'residentName': _tenantRealName,
      'phoneNumber': _tenantPhoneNumber,
      'apartmentNumber': _apartmentNumber,
      'rentType': _rentType,
      'monthlyRentAmount': _monthlyRentAmount,
      'monthlyRentPaymentDate': _monthlyRentPaymentDate,
      'deposit': _deposit,
      'contractExpirationDate': _contractExpirationDate,
      'contractImageURL': imageURLs,
    };

    final response = await _dio.post(
      //TODO: url에 buildingID, tenantID 전달
      "$backendURL/api/residents/tenant/resident-register/${widget.buildingID}/$memberID",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  SizedBox(height: 30),
                  InitialInputSectionWidget(
                    label: "임차인 이름",
                    hintText: "최초 1회 입력",
                    maxLength: 10,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    initialValue: _tenantRealName,
                    isEditable: _isTenantNameEditable,
                    onSaved: (value) {
                      _tenantRealName = value ?? _tenantRealName;
                    },
                  ),
                  SizedBox(height: 30),
                  InitialPhoneNumberSection(
                      validator: (value) =>
                          value!.isEmpty ? "필수 입력값입니다." : null,
                      initialValue: _tenantPhoneNumber,
                      isEditable: _isTenantPhoneEditable,
                      onSaved: (value) {
                        _tenantPhoneNumber = value ?? _tenantPhoneNumber;
                      }),
                  SizedBox(height: 30),
                  TextFieldSection(
                    label: "상세주소",
                    hintText: "xxx호",
                    maxLength: 10,
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
                  SizedBox(height: 30),
                  RentDetails(
                    rentType: _rentType,
                    rentAmountController: _rentAmountController,
                    paymentDateController: _paymentDateController,
                    onSavedRentAmount: (value) => _monthlyRentAmount = value!,
                    onSavedPaymentDate: (value) =>
                        _monthlyRentPaymentDate = value!,
                  ),
                  TextFieldSection(
                    label: "보증금",
                    hintText: "n.n억 혹은 n.n만",
                    maxLength: 10,
                    counterText: "",
                    validator: (value) => value!.isEmpty ? "필수 입력값입니다." : null,
                    onSaved: (value) => _deposit = value!,
                  ),
                  SizedBox(height: 30),
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
      );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text('건물 등록'),
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
