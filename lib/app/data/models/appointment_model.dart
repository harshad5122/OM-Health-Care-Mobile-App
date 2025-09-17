import 'dart:ui';

import 'package:flutter/material.dart';

class AppointmentModel {
  String? patientId;
  String? patientName;
  String? staffId;
  String? date;
  TimeSlot? timeSlot;
  String? visitType;
  String? appointmentId;

  AppointmentModel({
    this.patientId,
    this.patientName,
    this.staffId,
    this.date,
    this.timeSlot,
    this.visitType,
    this.appointmentId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
    patientId: json['patient_id'],
    patientName: json['patient_name'],
    staffId: json['staff_id'],
    date: json['date'],
    timeSlot: json['time_slot'] != null
        ? TimeSlot.fromJson(json['time_slot'])
        : null,
    visitType: json['visit_type'],
    appointmentId: json['id'],
  );

  Map<String, dynamic> toJson() => {
    'patient_id': patientId,
    'patient_name': patientName,
    'staff_id': staffId,
    'date': date,
    'time_slot': timeSlot?.toJson(),
    'visit_type': visitType,
    if (appointmentId != null) '_id': appointmentId, // Use '_id' for update/delete if your API expects it

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
  final String date;
  final String status;
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
  final String start;
  final String end;
  final String type;
  final String status;
  final String id;
  final String visitType;
  final String patientId;

  Event({
    required this.title,
    required this.start,
    required this.end,
    required this.type,
    required this.status,
    required this.id,
    required this.visitType,
    required this.patientId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      start: json['start'],
      end: json['end'],
      type: json['type'],
      status: json['status'],
      id: json['id'],
      visitType: json['visit_type'],
      patientId: json['patient_id'],
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

// Class to hold appointment data for Syncfusion Calendar
class CalendarAppointment {
  CalendarAppointment({
    required this.eventName,
    required this.from,
    required this.to,
    this.background = Colors.blue, // Default color for appointments
    this.isAllDay = false,
    this.appointmentId,
    this.patientId,
    this.visitType,
    this.patientName,
    this.status,
  });

  final String eventName;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;
  final String? appointmentId;
  final String? patientId;
  final String? visitType;
  final String? patientName;
  final String? status;
}