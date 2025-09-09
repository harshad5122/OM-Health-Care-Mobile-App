class ChatUserResponse {
  final int success;
  final int code;
  final String msg;
  final List<ChatUser> body;

  ChatUserResponse({
    required this.success,
    required this.code,
    required this.msg,
    required this.body,
  });

  factory ChatUserResponse.fromJson(Map<String, dynamic> json) {
    return ChatUserResponse(
      success: json['success'] ?? 0,
      code: json['code'] ?? 0,
      msg: json['msg'] ?? "",
      body: (json['body'] as List<dynamic>?)
          ?.map((e) => ChatUser.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "code": code,
      "msg": msg,
      "body": body.map((e) => e.toJson()).toList(),
    };
  }
}

class ChatUser {
  final String userId;
  final String name;
  final String email;
  final int role;
  final bool isOnline;
  final LastMessage? lastMessage;
  final String messagePreview;
  final int unreadCount;

  ChatUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isOnline,
    this.lastMessage,
    required this.messagePreview,
    required this.unreadCount,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      userId: json['user_id'] ?? "",
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      role: json['role'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
      messagePreview: json['messagePreview'] ?? "",
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "name": name,
      "email": email,
      "role": role,
      "isOnline": isOnline,
      "last_message": lastMessage?.toJson(),
      "messagePreview": messagePreview,
      "unreadCount": unreadCount,
    };
  }
}

class LastMessage {
  final String? text;
  final String? type;
  final DateTime? createdAt;
  final String? senderId;

  LastMessage({
    this.text,
    this.type,
    this.createdAt,
    this.senderId,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      text: json['text'],
      type: json['type'],
      createdAt:
      json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      senderId: json['sender_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "type": type,
      "created_at": createdAt?.toIso8601String(),
      "sender_id": senderId,
    };
  }
}
