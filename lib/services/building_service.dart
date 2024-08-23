import 'package:dio/dio.dart';
import '../const/backend_url.dart';
import '../models/building_model.dart';

class BuildingService {
  final Dio _dio = Dio(BaseOptions(baseUrl: backendURL));

  Future<List<Building>> getBuildingsByTenantIDAndLandlordID (String tenantID, String landlordID) async {
    try {
      final response = await _dio.get('/api/residents/$tenantID/$landlordID');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Building.fromJson(json)).toList();
      } else {
        throw Exception("빌딩 목록 로딩 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("빌딩 목록 로딩 실패: $e");
    }
  }
}