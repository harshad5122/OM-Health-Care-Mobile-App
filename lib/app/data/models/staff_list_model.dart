class StaffListModel {
  String? id;
  String? firstname;
  String? lastname;
  String? email;
  String? gender;
  String? address;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? qualification;
  String? specialization;
  String? occupation;
  String? professionalStatus;
  String? phone;
  String? dob;
  String? fatherName;
  String? motherName;
  String? emergencyContactName;
  String? emergencyContactRelation;
  String? emergencyContactContact;

  StaffListModel({
    this.id,
    this.firstname,
    this.lastname,
    this.email,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.qualification,
    this.specialization,
    this.occupation,
    this.professionalStatus,
    this.phone,
    this.dob,
    this.fatherName,
    this.motherName,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactContact,
  });

  factory StaffListModel.fromJson(Map<String, dynamic> json) => StaffListModel(
    id: json["_id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    email: json["email"],
    gender: json["gender"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    pincode: json["pincode"],
    qualification: json["qualification"],
    specialization: json["specialization"],
    occupation: json["occupation"],
    professionalStatus: json["professionalStatus"],
    phone: json["phone"],
    dob: json["dob"],
    fatherName: json["father_name"],
    motherName: json["mother_name"],
    emergencyContactName: json["emergencyContact_name"],
    emergencyContactRelation: json["emergencyContact_relation"],
    emergencyContactContact: json["emergencyContact_contact"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstname": firstname,
    "lastname": lastname,
    "email": email,
    "gender": gender,
    "address": address,
    "city": city,
    "state": state,
    "country": country,
    "pincode": pincode,
    "qualification": qualification,
    "specialization": specialization,
    "occupation": occupation,
    "professionalStatus": professionalStatus,
    "phone": phone,
    "dob": dob,
    "father_name": fatherName,
    "mother_name": motherName,
    "emergencyContact_name": emergencyContactName,
    "emergencyContact_relation": emergencyContactRelation,
    "emergencyContact_contact": emergencyContactContact,
  };
}
