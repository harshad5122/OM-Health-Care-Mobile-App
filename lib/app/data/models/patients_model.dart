import 'dart:convert';

class PatientModel {
  final String id;
  final String firstname;
  final String lastname;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String country;
  final String gender;
  final int visitCount;
  final int totalAppointments;
  final String patientStatus;
  final String dob;
  String? fullName;
  final int? totalCount;


  PatientModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.gender,
    required this.visitCount,
    required this.totalAppointments,
    required this.patientStatus,
    required this.dob,
    this.fullName,
    this.totalCount,

  });

  // String get fullName => '${firstname.trim()} ${lastname.trim()}';

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['_id'] ?? '',
      firstname: map['firstname'] ?? '',
      lastname: map['lastname'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      gender: map['gender'] ?? '',
      visitCount: map['visit_count'] ?? 0,
      totalAppointments: map['total_appointments'] ?? 0,
      patientStatus: map['patient_status'] ?? '',
      dob: map['dob'] ?? '',
      fullName: map['full_name'] ?? '',
      totalCount: map['total_count'],
    );
  }

  static List<PatientModel> fromJsonList(String body) {
    final decoded = jsonDecode(body);
    final rows = decoded['body']['rows'] as List;
    return rows.map((e) => PatientModel.fromMap(e)).toList();
  }
}
