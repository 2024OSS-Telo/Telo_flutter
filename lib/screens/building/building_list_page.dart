import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/building/resident_detail_page.dart';
import 'package:telo/screens/building/resident_list_page.dart';
import 'package:telo/screens/building/tenant_resident_register_page.dart';
import 'package:telo/screens/building/widgets/count_residents_widget.dart';
import 'package:telo/screens/building/widgets/notice_widget.dart';
import '../../const/backend_url.dart';
import '../../const/colors.dart';
import '../../models/building_model.dart';
import '../../models/building_with_residents_model.dart';
import '../../models/resident_model.dart';
import '../../provider/building_provider.dart';
import '../../services/member_service.dart';
import 'landlord_building_register_page.dart';

class LandlordBuildingListPage extends StatefulWidget {
  const LandlordBuildingListPage({super.key});

  @override
  State<LandlordBuildingListPage> createState() =>
      _LandlordBuildingListPageState();
}

class _LandlordBuildingListPageState extends State<LandlordBuildingListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final buildingProvider =
        Provider.of<BuildingProvider>(context, listen: false);
    _searchController.addListener(() {
      buildingProvider.filterBuildings(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      buildingProvider.initializeData(MemberService());
    });
  }

  @override
  Widget build(BuildContext context) {
    final buildingProvider = Provider.of<BuildingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("건물 목록"),
        automaticallyImplyLeading: false,
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
      body: Builder(
        builder: (context) {
          if (buildingProvider.buildings.isEmpty &&
              buildingProvider.filteredBuildings.isEmpty) {
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
          } else if (buildingProvider.filteredBuildings.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Text(
                        '건물 ${buildingProvider.filteredBuildings.length} 개',
                        style: TextStyle(fontSize: 11.0),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: buildingProvider.filteredBuildings.length,
                    itemBuilder: (context, index) {
                      Building building =
                          buildingProvider.filteredBuildings[index];
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
            buildingProvider.fetchBuildings(buildingProvider.memberID!);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: MAIN_COLOR,
        child: const Icon(
          color: Colors.white,
          Icons.add,
          size: 30,
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
          Provider.of<BuildingProvider>(context, listen: false).fetchBuildings(
              Provider.of<BuildingProvider>(context, listen: false).memberID!);
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
                      fontWeight: FontWeight.w600,
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
                          style: TextStyle(fontSize: 12.0, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Expanded(
                        child: Text(
                          '임대 가능: ${building.numberOfHouseholds - building.numberOfRentedHouseholds} 건',
                          style: TextStyle(fontSize: 12.0, color: Colors.black),
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
        ),
      ),
    );
  }
}

class TenantBuildingListPage extends StatefulWidget {
  const TenantBuildingListPage({super.key});

  @override
  State<TenantBuildingListPage> createState() => _TenantBuildingListPageState();
}

class _TenantBuildingListPageState extends State<TenantBuildingListPage> {
  MemberService memberService = MemberService();
  late String memberID;

  final Dio _dio = Dio();
  Future<List<BuildingWithResidents>>? _buildingsFuture;
  late List<BuildingWithResidents> _buildings;
  List<BuildingWithResidents> _filteredBuildings = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterBuildings();
    });
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      memberID = await memberService.findMemberID();
      setState(() {
        _buildingsFuture = _fetchBuildings(memberID);
      });
    } catch (error) {
      print('빌딩 리스트 멤버아이디 에러: $error');
    }
  }

  Future<List<BuildingWithResidents>> _fetchBuildings(String tenantID) async {
    try {
      final response = await _dio
          .get('$backendURL/api/residents/tenant/resident-list/$tenantID');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print('DATA ${response.data}');
        _buildings = data
            .map((building) => BuildingWithResidents.fromJson(building))
            .toList();
        _filteredBuildings = _buildings;
        return _buildings;
      } else {
        print('tenant building list error');
        return [];
      }
    } catch (e, stackTrace) {
      print('tenant building list error : $e');
      print('스택: $stackTrace');
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
    return Scaffold(
      appBar: AppBar(
        title: Text("건물 목록"),
        automaticallyImplyLeading: false,
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
      body: _buildingsFuture == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<BuildingWithResidents>>(
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
                              style: TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemCount: _filteredBuildings.length,
                          itemBuilder: (context, index) {
                            BuildingWithResidents resident =
                                _filteredBuildings[index];
                            return _buildingCard(resident);
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
            MaterialPageRoute(builder: (context) => AddressComparePage()),
          );
          if (result == true) {
            setState(() {
              _buildingsFuture = _fetchBuildings(memberID);
              _initializeData();
            });
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: MAIN_COLOR,
        child: const Icon(
          color: Colors.white,
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildingCard(BuildingWithResidents buildingWithResidents) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResidentDetailPage(
                buildingWithResidents: buildingWithResidents,
                landlordID: buildingWithResidents.landlordID),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: Image.asset(
                    'assets/image/buildingIMGtest.png',
                    width: 120.0,
                    height: 150.0,
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
                        '${buildingWithResidents.buildingName} ${buildingWithResidents.apartmentNumber}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        buildingWithResidents.buildingAddress,
                        style:
                            TextStyle(fontSize: 12.0, color: DARK_MAIN_COLOR),
                      ),
                      SizedBox(height: 10.0),
                      if (buildingWithResidents.rentType == '월세') ...[
                        Text(
                          '월세: ${buildingWithResidents.monthlyRentAmount}만 원',
                          style: TextStyle(fontSize: 11.0, color: Colors.black),
                        ),
                        Text(
                          '월세 납부일: ${buildingWithResidents.monthlyRentPaymentDate}',
                          style: TextStyle(fontSize: 11.0, color: Colors.black),
                        ),
                        SizedBox(height: 10.0),
                      ],
                      if (buildingWithResidents.rentType == '전세') ...[
                        Text(''),
                      ],
                      Text(
                        '보증금: ${buildingWithResidents.deposit} 원',
                        style: TextStyle(fontSize: 11.0, color: Colors.black),
                      ),
                      Text(
                        '계약 만료일: ${buildingWithResidents.contractExpirationDate}',
                        style: TextStyle(fontSize: 11.0, color: Colors.black),
                      ),
                      if (buildingWithResidents.rentType == '전세') ...[
                        Text(''),
                      ],
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
                              text:
                                  buildingWithResidents.notice ?? '공지를 등록해보세요',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: (buildingWithResidents.notice ??
                                            '공지를 등록해보세요') ==
                                        '공지를 등록해보세요'
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
