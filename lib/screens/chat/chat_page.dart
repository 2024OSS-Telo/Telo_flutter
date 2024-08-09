import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:telo/services/chat_service.dart';

import '../../const/backend_url.dart';
import '../../const/colors.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat_widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.memberID, required this.roomID});

  final String memberID;
  final String roomID;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final chatService = ChatService();

  final _textController = TextEditingController();
  late StompClient _stompClient;
  late List<dynamic> _messages = [];

  String _messageValue = "";

  void _onConnect(StompFrame frame) {
    _stompClient.subscribe(
      destination: '/queue/${widget.roomID}',
      callback: (frame) {
        setState(() {
          _messages.add(TextMessage.fromJson(jsonDecode(frame.body!)));
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: webSocketURL,
        onConnect: _onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );
    _stompClient.activate();
    _initializeMessages();
  }

  Future<void> _initializeMessages() async {
    try {
      final messages = await chatService.getChatMessages(widget.roomID);
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      print('메시지 로딩 오류: $e');
    }
  }

  void _sendTextMessage() {
    final textMessage = TextMessage(
      roomID: widget.roomID,
      senderID: widget.memberID,
      // senderID: '2',
      sendDate: DateTime.now(),
      message: _messageValue,
    );
    try {
      _stompClient.send(
        destination: '/app/chat/${widget.roomID}/text',
        body: jsonEncode(textMessage.toJson()),
      );
      _textController.clear();
    } catch (e) {
      debugPrint("메시지 전송 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
            title: Text('상대 이름'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기
              },
            )),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Column(
                        children: <Widget>[
                          if (message.messageType == MessageType.TEXT)
                            TextMessageBubble(
                              textMessage: message as TextMessage,
                              isMe: message.senderID == widget.memberID,
                            )
                          else if (message.messageType ==
                              MessageType.REPAIR_REQUEST)
                            RequestMessageBubble(
                                requestMessage: message as RepairRequestMessage,
                                isMe: message.senderID == widget.memberID)
                        ],
                      );
                    })),
            Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          maxLines: null,
                          maxLength: 800,
                          controller: _textController,
                          style: TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                              hintText: "채팅을 입력하세요.",
                              hintStyle: TextStyle(color: LIGHT_GRAY_COLOR),
                              counterText: '',
                              contentPadding: EdgeInsets.all(10),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: LIGHT_GRAY_COLOR,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: LIGHT_GRAY_COLOR,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              )),
                          onChanged: (value) {
                            setState(() {
                              _messageValue = value;
                            });
                          }),
                    ),
                    IconButton(
                      onPressed: _messageValue.trim().isEmpty
                          ? null
                          : _sendTextMessage,
                      icon: Icon(Icons.send),
                    )
                  ],
                ))
          ],
        ));
  }
}
