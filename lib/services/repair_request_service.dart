import 'package:dio/dio.dart';

import '../const/backend_url.dart';
import '../models/repair_request_model.dart';

class RepairRequestService {
  final Dio _dio = Dio(BaseOptions(baseUrl: backendURL));

  Future<List<RepairRequest>> getRepairRequestList(String memberID) async {
    try {
      final response = await _dio.get('/api/repair-request/$memberID');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print(memberID);
        print(data);
        return data.map((json) => RepairRequest.fromJson(json)).toList();
      } else {
        throw Exception("수리 요청 목록 로딩 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("수리 요청 목록 로딩 실패: $e");
    }
  }

  Future<void> updateRepairState (String requestID, RepairState state) async {
    try {
      final response = await _dio.post('/api/repair-request/update-state',
      data: {
        'requestID': requestID,
        'state': state.toString().split('.').last
      });
    } catch (e) {
      print('Error: $e');
      throw Exception("수리 요청 상태 업데이트 실패: $e");
    }
  }
}