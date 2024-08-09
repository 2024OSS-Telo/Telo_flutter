import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telo/services/chat_service.dart';

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
  late Future<List<ChatRoom>> _chatRooms;

  @override
  void initState() {
    super.initState();
    _chatRooms = _chatService.getChatRoomList(widget.memberID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("채팅"),
      ),
      body: FutureBuilder<List<ChatRoom>>(
        future: _chatRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('채팅을 가져오지 못했습니다.: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('아직 채팅이 없습니다.'));
          } else {
            final chatRooms = snapshot.data!;
            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                return ListTile(
                  title: Text('Room ID: ${chatRoom.roomID}'),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          memberID: widget.memberID,
                          roomID: chatRoom.roomID,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
