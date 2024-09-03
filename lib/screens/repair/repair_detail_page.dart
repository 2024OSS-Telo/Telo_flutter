import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';

import '../../models/repair_request_model.dart';
import '../../widgets/repair_request_widget.dart';

class RepairDetailPage extends StatelessWidget {
  const RepairDetailPage({super.key, required this.repairRequest});

  final RepairRequest repairRequest;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text("수리 요청 내용"),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context); // 뒤로가기
                  },
                )),
            body: SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width:double.infinity,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: repairRequest.imageURL.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child:
                          Image.network(
                            repairRequest.imageURL[index],
                            width: 200,
                            fit: BoxFit.cover
                          ),
                        );
                      }),
                ),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              repairRequest.requestTitle,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              repairRequest.createdDate
                                  .toString()
                                  .substring(0, 10),
                              style: TextStyle(fontSize: 13, color: GRAY_COLOR),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          repairRequest.requestContent,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(color: LIGHT_GRAY_COLOR, thickness: 0.5),
                        SizedBox(
                          height: 10,
                        ),
                        Row(children: [
                          Text(
                            "예상 청구 금액",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("${repairRequest.estimatedValue.toString()}원",
                              style: TextStyle(
                                fontSize: 15,
                              ))
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Row(children: [
                          Text(
                            "실제 청구 금액",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("${repairRequest.actualValue.toString()}원",
                              style: TextStyle(
                                fontSize: 15,
                              ))
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(color: LIGHT_GRAY_COLOR, thickness: 0.5),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "영수증 사진",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: repairRequest.receiptImageURL.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child:
                                Image.network(
                                  repairRequest.receiptImageURL[index],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(repairRequest.claimContent),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(color: LIGHT_GRAY_COLOR, thickness: 0.5),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "진행 상황",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        PrograssBar(
                          repairState: repairRequest.repairState,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(color: LIGHT_GRAY_COLOR, thickness: 0.5),
                        SizedBox(
                          height: 10,
                        ),
                        repairRequest.repairState == RepairState.REFUSAL
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "거절 사유",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    repairRequest.refusalReason,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox()
                      ],
                    ))
              ],
            ))));
  }
}
