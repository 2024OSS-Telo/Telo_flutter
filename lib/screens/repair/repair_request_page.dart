import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home_page.dart';

class RepairRequestPage extends StatelessWidget {
  const RepairRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,
            title: Text("수리 요청하기"),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context); //뒤로가기
              },
            )
        ),
      body: Container(),
    ));
  }
}

