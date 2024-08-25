import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/services/chat_service.dart';
import 'package:telo/widgets/chat_widget.dart';

import '../../models/chat_model.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  //TODO: 아이디 바꾸기
  final String memberID = 'TestID';

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  late List<dynamic> _chatRooms = [];

  @override
  void initState() {
    super.initState();
    _initializeChatRooms();
  }

  Future<void> _initializeChatRooms() async {
    try {
      final chatRooms = await _chatService.getChatRoomList(widget.memberID);
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
      ),
      body: _chatRooms.isEmpty
          ? Align(
              alignment: Alignment.center,
              child: Text(
                "아직 채팅이 없습니다.",
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
                                memberID: widget.memberID,
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
