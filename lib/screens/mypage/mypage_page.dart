import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../const/backend_url.dart';
import '../../const/colors.dart';
import '../../models/member_model.dart';
import '../../services/member_service.dart';

class MypagePage extends StatefulWidget {
  const MypagePage({super.key});

  @override
  State<MypagePage> createState() => _MypagePageState();
}

class _MypagePageState extends State<MypagePage> {
  MemberService memberService = MemberService();
  late String memberID;
  Future<Member?>? _futureMember;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      memberID = await memberService.findMemberID();
      setState(() {
        _futureMember = _fetchMember(memberID);
      });
    } catch (error) {
      print('마이페이지 리스트 멤버아이디 에러: $error');
    }
  }

  Future<Member?> _fetchMember(String memberID) async {
    try {
      final response = await _dio.get('$backendURL/api/members/$memberID');
      if (response.statusCode == 200) {
        return Member.fromJson(response.data);
      } else {
        print('멤버 로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error : $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('내 정보'),
          ),
          body: Center(
              child: FutureBuilder<Member?>(
                  future: _futureMember,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          '마이페이지 로드 실패',
                          style: TextStyle(
                            color: GRAY_COLOR,
                            fontSize: 12.0,
                          ),
                        ),
                      );
                    } else {
                      final member = snapshot.data!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: LIGHT_GRAY_COLOR,
                            backgroundImage: member.profile != null &&
                                member.profile!.isNotEmpty
                                ? NetworkImage(member.profile!)
                                : null,
                            child: member.profile == null ||
                                member.profile!.isEmpty
                                ? Icon(Icons.person,
                                size: 50, color: Colors.black)
                                : null,
                          ),
                          SizedBox(height: 20.0),
                          Text(member.memberNickName,
                            style: TextStyle( fontSize: 20.0,),
                          ),
                          SizedBox(height: 40.0),
                          Text('실명: ${member.memberRealName}',
                            style: TextStyle( fontSize: 15.0,),
                          ),
                          SizedBox(height: 15.0),

                          if (member.provider == 'kakao' || member.provider == 'google')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '로그인 플랫폼:   ',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Image.asset(
                                    member.provider == 'kakao'
                                        ? 'assets/image/kakaotalk_platform_logo.png'
                                        : 'assets/image/google_platform_logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),

                          SizedBox(height: 15.0),
                          Text('연락처: ${member.phoneNumber}',
                              style: TextStyle( fontSize: 15.0, )
                          ),

                        ],
                      );
                    }
                  }))),
    );
  }
}
