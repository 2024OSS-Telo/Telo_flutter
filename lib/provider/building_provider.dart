import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../const/backend_url.dart';
import '../models/building_model.dart';
import '../models/building_with_residents_model.dart';
import '../services/member_service.dart';

class BuildingProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<Building> _buildings = [];
  List<Building> _filteredBuildings = [];
  String? memberID;

  List<Building> get buildings => _buildings;
  List<Building> get filteredBuildings => _filteredBuildings;

  void filterAvailableBuildings() {
    _filteredBuildings = _buildings.where((building) {
      return (building.numberOfHouseholds - building.numberOfRentedHouseholds) > 0;
    }).toList();
    notifyListeners();
  }

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

class TenantBuildingProvider with ChangeNotifier {
  final MemberService memberService = MemberService();
  final Dio _dio = Dio();

  late String memberID;
  List<BuildingWithResidents> _buildings = [];
  List<BuildingWithResidents> filteredBuildings = [];
  bool _isLoading = true;
  String _error = '';

  List<BuildingWithResidents> get buildings => filteredBuildings;
  bool get isLoading => _isLoading;
  String get error => _error;

  TenantBuildingProvider() {
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      memberID = await memberService.findMemberID();
      await fetchBuildings(memberID);
    } catch (error) {
      _error = '빌딩 리스트 멤버아이디 에러: $error';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBuildings(String tenantID) async {
    try {
      final response = await _dio.get('$backendURL/api/residents/tenant/resident-list/$tenantID');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _buildings = data.map((building) => BuildingWithResidents.fromJson(building)).toList();
        filteredBuildings = _buildings;
      } else {
        _error = 'tenant building list error';
      }
    } catch (e) {
      _error = 'tenant building list error : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterBuildings(String query) {
    query = query.toLowerCase();
    filteredBuildings = _buildings.where((building) {
      return building.buildingName.toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }
}