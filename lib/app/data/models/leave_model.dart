import 'dart:convert';

LeaveModel leaveModelFromJson(String str) => LeaveModel.fromJson(json.decode(str));

String leaveModelToJson(LeaveModel data) => json.encode(data.toJson());

class LeaveModel {
  LeaveModel({
    required this.success,
    required this.code,
    required this.msg,
    required this.body,
  });

  int success;
  int code;
  String msg;
  List<LeaveRecord> body;

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    success: json["success"],
    code: json["code"],
    msg: json["msg"],
    body: List<LeaveRecord>.from(json["body"].map((x) => LeaveRecord.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "msg": msg,
    "body": List<dynamic>.from(body.map((x) => x.toJson())),
  };
}

class LeaveRecord {
  LeaveRecord({
    required this.id,
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.leaveType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  String id;
  String staffId;
  DateTime startDate;
  DateTime endDate;
  String reason;
  String leaveType;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory LeaveRecord.fromJson(Map<String, dynamic> json) => LeaveRecord(
    id: json["_id"],
    staffId: json["staff_id"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    reason: json["reason"],
    leaveType: json["leave_type"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "staff_id": staffId,
    "start_date": startDate.toIso8601String(),
    "end_date": endDate.toIso8601String(),
    "reason": reason,
    "leave_type": leaveType,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

// For create leave response
CreateLeaveResponse createLeaveResponseFromJson(String str) => CreateLeaveResponse.fromJson(json.decode(str));

String createLeaveResponseToJson(CreateLeaveResponse data) => json.encode(data.toJson());

class CreateLeaveResponse {
  CreateLeaveResponse({
    required this.success,
    required this.code,
    required this.msg,
    required this.body,
  });

  int success;
  int code;
  String msg;
  CreatedLeaveBody body;

  factory CreateLeaveResponse.fromJson(Map<String, dynamic> json) => CreateLeaveResponse(
    success: json["success"],
    code: json["code"],
    msg: json["msg"],
    body: CreatedLeaveBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "msg": msg,
    "body": body.toJson(),
  };
}

class CreatedLeaveBody {
  CreatedLeaveBody({
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.leaveType,
    required this.status,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  String staffId;
  DateTime startDate;
  DateTime endDate;
  String reason;
  String leaveType;
  String status;
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory CreatedLeaveBody.fromJson(Map<String, dynamic> json) => CreatedLeaveBody(
    staffId: json["staff_id"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    reason: json["reason"],
    leaveType: json["leave_type"],
    status: json["status"],
    id: json["_id"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "staff_id": staffId,
    "start_date": startDate.toIso8601String(),
    "end_date": endDate.toIso8601String(),
    "reason": reason,
    "leave_type": leaveType,
    "status": status,
    "_id": id,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}