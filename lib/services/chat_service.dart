import 'package:dio/dio.dart';
import 'package:telo/models/repair_request_model.dart';

import '../const/backend_url.dart';
import '../models/chat_model.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(baseUrl: backendURL));

  Future<List<ChatRoom>> getChatRoomList(String memberID) async {
    try {
      final response = await _dio.get('/api/chat/rooms/$memberID');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception("채팅룸 로딩 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("채팅룸 로딩 실패: $e");
    }
  }

  Future<List<ChatMessage>> getChatMessages(String roomID) async {
    try {
      final response = await _dio.get('/api/chat/$roomID/messages');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception("채팅 메시지 로딩 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("채팅 메시지 로딩 실패: $e");
    }
  }

  Future<void> createNoticeMessage(String roomID, String requestID, String noticeType) async {
    try {
      final response = await _dio.post('/api/chat/$roomID/create-notice',
          data: {
            'requestID': requestID,
            'noticeType': noticeType,
          });
    } catch (e) {
      print('Error: $e');
      throw Exception("알림 메시지 생성 실패: $e");
    }
  }

}