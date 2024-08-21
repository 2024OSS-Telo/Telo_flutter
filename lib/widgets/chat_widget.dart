import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/models/chat_model.dart';
import 'package:telo/screens/chat/chat_page.dart';
import 'package:telo/screens/repair/request_refuse_page.dart';
import 'package:telo/services/chat_service.dart';
import 'package:telo/services/member_service.dart';
import 'package:telo/services/repair_request_service.dart';

import '../models/member_model.dart';
import '../models/repair_request_model.dart';
import '../screens/repair/claim_page.dart';
import '../screens/repair/repair_detail_page.dart';

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
            borderRadius: BorderRadius.circular(15),
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

class RequestMessageBubble extends StatefulWidget {
  RequestMessageBubble(
      {super.key,
      required this.requestMessage,
      required this.isMe,
      required this.memberType,
      required this.roomID,
      required this.onUpdate});

  final RepairRequestMessage requestMessage;
  final bool isMe;
  final String memberType;
  final String roomID;
  final VoidCallback onUpdate;

  @override
  State<RequestMessageBubble> createState() => _RequestMessageBubbleState();
}

class _RequestMessageBubbleState extends State<RequestMessageBubble> {
  final RepairRequestService _requestService = RepairRequestService();

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    int contentLength =
        widget.requestMessage.repairRequest.requestContent.length;
    contentLength >= 50 ? contentLength = 49 : contentLength--;
    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        widget.isMe
            ? Text(
                widget.requestMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12),
              )
            : SizedBox(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepairDetailPage(
                    repairRequest: widget.requestMessage.repairRequest),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: LIGHT_GRAY_COLOR),
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
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
                      widget.requestMessage.repairRequest.imageURL.first,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    "제목: ${widget.requestMessage.repairRequest.requestTitle}",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "상세 설명: ${widget.requestMessage.repairRequest.requestContent.substring(0, contentLength)}···",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "예상 금액: ${widget.requestMessage.repairRequest.estimatedValue.toString()}원",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  if (widget.memberType == 'landlord' &&
                      widget.requestMessage.repairRequest.repairState ==
                          RepairState.NONE)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 7),
                            backgroundColor: MAIN_COLOR,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            await _requestService.updateRepairState(
                                widget.requestMessage.repairRequest.requestID,
                                RepairState.UNDER_REPAIR);
                            await _chatService.createNoticeMessage(
                                widget.roomID,
                                widget.requestMessage.repairRequest.requestID,
                                'approval');
                            widget.onUpdate();
                          },
                          child: Text("승인",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                        SizedBox(width: 15),
                        TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 7),
                            backgroundColor: Color(0xffB3B3B3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestRefusePage(
                                    repairRequest:
                                        widget.requestMessage.repairRequest,
                                    roomID: widget.roomID,
                                    onUpdate: widget.onUpdate),
                              ),
                            );
                          },
                          child: Text("거절",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        widget.isMe
            ? SizedBox()
            : Text(
                widget.requestMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12),
              ),
      ],
    );
  }
}

class NoticeMessageBubble extends StatelessWidget {
  NoticeMessageBubble(
      {super.key,
      required this.noticeMessage,
      required this.isMe,
      required this.memberType,
      required this.roomID,
      required this.onUpdate});

  final RepairRequestService _requestService = RepairRequestService();
  final NoticeMessage noticeMessage;
  final bool isMe;
  final String memberType;
  final String roomID;
  final VoidCallback onUpdate;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final String noticeType = noticeMessage.noticeType;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isMe
            ? Text(
                noticeMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12),
              )
            : SizedBox(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: LIGHT_GRAY_COLOR),
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Image.network(
                  noticeMessage.repairRequest.imageURL.first,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              noticeType == 'approval'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\"${noticeMessage.repairRequest.requestTitle}\" 요청이 승인되었습니다.",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (memberType == 'tenant' &&
                            noticeMessage.repairRequest.repairState ==
                                RepairState.UNDER_REPAIR)
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 5),
                                backgroundColor: MAIN_COLOR,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClaimPage(
                                        requestID: noticeMessage
                                            .repairRequest.requestID,
                                        roomID: roomID,
                                        onUpdate: onUpdate),
                                  ),
                                );
                              },
                              child: Text("수리 완료 및 청구하기",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
                            ),
                          )
                      ],
                    )
                  : noticeType == 'refusal'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "\"${noticeMessage.repairRequest.requestTitle}\" 요청이 거절되었습니다.",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "사유: ${noticeMessage.repairRequest.refusalReason}",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      : noticeType == 'claim'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\"${noticeMessage.repairRequest.requestTitle}\"의 수리 비용이 청구되었습니다.",
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "청구 금액: ${noticeMessage.repairRequest.actualValue}원",
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 10),
                                if (memberType == 'landlord' &&
                                    noticeMessage.repairRequest.repairState ==
                                        RepairState.CLAIM)
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 5),
                                        backgroundColor: MAIN_COLOR,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await _requestService.updateRepairState(
                                            noticeMessage
                                                .repairRequest.requestID,
                                            RepairState.COMPLETE);
                                        await _chatService.createNoticeMessage(
                                            roomID,
                                            noticeMessage
                                                .repairRequest.requestID,
                                            'approval');
                                        onUpdate();
                                      },
                                      child: Text("송금 완료",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ),
                                  )
                              ],
                            )
                          : Text(
                              "\"${noticeMessage.repairRequest.requestTitle}\" 요청이 완료되었습니다.",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
            ]),
          ),
        ),
        isMe
            ? SizedBox()
            : Text(
                noticeMessage.sendDate.toString().substring(11, 16),
                style: TextStyle(fontSize: 12),
              ),
      ],
    );
  }
}

class ChatRoomCard extends StatefulWidget {
  const ChatRoomCard(
      {super.key, required this.chatRoom, required this.memberID});

  final ChatRoom chatRoom;
  final String memberID;

  @override
  State<ChatRoomCard> createState() => _ChatRoomCardState();
}

class _ChatRoomCardState extends State<ChatRoomCard> {
  final memberService = MemberService();
  late Member _member;

  @override
  void initState() {
    super.initState();
    _getMember();
  }

  Future<void> _getMember() async {
    try {
      final member = await memberService.getMember(widget.memberID);
      setState(() {
        _member = member;
      });
    } catch (e) {
      print('멤버 정보 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              roomID: widget.chatRoom.roomID,
              memberID: widget.memberID,
            ),
          ),
        );
      },
      child: Column(

      )
    );
  }
}
