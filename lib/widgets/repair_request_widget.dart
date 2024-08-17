import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/models/repair_request_model.dart';

import '../const/colors.dart';
import '../screens/repair/repair_detail_page.dart';

class RepairRequestWidget extends StatelessWidget {
  const RepairRequestWidget({super.key, required this.repairRequest});

  final RepairRequest repairRequest;

  @override
  Widget build(BuildContext context) {
    int contentLength = repairRequest.requestContent.length;
    contentLength >= 20 ? contentLength = 19 : contentLength--;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RepairDetailPage(repairRequest: repairRequest),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
            border: Border.all(color: LIGHT_GRAY_COLOR),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text(repairRequest.requestTitle, style: TextStyle(
                          fontSize: 15,

                        ),),
                        SizedBox(width: 20,),
                        Text(
                          repairRequest.createdDate.toString().substring(0, 10),
                          style: TextStyle(
                              fontSize: 11,
                              color: GRAY_COLOR
                          ),)
                      ],
                    ),
                    Text("${repairRequest.requestContent.substring(
                        0, contentLength)}···")
                  ],
                ),
                // Image.network(
                //   repairRequest.imageURL.first,
                //   width: 70,
                //   height: 70,
                //   fit: BoxFit.cover,
                // ),
              ],
            ),
            PrograssBar(repairState: repairRequest.repairState)
          ],
        ),
      ),
    );
  }
}

class PrograssBar extends StatelessWidget {
  const PrograssBar({super.key, required this.repairState});

  final RepairState repairState;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(context, '승인', _isApproved(repairState), true),
        _buildLine(context, _isApproved(repairState)),
        _buildStep(context, '수리중', _isUnderRepair(repairState),
            _isApproved(repairState)),
        _buildLine(context, _isUnderRepair(repairState)),
        _buildStep(context, '금액 청구중', _isClaiming(repairState),
            _isUnderRepair(repairState)),
        _buildLine(context, _isClaiming(repairState)),
        _buildStep(
            context, '완료', _isCompleted(repairState), _isClaiming(repairState)),
      ],
    );
  }

  bool _isApproved(RepairState state) {
    return state != RepairState.NONE;
  }

  bool _isUnderRepair(RepairState state) {
    return state == RepairState.UNDER_REPAIR || state == RepairState.CLAIM ||
        state == RepairState.COMPLETE;
  }

  bool _isClaiming(RepairState state) {
    return state == RepairState.CLAIM || state == RepairState.COMPLETE;
  }

  bool _isCompleted(RepairState state) {
    return state == RepairState.COMPLETE;
  }

  Widget _buildStep(BuildContext context, String title, bool isCompleted,
      bool previousCompleted) {
    return Column(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.black : previousCompleted
              ? Colors.green
              : Colors.grey,
          size: 25,
        ),
        Text(title,
            style: TextStyle(color: isCompleted ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildLine(BuildContext context, bool isCompleted) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        height: 2,
        color: isCompleted ? Colors.black : Colors.grey,
      ),
    );
  }
}
