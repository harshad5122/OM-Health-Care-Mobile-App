class BroadcastModel {
  final String id;
  final String title;
  final String createdBy;
  final List<String> recipients;
  final DateTime createdAt;
  final String lastMessage;

  BroadcastModel({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.recipients,
    required this.createdAt,
    this.lastMessage = "",
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    return BroadcastModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      createdBy: json["createdBy"] is Map
          ? json["createdBy"]["id"] ?? ""
          : json["createdBy"] ?? "",
      recipients: (json["recipients"] as List?)
          ?.map<String>((e) => e is Map ? (e["id"] ?? "").toString() : e.toString())
          .toList()
          ?? [],

      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      lastMessage: json["lastMessage"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "createdBy": createdBy,
      "recipients": recipients,
      "createdAt": createdAt.toIso8601String(),
      "lastMessage": lastMessage,
    };
  }
}
