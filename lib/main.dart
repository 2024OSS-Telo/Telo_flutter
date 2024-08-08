import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:telo/screens/home_page.dart';
import 'package:telo/screens/notification_page.dart';
import 'package:telo/screens/repair/repair_list_page.dart';
import 'const/login_platform.dart';
import 'package:dio/dio.dart';

void main() {
  KakaoSdk.init(nativeAppKey: 'aa');
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LoginPlatform _loginPlatform = LoginPlatform.none;
  bool _isLoading = true;
  bool _isTenantOrLandlord = false;

  final Dio dio = Dio();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkLoginStatus();
    await _initializeMemberType();
  }

  Future<void> _checkLoginStatus() async {
    bool isKakaoLoggedIn = await AuthApi.instance.hasToken();
    bool isGoogleLoggedIn = await _googleSignIn.isSignedIn();

    setState(() {
      if (isKakaoLoggedIn) {
        _loginPlatform = LoginPlatform.kakao;
      } else if (isGoogleLoggedIn) {
        _loginPlatform = LoginPlatform.google;
      } else {
        _loginPlatform = LoginPlatform.none;
      }
    });
  }

  Future<void> _initializeMemberType() async {
    print("Initializing member type for platform: $_loginPlatform");
    if (_loginPlatform != LoginPlatform.none) {
      await checkMemberType();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> signUpUser(String memberID, String memberName, String profile, String provider) async {
    final response = await dio.post(
      'http://localhost:80/api/members/signup',
      data: {
        'memberID': memberID,
        'memberName': memberName,
        'profile': profile,
        'provider': provider,
        'memberType': 'user'
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode != 200) {
      print('요청 전송에 실패했습니다.: ${response.statusMessage}');
    }
  }

  Future<void> updateUserType(String memberType) async {
    final String memberID = await findMemberID();
    print('Member ID: $memberID');
    print('Member Type: $memberType');
    print('Member Type Type: ${memberType.runtimeType}');

    final response = await dio.post(
      'http://localhost:80/api/members/updateMemberType/$memberID',
      data: {'memberType': memberType},
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode != 200) {
      print('Request failed: ${response.statusMessage}');
    }
  }

  Future<String> findMemberID() async {
    if (_loginPlatform == LoginPlatform.kakao) {
      final user = await UserApi.instance.me();
      String memberID = user.id.toString();
      print('MemberID: $memberID');
      print('Type of MemberID: ${memberID.runtimeType}');
      return memberID;
    } else if (_loginPlatform == LoginPlatform.google) {
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

  Future<void> checkMemberType() async {
    try {
      final String memberID = await findMemberID();
      print("Checking member type for memberID: $memberID");
      final response = await dio.get('http://localhost:80/api/members/$memberID');
      if (response.statusCode == 200) {
        final memberType = response.data['memberType'];
        print("Member Type: $memberType");
        setState(() {
          _isTenantOrLandlord =
              memberType == 'tenant' || memberType == 'landlord';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isTenantOrLandlord = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isTenantOrLandlord = false;
        _isLoading = false;
      });
      print("Error occurred: $e");
    }
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      final String memberID = googleUser.id;
      final String memberName = googleUser.displayName ?? '';
      final String profile = googleUser.photoUrl ?? '';
      const String provider = 'google';

      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });

      await signUpUser(memberID, memberName, profile, provider);
      await _initializeMemberType();
    }
  }

  void signInWithKakao() async {
    bool isLoggedIn = false;
    User? user;

    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        setState(() {
          _loginPlatform = LoginPlatform.kakao;
        });

        isLoggedIn = true;
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        try {
          await UserApi.instance.loginWithKakaoAccount();
          setState(() {
            _loginPlatform = LoginPlatform.kakao;
          });

          isLoggedIn = true;
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        setState(() {
          _loginPlatform = LoginPlatform.kakao;
        });

        isLoggedIn = true;
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }

    if (isLoggedIn) {
      try {
        user = await UserApi.instance.me();
        String memberID = user.id.toString();
        String memberName = user.kakaoAccount?.profile?.nickname ?? '';
        String profile = user.kakaoAccount?.profile?.profileImageUrl ?? '';
        String provider = 'kakao';

        print('로그인 성공 후 user 정보: $user');
        print( '서버 요청 본문: memberID=$memberID, memberName=$memberName, profile=$profile, provider=$provider');

        await signUpUser(memberID, memberName, profile, provider);
        await _initializeMemberType();
      } catch (error) {
        print('사용자 정보 가져오기 실패: $error');
      }
    }
  }

  void signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.google:
        await GoogleSignIn().signOut();
        break;
      case LoginPlatform.kakao:
        await UserApi.instance.logout();
        break;
      case LoginPlatform.none:
        break;
    }

    setState(() {
      _loginPlatform = LoginPlatform.none;
      _isLoading = true;
      _isTenantOrLandlord = false;
    });

    //await _checkLoginStatus();
    //await _initializeMemberType();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_loginPlatform == LoginPlatform.none) {
      return PageSlide(
        onGoogleSignIn: signInWithGoogle,
        onKakaoSignIn: signInWithKakao,
      );
    } else {
      print("_isTenantOrLandlord: $_isTenantOrLandlord");
      if (_isTenantOrLandlord) {
        return MainPage(onSignOut: signOut);
      } else {
        return AfterLogin(
          onSignOut: signOut,
          updateService: updateUserType,
        );
      }
    }
  }
}

