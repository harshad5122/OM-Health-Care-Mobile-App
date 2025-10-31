import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class AppointmentModel {
  String? patientId;
  String? patientName;
  String? patientPhone;
  String? patientAddress;
  String? patientCity;
  String? patientState;
  String? patientCountry;
  String? staffId;
  String? date;
  TimeSlot? timeSlot;
  String? visitType;
  String? appointmentId;
  String? status;
  String? id;

  AppointmentModel({
    this.patientId,
    this.patientName,
    this.patientPhone,
    this.patientAddress,
    this.patientCity,
    this.patientState,
    this.patientCountry,
    this.staffId,
    this.date,
    this.timeSlot,
    this.visitType,
    this.appointmentId,
    this.status,
    this.id,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
    patientId: json['patient_id'],
    patientName: json['patient_name'],
    patientPhone: json['patient_phone'],
    patientAddress: json['patient_address'],
    patientCity: json['patient_city'],
    patientState: json['patient_state'],
    patientCountry: json['patient_country'],
    staffId: json['staff_id'],
    date: json['date'],
    timeSlot: json['time_slot'] != null
        ? TimeSlot.fromJson(json['time_slot'])
        : null,
    visitType: json['visit_type'],
    appointmentId: json['_id'],
    status: json['status'],
    id: json['_id'],
  );

  Map<String, dynamic> toJson() => {
    'patient_id': patientId,
    'patient_name': patientName,
    'patient_phone': patientPhone,
    'patient_address': patientAddress,
    'patient_city': patientCity,
    'patient_state': patientState,
    'patient_country': patientCountry,
    'visit_type': visitType,
    'staff_id': staffId,
    'date': date,
    'time_slot': timeSlot?.toJson(),
    if (appointmentId != null) '_id': appointmentId,
    if (status != null) 'status': status,
    if (id != null) '_id': id,
  };
}

class TimeSlot {
  String? start;
  String? end;
  String? id;

  TimeSlot({this.start, this.end, this.id});

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      TimeSlot(start: json['start'], end: json['end'], id: json['id'] is List ? json['id'][0] : json['id']);

  Map<String, dynamic> toJson() => {
    'start': start,
    'end': end,
    if (id != null) 'id': id,
  };

  @override
  String toString() {
    return '$start - $end';
  }
}

class DayAppointments {
  final String? date;
  final String? status;
  final List<Event> events;
  final DaySlots slots;

  DayAppointments({
    required this.date,
    required this.status,
    required this.events,
    required this.slots,
  });

  factory DayAppointments.fromJson(Map<String, dynamic> json) {
    return DayAppointments(
      date: json['date'],
      status: json['status'],
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      slots: DaySlots.fromJson(json['slots'] as Map<String, dynamic>),
    );
  }
}

class Event {
  final String title;
  final String? startDate;
  final String? endDate;
  final String start;
  final String end;
  final String type;
  final String status;
  final String? id;
  final String? visitType;
  final String? patientId;
  final String? patientName;

  Event({
    required this.title,
    required this.start,
    required this.end,
    required this.type,
    required this.status,
    this.startDate,
    this.endDate,
    this.id,
    this.visitType,
    this.patientName,
    this.patientId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] as String,
      startDate: json['start_date'],
      endDate: json['end_date'],
      start: json['start'] as String,
      end: json['end'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      id: json['id'] as String?,
      visitType: json['visit_type'] as String?,
      patientId: json['patient_id'] as String?,
      patientName: json['patient_name'],
    );
  }
}

class DaySlots {
  final List<TimeSlot> available;
  final List<TimeSlot> booked;
  final List<TimeSlot> leave;

  DaySlots({
    required this.available,
    required this.booked,
    required this.leave,
  });

  factory DaySlots.fromJson(Map<String, dynamic> json) {
    return DaySlots(
      available: (json['available'] as List<dynamic>?)
          ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      booked: (json['booked'] as List<dynamic>?)
          ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      leave: (json['leave'] as List<dynamic>?)
          ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class CalendarAppointment {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String title;
  final Color color;
  final bool isAllDay;

  final String? appointmentId;
  final String? patientId;
  final String? visitType;
  final String? patientName;
  final String? status;
  final String? type; // "leave" or "appointment"

  CalendarAppointment({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.color = Colors.blue,
    this.isAllDay = false,
    this.appointmentId,
    this.patientId,
    this.visitType,
    this.patientName,
    this.status,
    this.type,
  });

  /// Helper to create a CalendarAppointment from our new `Event` model.
  factory CalendarAppointment.fromEvent(Event event, DateTime eventDate) {
    DateTime startTime = eventDate;
    DateTime endTime = eventDate;

    try {
      final startParts = event.start.split(':'); // "14:00"
      final endParts = event.end.split(':'); // "20:00"

      startTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      endTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
    } catch (e) {
      print("Error parsing time: $e");
    }

    // Determine color based on type or status
    Color eventColor = Colors.blue;
    if (event.type == 'leave') {
      eventColor = event.status == 'CONFIRMED' ? Colors.grey : Colors.orange;
    } else if (event.status == 'CONFIRMED') {
      eventColor = Colors.green;
    }

    return CalendarAppointment(
      date: eventDate,
      title: event.title,
      startTime: startTime,
      endTime: endTime,
      color: eventColor,
      isAllDay: false, // Individual events are not all-day
      appointmentId: event.id,
      patientId: event.patientId,
      patientName: event.patientName,
      status: event.status,
      type: event.type,
      visitType: event.type,
    );
  }
}
// class CalendarAppointment extends CalendarEventData {
//   // Constructor adapted for CalendarEventData
//   CalendarAppointment({
//     required super.date,
//     required super.startTime,
//     required super.endTime,
//     super.endDate,
//     super.title = '',
//     super.description = '',
//     super.color = Colors.blue,
//     this.appointmentId,
//     this.patientId,
//     this.visitType,
//     this.patientName,
//     this.status,
//     this.type,
//   }) : super(
//     // Pass properties to super constructor
//     // The `title` property of CalendarEventData will be used for eventName
//     // `date` will be the event start date
//     // `startTime` and `endTime` will represent the time component
//   );
//
//   final String? appointmentId;
//   final String? patientId;
//   final String? visitType;
//   final String? patientName;
//   final String? status;
//   final String? type;
// }
