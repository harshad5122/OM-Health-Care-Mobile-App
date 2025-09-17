import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';

// Meeting model for SfCalendar
class CalendarEvent {
  final String eventName;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;
  final String type;
  final String? status;
  final String? visitType;

  CalendarEvent({
    required this.eventName,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
    required this.type,
    this.status,
    this.visitType,
  });
}

// Custom DataSource
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from;
  @override
  DateTime getEndTime(int index) => appointments![index].to;
  @override
  String getSubject(int index) => appointments![index].eventName;
  @override
  Color getColor(int index) => appointments![index].background;
  @override
  bool isAllDay(int index) => appointments![index].isAllDay;
}
