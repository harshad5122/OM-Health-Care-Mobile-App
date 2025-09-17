import 'package:flutter/material.dart';

// Appointment Event Model
class DoctorAppointmentEvent {
  final String title;
  final String start;
  final String end;
  final String type;
  final String? status;
  final String? id;
  final String? visitType;
  final String? patientId;

  DoctorAppointmentEvent({
    required this.title,
    required this.start,
    required this.end,
    required this.type,
    this.status,
    this.id,
    this.visitType,
    this.patientId,
  });

  factory DoctorAppointmentEvent.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentEvent(
      title: json['title'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      type: json['type'] ?? '',
      status: json['status'],
      id: json['id'],
      visitType: json['visit_type'],
      patientId: json['patient_id'],
    );
  }
}

class DoctorAppointmentDay {
  final String date;
  final String status;
  final List<DoctorAppointmentEvent> events;
  final List<Map<String, String>> availableSlots;
  final List<Map<String, String>> bookedSlots;

  DoctorAppointmentDay({
    required this.date,
    required this.status,
    required this.events,
    required this.availableSlots,
    required this.bookedSlots,
  });

  factory DoctorAppointmentDay.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentDay(
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => DoctorAppointmentEvent.fromJson(e))
          .toList() ??
          [],
      availableSlots: (json['slots']?['available'] as List<dynamic>?)
          ?.map((slot) => {
        "start": slot['start']?.toString() ?? "",
        "end": slot['end']?.toString() ?? "",
      })
          .toList() ?? [],

      bookedSlots: (json['slots']?['booked'] as List<dynamic>?)
          ?.map((slot) => {
        "start": slot['start']?.toString() ?? "",
        "end": slot['end']?.toString() ?? "",
      })
          .toList() ?? [],

      // availableSlots: (json['slots']?['available'] as List<dynamic>?)
      //     ?.map((slot) => {"start": slot['start'], "end": slot['end']})
      //     .toList() ??
      //     [],
      // bookedSlots: (json['slots']?['booked'] as List<dynamic>?)
      //     ?.map((slot) => {"start": slot['start'], "end": slot['end']})
      //     .toList() ??
      //     [],
    );
  }
}
