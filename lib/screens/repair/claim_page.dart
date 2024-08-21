import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../const/backend_url.dart';
import '../../const/colors.dart';

class ClaimPage extends StatefulWidget {
  const ClaimPage({super.key, required this.requestID, required this.roomID, required this.onUpdate});

  final String requestID;
  final String roomID;
  final VoidCallback onUpdate;

  @override
  State<ClaimPage> createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  int _actualValue = 0;
  String _descriptionValue = "";
  List<XFile> _pickedImages = [];

  Future<bool> _submitRequest() async {
    final String roomID = widget.roomID;
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
      'requestID': widget.requestID,
      'actualValue': _actualValue,
      'receiptImageURL': imageURLs,
      'claimContent': _descriptionValue,
    };

    final response = await _dio.post(
      backendURL + "/api/repair-request/$roomID/claim",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
      data: jsonEncode(requestPayload),
    );
    if (response.statusCode != 200) {
      print('요청 전송에 실패했습니다.: ${response.statusMessage}');
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
            appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text("청구하기"),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context); // 뒤로가기
                  },
                )),
            body: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(30),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "영수증 사진",
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ..._pickedImages.map((image) => Padding(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Stack(children: [
                                    ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(10.0),
                                      child: Image.file(File(image.path),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover),
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
                                            _pickedImages.removeWhere((img) => img.path == image.path);
                                          });
                                        },
                                      ),
                                    )
                                  ]),
                                )),
                                if (_pickedImages.length < 5)
                                  ElevatedButton(
                                    onPressed: () async {
                                      final List<XFile>? images =
                                      await _picker.pickMultiImage(
                                          limit: 5,
                                          maxHeight: 500,
                                          maxWidth: 500);
                                      if (images != null) {
                                        setState(() {
                                          List<XFile> newImages = images.where((image) => !_pickedImages.any((pickedImage) => pickedImage.path == image.path)).toList();
                                          if (_pickedImages.length +
                                              newImages.length <=
                                              5) {
                                            _pickedImages.addAll(newImages);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "사진은 최대 5장까지 등록 가능합니다.");
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
                                    child: Icon(
                                      Icons.image,
                                      color: GRAY_COLOR,
                                    ),
                                  )
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("청구 금액",
                              style: TextStyle(fontSize: 15)),
                          SizedBox(height: 10),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "필수 입력값입니다.";
                              }
                            },
                            onSaved: (value) {
                              setState(() {
                                if (value != null && value.isNotEmpty) {
                                  _actualValue = int.parse(value);
                                } else {
                                  _actualValue = 0;
                                }
                              });
                            },
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: "₩",
                                hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: LIGHT_GRAY_COLOR,
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: LIGHT_GRAY_COLOR,
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                )),
                          ),
                          Text("설명 (선택 사항)", style: TextStyle(fontSize: 15)),
                          SizedBox(height: 10),
                          TextFormField(
                            onSaved: (value) {
                              setState(() {
                                _descriptionValue = value!;
                              });
                            },
                            maxLength: 200,
                            maxLines: 6,
                            decoration: const InputDecoration(
                                hintText: "수리 과정에서 발생한 문제가 있다면 설명해 주세요.",
                                hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: LIGHT_GRAY_COLOR,
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: LIGHT_GRAY_COLOR,
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                )),
                          ),
                          SizedBox(height: 20),
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
                              onPressed: () async {
                                if (await _submitRequest()) {
                                  Fluttertoast.showToast(msg: "등록되었습니다.");
                                  widget.onUpdate();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                '등록하기',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ])),
              ),
            )));
  }
}
