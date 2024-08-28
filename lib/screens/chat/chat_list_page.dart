import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/services/chat_service.dart';
import 'package:telo/services/member_service.dart';
import 'package:telo/widgets/chat_widget.dart';

import '../../const/colors.dart';
import '../../models/chat_model.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  final MemberService _memberService = MemberService();
  late List<dynamic> _chatRooms = [];

  late String memberID;

  @override
  void initState() {
    super.initState();
    _initializeChatRooms();
  }

  Future<void> _initializeChatRooms() async {
    try {
      memberID = await _memberService.findMemberID();
      final chatRooms = await _chatService.getChatRoomList(memberID);
      setState(() {
        _chatRooms = chatRooms.reversed.toList();
      });
    } catch (e) {
      print('채팅룸 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("채팅"),
        automaticallyImplyLeading: false,
      ),
      body: _chatRooms.isEmpty
          ? Align(
              alignment: Alignment.center,
              child: Text(
                "아직 채팅이 없습니다.",
                style: TextStyle(
                  color: GRAY_COLOR,
                  fontSize: 12.0,
                ),
              ))
          : Column(
              children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: _chatRooms.length,
                        itemBuilder: (context, index) {
                          final chatRoom = _chatRooms[index];
                          return Column(
                            children: <Widget>[
                              ChatRoomCard(
                                memberID: memberID,
                                chatRoom: chatRoom,
                              )
                            ],
                          );
                        })),
              ],
            ),
    );
  }
}
