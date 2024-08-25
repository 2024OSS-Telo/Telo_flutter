import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../const/backend_url.dart';
import '../models/chat_model.dart';

class ChatWebSocketService {
  late StompClient _stompClient;
  final _messagesController = StreamController<List<TextMessage>>.broadcast();
  List<TextMessage> _messages = [];

  ChatWebSocketService(String roomID) {
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
  }

  Stream<List<TextMessage>> get messagesStream => _messagesController.stream;

  void _onConnect(StompFrame frame) {
    _stompClient.subscribe(
      destination: '/queue/{roomID}',
      callback: (frame) {
        final message = TextMessage.fromJson(jsonDecode(frame.body!));
        _messages.add(message);
        _messagesController.sink.add(_messages);
      },
    );
  }

  void sendTextMessage(TextMessage textMessage) {
    _stompClient.send(
      destination: '/app/chat/${textMessage.roomID}/text',
      body: jsonEncode(textMessage.toJson()),
    );
  }

  void dispose() {
    _stompClient.deactivate();
    _messagesController.close();
  }
}
