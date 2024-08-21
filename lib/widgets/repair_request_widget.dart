import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/models/repair_request_model.dart';

import '../const/colors.dart';
import '../screens/repair/repair_detail_page.dart';

class RepairRequestCard extends StatefulWidget {
  const RepairRequestCard({super.key, required this.repairRequest});

  final RepairRequest repairRequest;

  @override
  State<RepairRequestCard> createState() => _RepairRequestCardState();
}

class _RepairRequestCardState extends State<RepairRequestCard> {
  @override
  Widget build(BuildContext context) {
    int contentLength = widget.repairRequest.requestContent.length;
    contentLength >= 50 ? contentLength = 49 : contentLength--;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RepairDetailPage(repairRequest: widget.repairRequest),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
            border: Border.all(color: LIGHT_GRAY_COLOR),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.repairRequest.requestTitle,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            widget.repairRequest.createdDate
                                .toString()
                                .substring(0, 10),
                            style: TextStyle(fontSize: 11, color: GRAY_COLOR),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${widget.repairRequest.requestContent.substring(0, contentLength)}···",
                        style: TextStyle(color: GRAY_COLOR),
                          softWrap: true
                      )
                    ],
                  ),
                ),
                // Image.network(
                //   widget.repairRequest.imageURL.first,
                //   width: 70,
                //   height: 70,
                //   fit: BoxFit.cover,
                // ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            PrograssBar(repairState: widget.repairRequest.repairState)
          ],
        ),
      ),
    );
  }
}

class PrograssBar extends StatefulWidget {
  const PrograssBar({super.key, required this.repairState});

  final RepairState repairState;

  @override
  State<PrograssBar> createState() => _PrograssBarState();
}

class _PrograssBarState extends State<PrograssBar> {
  late List<String> stepStatus;
  late List<bool> lineStatus;

  @override
  void initState() {
    super.initState();
    switch (widget.repairState) {
      case RepairState.NONE:
        stepStatus = ['inProgress', 'notStarted', 'notStarted', 'notStarted'];
        lineStatus = [false, false, false];
        break;
      case RepairState.UNDER_REPAIR:
        stepStatus = ['completed', 'inProgress', 'notStarted', 'notStarted'];
        lineStatus = [true, false, false];
        break;
      case RepairState.CLAIM:
        stepStatus = ['completed', 'completed', 'inProgress', 'notStarted'];
        lineStatus = [true, true, false];
        break;
      case RepairState.COMPLETE:
        stepStatus = ['completed', 'completed', 'completed', 'completed'];
        lineStatus = [true, true, true];
        break;
      case RepairState.REFUSAL:
        stepStatus = ['completed', 'notStarted', 'notStarted', 'notStarted'];
        lineStatus = [false, false, false];
        break;
      default:
        stepStatus = ['notStarted', 'notStarted', 'notStarted', 'notStarted'];
        lineStatus = [false, false, false];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              widget.repairState == RepairState.REFUSAL
                  ? _buildStep(context, stepStatus[0])
                  : _buildStep(context, stepStatus[0]),
              _buildLine(context, lineStatus[0]),
              _buildStep(context, stepStatus[1]),
              _buildLine(context, lineStatus[1]),
              _buildStep(context, stepStatus[2]),
              _buildLine(context, lineStatus[2]),
              _buildStep(context, stepStatus[3]),
            ],
          ),
          Row(
            children: [
              Text(widget.repairState == RepairState.REFUSAL ? '거절' : '승인'),
              SizedBox(width:5),
              Spacer(flex: 1),
              Text('수리중'),
              Spacer(flex: 1),
              Text('청구중'),
              Spacer(flex: 1),
              Text('완료'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String status) {
    return status == 'completed'
        ? Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: DARK_GRAY_COLOR,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.repairState == RepairState.REFUSAL ? Icons.close : status == 'completed' ? Icons.done : null,
              color: Colors.white,
              size: 20,
            ),
          )
        : status == 'inProgress'
            ? Stack(alignment: Alignment.center, children: [
                Container(
                  decoration: BoxDecoration(
                    color: MAIN_COLOR.withOpacity(.6),
                    shape: BoxShape.circle,
                  ),
                  width: 25,
                  height: 25,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: MAIN_COLOR,
                    shape: BoxShape.circle,
                  ),
                  width: 15,
                  height: 15,
                ),
              ])
            : Container(
                decoration: BoxDecoration(
                  color: LIGHT_GRAY_COLOR,
                  shape: BoxShape.circle,
                ),
      width: 15,
      height: 15,
              );
  }

  Widget _buildLine(BuildContext context, bool status) {
    return Expanded(
      child: Container(
        height: status ? 2 : 1,
        color: status ? Colors.black : LIGHT_GRAY_COLOR,
      ),
    );
  }
}
