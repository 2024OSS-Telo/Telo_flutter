import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../const/login_platform.dart';

import 'package:dio/dio.dart';

import '../const/backend_url.dart';

class MemberService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio(BaseOptions(baseUrl: backendURL));

  Future<String> findMemberID(LoginPlatform loginPlatform) async {
    if (loginPlatform == LoginPlatform.kakao) {
      final user = await UserApi.instance.me();
      String memberID = user.id.toString();
      print('MemberID: $memberID');
      print('Type of MemberID: ${memberID.runtimeType}');
      return memberID;
    } else if (loginPlatform == LoginPlatform.google) {
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser != null) {
        final String memberID = googleUser.id;
        print('Google MemberID: $memberID');
        return memberID;
      } else {
        throw Exception('구글 로그인 정보가 없습니다.');
      }
    } else {
      throw Exception('로그인 플랫폼을 찾을 수 없습니다.');
    }
  }

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