class ChatItem {
  final bool isRoom;
  final String name;
  final String? messageWithPrefix;
  final DateTime createdAt;
  final String? email;
  final String? userId;
  final String? roomId;
  final bool unread;

  DateTime? lastSeen;
  bool isOnline;

  //final bool isUnread;

  ChatItem({
    required this.isRoom,
    required this.name,
    this.messageWithPrefix,
    required this.createdAt,
    this.email,
    this.userId,
    this.roomId,
    required this.unread,
    this.lastSeen,
    this.isOnline = false,
    // this.isUnread = false,
  });

  void updateOnlineStatus(bool online) {
    isOnline = online;
    if (online) {
      lastSeen = DateTime.now();
    }
  }

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      isRoom: json['isRoom'] ?? false,
      name: json['name'] ?? '',
      messageWithPrefix: json['messageWithPrefix'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      email: json['email'],
      userId: json['user_id'],
      roomId: json['room_id'],
      unread: json['unread'] ?? false,
    );
  }


  ChatItem copyWith({
    bool? isRoom,
    String? name,
    String? messageWithPrefix,
    DateTime? createdAt,
    String? email,
    String? userId,
    String? roomId,
    bool? unread,
    DateTime? lastSeen,
    bool? isOnline,
    // bool? isUnread
  }) {
    return ChatItem(
      isRoom: isRoom ?? this.isRoom,
      name: name ?? this.name,
      messageWithPrefix: messageWithPrefix ?? this.messageWithPrefix,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      unread: unread ?? this.unread,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      // isUnread: isUnread ?? this.isUnread,
    );
  }
}