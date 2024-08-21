import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/services/chat_service.dart';
import 'package:telo/widgets/chat_widget.dart';

import '../../models/chat_model.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  final String memberID = '1';

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
      final chatRooms = _chatService.getChatRoomList(widget.memberID);
      setState(() {
        _chatRooms = _chatRooms.reversed.toList();
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
      body:  Column(
        children: [
          Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
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
