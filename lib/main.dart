import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:telo/screens/home_page.dart';
import 'package:telo/screens/notification_page.dart';
import 'package:telo/screens/repair/repair_list_page.dart';

void main() {
  runApp(const MaterialApp(
    // home: MyApp(),
    home: MainPage()
  ));
}

// 로그인 전
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _PageSlideState();
}

class _PageSlideState extends State<MyApp> {
  final PageController _pageController = PageController(initialPage: 0);

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
                  dotColor: Colors.black38
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: (){}, child: Text('구글 로그인', textAlign: TextAlign.center,)),
              TextButton(onPressed: (){}, child: Text('카카오톡 로그인'))
            ],
          )
        ],

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