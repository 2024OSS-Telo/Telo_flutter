import 'package:telo/models/repair_request_model.dart';

enum MessageType { TEXT, REPAIR_REQUEST, PHOTO }

class ChatMessage {
  final String roomID;
  final String senderID;
  final DateTime sendDate;
  final MessageType messageType;

  ChatMessage({required this.roomID,
    required this.senderID,
    required this.sendDate,
    required this.messageType});

  Map<String, dynamic> toJson() {
    return {
      'roomID': roomID,
      'senderID': senderID,
      'sendDate': sendDate.toIso8601String(),
      'messageType': messageType
          .toString()
          .split('.')
          .last,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final messageTypeString = json['messageType'] as String;
    final messageType = MessageType.values.firstWhere(
          (e) => e.toString().split('.').last == messageTypeString,
    );

    switch (messageType) {
      case MessageType.TEXT:
        return TextMessage.fromJson(json);
      case MessageType.PHOTO:
        return PhotoMessage.fromJson(json);
      case MessageType.REPAIR_REQUEST:
        return RepairRequestMessage.fromJson(json);
      default:
        throw Exception("message type 오류: $messageTypeString");
    }
  }
}

class TextMessage extends ChatMessage {
  final String message;

  TextMessage({
    required String roomID,
    required String senderID,
    required DateTime sendDate,
    required this.message,
  }) : super(
      roomID: roomID,
      senderID: senderID,
      sendDate: sendDate,
      messageType: MessageType.TEXT);

  factory TextMessage.fromJson(Map<String, dynamic> json) {
    return TextMessage(
      roomID: json['roomID'],
      senderID: json['senderID'],
      sendDate: DateTime.parse(json['sendDate']),
      message: json['message'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['message'] = message;
    return json;
  }
}

class PhotoMessage extends ChatMessage {
  final String imageURL;

  PhotoMessage({required String roomID,
    required String senderID,
    required DateTime sendDate,
    required this.imageURL})
      : super(
      roomID: roomID,
      senderID: senderID,
      sendDate: sendDate,
      messageType: MessageType.PHOTO);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['imageURL'] = imageURL;
    return json;
  }

  factory PhotoMessage.fromJson(Map<String, dynamic> json) {
    return PhotoMessage(
      roomID: json['roomID'],
      senderID: json['senderID'],
      sendDate: DateTime.parse(json['sendDate']),
      imageURL: json['imageURL'],
    );
  }
}

class RepairRequestMessage extends ChatMessage {
  final RepairRequest repairRequest;

  RepairRequestMessage({required String roomID,
    required String senderID,
    required DateTime sendDate,
    required this.repairRequest})
      : super(
      roomID: roomID,
      senderID: senderID,
      sendDate: sendDate,
      messageType: MessageType.REPAIR_REQUEST);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['repairRequest'] = repairRequest.toJson();
    return json;
  }

  factory RepairRequestMessage.fromJson(Map<String, dynamic> json) {
    return RepairRequestMessage(
      roomID: json['roomID'],
      senderID: json['senderID'],
      sendDate: DateTime.parse(json['sendDate']),
      repairRequest: RepairRequest.fromJson(json['repairRequest']),
    );
  }
}

class ChatRoom {
  final String roomID;
  final String landlordID;
  final String tenantID;

  ChatRoom(
      {required this.roomID, required this.landlordID, required this.tenantID});

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomID: json['roomID'] as String,
      landlordID: json['landlordID'] as String,
      tenantID: json['tenantID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomID': roomID,
      'landlordID': landlordID,
      'tenantID': tenantID,
    };
  }
}
