import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/models/chat_model.dart';
import 'package:telo/screens/chat/chat_page.dart';
import 'package:telo/screens/repair/request_refuse_page.dart';
import 'package:telo/services/chat_service.dart';
import 'package:telo/services/member_service.dart';
import 'package:telo/services/repair_request_service.dart';

import '../models/building_model.dart';
import '../models/member_model.dart';
import '../models/repair_request_model.dart';
import '../models/resident_model.dart';
import '../screens/repair/claim_page.dart';
import '../screens/repair/repair_detail_page.dart';
import '../services/building_service.dart';
import '../services/resident_service.dart';

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
                maxWidth: MediaQuery.of(context).size.width * 0.6),
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
      required this.roomID,});

  final RepairRequestMessage requestMessage;
  final bool isMe;
  final String memberType;
  final String roomID;

  @override
  State<RequestMessageBubble> createState() => _RequestMessageBubbleState();
}

class _RequestMessageBubbleState extends State<RequestMessageBubble> {
  final RepairRequestService _requestService = RepairRequestService();

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
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
                      width: 60,
                      height: 60,
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
                    "상세 설명: ${widget.requestMessage.repairRequest.requestContent}",
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
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
                            widget.requestMessage.repairRequest.repairState = RepairState.UNDER_REPAIR;
                            await _chatService.createNoticeMessage(
                                widget.roomID,
                                widget.requestMessage.repairRequest.requestID,
                                'approval');
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
                                    roomID: widget.roomID,),
                              ),
                            );
                            widget.requestMessage.repairRequest.repairState = RepairState.REFUSAL;
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
      required this.roomID,});

  final RepairRequestService _requestService = RepairRequestService();
  final NoticeMessage noticeMessage;
  final bool isMe;
  final String memberType;
  final String roomID;
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
                child:
                Image.network(
                  noticeMessage.repairRequest.imageURL.first,
                  width: 60,
                  height: 60,
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
                                        roomID: roomID,),
                                  ),
                                );
                                noticeMessage.repairRequest.repairState = RepairState.CLAIM;
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
                                        noticeMessage.repairRequest.repairState = RepairState.COMPLETE;
                                        await _chatService.createNoticeMessage(
                                            roomID,
                                            noticeMessage
                                                .repairRequest.requestID,
                                            'complete');
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
  final residentService = ResidentService();
  final chatService = ChatService();
  Member? _other; // 대화 상대
  Resident? _resident; // 계약건
  ChatMessage? _recentMessage;

  @override
  void initState() {
    super.initState();
    _initializeInfo();
  }

  Future<void> _initializeInfo() async {
    try {
      print(widget.memberID);
      final Member other;
      if (widget.chatRoom.tenantID == widget.memberID) {
        other = await memberService.getMember(widget.chatRoom.landlordID);
      } else {
        other = await memberService.getMember(widget.chatRoom.tenantID);
      }

      final residents =
          await residentService.getResidentsByTenantIDAndLandlordID(
              widget.chatRoom.tenantID, widget.chatRoom.landlordID);
      final resident = residents.first;

      final messages =
          await chatService.getChatMessages(widget.chatRoom.roomID);
      final message = messages.last;
      setState(() {
        _other = other;
        _resident = resident;
        _recentMessage = message;
      });
    } catch (e) {
      print('채팅룸 정보 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_other == null || _resident == null || _recentMessage == null) {
      return CircularProgressIndicator();
    }
    return InkWell(
        splashColor: Colors.transparent,
        onTap: () async {
          final recentMessage = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                roomID: widget.chatRoom.roomID,
                memberID: widget.memberID,
              ),
            ),
          );
          if (recentMessage != null) {
            setState(() {
              _recentMessage = recentMessage as ChatMessage?;
            });
          }
        },
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    _other!.profile,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _other!.memberNickName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "${_resident!.buildingName} ${_resident!.apartmentNumber}",
                            style: TextStyle(
                                fontSize: 12.0, color: DARK_MAIN_COLOR),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _recentMessage!.messageType == MessageType.TEXT
                          ? Text(
                              (_recentMessage as TextMessage).message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 12.0, color: GRAY_COLOR),
                            )
                          : _recentMessage!.messageType ==
                                  MessageType.REPAIR_REQUEST
                              ? Text(
                                  "\"${(_recentMessage as RepairRequestMessage).repairRequest.requestTitle}\" 요청이 등록되었습니다.",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12.0, color: GRAY_COLOR),
                                )
                              : _recentMessage!.messageType ==
                                      MessageType.NOTICE
                                  ? Text(
                                      "\"${(_recentMessage as NoticeMessage).repairRequest.requestTitle}\"의 새로운 메시지가 있습니다.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12.0, color: GRAY_COLOR),
                                    )
                                  : Text(
                                      "사진을 보냈습니다.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12.0, color: GRAY_COLOR),
                                    )
                    ],
                  ),
                )
              ],
            )));
  }
}
