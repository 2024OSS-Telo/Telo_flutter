import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../const/backend_url.dart';
import '../models/building_model.dart';
import '../services/member_service.dart';

class BuildingProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<Building> _buildings = [];
  List<Building> _filteredBuildings = [];
  String? memberID;

  List<Building> get buildings => _buildings;
  List<Building> get filteredBuildings => _filteredBuildings;

  Future<void> initializeData(MemberService memberService) async {
    try {
      memberID = await memberService.findMemberID();
      await fetchBuildings(memberID!);
    } catch (error) {
      print('빌딩 리스트 멤버아이디 에러: $error');
    }
  }

  Future<void> fetchBuildings(String landlordID) async {
    try {
      final response = await _dio.get('$backendURL/api/buildings/landlord/building-list/$landlordID');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _buildings = data.map((building) => Building.fromJson(building)).toList();
        _filteredBuildings = _buildings;
      } else if (response.statusCode == 204) {
        _buildings = [];
        _filteredBuildings = [];
        print('빌딩 데이터가 없습니다.');
      } else {
        print('응답 에러: ${response.statusCode}');
      }

      notifyListeners();
    } catch (e) {
      print('데이터 로딩 에러: $e');
      _buildings = [];
      _filteredBuildings = [];
      notifyListeners();
    }
  }

  void filterBuildings(String query) {
    _filteredBuildings = _buildings.where((building) {
      return building.buildingName.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }

  void addBuilding(Building building) {
    _buildings.add(building);
    _filteredBuildings = _buildings;
    notifyListeners();
  }

  void updateBuilding(Building building) {
    int index = _buildings.indexWhere((b) => b.buildingID == building.buildingID);
    if (index != -1) {
      _buildings[index] = building;
      _filteredBuildings = _buildings;
      notifyListeners();
    }
  }
}