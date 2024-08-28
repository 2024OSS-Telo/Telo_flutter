import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/building/widgets/count_residents_widget.dart';
import 'package:telo/screens/building/widgets/notice_widget.dart';

import '../../const/backend_url.dart';
import '../../models/resident_model.dart';

class ResidentListPage extends StatefulWidget {
  final String buildingID;
  final String buildingName;

  const ResidentListPage(
      {super.key, required this.buildingID, required this.buildingName});

  @override
  State<ResidentListPage> createState() => ResidentListPageState();
}

class ResidentListPageState extends State<ResidentListPage> {
  final Dio _dio = Dio();
  late Future<List<Resident>> _residentsFuture;
  late List<Resident> _residents;
  List<Resident> _filteredResidents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(() {
      _filterResidents();
    });
  }

  Future<void> _initializeData() async {
    _residentsFuture = _fetchResidents(widget.buildingID, widget.buildingName);
    setState(() {});
  }

  Future<List<Resident>> _fetchResidents(
      String buildingID, String buildingName) async {
    try {
      final response = await _dio
          .get('$backendURL/api/residents/landlord/resident-list/$buildingID');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;

        print('DATA: ${response.data}');
        _residents =
            data.map((resident) => Resident.fromJson(resident)).toList();
        _filteredResidents = _residents;
        return _residents;
      } else {
        return [];
      }
    } catch (e) {
      print('주민 정보 가져오기 오류: $e');
      return [];
    }
  }

  void _filterResidents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResidents = _residents.where((resident) {
        return resident.residentName.toLowerCase().contains(query) ||
            resident.apartmentNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showImagePopup(BuildContext context, int initialIndex, List<String> imageURLs) {
    final PageController pageController = PageController(initialPage: initialIndex);
    int currentPage = 0;

    print('이미지 url 길이: ${imageURLs.length}');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: DARK_GRAY_COLOR.withOpacity(0.5),
          insetPadding: EdgeInsets.symmetric(vertical: 50.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Stack(
            children: [
              PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: imageURLs.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    imageURLs[index],
                    fit: BoxFit.contain,
                  );
                },
              ),
              Positioned(
                top: 20.0,
                right: 10.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: DARK_GRAY_COLOR,
                    size: 30.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.buildingName),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () async {
              Navigator.pop(context, true);
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(290.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  NoticeWidget(
                    buildingID: widget.buildingID,
                    initialNotice: '',
                  ),
                  Divider(
                    color: LIGHT_GRAY_COLOR,
                    thickness: 0.5,
                  ),
                  SizedBox(
                    height: 40.0,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: VERY_LIGHT_GRAY_COLOR,
                        hintText: '세입자 이름 혹은 호 수로 검색...',
                        hintStyle: TextStyle(
                          color: GRAY_COLOR,
                          fontSize: 13.0,
                          height: 1.45,
                        ),
                        prefixIcon: Icon(Icons.search, color: DARK_GRAY_COLOR),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<Resident>>(
          future: _residentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  textAlign: TextAlign.center,
                  '등록된 입주민이 없습니다.\n세입자가 등록하기를 기다려 주세요.',
                  style: TextStyle(
                    color: GRAY_COLOR,
                    fontSize: 12.0,
                  ),
                ),
              );
            } else {
              final residents = snapshot.data!;
              return Column(
                children: [
                  ResidentCountWidget(residentCount: residents.length),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: _filteredResidents.length,
                      itemBuilder: (context, index) {
                        Resident resident = _filteredResidents[index];

                        return _residentCard(resident);
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _residentCard(Resident resident) {
    return Stack(children: [
      Container(
          margin: EdgeInsets.symmetric(vertical: 1.5, horizontal: 1.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: LIGHT_GRAY_COLOR),
            borderRadius: BorderRadius.circular(13.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  print('이미지 url 길이: ${resident.imageURL.length}');
                  _showImagePopup(context, 0, resident.contractImageURL);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    resident.imageURL.first,
                    width: 100.0,
                    height: 120.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${resident.apartmentNumber}     ${resident.residentName}',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      resident.phoneNumber,
                      style: TextStyle(fontSize: 11.0, color: Colors.black),
                    ),
                    SizedBox(height: 10.0),
                    if (resident.rentType == '월세') ...[
                      Text(
                        '월세: ${resident.monthlyRentAmount}만 원',
                        style: TextStyle(fontSize: 11.0, color: Colors.black),
                      ),
                      Text(
                        '월세 납부일: ${resident.monthlyRentPaymentDate}',
                        style: TextStyle(fontSize: 11.0, color: Colors.black),
                      ),
                      SizedBox(height: 10.0),
                    ],
                    if (resident.rentType == '전세') ...[
                      SizedBox(height: 20.0),
                    ],
                    Text(
                      '보증금: ${resident.deposit} 원',
                      style: TextStyle(fontSize: 11.0, color: Colors.black),
                    ),
                    Text(
                      '계약 만료일: ${resident.contractExpirationDate}',
                      style: TextStyle(fontSize: 11.0, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          )),
      Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: DARK_MAIN_COLOR,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Text(resident.rentType,
              style: TextStyle(fontSize: 13, color: Colors.white)),
        ),
      )
    ]);
  }
}