class PageSlide extends StatelessWidget {
  final PageController _pageController = PageController(initialPage: 0);
  final VoidCallback onGoogleSignIn;
  final VoidCallback onKakaoSignIn;

  PageSlide(
      {super.key, required this.onGoogleSignIn, required this.onKakaoSignIn});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double indicatorPosition = screenHeight * 0.6;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              Container(
                color: Color(0xff93A98D),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 90, 0, 0),
                  child: Text(
                    '임대인과\n임차인을 잇다\n\u{1f3e0}\nTELO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      letterSpacing: 5,
                      height: 1.8,
                    ),
                  ),
                ),
              ),
              Container(
                color: Color(0xff93A98D),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 90, 0, 0),
                  child: Text(
                    '현명한\n집 관리 플랜\nTELO로부터',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      letterSpacing: 5,
                      height: 1.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: indicatorPosition,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: SwapEffect(
                  activeDotColor: Colors.black,
                  dotColor: Colors.black38,
                  spacing: 8.0,
                  dotWidth: 13.0,
                  dotHeight: 13.0,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsetsDirectional.only(bottom: 50),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.all(7),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Image.asset(
                      'assets/image/android_neutral_sq_SI@1x.png',
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                    onPressed: onGoogleSignIn,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(7),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Image.asset(
                      'assets/image/kakao_login_medium_narrow.png',
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                    onPressed: onKakaoSignIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AfterLogin extends StatelessWidget {
  final VoidCallback onSignOut;
  final Future<void> Function(String) updateService;

  const AfterLogin({super.key, required this.onSignOut, required this.updateService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff93A98D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '반가워요!\n누구신가요?\n',
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                letterSpacing: 5,
                height: 1.8,
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 350,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xff2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () async {
                  await updateService('landlord');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(onSignOut: onSignOut),
                    ),
                  );
                },
                child: Text(
                  '집주인입니다',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () async {
                  await updateService('tenant');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(onSignOut: onSignOut),
                    ),
                  );
                },
                child: Text(
                  '세입자입니다',
                  style: TextStyle(color: Color(0xff2C2C2C)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final VoidCallback onSignOut;

  const MainPage({super.key, required this.onSignOut});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(onSignOut: widget.onSignOut),
      RepairListPage(),
      RepairListPage(),
      RepairListPage(),
      RepairListPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.chat_bubble,
              ),
              label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: '건물'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: '수리요청'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내정보')
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xff2c2c2c),
        unselectedItemColor: Color(0xff757575),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: _onItemTapped,
      ),
    );
  }
}
