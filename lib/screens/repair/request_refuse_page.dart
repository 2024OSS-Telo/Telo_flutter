import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:telo/const/colors.dart';

import '../../const/backend_url.dart';
import '../../models/repair_request_model.dart';

class RequestRefusePage extends StatefulWidget {
  const RequestRefusePage(
      {super.key, required this.repairRequest, required this.roomID, required this.onUpdate});

  final RepairRequest repairRequest;
  final String roomID;
  final VoidCallback onUpdate;

  @override
  State<RequestRefusePage> createState() => _RequestRefusePageState();
}

class _RequestRefusePageState extends State<RequestRefusePage> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  String _descriptionValue = "";

  Future<bool> _submitRequest() async {
    final String roomID = widget.roomID;
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    _formKey.currentState!.save();

    final requestPayload = {
      'requestID': widget.repairRequest.requestID,
      'refusalReason': _descriptionValue,
    };
    final response = await _dio.post(
      backendURL + "/api/repair-request/$roomID/request-refuse",
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text("요청 거절하기"),
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
                      _repairRequestCard(),
                      SizedBox(height: 20),
                      Text("거절 사유", style: TextStyle(fontSize: 15)),
                      SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "필수 입력값입니다.";
                          }
                        },
                        onSaved: (value) {
                          setState(() {
                            _descriptionValue = value!;
                          });
                        },
                        maxLength: 200,
                        maxLines: 6,
                        decoration: const InputDecoration(
                            hintText: "거절 사유를 자세히 적어 주세요.",
                            hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: LIGHT_GRAY_COLOR,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(13)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: LIGHT_GRAY_COLOR,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(13)),
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
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget _repairRequestCard() {
    return Container(
        width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: LIGHT_GRAY_COLOR),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("사진",
              style: TextStyle(fontSize: 15)),
          SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // 가로 스크롤
              itemCount: widget.repairRequest.imageURL.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child:
                  //TODO: 테스트 이미지 삭제
                  Image.asset(
                    'assets/image/buildingIMGtest.png',
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                  ),
                  // Image.network(
                  //   widget.repairRequest.imageURL[index],
                  //   width: 70,
                  //   height: 70,
                  //   fit: BoxFit.cover,
                  // ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Text(
            "제목: ${widget.repairRequest.requestTitle}",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "상세 설명: ${widget.repairRequest.requestContent}",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "예상 금액: ${widget.repairRequest.estimatedValue.toString()}원",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
