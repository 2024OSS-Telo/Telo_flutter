import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/repair/repair_request_page.dart';
import 'package:telo/services/repair_request_service.dart';

import '../../models/repair_request_model.dart';
import '../../widgets/repair_request_widget.dart';

class RepairListPage extends StatefulWidget {
  const RepairListPage({super.key});

  final String memberID = '2';

  @override
  State<RepairListPage> createState() => _RepairListPageState();
}

class _RepairListPageState extends State<RepairListPage> {
  final repairRequestService = RepairRequestService();
  late List<RepairRequest> _repairRequests = [];

  @override
  void initState(){
    super.initState();
    _initializeRequests();
  }

  Future<void> _initializeRequests() async {
    try {
      final repairRequests = await repairRequestService.getRepairRequestList(widget.memberID);
      setState(() {
        _repairRequests = repairRequests;
      });
    } catch (e) {
      print('수리 요청 목록 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("수리 요청 목록"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _repairRequests.length,
                  itemBuilder: (context, index) {
                    final repairRequest = _repairRequests[index];
                    return Column(
                      children: <Widget>[
                        RepairRequestWidget(
                          repairRequest: repairRequest,
                        )
                      ],
                    );
                  })),
        ],
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
