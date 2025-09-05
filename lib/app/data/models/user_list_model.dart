class UserListModel {
  bool? isPasswordChanged;
  String? otp;
  String? otpExpiresAt;
  String? id;
  String? firstname;
  String? lastname;
  String? countryCode;
  String? phone;
  String? email;
  String? dob;
  String? address;
  String? country;
  String? state;
  String? city;
  String? gender;
  bool? isOnline;
  int? role;
  bool? addedByAdmin;
  bool? isDeleted;
  int? status;
  String? lastSeen;
  String? createdAt;
  String? updatedAt;


  UserListModel({
    this.isPasswordChanged,
    this.otp,
    this.otpExpiresAt,
    this.id,
    this.firstname,
    this.lastname,
    this.countryCode,
    this.phone,
    this.email,
    this.dob,
    this.address,
    this.country,
    this.state,
    this.city,
    this.gender,
    this.isOnline,
    this.role,
    this.addedByAdmin,
    this.isDeleted,
    this.status,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) => UserListModel(
    isPasswordChanged: json["isPasswordChanged"],
    otp: json["otp"],
    otpExpiresAt: json["otpExpiresAt"],
    id: json["_id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    countryCode: json["countryCode"],
    phone: json["phone"],
    email: json["email"],
    dob: json["dob"],
    address: json["address"],
    country: json["country"],
    state: json["state"],
    city: json["city"],
    gender: json["gender"],
    isOnline: json["is_online"],
    role: json["role"],
    addedByAdmin: json["addedByAdmin"],
    isDeleted: json["is_deleted"],
    status: json["status"],
    lastSeen: json["last_seen"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "isPasswordChanged": isPasswordChanged,
    "otp": otp,
    "otpExpiresAt": otpExpiresAt,
    "_id": id,
    "firstname": firstname,
    "lastname": lastname,
    "countryCode": countryCode,
    "phone": phone,
    "email": email,
    "dob": dob,
    "address": address,
    "country": country,
    "state": state,
    "city": city,
    "gender": gender,
    "is_online": isOnline,
    "role": role,
    "addedByAdmin": addedByAdmin,
    "is_deleted": isDeleted,
    "status": status,
    "last_seen": lastSeen,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}