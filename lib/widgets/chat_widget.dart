import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/models/chat_model.dart';
import 'package:telo/services/repair_request_service.dart';

import '../models/repair_request_model.dart';
import '../screens/repair/claim_page.dart';

class TextMessageBubble extends StatelessWidget {
  const TextMessageBubble(
      {super.key, required this.textMessage, required this.isMe});

  final TextMessage textMessage;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isMe
            ? Text(
                textMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12),
              )
            : SizedBox(),
        Container(
          decoration: BoxDecoration(
            border: isMe
                ? Border.all(color: MAIN_COLOR)
                : Border.all(color: LIGHT_GRAY_COLOR),
            color: isMe ? MAIN_COLOR : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            child: Text(
              textMessage.message,
              style: TextStyle(
                  fontSize: 15, color: isMe ? Colors.white : Colors.black),
            ),
          ),
        ),
        isMe
            ? SizedBox()
            : Text(textMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12))
      ],
    );
  }
}

class PhotoMessageBubble extends StatelessWidget {
  const PhotoMessageBubble({super.key, required this.photoMessage});

  final PhotoMessage photoMessage;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class RequestMessageBubble extends StatelessWidget {
  RequestMessageBubble(
      {super.key,
      required this.requestMessage,
      required this.isMe,
      required this.memberType});

  final RepairRequestService _requestService = RepairRequestService();
  final RepairRequestMessage requestMessage;
  final bool isMe;
  final String memberType;

  @override
  Widget build(BuildContext context) {
    int contentLength = requestMessage.repairRequest.requestContent.length;
    contentLength >= 30 ? contentLength = 29 : contentLength--;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isMe
            ? Text(
                requestMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12),
              )
            : SizedBox(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: LIGHT_GRAY_COLOR),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.network(
                    requestMessage.repairRequest.imageURL.first,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  "제목: ${requestMessage.repairRequest.requestTitle}",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "상세 설명: ${requestMessage.repairRequest.requestContent.substring(0, contentLength)}···",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "예상 금액: ${requestMessage.repairRequest.estimatedValue.toString()}원",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                if (memberType == 'landlord' &&
                    requestMessage.repairRequest.repairState ==
                        RepairState.NONE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: Size(10, 8),
                          backgroundColor: MAIN_COLOR,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          _requestService.updateRepairState(
                              requestMessage.repairRequest.requestID,
                              RepairState.UNDER_REPAIR);
                        },
                        child: Text("승인"),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: Size(10, 8),
                          backgroundColor: MAIN_COLOR,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          _requestService.updateRepairState(
                              requestMessage.repairRequest.requestID,
                              RepairState.REFUSAL);
                        },
                        child: Text("거절"),
                      ),
                    ],
                  ),
                if (memberType == 'tenant' &&
                    requestMessage.repairRequest.repairState ==
                        RepairState.UNDER_REPAIR)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: Size(10, 8),
                          backgroundColor: MAIN_COLOR,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClaimPage(
                                requestID:
                                    requestMessage.repairRequest.requestID,
                              ),
                            ),
                          );
                        },
                        child: Text("청구하기"),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
        isMe
            ? SizedBox()
            : Text(
                requestMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12),
              ),
      ],
    );
  }
}
