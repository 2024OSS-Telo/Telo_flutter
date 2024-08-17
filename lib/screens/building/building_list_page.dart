import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import '../../const/colors.dart';
import 'building_resister_page.dart';

class BuildingListPage extends StatefulWidget {
  const BuildingListPage({super.key});

  @override
  State<BuildingListPage> createState() => _BuildingListPage();
}

class _BuildingListPage extends State<BuildingListPage> {

  final Dio _dio = Dio();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("건물 목록"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildingCard();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BuildingResisterPage()),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: MAIN_COLOR,
        child: const Icon(
          color: Colors.white,
          Icons.add,
          size: 30,
        ),
      ),
    ));
  }

  Widget _buildingCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 1.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: GRAY_COLOR),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            child: Image.asset(
              'assets/image/buildingIMGtest.png',
              width: 100.0,
              height: 120.0,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15.0),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '류진 빌딩',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '서울시 중랑구 제이슨로 816',
                style: TextStyle(
                    fontSize: 13.0,
                    color: DARK_MAIN_COLOR),
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Icon(Icons.apartment, size: 14.0, color: Colors.grey[600]),
                  SizedBox(width: 5.0),
                  Text(
                    '임대완료: 3건',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 15.0),
                  Text(
                    '임대가능: 1건',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '최근 공지: 요즘 고양이 키우는 사람이 많답니다.',
                style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
