import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:telo/screens/home_page.dart';
import 'package:telo/screens/notification_page.dart';
import 'package:telo/screens/repair/repair_list_page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'const/login_platform.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '7175c6f048b50e0a135ab044f8f3155e');

  runApp(const MaterialApp(
    home: MyApp(),
    //home: MainPage()
    //home: AfterLogin(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool isKakaoLoggedIn = await AuthApi.instance.hasToken();
    bool isGoogleLoggedIn = await GoogleSignIn().isSignedIn();

    if (isKakaoLoggedIn) {
      setState(() {
        _loginPlatform = LoginPlatform.kakao;
      });
    } else if (isGoogleLoggedIn) {
      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
    }
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
    }
  }

  void signInWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        setState(() {
          _loginPlatform = LoginPlatform.kakao;
        });
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
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loginPlatform == LoginPlatform.none) {
      return PageSlide(
        onGoogleSignIn: signInWithGoogle,
        onKakaoSignIn: signInWithKakao,
      );
    } else {
      bool userInfoExists = false;
      // bool userInfoExists = await checkUserInfoExists();
      if (!userInfoExists) {
        return AfterLogin(onSignOut: signOut);
      } else {
        return MainPage(onSignOut: signOut);
      }
    }
  }

  Future<bool> checkUserInfoExists() async {
    return true;
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

  const AfterLogin({super.key, required this.onSignOut});

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
                    MaterialPageRoute(builder: (context) => MainPage(onSignOut: onSignOut)),
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
                    MaterialPageRoute(builder: (context) => MainPage(onSignOut: onSignOut)),
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

  const MainPage({Key? key, required this.onSignOut}) : super(key: key);

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
