class UserDetails {
  final String? id;
  final String firstname;
  final String lastname;
  final String email;

  UserDetails({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['_id']??'',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
    };
  }
}
