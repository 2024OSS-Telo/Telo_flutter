import 'package:dio/dio.dart';

import '../const/backend_url.dart';

class MemberService {
  final Dio _dio = Dio(BaseOptions(baseUrl: backendURL));

  Future<String> getMemberType(String memberID) async {
    try {
      final response = await _dio.get('/api/members/$memberID');
      if (response.statusCode == 200) {
        return response.data['memberType'];
      }
      else {
        throw Exception("멤버 타입 가져오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("멤버 타입 가져오기 실패: $e");
    }
  }
}