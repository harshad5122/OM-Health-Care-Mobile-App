enum MessageType { text, image, video, audio, document, location }

MessageType getMessageType(String fileType) {
  switch (fileType) {
    case "image":
      return MessageType.image;
    case "video":
      return MessageType.video;
    case "audio":
      return MessageType.audio;
    case "document":
      return MessageType.document;
    case "location":
      return MessageType.location;
    default:
      return MessageType.text;
  }
}
