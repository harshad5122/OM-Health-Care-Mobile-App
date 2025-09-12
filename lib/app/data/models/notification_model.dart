import 'dart:convert';

class NotificationModel {
  final String? id;
  final String? senderId;
  final String? receiverId;
  final String? type; // SYSTEM, MESSAGE, APPOINTMENT etc.
  final String? message;
  final String? referenceId;
  final String? referenceModel; // Appointment, Message, Other
  final bool read;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional - for attachments/messages
  final List<Attachment>? attachmentDetails;
  final String? messageType; // text, image, video, audio, document, location

  NotificationModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.referenceId,
    this.referenceModel,
    this.read = false,
    this.createdAt,
    this.updatedAt,
    this.attachmentDetails,
    this.messageType,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString(),
      senderId: json['sender_id']?.toString(),
      receiverId: json['receiver_id']?.toString(),
      type: json['type']?.toString(),
      message: json['message']?.toString(),
      referenceId: json['reference_id']?.toString(),
      referenceModel: json['reference_model']?.toString(),
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      messageType: json['message_type']?.toString(),
      attachmentDetails: json['attechment_details'] != null
          ? List<Attachment>.from(
        (json['attechment_details'] as List).map((e) => Attachment.fromJson(e)),
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "sender_id": senderId,
      "receiver_id": receiverId,
      "type": type,
      "message": message,
      "reference_id": referenceId,
      "reference_model": referenceModel,
      "read": read,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "message_type": messageType,
      "attechment_details": attachmentDetails?.map((e) => e.toJson()).toList(),
    };
  }
}

class Attachment {
  final String? id;
  final String? fileType; // image, video, audio, document
  final String? name;
  final int? size;
  final String? url;

  Attachment({
    this.id,
    this.fileType,
    this.name,
    this.size,
    this.url,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      fileType: json['fileType']?.toString(),
      name: json['name']?.toString(),
      size: json['size'] is int ? json['size'] : int.tryParse(json['size']?.toString() ?? ""),
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fileType": fileType,
      "name": name,
      "size": size,
      "url": url,
    };
  }
}
