import 'package:om_health_care_app/app/data/models/upload_file_model.dart';
import 'package:om_health_care_app/app/data/models/user_detail_model.dart';

class MessageModel {
  final String? messageId;
  final String? senderId;
  final String? receiverId;
  final String? message;
  final List<String>? attachmentId;
  final List<UploadFile>? attachmentDetails;
  List<UserDetails>? senderDetails;
  final List<UserDetails>? receiverDetails;
  final String? roomId;
  final String? messageType;
  final double? latitude;
  final double? longitude;
  final MessageModel? replyTo;
  String messageStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dateTime;
  final bool isDeleted;
  final int status;
  final MessageModel? replyToDetails;
  final String? localFilePath;
  final bool isEdited;
  final bool isRead;
  final String? broadcastId;


  MessageModel({
    this.messageId,
    this.senderId,
    this.receiverId,
    this.message,
    this.attachmentId,
    this.attachmentDetails,
    this.receiverDetails,
    this.senderDetails,
    this.roomId,
    this.messageType,
    this.latitude,
    this.longitude,
    this.replyTo,
    required this.messageStatus,
    required dynamic createdAt,
    required this.updatedAt,
    this.dateTime,
    this.isDeleted = false,
    this.status = 1,
    this.replyToDetails,
    this.localFilePath,
    this.isEdited = false,
    this.isRead = false,
    this.broadcastId,
  }) : createdAt = createdAt is int
      ? DateTime.fromMillisecondsSinceEpoch(createdAt)
      : createdAt is String
      ? DateTime.tryParse(createdAt) ?? DateTime.now()
      : createdAt;

  ///  Convert JSON to `MessageModel` object
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json["_id"] ?? '',
      senderId: json["sender_id"] ?? '',
      receiverId: json["receiver_id"] ??'',
      broadcastId: json["broadcast_id"] ?? '',
      message: json["message"] ?? '',

      attachmentId: json["attechment_id"] is String
          ? [json["attechment_id"]]
          : (json["attechment_id"] as List<dynamic>?)?.map((id) => id.toString()).toList(),



      attachmentDetails: json["attechment_details"] is Map<String, dynamic>
          ? [UploadFile.fromJson(json["attechment_details"])]
          : (json["attechment_details"] as List<dynamic>?)?.map((item) => UploadFile.fromJson(item)).toList(),
      senderDetails: (json['sender_details'] as List<dynamic>?)
          ?.map((e) => UserDetails.fromJson(e))
          .toList() ??
          [],
      receiverDetails: (json['receiver_details'] as List<dynamic>?)
          ?.map((e) => UserDetails.fromJson(e))
          .toList() ??
          [],
      roomId: json["room_id"] ?? '',
      messageType: json["message_type"] ?? '',

      latitude: (json["latitude"] is String)
          ? double.tryParse(json["latitude"])
          : json["latitude"] as double?,

      longitude: (json["longitude"] is String)
          ? double.tryParse(json["longitude"])
          : json["longitude"] as double?,
      replyTo: json['reply_to'] is Map<String, dynamic>
          ? MessageModel.fromJson(json['reply_to'])
          : null,

      messageStatus: json["message_status"] ?? 'sent',
      createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"]) ?? DateTime.now() : DateTime.now(),
      updatedAt: json["updated_at"] != null ? DateTime.tryParse(json["updated_at"]) ?? DateTime.now() : DateTime.now(),
      isDeleted: json["is_deleted"] ?? false,
      status: json["status"] ?? 1,
      replyToDetails: json['reply_to_details'] != null
          ? MessageModel.fromJson(json['reply_to_details'])
          : null,

      isEdited: json["is_edited"] ?? false,
      isRead: json["is_read"] ?? false,
    );
  }

  ///  Convert `MessageModel` object to JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": messageId,
      "sender_id": senderId,
      "receiver_id": receiverId,
      "broadcast_id": broadcastId,
      "message": message,
      "attechment_id": attachmentId,
      // "attechment_details": attachmentDetails?.toJson(),
      "attechment_details": attachmentDetails?.map((e) => e.toJson()).toList(),
      "sender_details": senderDetails?.map((e) => e.toJson()).toList(),
      "receiver_details": receiverDetails?.map((e) => e.toJson()).toList(),
      "room_id": roomId,
      "message_type": messageType,
      "latitude": latitude,
      "longitude": longitude,
      "reply_to": replyTo?.toJson(),
      "message_status": messageStatus,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "is_deleted": isDeleted,
      "status": status,
      'reply_to_details': replyToDetails?.toJson(),

      "is_edited": isEdited,
      "is_read": isRead,
    };
  }

  /// Convert JSON List to List of `MessageModel`
  static List<MessageModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MessageModel.fromJson(json)).toList();
  }
  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? message,
    List<String>? attachmentId,
    List<UploadFile>? attachmentDetails,
    List<UserDetails>? senderDetails,
    List<UserDetails>? receiverDetails,
    String? roomId,
    String? messageType,
    double? latitude,
    double? longitude,
    MessageModel? replyTo,
    String? messageStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? status,
    MessageModel? replyToDetails,

    bool? isEdited,
    bool? isRead,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      attachmentId: attachmentId ?? this.attachmentId,
      attachmentDetails: attachmentDetails ?? this.attachmentDetails,
      senderDetails: senderDetails ?? this.senderDetails,
      receiverDetails: receiverDetails ?? this.receiverDetails,
      roomId: roomId ?? this.roomId,
      messageType: messageType ?? this.messageType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      replyTo: replyTo ?? this.replyTo,
      messageStatus: messageStatus ?? this.messageStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      status: status ?? this.status,
      replyToDetails: replyToDetails ?? this.replyToDetails,

      isEdited: isEdited ?? this.isEdited,
      isRead: isRead ?? this.isRead,
    );
  }

}