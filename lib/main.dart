import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:telo/screens/home_page.dart';
import 'package:telo/screens/notification_page.dart';
import 'package:telo/screens/repair/repair_list_page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'login_platform.dart';

void main() {
  KakaoSdk.init(
      nativeAppKey: '7175c6f048b50e0a135ab044f8f3155e'
  );

  runApp(const MaterialApp(
    home: MyApp(),
    //home: MainPage()
    //home: AfterLogin(),
  ));
}

class KakaoLoginApi {
  signWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }
}

class GoogleLoginApi {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');
      //
      // setState(() {
      //   _loginPlatform = LoginPlatform.google;
      // });
    }
  }
}

Future<bool> isLoggedIn() async {
  try {
    // 유저 정보를 가져오려 시도
    final User user = await UserApi.instance.me();
    return user != null;
  } catch (e) {
    return false;
  }
}

// void signOut() async {
//   switch (_loginPlatform) {
//     case LoginPlatform.google:
//       await GoogleSignIn().signOut();
//       break;
//     case LoginPlatform.kakao:
//       break;
//     case LoginPlatform.none:
//       break;
//   }
//
//   setState(() {
//     _loginPlatform = LoginPlatform.none;
//   });
// }

// 로그인 전
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error occurred')),
            );
          } else {
            bool loggedIn = snapshot.data ?? false;
            if (loggedIn) {
              return AfterLogin();
            } else {
              return PageSlide();
            }
          }
        },
      ),
    );
  }
}

class PageSlide extends StatelessWidget {
  final PageController _pageController = PageController(initialPage: 0);

  PageSlide({super.key});

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
          LoginApiButton(),
        ],
      ),
    );
  }
}

class LoginApiButton extends StatelessWidget {
  const LoginApiButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onPressed: () {},
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
              onPressed: () {
                KakaoLoginApi().signWithKakao();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AfterLogin extends StatelessWidget {
  const AfterLogin({super.key});

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
                onPressed: () {
                  //데베에 전송하고 처음 에 role > !=null 일때 다음페이지로? 아니면 isLogged에서 role 이 null 일때만 이페이지로
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
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

// 로그인 후
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    RepairListPage(),
    RepairListPage(),
    RepairListPage(),
    // ChatPage(),
    // BuildingPage(),
    RepairListPage(),
    // MyPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
