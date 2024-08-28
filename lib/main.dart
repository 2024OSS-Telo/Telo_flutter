import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/provider/building_provider.dart';
import 'package:telo/screens/building/building_list_page.dart';
import 'package:telo/screens/building/resident_list_page.dart';
import 'package:telo/screens/chat/chat_list_page.dart';
import 'package:telo/screens/home_page.dart';
import 'package:telo/screens/mypage/mypage_page.dart';
import 'package:telo/screens/repair/repair_list_page.dart';
import 'package:telo/services/member_service.dart';
import 'const/backend_url.dart';
import 'const/key.dart';
import 'const/login_platform.dart';
import 'package:dio/dio.dart';
import 'const/login_platform.dart';
import 'package:dio/dio.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'message_channel', // 알림 채널 ID
      'Messages', // 알림 채널 이름
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // 알림 ID
      message.notification?.title, // 알림 제목
      message.notification?.body, // 알림 본문
      platformChannelSpecifics,
      payload: message.data.isNotEmpty ? message.data['data'] : null,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // 기본 아이콘

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // FlutterLocalNotificationsPlugin 인스턴스 초기화
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  // 알림 채널 설정
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'message_channel',
    'Messages',
    importance: Importance.max,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(channel);
  }

  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'message_channel',
    'Messages',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    playSound: true,
    enableVibration: true,
  );

  // 포그라운드에서 알림 수신 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('@@@@@@@@@@Received a message in the foreground: ${message.notification?.body}');
    if (message.notification != null) {
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: message.data.isNotEmpty ? message.data['data'] : null,
      );
    }
  });

  //TODO: 테스트를 위한 토큰 리턴 (삭제하기)
  String? token = await FirebaseMessaging.instance.getToken();
  print("@@@@@@@@@token: $token");

  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);

  void signOut(){}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BuildingProvider()),
        ChangeNotifierProvider(create: (_) => TenantBuildingProvider()),
      ],
      child: MaterialApp(
        home: MainPage(onSignOut: signOut),
      ),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MemberService _memberService = MemberService();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedStatus = prefs.getBool('isTenantOrLandlord');

    if (savedStatus != null && savedStatus) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(onSignOut: signOut),
        ),
      );

    } else {
      await _checkLoginStatus();
      await _initializeMemberType();
    }
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

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (_isTenantOrLandlord) {
        await prefs.setBool('isTenantOrLandlord', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(onSignOut: signOut),
          ),
        );
      } else {
        await prefs.setBool('isTenantOrLandlord', false);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signUpUser(String memberID, String memberNickName,
      String profile, String provider) async {
    String? token = await FirebaseMessaging.instance.getToken();
    final response = await dio.post(
      "$backendURL/api/members/signup",
      data: {
        'memberID': memberID,
        'memberNickName': memberNickName,
        'profile': profile,
        'provider': provider,
        'memberType': 'user',
        'token' : token,
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
    final String memberID = await _memberService.findMemberID();

    print('Member ID: $memberID');
    print('Member Type: $memberType');
    print('Member Type Type: ${memberType.runtimeType}');

    final response = await dio.post(
      "$backendURL/api/members/updateMemberType/$memberID",
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

  Future<void> checkMemberType() async {
    try {
      final String memberID = await _memberService.findMemberID();
      print("Checking member type for memberID: $memberID");
      final response = await dio.get("$backendURL/api/members/$memberID");
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
      final String memberNickName = googleUser.displayName ?? '';
      final String profile = googleUser.photoUrl ?? '';
      const String provider = 'google';

      print('memberNickName = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });

      await signUpUser(memberID, memberNickName, profile, provider);
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
        String memberNickName = user.kakaoAccount?.profile?.nickname ?? '';
        String profile = user.kakaoAccount?.profile?.profileImageUrl ?? '';
        String provider = 'kakao';

        print('로그인 성공 후 user 정보: $user');
        print(
            '서버 요청 본문: memberID=$memberID, memberNickName=$memberNickName, profile=$profile, provider=$provider');

        await signUpUser(memberID, memberNickName, profile, provider);
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              children: [
                Container(
                  color: MAIN_COLOR,
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
                  color: MAIN_COLOR,
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
      ),
    );
  }
}

class AfterLogin extends StatelessWidget {
  final VoidCallback onSignOut;
  final Future<void> Function(String) updateService;

  const AfterLogin(
      {super.key, required this.onSignOut, required this.updateService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: MAIN_COLOR,
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
  String? memberID;
  String _memberType = "";
  MemberService memberService = MemberService();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _widgetOptions = <Widget>[
      Placeholder(),
      ChatListPage(),
      Placeholder(),
      RepairListPage(),
      MypagePage(),
    ];
  }

  Future<void> _initializeData() async {
    try {
      memberID = await memberService.findMemberID();
      if (memberID != null) {
        await _fetchMemberType();
        setState(() {
          _widgetOptions[0] = _memberType == 'landlord'
              ? LandlordHomePage(onSignOut: widget.onSignOut)
              : TenantHomePage(onSignOut: widget.onSignOut);
        });
      } else {
        print('Member ID could not be initialized.');
      }
    } catch (error) {
      print('Error initializing member ID: $error');
    }
  }

  Future<void> _fetchMemberType() async {
    if (memberID == null) {
      print('Member ID is null');
      return;
    }

    try {
      final response =
          await _dio.get('$backendURL/api/members/$memberID/memberType');
      if (response.statusCode == 200) {
        print('member type: ${response.data}');

        setState(() {
          _memberType = response.data;
        });
      } else {
        print(
            'Failed to load member type, status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading member type: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('앱을 종료하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('아니요'),
                ),
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text('예'),
                ),
              ],
            ),
          );
        },
        child: Scaffold(
          body: SafeArea(
            child: _selectedIndex == 2
                ? (_memberType == 'landlord'
                    ? LandlordBuildingListPage()
                    : TenantBuildingListPage())
                : _widgetOptions.elementAt(_selectedIndex),
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
            selectedItemColor: DARK_GRAY_COLOR,
            unselectedItemColor: GRAY_COLOR,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            onTap: _onItemTapped,
          ),
        ));
  }
}
