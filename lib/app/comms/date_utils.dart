import 'package:intl/intl.dart';


class DateUtilsHelper {
  static String formatDate(String apiDate) {
    DateTime parsedDate = DateTime.parse(apiDate).toLocal(); // Convert to local time
    DateTime now = DateTime.now();

    Duration diff = now.difference(parsedDate);

    // Check if it's today
    if (parsedDate.day == now.day &&
        parsedDate.month == now.month &&
        parsedDate.year == now.year) {
      return DateFormat.jm().format(parsedDate);
    }

    // Check if it's yesterday
    DateTime yesterday = now.subtract(Duration(days: 1));
    if (parsedDate.day == yesterday.day &&
        parsedDate.month == yesterday.month &&
        parsedDate.year == yesterday.year) {
      return "Yesterday";
    }

    // For older dates
    return DateFormat('d/M/yy').format(parsedDate); // e.g., "4/9/25"
  }
}

