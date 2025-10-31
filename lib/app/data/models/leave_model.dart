import 'dart:convert';

// For GET request (List of leaves)
LeaveModel leaveModelFromJson(String str) => LeaveModel.fromJson(json.decode(str));
// For CREATE request (Single leave)
CreateLeaveResponse createLeaveResponseFromJson(String str) => CreateLeaveResponse.fromJson(json.decode(str));

// --- Model for fetching a LIST of leave records ---
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
}

// --- Model for the response after CREATING a single leave ---
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
  LeaveRecord body; // Body is a single object here

  factory CreateLeaveResponse.fromJson(Map<String, dynamic> json) => CreateLeaveResponse(
    success: json["success"],
    code: json["code"],
    msg: json["msg"],
    body: LeaveRecord.fromJson(json["body"]),
  );
}


// --- The shared LeaveRecord object used by both models ---
class LeaveRecord {
  LeaveRecord({
    required this.id,
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.leaveType,
    required this.status,
    this.adminId,    // Now optional
    this.adminName,  // Now optional
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
  String? adminId;
  String? adminName;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory LeaveRecord.fromJson(Map<String, dynamic> json) => LeaveRecord(
    id: json["_id"],
    staffId: json["staff_id"],
    startDate: DateTime.parse(json["start_date"]).toLocal(),
    endDate: DateTime.parse(json["end_date"]).toLocal(),
    reason: json["reason"],
    leaveType: json["leave_type"],
    status: json["status"],
    adminId: json["admin_id"],
    adminName: json["admin_name"],
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
    "admin_id": adminId,
    "admin_name": adminName,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}