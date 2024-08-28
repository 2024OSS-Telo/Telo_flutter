import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../const/backend_url.dart';
import '../../const/colors.dart';
import '../../models/building_with_residents_model.dart';
import '../../models/member_model.dart';
import '../../services/member_service.dart';

class ResidentDetailPage extends StatefulWidget {
  final BuildingWithResidents buildingWithResidents;
  final String landlordID;

  const ResidentDetailPage({super.key, required this.buildingWithResidents, required this.landlordID});

  @override
  State<ResidentDetailPage> createState() => _ResidentDetailPageState();
}

class _ResidentDetailPageState extends State<ResidentDetailPage> {
  MemberService memberService = MemberService();
  late String memberID;

  final Dio _dio = Dio();

  String landlordName = '';
  String landlordPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      memberID = await memberService.findMemberID();
      await _fetchLandlordDetails();
      setState(() {
      });
    } catch (error) {
      print('멤버아이디 에러: $error');
    }
  }

  Future<void> _fetchLandlordDetails() async {
    try {
      final response = await _dio.get('$backendURL/api/members/${widget.landlordID}');
      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          landlordName = data['memberRealName'] ?? 'Unknown';
          landlordPhoneNumber = data['phoneNumber'] ?? 'Unknown';

          print('실명 : $landlordName');
          print('전번 : $landlordPhoneNumber');
        });
      } else {
        setState(() {
        });
      }
    } catch (e) {
      print("에러 : $e");
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildingWithResidents = widget.buildingWithResidents;
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                '${buildingWithResidents.buildingName} ${buildingWithResidents.apartmentNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(160.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      notice(),
                      SizedBox(height: 10,),
                      Divider(
                        color: LIGHT_GRAY_COLOR,
                        thickness: 0.5,
                      ),
                      SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: buildingWithResidents.buildingImageURL?.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.only(right: 8.0),
                          child:
                          Image.network(
                            buildingWithResidents.buildingImageURL![index],
                            width: screenWidth,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '건물 정보',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      "주소",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "계약 분류",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 10),
                                    if (buildingWithResidents.rentType == '월세') ...[
                                      Text(
                                        '월세',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '월세 납부일',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                    Text(
                                      "보증금",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "계약 기간",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      buildingWithResidents.buildingAddress,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      buildingWithResidents.rentType,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),

                                    if (buildingWithResidents.rentType == '월세') ...[
                                      Text(
                                        buildingWithResidents.monthlyRentAmount,
                                        style: TextStyle(
                                            fontSize: 15),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        buildingWithResidents.monthlyRentPaymentDate,
                                        style: TextStyle(
                                            fontSize: 15),
                                      ),
                                    ],

                                    SizedBox(height: 10),
                                    Text(
                                      buildingWithResidents.deposit,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      buildingWithResidents.contractExpirationDate,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(color: LIGHT_GRAY_COLOR, thickness: 0.5),
                            SizedBox(height: 10),
                            Text(
                              '임대인 정보',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      "임대인 명",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "연락처",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      landlordName,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      landlordPhoneNumber,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(color: LIGHT_GRAY_COLOR, thickness: 0.5),
                            SizedBox(height: 10),
                            Text(
                              "계약서 사진",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 10,),
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                buildingWithResidents.residentImageURL?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child:
                                    Image.network(
                                      buildingWithResidents.residentImageURL![index],
                                       width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ]))
                ]))));
  }

  Widget notice() {
    final buildingWithResidents = widget.buildingWithResidents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: VERY_LIGHT_GRAY_COLOR,
              borderRadius: BorderRadius.circular(10.0)),
          child: Column(children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: DARK_GRAY_COLOR),
                SizedBox(width: 8),
                Text(
                  '공지사항',
                  style: TextStyle(fontSize: 16, color: DARK_GRAY_COLOR),
                ),
              ],
            ),
            SizedBox(height: 3),
            TextFormField(
              initialValue: buildingWithResidents.notice,
              enabled: false,
              maxLines: 2,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
