enum MessageStatus {
  sent,
  delivered,
  seen,
}

// This extension is optional but makes it easy to use
// the enum with string values from a database (like 'sent', 'seen')
extension MessageStatusExtension on MessageStatus {
  String get value {
    switch (this) {
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.seen:
        return 'seen';
      // Default fallback
    }
  }

  static MessageStatus fromString(String status) {
    return MessageStatus.values.firstWhere(
          (e) => e.value == status,
      orElse: () => MessageStatus.sent, // Default fallback
    );
  }
}