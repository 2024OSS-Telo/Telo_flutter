import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/building/resident_list_page.dart';
import '../../const/backend_url.dart';
import '../../const/colors.dart';
import '../../models/building_model.dart';
import 'building_resister_page.dart';

class BuildingListPage extends StatefulWidget {
  const BuildingListPage({super.key});

  @override
  BuildingListPageState createState() => BuildingListPageState();
}

class BuildingListPageState extends State<BuildingListPage> {
  final Dio _dio =
      Dio(BaseOptions(baseUrl: '$backendURL/api/buildings/building-list'));
  late Future<List<Building>> _buildingsFuture;
  late List<Building> _buildings;
  List<Building> _filteredBuildings = [];
  late String memberID;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(() {
      _filterBuildings();
    });
  }

  Future<void> _initializeData() async {
    memberID = 'aaa'; // 멤버아이디 변경
    _buildingsFuture = _fetchBuildings(memberID);
    setState(() {});
  }

  Future<List<Building>> _fetchBuildings(String memberID) async {
    try {
      final response =
          await _dio.get('$backendURL/api/buildings/member/$memberID');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print('DATA ${response.data}');
        _buildings =
            data.map((building) => Building.fromJson(building)).toList();
        _filteredBuildings = _buildings;
        return _buildings;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  void _filterBuildings() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBuildings = _buildings.where((building) {
        return building.buildingName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("건물 목록"),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 40.0,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: VERY_LIGHT_GRAY_COLOR,
                  hintText: '건물 이름으로 검색...',
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
          ),
        ),
        body: FutureBuilder<List<Building>>(
          future: _buildingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  textAlign: TextAlign.center,
                  '등록된 건물이 없습니다.\n우측 하단의 버튼을 통해 건물을 등록해 주세요.',
                  style: TextStyle(
                    color: GRAY_COLOR,
                    fontSize: 12.0,
                  ),
                ),
              );
            } else {
              final buildings = snapshot.data!;
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                        child: Text(
                          '건물 ${buildings.length} 개',
                          style: TextStyle(
                              fontSize: 11.0),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: _filteredBuildings.length,
                      itemBuilder: (context, index) {
                        Building building = _filteredBuildings[index];
                        return _buildingCard(building);
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BuildingResisterPage()),
            );
            if (result == true) {
              setState(() {
                _buildingsFuture = _fetchBuildings(memberID);
              });
            }
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: MAIN_COLOR,
          child: const Icon(
            color: Colors.white,
            Icons.add,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildingCard(Building building) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResidentListPage(
              buildingID: building.buildingID,
              buildingName: building.buildingName,
            ),
          ),
        );
        if (result == true) {
          setState(() {
            _buildingsFuture = _fetchBuildings(memberID);
          });
        }
      },
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 1.5, horizontal: 1.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: LIGHT_GRAY_COLOR),
            borderRadius: BorderRadius.circular(13.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                child: Image.asset(
                  'assets/image/buildingIMGtest.png',
                  //building.imageURL.isNotEmpty ? building.imageURL[0] : 'assets/image/buildingIMGtest.png',
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
                      building.buildingName,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      building.buildingAddress,
                      style: TextStyle(fontSize: 12.0, color: DARK_MAIN_COLOR),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Icon(Icons.apartment, size: 12.0, color: Colors.black),
                        SizedBox(width: 5.0),
                        Expanded(
                          child: Text(
                            '임대 완료: ${building.numberOfRentedHouseholds} 건',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 15.0),
                        Expanded(
                          child: Text(
                            '임대 가능: ${building.numberOfHouseholds-building.numberOfRentedHouseholds} 건',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '최근 공지: ',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: building.notice ?? '공지를 등록해보세요',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: (building.notice ?? '공지를 등록해보세요') ==
                                      '공지를 등록해보세요'
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
