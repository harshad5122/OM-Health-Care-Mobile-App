import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/staff_list_model.dart';
import '../../../data/models/user_list_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class AppointmentController extends GetxController {
  /// Observables
  var isLoading = false.obs;
  var doctors = <StaffListModel>[].obs;
  var patients = <UserListModel>[].obs;

  var allDayAppointments = <CalendarAppointment>[].obs; // All appointments for the month/range

  var skip = 0.obs;
  final int pageSize = 10;
  var hasMore = true.obs;


  var selectedDate = DateTime.now().obs;
  var availableSlots = <TimeSlot>[].obs;
  var bookedSlots = <Event>[].obs;
  var startTime = "".obs;
  var endTime = "".obs;
  var selectedPatientId = "".obs;
  var selectedPatientName = "".obs;
  var selectedVisitType = "".obs;
  var selectedStaffId = "".obs;

  var selectedAppointmentId = Rxn<String>();

  var saveEnabled = false.obs;
  var isEditMode = false.obs; // To differentiate between booking and editing


  /// Scroll controller for infinite scroll
  final scrollController = ScrollController();

  @override
  // void onInit() {
  //   super.onInit();
  //   fetchDoctors(clear: true);
  //   fetchPatients();
  //
  //   _fetchAppointmentsForMonth(selectedDate.value);
  //   ever(selectedDate, (DateTime date) {
  //     _fetchAppointmentsForDay(date);
  //   });
  //
  //   // Infinite scroll listener
  //   scrollController.addListener(() {
  //     if (scrollController.position.pixels >=
  //         scrollController.position.maxScrollExtent - 200 &&
  //         !isLoading.value &&
  //         hasMore.value) {
  //       fetchDoctors();
  //     }
  //   });
  // }
  @override
  void onInit() {
    super.onInit();

    // Defer initial data fetching to after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDoctors(clear: true);
      fetchPatients();
      // Ensure selectedStaffId is set before fetching appointments for month
      // This is crucial. If doctor.id is not available immediately,
      // _fetchAppointmentsForMonth might need to be called after it's set.
      // For now, assuming selectedStaffId is set by BookingCalenderView
      if (selectedStaffId.value.isNotEmpty) {
        _fetchAppointmentsForMonth(selectedDate.value);
      }
    });


    // React to date changes in the calendar to fetch specific day slots
    // This `ever` listener is fine, as it reacts to *future* changes,
    // not directly causing the initial build error.
    ever(selectedDate, (DateTime date) {
      if (selectedStaffId.value.isNotEmpty) {
        _fetchAppointmentsForDay(date);
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200 &&
          !isLoading.value &&
          hasMore.value) {
        fetchDoctors();
      }
    });
  }

  void setSelectedStaff(String staffId) {
    selectedStaffId.value = staffId;
    if (selectedStaffId.value.isNotEmpty) {
      _fetchAppointmentsForMonth(selectedDate.value);
    }
    // _fetchAppointmentsForMonth(selectedDate.value); // Fetch appointments when staff is set
  }

  void updateSaveEnabled() {
    saveEnabled.value = startTime.isNotEmpty &&
        endTime.isNotEmpty &&
        selectedPatientId.isNotEmpty &&
        selectedVisitType.isNotEmpty;
  }

  String _formatTime(String time) {
    // Check if time is already in 24-hour format
    if (time.contains(':')) {
      return time;
    }
    // Attempt to parse 12-hour format if it's not 24-hour
    try {
      final format12 = DateFormat('h:mm a');
      final format24 = DateFormat('HH:mm');
      final dateTime = format12.parse(time);
      return format24.format(dateTime);
    } catch (e) {
      // If parsing fails, return original or handle error
      return time;
    }
  }


  /// API: Fetch Doctors
  Future<void> fetchDoctors({bool clear = false}) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      if (clear) {
        skip.value = 0;
        hasMore.value = true;
        doctors.clear();
      }

      final token = await TokenStorage.getToken();

      final uri = Uri.parse(ApiConstants.GET_DOCTOR).replace(
        queryParameters: {
          "skip": skip.value.toString(),
          "limit": pageSize.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == 1 && data["body"]?["rows"] != null) {
          final List<dynamic> rows = data["body"]["rows"];
          final fetchedDoctors = rows
              .map((e) => StaffListModel.fromJson(e as Map<String, dynamic>))
              .toList();

          doctors.addAll(fetchedDoctors);

          if (fetchedDoctors.length < pageSize) {
            hasMore.value = false;
          } else {
            skip.value += pageSize;
          }
        }
      } else {
        Get.snackbar("Error", "Failed to fetch doctors (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPatients() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.GET_PATIENTS),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"] != null) {
          final List<dynamic> list = data["body"];
          patients.assignAll(list.map((e) => UserListModel.fromJson(e)).toList());
        }
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    }
  }

  /// API: Fetch appointments for a given month range
  Future<void> _fetchAppointmentsForMonth(DateTime date) async {
    if (selectedStaffId.value.isEmpty) {
      availableSlots.clear();
      bookedSlots.clear();
      return; // Cannot fetch without a staff ID
    }

    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

      final uri = Uri.parse(
          "${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/${selectedStaffId.value}")
          .replace(queryParameters: {
        "from": DateFormat('yyyy-MM-dd').format(firstDayOfMonth),
        "to": DateFormat('yyyy-MM-dd').format(lastDayOfMonth),
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"] != null) {
          final List<dynamic> daysData = data["body"];
          final List<CalendarAppointment> fetchedAppointments = [];
          for (var dayJson in daysData) {
            final DayAppointments dayAppts = DayAppointments.fromJson(dayJson);
            for (var event in dayAppts.events) {
              try {
                final appointmentDate = DateTime.parse(dayAppts.date);
                final startParts = _formatTime(event.start).split(':');
                final endParts = _formatTime(event.end).split(':');

                final startTime = DateTime(
                  appointmentDate.year,
                  appointmentDate.month,
                  appointmentDate.day,
                  int.parse(startParts[0]),
                  int.parse(startParts[1]),
                );
                final endTime = DateTime(
                  appointmentDate.year,
                  appointmentDate.month,
                  appointmentDate.day,
                  int.parse(endParts[0]),
                  int.parse(endParts[1]),
                );

                fetchedAppointments.add(
                  CalendarAppointment(
                    eventName: event.title,
                    from: startTime,
                    to: endTime,
                    background: event.type == 'booked' ? Colors.red : Colors.green, // Differentiate colors
                    appointmentId: event.id,
                    patientId: event.patientId,
                    visitType: event.visitType,
                    status: event.status,
                    // patientName is not in event object, you might need to fetch/map it
                  ),
                );
              } catch (e) {
                print("Error parsing event time for ${event.title}: $e");
              }
            }
          }
          allDayAppointments.assignAll(fetchedAppointments);
          _fetchAppointmentsForDay(selectedDate.value); // Update slots for the initially selected day
        }
      } else {
        Get.snackbar("Error", "Failed to fetch appointments (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Exception", "Error fetching month appointments: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> _fetchAppointmentsForDay(DateTime date) async {
    if (selectedStaffId.value.isEmpty) {
      availableSlots.clear();
      bookedSlots.clear();
      return;
    }

    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final uri = Uri.parse(
          "${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/${selectedStaffId.value}")
          .replace(queryParameters: {
        "from": formattedDate,
        "to": formattedDate,
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"] != null) {
          final List<dynamic> daysData = data["body"];
          if (daysData.isNotEmpty) {
            final DayAppointments dayAppts = DayAppointments.fromJson(daysData[0]);
            availableSlots.assignAll(dayAppts.slots.available );
            bookedSlots.assignAll(dayAppts.events); // Use events for booked slots to get full info
          } else {
            availableSlots.clear();
            bookedSlots.clear();
          }
        }
      } else {
        Get.snackbar("Error", "Failed to fetch day slots (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Exception", "Error fetching day slots: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectTimeSlot(TimeSlot slot) {
    startTime.value = slot.start ?? "";
    endTime.value = slot.end ?? "";
    selectedAppointmentId.value = null; // Clear if previously selected for edit
    isEditMode.value = false;
    updateSaveEnabled();
  }

  void selectExistingAppointment(CalendarAppointment appointment) {
    isEditMode.value = true;
    selectedAppointmentId.value = appointment.appointmentId;
    startTime.value = DateFormat('HH:mm').format(appointment.from);
    endTime.value = DateFormat('HH:mm').format(appointment.to);
    selectedPatientId.value = appointment.patientId ?? "";
    selectedVisitType.value = appointment.visitType ?? "";

    final selectedPatient = patients.firstWhereOrNull((p) => p.id == appointment.patientId);
    selectedPatientName.value =
    (selectedPatient != null) ? "${selectedPatient.firstname ?? ''} ${selectedPatient.lastname ?? ''}" : "";

    updateSaveEnabled();
  }

  void clearAppointmentSelection() {
    isEditMode.value = false;
    selectedAppointmentId.value = null;
    startTime.value = "";
    endTime.value = "";
    selectedPatientId.value = "";
    selectedPatientName.value = "";
    selectedVisitType.value = "";
    updateSaveEnabled();
  }



  // Future<void> bookAppointment() async {
  //   isLoading.value = true;
  //   final appointment = AppointmentModel(
  //     patientId: selectedPatientId.value,
  //     patientName: selectedPatientName.value, // Fill from patient dropdown data
  //     staffId: selectedStaffId.value, // Fill from doctor/staff selection
  //     date: selectedDate.value.toString().substring(0, 10),
  //     timeSlot: TimeSlot(start: startTime.value, end: endTime.value),
  //     visitType: selectedVisitType.value,
  //   );
  //
  //   final token = await TokenStorage.getToken();
  //
  //   final response = await http.post(
  //     Uri.parse(ApiConstants.CREATE_APPOINTMENT),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(appointment.toJson()),
  //   );
  //
  //   isLoading.value = false;
  //   print('book appointment response ==> ${response.body}');
  //   print('status code ==> ${response.statusCode}');
  //   if (response.statusCode == 200) {
  //     Get.snackbar('Success', 'Appointment booked!');
  //     print('success');
  //     Get.back();
  //   } else {
  //     Get.snackbar('Error', 'Failed to book appointment');
  //   }
  // }

  Future<void> bookAppointment() async {
    isLoading.value = true;
    final appointment = AppointmentModel(
      patientId: selectedPatientId.value,
      patientName: selectedPatientName.value,
      staffId: selectedStaffId.value,
      date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
      timeSlot: TimeSlot(start: startTime.value, end: endTime.value),
      visitType: selectedVisitType.value,
    );

    final token = await TokenStorage.getToken();
    final url = Uri.parse(ApiConstants.CREATE_APPOINTMENT);

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(appointment.toJson()),
      );

      isLoading.value = false;

      print('book appointment response ==> ${response.body}');
        print('status code ==> ${response.statusCode}');
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Appointment booked successfully!');
        Get.back(); // Close dialog
        print('success');
        _fetchAppointmentsForMonth(selectedDate.value); // Refresh calendar appointments
        clearAppointmentSelection();
      } else {
        Get.snackbar('Error', 'Failed to book appointment: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', 'Error booking appointment: $e');
    }
  }

  // Future<void> updateAppointment() async {
  //   if (selectedAppointmentId.value == null) {
  //     Get.snackbar('Error', 'No appointment selected for update.');
  //     return;
  //   }
  //
  //   isLoading.value = true;
  //   final appointment = AppointmentModel(
  //     patientId: selectedPatientId.value,
  //     patientName: selectedPatientName.value,
  //     staffId: selectedStaffId.value,
  //     date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
  //     timeSlot: TimeSlot(start: startTime.value, end: endTime.value),
  //     visitType: selectedVisitType.value,
  //     appointmentId: selectedAppointmentId.value, // Pass the existing appointment ID
  //   );
  //
  //   final token = await TokenStorage.getToken();
  //   final url = Uri.parse(ApiConstants.UPDATE_APPOINTMENT); // Assuming an update API endpoint
  //
  //   try {
  //     final response = await http.put( // Assuming PUT or PATCH for update
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(appointment.toJson()),
  //     );
  //
  //     isLoading.value = false;
  //     if (response.statusCode == 200) {
  //       Get.snackbar('Success', 'Appointment updated successfully!');
  //       Get.back(); // Close dialog
  //       _fetchAppointmentsForMonth(selectedDate.value); // Refresh calendar appointments
  //       clearAppointmentSelection();
  //     } else {
  //       Get.snackbar('Error', 'Failed to update appointment: ${response.body}');
  //     }
  //   } catch (e) {
  //     isLoading.value = false;
  //     Get.snackbar('Exception', 'Error updating appointment: $e');
  //   }
  // }
  Future<void> updateAppointment() async {
    if (selectedAppointmentId.value == null) {
      Get.snackbar('Error', 'No appointment selected for update.');
      return;
    }

    isLoading.value = true;

    final token = await TokenStorage.getToken();
    final url = Uri.parse(ApiConstants.UPDATE_APPOINTMENT);

    final body = {
      "reference_id": selectedAppointmentId.value,   // 👈 backend expects this
      "patient_id": selectedPatientId.value,
      "date": DateFormat('yyyy-MM-dd').format(selectedDate.value),
      "time_slot": {
        "start": startTime.value, // ensure 24hr format
        "end": endTime.value,
      },
      "visit_type": selectedVisitType.value,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      isLoading.value = false;

      print('status code ==> ${response.statusCode}');
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Appointment updated successfully!');
        Get.back(); // Close dialog
        print('response body: ${response.body}');
        _fetchAppointmentsForMonth(selectedDate.value);
        clearAppointmentSelection();
      } else {
        Get.snackbar('Error', 'Failed to update appointment: ${response.body}');
        print('error response body: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', 'Error updating appointment: $e');
    }
  }



  // Future<void> deleteAppointment() async {
  //   if (selectedAppointmentId.value == null) {
  //     Get.snackbar('Error', 'No appointment selected for deletion.');
  //     return;
  //   }
  //
  //   isLoading.value = true;
  //   final token = await TokenStorage.getToken();
  //   final url = Uri.parse("${ApiConstants.DELETE_APPOINTMENT}/${selectedAppointmentId.value}"); // Assuming a delete API endpoint
  //
  //   try {
  //     final response = await http.delete( // Assuming DELETE method
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     isLoading.value = false;
  //     if (response.statusCode == 200) {
  //       Get.snackbar('Success', 'Appointment deleted successfully!');
  //       Get.back(); // Close dialog
  //       _fetchAppointmentsForMonth(selectedDate.value); // Refresh calendar appointments
  //       clearAppointmentSelection();
  //     } else {
  //       Get.snackbar('Error', 'Failed to delete appointment: ${response.body}');
  //     }
  //   } catch (e) {
  //     isLoading.value = false;
  //     Get.snackbar('Exception', 'Error deleting appointment: $e');
  //   }
  // }

  // Handle saving (book or update)
  void handleSaveAppointment() {
    if (isEditMode.value) {
      updateAppointment();
    } else {
      bookAppointment();
    }
  }

}


class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<CalendarAppointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getAppointmentData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getAppointmentData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getAppointmentData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getAppointmentData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getAppointmentData(index).isAllDay;
  }

  CalendarAppointment _getAppointmentData(int index) {
    final dynamic appointment = appointments![index];
    late final CalendarAppointment appointmentData;
    if (appointment is CalendarAppointment) {
      appointmentData = appointment;
    }
    return appointmentData;
  }
}