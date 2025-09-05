import 'dart:convert';

class UploadFile {
  String? id;
  String? name;
  int? size;
  String? url;
  String? fileType;


  UploadFile({
    this.id,
    this.name,
    this.size,
    this.url,
    this.fileType,

  });

  // Convert JSON to UploadFile object
  factory UploadFile.fromJson(Map<String, dynamic> json) {
    return UploadFile(
      id: json['_id'], // MongoDB ObjectId (if available)
      name: json['name'],
      size: json['size'],
      url: json['url'],
      fileType: json['fileType'],

    );
  }

  // Convert UploadFile object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'size': size,
      'url': url,
      'fileType': fileType,
    };

  }
  @override
  String toString() => toJson().toString();
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
