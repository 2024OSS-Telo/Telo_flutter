import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/repair/repair_request_page.dart';

class RepairListPage extends StatelessWidget {
  const RepairListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("수리 요청 목록"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RepairRequestPage()),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: MAIN_COLOR,
        child: const Icon(
          color: Colors.white,
          Icons.add,
          size: 30,
        ),
      ),
    ));
  }
}
