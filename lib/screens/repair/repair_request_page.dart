import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RepairRequestPage extends StatefulWidget {
  const RepairRequestPage({super.key});

  @override
  State<RepairRequestPage> createState() => _RepairRequestPageState();
}

class _RepairRequestPageState extends State<RepairRequestPage> {
  final _formKey = GlobalKey<FormState>();

  String _titleValue = "";
  String _descriptionValue = "";
  int _estimateValue = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text("수리 요청하기"),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context); // 뒤로가기
                  },
                )),
            body: Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("사진", style: TextStyle(fontSize: 15),),
                        SizedBox(height: 10),
                        IconButton(onPressed: () async {
                          var picker = ImagePicker();
                          var image = await picker.pickImage(source: ImageSource.gallery);
                        }, icon: Icon(Icons.camera)),
                        SizedBox(height: 10),
                        Text("제목", style: TextStyle(fontSize: 15),),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "필수 입력값입니다.";
                            }
                          },
                          onSaved: (value) {
                            setState(() {
                              _titleValue = value!;
                            });
                          },
                          maxLength: 15,
                          decoration: const InputDecoration(
                              hintText: "제목",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xffD9D9D9),),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              )
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("설명", style: TextStyle(fontSize: 15)),
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
                              hintText: "어떤 문제가 있는지 자세히 설명해 주세요.",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xffD9D9D9),),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              )),
                        ),
                        SizedBox(height: 10),
                        Text("예상 청구 금액 (선택 사항)", style: TextStyle(fontSize: 15)),
                        SizedBox(height: 10),
                        TextFormField(
                          onSaved: (value) {
                            setState(() {
                              if (value != null && value.isNotEmpty) {
                                _estimateValue = int.parse(value);
                              } else {
                                _estimateValue = 0;
                              }
                            });
                          },
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              hintText: "₩",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xffD9D9D9),),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              )),
                        )
                      ])),
            )));
  }
}
