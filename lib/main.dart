import 'package:flutter/material.dart';
import 'package:telo/screens/notification_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: HeaderHome(),
      body: BodyHome(),
      bottomNavigationBar: BottomHome(),
    ));
  }
}

class HeaderHome extends StatelessWidget implements PreferredSizeWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xff93A98D),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            child: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}



class BodyHome extends StatelessWidget {
  const BodyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Container(
              color: Color(0xff93A98D),
              ),
        ),
        Flexible(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  color: Color(0xff93A98D),
                ),
                Container(
                    decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                )),
              ],
            )),
      ],
    );
  }
}

class BottomHome extends StatelessWidget {
  const BottomHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    color: Color(0xff757575),
                  ),
                  Text('홈')
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble, color: Color(0xff757575)),
                  Text('채팅')
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apartment, color: Color(0xff757575)),
                  Text('건물')
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build, color: Color(0xff757575)),
                  Text('수리요청')
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: Color(0xff757575)),
                  Text('내정보')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
