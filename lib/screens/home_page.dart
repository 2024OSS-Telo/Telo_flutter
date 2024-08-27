import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/main.dart';
import 'package:telo/main.dart';
import 'package:telo/screens/notification_page.dart';
import 'package:telo/screens/repair/repair_list_page.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onSignOut;

  const HomePage({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: HeaderHome(),
          body: BodyHome(onSignOut: onSignOut)
        )
    );
  }
}

class HeaderHome extends StatelessWidget implements PreferredSizeWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MAIN_COLOR,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: GestureDetector(
            onTap: () {
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
  final VoidCallback onSignOut;

  const BodyHome({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Container(
            color: MAIN_COLOR,


            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.logout),
                color: Colors.white,
                onPressed: onSignOut,
              ),
            ),

          ),
        ),
        Flexible(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  color: MAIN_COLOR,
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
