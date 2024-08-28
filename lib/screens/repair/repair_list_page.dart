import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/screens/repair/repair_request_page.dart';
import 'package:telo/services/repair_request_service.dart';

import '../../models/repair_request_model.dart';
import '../../provider/repair_request_provider.dart';
import '../../services/member_service.dart';
import '../../widgets/repair_request_widget.dart';

class RepairListPage extends StatefulWidget {
  const RepairListPage({super.key});

  @override
  State<RepairListPage> createState() => _RepairListPageState();
}

class _RepairListPageState extends State<RepairListPage> {
  final memberService = MemberService();
  late String memberID;
  late String memberType = "";
  late RepairRequestProvider repairRequestProvider;

  @override
  void initState() {
    super.initState();
    _initializeMember();
  }

  Future<void> _initializeMember() async {
    try {
      memberID = await memberService.findMemberID();
      final _member = await memberService.getMember(memberID);

      repairRequestProvider =
          Provider.of<RepairRequestProvider>(context, listen: false);

      setState(() {
        memberType = _member.memberType;
      });
      await repairRequestProvider.initializeData(memberID);
    } catch (e) {
      print('수리 요청 목록 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text("수리 요청 목록"),
          ),
          body: Consumer<RepairRequestProvider>(
              builder: (context, repairRequestProvider, child) {
            final repairRequests = repairRequestProvider.repairRequests.reversed.toList();

            if (repairRequests.isEmpty) {
              return Align(
                  alignment: Alignment.center,
                  child: Text(
                    "아직 수리 요청이 없습니다.",
                    style: TextStyle(
                      color: GRAY_COLOR,
                      fontSize: 12.0,
                    ),
                  ));
            }

            return Column(
              children: [
                Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: repairRequests.length,
                        itemBuilder: (context, index) {
                          final repairRequest = repairRequests[index];
                          return Column(
                            children: <Widget>[
                              RepairRequestCard(
                                key: ValueKey(repairRequest.requestID),
                                repairRequest: repairRequest,
                              )
                            ],
                          );
                        })),
              ],
            );
          }),
          floatingActionButton: memberType == 'tenant'
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepairRequestPage(
                            onUpdate: () async {
                              final repairRequestProvider =
                                  Provider.of<RepairRequestProvider>(context,
                                      listen: false);
                              await repairRequestProvider
                                  .initializeData(memberID);
                            },
                          ),
                        ));
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: MAIN_COLOR,
                  child: const Icon(
                    color: Colors.white,
                    Icons.add,
                    size: 30,
                  ),
                )
              : null,
        ));
  }
}
