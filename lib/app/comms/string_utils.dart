import 'dart:math' as Math;

class StringUtils {
  static String getInitials(String name) {
    if (name
        .trim()
        .isEmpty) return "?";
    List<String> nameParts = name.split(' ');
    return nameParts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }

  static String getFileSizeString({required int bytes, int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (bytes > 0) ? (Math.log(bytes) / Math.log(1024)).floor() : 0;
    final size = bytes / Math.pow(1024, i);
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }
}