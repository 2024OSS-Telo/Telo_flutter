import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../const/login_platform.dart';
import 'package:dio/dio.dart';
import '../const/backend_url.dart';
import '../models/member_model.dart';

class MemberService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio(BaseOptions(baseUrl: backendURL));

  Future<String> findMemberID() async {
    try {
      final user = await UserApi.instance.me();
      if (user != null) {
        String memberID = user.id.toString();
        print('Kakao MemberID: $memberID');
        return memberID;
      }
    } catch (e) {
      print('Kakao 로그인 안됨: $e');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        final String memberID = googleUser.id;
        print('Google MemberID: $memberID');
        return memberID;
      }
    } catch (e) {
      print('Google 로그인 안됨: $e');
    }

    //TODO: 추후 리턴값 없이 로그인화면으로 돌아가도록 수정
    String ID = "3";
    print('로그인된 사용자가 없습니다. 기본 ID를 반환합니다. : $ID');
    return ID;
  }

  Future<Member> getMember(String memberID) async {
    try {
      final response = await _dio.get('/api/members/$memberID');
      if (response.statusCode == 200) {
        print(response.data);
        return Member.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception("멤버 가져오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("멤버 가져오기 실패: $e");
    }
  }

}