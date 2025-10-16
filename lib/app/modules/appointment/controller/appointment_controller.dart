
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_view/calendar_view.dart';
import 'package:om_health_care_app/app/global/global.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/patients_model.dart';
import '../../../data/models/staff_list_model.dart';
import '../../../data/models/user_list_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';
//
// enum AppointmentFilterDateRange {
//   all,
//   thisMonth,
//   lastMonth,
//   thisWeek,
//   custom,
// }

enum DateRangeOption { thisMonth, lastMonth, thisWeek, custom }

class AppointmentController extends GetxController {
  /// Observables
  var isLoading = false.obs;
  final isLoadingPatients  = false.obs;
  var doctors = <StaffListModel>[].obs;
  var patients = <PatientModel>[].obs;
  var appointments = <AppointmentModel>[].obs;

  final EventController<CalendarAppointment> eventController = EventController<CalendarAppointment>();

  var skip = 0.obs;
  final int pageSize = 10;
  var hasMore = true.obs;

  var selectedDate = DateTime.now().obs;
  var availableSlots = <TimeSlot>[].obs; // This will hold available slots for the selectedDate
  var bookedSlots = <Event>[].obs;       // This will hold booked events for the selectedDate
  var startTime = "".obs;
  var endTime = "".obs;
  var selectedPatientId = "".obs;
  var selectedPatientName = "".obs;
  var selectedVisitType = "".obs;
  var selectedStaffId = "".obs;

  var selectedAppointmentId = Rxn<String>();

  final selectedDoctor = Rxn<StaffListModel>();
  final dateRangeOption = DateRangeOption.thisMonth.obs;

  var saveEnabled = false.obs;
  var isEditMode = false.obs;

  var editingStatuses = <String, String>{}.obs;

  final TextEditingController searchController = TextEditingController();
  var currentSearchQuery = ''.obs;
  // var currentFilterStatus = ''.obs;
  var currentFilterStatus = <String>[].obs;

  var currentFilterDateRange = DateRangeOption.thisMonth.obs;
  var filterFromDate = Rxn<DateTime>();
  var filterToDate = Rxn<DateTime>();
  var selectedFilterStaffId = ''.obs;

  var allDayAppointments = <CalendarAppointment>[].obs;

  final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');

  late Worker _selectedDateWorker;
  late Worker _selectedStaffIdWorker;

  final scrollController = ScrollController();

  final customFrom = Rxn<DateTime>();
  final customTo = Rxn<DateTime>();


  DateTime get fromDate {
    final now = DateTime.now();
    switch (dateRangeOption.value) {
      case DateRangeOption.thisMonth:
        return DateTime(now.year, now.month, 1);
      case DateRangeOption.lastMonth:
        final last = DateTime(now.year, now.month - 1, 1);
        return last;
      case DateRangeOption.thisWeek:
        return now.subtract(Duration(days: now.weekday - 1));
      case DateRangeOption.custom:
        return customFrom.value ?? now;
    }
  }

  DateTime get toDate {
    final now = DateTime.now();
    switch (dateRangeOption.value) {
      case DateRangeOption.thisMonth:
        return DateTime(now.year, now.month + 1, 0);
      case DateRangeOption.lastMonth:
        final last = DateTime(now.year, now.month - 1, 1);
        return DateTime(last.year, last.month + 1, 0);
      case DateRangeOption.thisWeek:
        return now.add(Duration(days: 7 - now.weekday));
      case DateRangeOption.custom:
        return customTo.value ?? now;
    }
  }

  @override
  void onInit() {
    super.onInit();

    fetchDoctors(clear: true).then((_) {
      // fetchPatients();
      if (doctors.isNotEmpty && selectedFilterStaffId.value.isEmpty) {
        selectedFilterStaffId.value = doctors.first.id ?? '';
      }
      fetchPatientAppointments();
    });

    // ever(currentSearchQuery, (_) => fetchPatientAppointments());
    // ever(currentFilterStatus, (_) => fetchPatientAppointments());
    // ever(currentFilterDateRange, (range) {
    //   if (range != (filterFromDate.value != null || filterToDate.value != null)) {
    //     fetchPatientAppointments();
    //   }
    // });
    // ever(filterFromDate, (_) => fetchPatientAppointments());
    // ever(filterToDate, (_) => fetchPatientAppointments());

    _selectedDateWorker = ever(selectedDate, (DateTime date) {
      if (selectedStaffId.value.isNotEmpty) {
        _fetchAppointmentsForRange(date);      // For calendar view events (month-wide)
        _fetchAppointmentsForDaySlots(date);  // For dialog's available/booked slots (day-specific)
      }
    });

    _selectedStaffIdWorker = ever(selectedStaffId, (String staffId) {
      if (staffId.isNotEmpty) {
        selectedDate.refresh(); // This triggers _selectedDateWorker
      } else {
        eventController.removeWhere((event) => true); // Clear all calendar events
        allDayAppointments.clear();
        availableSlots.clear();
        bookedSlots.clear();
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

  @override
  void onClose() {
    _selectedDateWorker.dispose();
    _selectedStaffIdWorker.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void setSelectedStaff(String staffId) {
    // if (selectedStaffId.value != staffId) {
    //   selectedStaffId.value = staffId;
    //   selectedDate.value = DateTime.now();
    // }
    selectedFilterStaffId.value = staffId;
    _fetchAppointmentsForRange(selectedDate.value);
    _fetchAppointmentsForDaySlots(selectedDate.value);
  }

  void updateSaveEnabled() {
    saveEnabled.value = startTime.isNotEmpty &&
        endTime.isNotEmpty &&
        selectedPatientId.isNotEmpty &&
        selectedVisitType.isNotEmpty;
  }

  void clearFiltersAndPatients() {
    selectedDoctor.value = null; // Clear selected doctor
    dateRangeOption.value = DateRangeOption.thisMonth; // Reset to default
    patients.clear(); // Clear the patient list
  }

  // Helper to ensure time is in HH:mm format, handling potential nulls safely
  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '00:00'; // Default or handle as error
    if (time.contains(':')) {
      return time;
    }
    try {
      // Try parsing 12-hour format
      final format12 = DateFormat('h:mm a');
      final format24 = DateFormat('HH:mm');
      final dateTime = format12.parse(time);
      return format24.format(dateTime);
    } catch (e) {
      // If 12-hour parsing fails, return original or default
      return time;
    }
  }


  /// API: Fetch Doctors (Unchanged)
  Future<void> fetchDoctors({bool clear = false,
    String search = '',
    String fromDate = '',
    String toDate = '',}) async {
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
          'search': search,
          'from_date': fromDate,
          'to_date': toDate,
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

  /// API: Fetch Patients (Users) - Needed for patient names in cards (Unchanged)
  Future<void> fetchPatients() async {
    // if (selectedDoctor.value == null) {
    //   Get.log("⚠️ No doctor selected yet, skipping fetchPatients()");
    //   print("selectedDoctor.value: ${selectedDoctor.value}");
    //   return;
    // }
    try {
      isLoadingPatients.value = true;
      final from = DateFormat('yyyy-MM-dd').format(fromDate);
      final to = DateFormat('yyyy-MM-dd').format(toDate);
      final token = await TokenStorage.getToken();

      final doctorId = (Global.role == 3)
          ? Global.staffId
          : selectedDoctor.value?.id ?? '';

      if (doctorId!.isEmpty) {
        Get.snackbar("Error", "Doctor not selected");
        return;
      }

      // Prepare query params
      final queryParams = {
        'doctor_id': doctorId,
        'from_date': from,
        'to_date': to,
        'limit': '20',
        'search': currentSearchQuery.value,
      };

      if (currentFilterStatus.isNotEmpty) {
        queryParams['patient_status'] = currentFilterStatus.join(', ');
      } else {
        // Send all statuses
        queryParams['patient_status'] =
        'CONTINUE,ALTERNATE,DISCONTINUE,WEEKLY,DISCHARGE,OBSERVATION';
      }

      final uri = Uri.parse(ApiConstants.GET_PATIENTS).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        // Uri.parse(ApiConstants.GET_PATIENTS).replace(
        //   queryParameters: {
        //     'doctor_id': selectedDoctor.value!.id,
        //     'from_date': from,
        //     'to_date': to,
        //   }
        // ),
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1) {
          // final List<dynamic> list = data["body"];
          // patients.assignAll(list.map((e) => UserListModel.fromJson(e)).toList());
          final rows = List<Map<String, dynamic>>.from(data['body']['rows']);
          patients.assignAll(rows.map((e) => PatientModel.fromMap(e)).toList());
        }else {
          patients.clear();
        }
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    }finally {
      isLoadingPatients.value = false;
    }
  }

  void selectDoctor(StaffListModel? d) {
    selectedDoctor.value = d;
    // if (d != null) fetchPatients();
  }

  void changeDateRange(DateRangeOption option) {
    dateRangeOption.value = option;
    if (option != DateRangeOption.custom) {
      customFrom.value = null;
      customTo.value = null;
      // if (selectedDoctor.value != null) fetchPatients();
    }
  }

  void setCustomRange(DateTime from, DateTime to) {
    customFrom.value = from;
    customTo.value = to;
    // if (selectedDoctor.value != null) fetchPatients();
  }

  /// API: Fetch ALL Appointments for the Patient Appointments Page (Admin View) with filters (Unchanged logic, just ensure models are null-safe)
  // Future<void> fetchPatientAppointments() async {
  //   isLoading.value = true;
  //   try {
  //     final token = await TokenStorage.getToken();
  //     final Map<String, String> queryParams = {};
  //
  //     if (currentSearchQuery.value.isNotEmpty) {
  //       queryParams['q'] = currentSearchQuery.value;
  //     }
  //
  //     DateTime? effectiveFromDate;
  //     DateTime? effectiveToDate;
  //
  //     switch (currentFilterDateRange.value) {
  //       case AppointmentFilterDateRange.all:
  //         break;
  //       case AppointmentFilterDateRange.thisMonth:
  //         effectiveFromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  //         effectiveToDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  //         break;
  //       case AppointmentFilterDateRange.lastMonth:
  //         final now = DateTime.now();
  //         effectiveFromDate = DateTime(now.year, now.month - 1, 1);
  //         effectiveToDate = DateTime(now.year, now.month, 0);
  //         break;
  //       case AppointmentFilterDateRange.thisWeek:
  //         final now = DateTime.now();
  //         effectiveFromDate = now.subtract(Duration(days: now.weekday - 1));
  //         effectiveToDate = effectiveFromDate.add(const Duration(days: 6));
  //         break;
  //       case AppointmentFilterDateRange.custom:
  //         effectiveFromDate = filterFromDate.value;
  //         effectiveToDate = filterToDate.value;
  //         break;
  //     }
  //
  //     if (effectiveFromDate != null) {
  //       queryParams['from'] = DateFormat('yyyy-MM-dd').format(effectiveFromDate);
  //     }
  //     if (effectiveToDate != null) {
  //       queryParams['to'] = DateFormat('yyyy-MM-dd').format(effectiveToDate);
  //     }
  //
  //     if (selectedFilterStaffId.value.isEmpty && doctors.isNotEmpty) {
  //       selectedFilterStaffId.value = doctors.first.id ?? '';
  //     }
  //
  //     if (selectedFilterStaffId.value.isEmpty) {
  //       Get.snackbar("Info", "No staff selected to fetch appointments. Please select a staff member or ensure doctors are loaded.");
  //       isLoading.value = false;
  //       return;
  //     }
  //
  //     final uri = Uri.parse("${ApiConstants.GET_APPOINTMENT_LIST}/${selectedFilterStaffId.value}").replace(
  //         queryParameters: queryParams);
  //
  //     final response = await http.get(
  //       uri,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data["success"] == 1 && data["body"] != null) {
  //         final List<dynamic> list = data["body"];
  //         List<AppointmentModel> fetchedAppointments = list.map((e) => AppointmentModel.fromJson(e)).toList();
  //
  //         // Enrich appointments with names (logic unchanged)
  //         List<AppointmentModel> enrichedAppointments = [];
  //         for (var appointment in fetchedAppointments) {
  //           final patient = patients.firstWhereOrNull((p) => p.id == appointment.patientId);
  //           final staff = doctors.firstWhereOrNull((d) => d.id == appointment.staffId);
  //           // Assuming you add patientFullName/staffFullName to AppointmentModel or handle display separately
  //           enrichedAppointments.add(appointment);
  //         }
  //         appointments.assignAll(enrichedAppointments);
  //       } else {
  //         appointments.clear();
  //       }
  //     } else {
  //       Get.snackbar("Error", "Failed to fetch all appointments (${response.statusCode})");
  //       appointments.clear();
  //     }
  //   } catch (e) {
  //     Get.snackbar("Exception", "Error fetching all appointments: $e");
  //     print("Error fetching all appointments: $e");
  //     appointments.clear();
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // --- Filtering Methods --- (Unchanged)

  Future<void> fetchPatientAppointments() async {
    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      final Map<String, String> queryParams = {};

      // ✅ Search
      if (currentSearchQuery.value.trim().isNotEmpty) {
        queryParams['search'] = currentSearchQuery.value.trim();
      }

      // ✅ Date range filters
      // DateTime? effectiveFromDate;
      // DateTime? effectiveToDate;

      DateTime from;
      DateTime to;
      final now = DateTime.now();

      switch (currentFilterDateRange.value) {
        case DateRangeOption.thisMonth:
          from = DateTime(now.year, now.month, 1);
          to = DateTime(now.year, now.month + 1, 0);
          break;
        case DateRangeOption.lastMonth:
          final lastMonth = DateTime(now.year, now.month - 1, 1);
          from = lastMonth;
          to = DateTime(lastMonth.year, lastMonth.month + 1, 0);
          break;
        case DateRangeOption.thisWeek:
          from = now.subtract(Duration(days: now.weekday - 1));
          to = from.add(const Duration(days: 6));
          break;
        case DateRangeOption.custom:
          from = filterFromDate.value ?? now;
          to = filterToDate.value ?? now;
          break;
      }

      queryParams['from'] = DateFormat('yyyy-MM-dd').format(from);
      queryParams['to'] = DateFormat('yyyy-MM-dd').format(to);

      // ✅ Add status filter if applied
      if (currentFilterStatus.isNotEmpty) {
        // Join multiple selected statuses with comma
        queryParams['status'] = currentFilterStatus.join(',');
      }

      // ✅ Add pagination (optional)
      queryParams['limit'] = '20';

      String staffIdForRequest = '';

      if (Global.role == 3) {
        // If doctor logged in
        staffIdForRequest = Global.staffId??'';
      } else {
        // 👥 Admin or other roles
        if (selectedFilterStaffId.value.isEmpty && doctors.isNotEmpty) {
          selectedFilterStaffId.value = doctors.first.id ?? '';
        }
        staffIdForRequest = selectedFilterStaffId.value;
      }
      if (staffIdForRequest.isEmpty) {
        Get.snackbar("Info", "No staff selected to fetch appointments.");
        isLoading.value = false;
        return;
      }

      // ✅ Ensure staff ID selected
      // if (selectedFilterStaffId.value.isEmpty && doctors.isNotEmpty) {
      //   selectedFilterStaffId.value = doctors.first.id ?? '';
      // }



      // if (selectedFilterStaffId.value.isEmpty) {
      //   Get.snackbar("Info", "No staff selected to fetch appointments.");
      //   isLoading.value = false;
      //   return;
      // }

      // final uri = Uri.parse(
      //   "${ApiConstants.GET_APPOINTMENT_LIST}/${selectedFilterStaffId.value}",
      // ).replace(queryParameters: queryParams);

      final uri = Uri.parse(
        "${ApiConstants.GET_APPOINTMENT_LIST}/$staffIdForRequest",
      ).replace(queryParameters: queryParams);


      print('get appointment list api url ==> $uri');

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
          final List<dynamic> list = data["body"]["rows"];
          appointments.assignAll(list.map((e) => AppointmentModel.fromJson(e)).toList());
        }
        // if (data["success"] == 1 && data["body"] != null) {
        //   final body = data["body"];
        //   final List<dynamic> list = body["rows"] ?? []; // ✅ Corrected: rows, not body
        //
        //   List<AppointmentModel> fetchedAppointments =
        //   list.map((e) => AppointmentModel.fromJson(e)).toList();
        //
        //   appointments.assignAll(fetchedAppointments);
        // }
        else {
          appointments.clear();
        }
      } else {
        Get.snackbar("Error", "Failed to fetch appointments (${response.statusCode})");
        appointments.clear();
      }
    } catch (e) {
      Get.snackbar("Exception", "Error fetching appointments: $e");
      print("Error fetching appointments: $e");
      appointments.clear();
    } finally {
      isLoading.value = false;
    }
  }


  void applySearch(String query) {
    currentSearchQuery.value = query;
  }

  // void setStatusFilter(String status) {
  //   currentFilterStatus.value = status;
  // }

  void setDateRangeFilter(DateRangeOption range) {
    currentFilterDateRange.value = range;
    if (range != DateRangeOption.custom) {
      filterFromDate.value = null;
      filterToDate.value = null;
    }
  }

  Future<void> showCustomDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: filterFromDate.value != null && filterToDate.value != null
          ? DateTimeRange(start: filterFromDate.value!, end: filterToDate.value!)
          : null,
    );

    if (picked != null) {
      filterFromDate.value = picked.start;
      filterToDate.value = picked.end;
      currentFilterDateRange.value = DateRangeOption.custom;
    }
  }

  void clearFilters() {
    searchController.clear();
    currentSearchQuery.value = '';
    currentFilterStatus.value = [];
    currentFilterDateRange.value = DateRangeOption.thisMonth;
    filterFromDate.value = null;
    filterToDate.value = null;
  }

  /// API: Fetch appointments for a given date range (month) for Calendar view
  Future<void> _fetchAppointmentsForRange(DateTime date) async {
    if (selectedStaffId.value.isEmpty) {
      eventController.removeWhere((event) => true);
      allDayAppointments.clear();
      return;
    }


    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      DateTime fetchStartDate = DateTime(date.year, date.month, 1);
      DateTime fetchEndDate = DateTime(date.year, date.month + 1, 0);

      final uri = Uri.parse(
          "${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/${selectedStaffId.value}")
          .replace(queryParameters: {
        "from": DateFormat('yyyy-MM-dd').format(fetchStartDate),
        "to": DateFormat('yyyy-MM-dd').format(fetchEndDate),
      });

      print("API route for calendar: $uri");
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
          final List<CalendarEventData<CalendarAppointment>> fetchedCalendarEvents = [];

          // Clear existing events for the current staff before adding new ones
          eventController.removeWhere((event) => true); // Clear all events


          for (var dayJson in daysData) {
            final DayAppointments dayAppts = DayAppointments.fromJson(dayJson);

            for (var event in dayAppts.events) {
              try {
                final appointmentDate = DateTime.parse(dayAppts.date);

                // Safely format time, handle null/empty strings
                final String formattedStartTime = _formatTime(event.start);
                final String formattedEndTime = _formatTime(event.end);

                // Split only if formatted time is valid
                final startParts = formattedStartTime.split(':');
                final endParts = formattedEndTime.split(':');

                // Ensure parts have at least two elements before parsing
                if (startParts.length < 2 || endParts.length < 2) {
                  print("Skipping event due to invalid time format: ${event.title}");
                  continue;
                }

                final startTime = DateTime(
                  appointmentDate.year,
                  appointmentDate.month,
                  appointmentDate.day,
                  int.tryParse(startParts[0]) ?? 0,
                  int.tryParse(startParts[1]) ?? 0,
                );
                final endTime = DateTime(
                  appointmentDate.year,
                  appointmentDate.month,
                  appointmentDate.day,
                  int.tryParse(endParts[0]) ?? 0,
                  int.tryParse(endParts[1]) ?? 0,
                );

                // Determine background color based on event type and status
                Color eventColor = Colors.red; // Default to red
                String displayTitle = event.title;
                if (event.type == 'booked') {
                  if (event.status == 'PENDING') {
                    eventColor = Colors.orange..shade400;
                  } else if (event.status == 'CONFIRMED') {
                    eventColor = Colors.green.shade600;
                  }
                } else if (event.type == 'leave') {
                  eventColor = Colors.grey;
                  displayTitle = event.title;
                }

                fetchedCalendarEvents.add(
                  CalendarEventData<CalendarAppointment>(
                    date: appointmentDate,
                    startTime: startTime,
                    endTime: endTime,
                    // title: event.title,
                    title: displayTitle,
                    // description: event.title, // or more detailed description
                    description: displayTitle, // or more detailed description
                    color: eventColor,
                    event: CalendarAppointment(
                      date: appointmentDate,
                      startTime: startTime,
                      endTime: endTime,
                      title: event.title,
                      color: eventColor,
                      appointmentId: event.id,
                      patientId: event.patientId,
                      visitType: event.visitType,
                      status: event.status,
                    ),
                  ),
                );
              } catch (e) {
                print("Error parsing event time or data for ${event.title}: $e");
              }
            }
          }
          eventController.addAll(fetchedCalendarEvents);
        }
      } else {
        Get.snackbar("Error", "Failed to fetch appointments (${response.statusCode})");
      }
    } catch (e) {
      // Get.snackbar("Exception", "Error fetching appointments for range: $e");
      print('Exception error fetching appointments for range: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// NEW: API to fetch available and booked slots for a specific day
  Future<void> _fetchAppointmentsForDaySlots(DateTime date) async {
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

      print("API route for day slots: $uri");
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
            availableSlots.assignAll(dayAppts.slots.available);
            bookedSlots.assignAll(dayAppts.events); // Use events for booked slots to get full info for dialog
          } else {
            availableSlots.clear();
            bookedSlots.clear();
          }
        }
      } else {
        Get.snackbar(
            "Error", "Failed to fetch day slots (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Exception", "Error fetching day slots: $e");
      print('Exception error fetching day slots: $e');
    } finally {
      isLoading.value = false;
    }
  }


  /// API: Update Appointment Status (Unchanged logic, just ensure models are null-safe)
  Future<void> updateAppointmentStatus(String appointmentId, String status, String patientId, String creatorId) async {
    isLoading.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final token = await TokenStorage.getToken();
      final body = {
        "reference_id": appointmentId,
        "patient_id": patientId,
        "creator_id": creatorId,
        "status": status
      };
      final response = await http.put(
        Uri.parse(ApiConstants.UPDATE_APPOINTMENT_STATUS),
        headers: { "Authorization": "Bearer $token",
          "Content-Type": "application/json",},
        body: jsonEncode(body),
      );
      Get.back();
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Appointment $status successfully");
        await fetchPatientAppointments();
        editingStatuses.remove(appointmentId);
        _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar
        _fetchAppointmentsForDaySlots(selectedDate.value); // Refresh dialog slots
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", "Failed to update appointment: ${errorData["msg"] ?? response.statusCode}");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Exception", "Error updating appointment status: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setEditingStatus(String appointmentId, String status) {
    editingStatuses[appointmentId] = status;
  }

  String getEditingStatus(String appointmentId, String defaultStatus) {
    return editingStatuses[appointmentId] ?? defaultStatus;
  }

  // --- NEW: Time Slot Conflict Detection ---
  bool _isTimeSlotBooked(String proposedStartTime, String proposedEndTime, {String? appointmentIdToExclude}) {
    if (proposedStartTime.isEmpty || proposedEndTime.isEmpty) {
      return false; // Cannot check if times are not selected
    }

    try {
      final DateFormat timeFormat = DateFormat('HH:mm');
      final DateTime proposedStart = timeFormat.parse(proposedStartTime);
      final DateTime proposedEnd = timeFormat.parse(proposedEndTime);

      // Convert proposed times to DateTime objects for the selected date
      final DateTime newAppointmentStart = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day, proposedStart.hour, proposedStart.minute);
      final DateTime newAppointmentEnd = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day, proposedEnd.hour, proposedEnd.minute);

      for (var bookedEvent in bookedSlots) {
        // Skip the current appointment being edited
        if (appointmentIdToExclude != null && bookedEvent.id == appointmentIdToExclude) {
          continue;
        }

        if (bookedEvent.start == null || bookedEvent.end == null) {
          continue; // Skip malformed booked events
        }

        final DateTime bookedEventStart = timeFormat.parse(bookedEvent.start!);
        final DateTime bookedEventEnd = timeFormat.parse(bookedEvent.end!);

        final DateTime existingAppointmentStart = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day, bookedEventStart.hour, bookedEventStart.minute);
        final DateTime existingAppointmentEnd = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day, bookedEventEnd.hour, bookedEventEnd.minute);

        // Check for overlap:
        // (StartA < EndB) && (EndA > StartB)
        if (newAppointmentStart.isBefore(existingAppointmentEnd) && newAppointmentEnd.isAfter(existingAppointmentStart)) {
          return true; // Conflict found
        }
      }
    } catch (e) {
      print("Error in _isTimeSlotBooked: $e");
      // Handle parsing errors gracefully, perhaps show a snackbar for invalid time format
      return true; // Assume conflict if times are unparseable
    }
    return false; // No conflict
  }

  // NEW: Validate time input from TimePicker against booked slots
  void _validateAndSetTime(Function(String) setter, String newTime) {
    // Temporarily set the time to check for conflicts (depends on which is being set)
    String tempStartTime = (setter == (val) => startTime.value = val) ? newTime : startTime.value;
    String tempEndTime = (setter == (val) => endTime.value = val) ? newTime : endTime.value;

    if (tempStartTime.isNotEmpty && tempEndTime.isNotEmpty) {
      if (_isTimeSlotBooked(tempStartTime, tempEndTime, appointmentIdToExclude: isEditMode.value ? selectedAppointmentId.value : null)) {
        Get.snackbar(
          'Error',
          'This time slot overlaps with an existing appointment. Please choose another.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return;
      }
    }

    setter(newTime);
    updateSaveEnabled();
  }

  // void selectTimeSlot(TimeSlot slot) {
  //   startTime.value = slot.start ?? "";
  //   endTime.value = slot.end ?? "";
  //   selectedAppointmentId.value = null;
  //   isEditMode.value = false;
  //   updateSaveEnabled();
  // }
  void selectTimeSlot(TimeSlot slot) {
    // Check if the selected available slot is actually still available (not newly booked by someone else)
    if (_isTimeSlotBooked(slot.start ?? "", slot.end ?? "", appointmentIdToExclude: isEditMode.value ? selectedAppointmentId.value : null)) {
      Get.snackbar(
        'Error',
        'This slot is no longer available. Please choose another.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }
    startTime.value = slot.start ?? "";
    endTime.value = slot.end ?? "";
    selectedAppointmentId.value = null;
    isEditMode.value = false;
    updateSaveEnabled();
  }


  void selectExistingAppointment(CalendarAppointment appointment) {
    isEditMode.value = true;
    selectedAppointmentId.value = appointment.appointmentId;
    startTime.value = DateFormat('HH:mm').format(appointment.startTime!); // Use startTime from CalendarAppointment
    endTime.value = DateFormat('HH:mm').format(appointment.endTime!);   // Use endTime from CalendarAppointment
    selectedPatientId.value = appointment.patientId ?? "";
    selectedVisitType.value = appointment.visitType ?? "";

    final selectedPatient =
    patients.firstWhereOrNull((p) => p.id == appointment.patientId);
    selectedPatientName.value = (selectedPatient != null)
        ? "${selectedPatient.firstname ?? ''} ${selectedPatient.lastname ?? ''}"
        : "";

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

  Future<void> bookAppointment() async {
    if (_isTimeSlotBooked(startTime.value, endTime.value)) {
      Get.snackbar(
        'Error',
        'The selected time slot is already booked. Please choose another.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.red.shade400,
      );
      return;
    }
    isLoading.value = true;

    // Ensure start/end times are parsed correctly
    final parsedStartTime = DateFormat('HH:mm').parse(startTime.value);
    final parsedEndTime = DateFormat('HH:mm').parse(endTime.value);

    // Combine selected date with time parts
    final appointmentStartTime = DateTime(selectedDate.value.year, selectedDate.value.month,
        selectedDate.value.day, parsedStartTime.hour, parsedStartTime.minute);
    final appointmentEndTime = DateTime(selectedDate.value.year, selectedDate.value.month,
        selectedDate.value.day, parsedEndTime.hour, parsedEndTime.minute);

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
        Get.back();
        print('success');
        _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar appointments
        _fetchAppointmentsForDaySlots(selectedDate.value); // Refresh dialog slots
        clearAppointmentSelection();
        fetchPatientAppointments();
      } else {
        Get.snackbar('Error', 'Failed to book appointment: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', 'Error booking appointment: $e');
    }
  }

  Future<void> updateAppointment() async {
    if (selectedAppointmentId.value == null) {
      Get.snackbar('Error', 'No appointment selected for update.');
      return;
    }

    isLoading.value = true;

    final token = await TokenStorage.getToken();
    final url = Uri.parse(ApiConstants.UPDATE_APPOINTMENT);

    final body = {
      "reference_id": selectedAppointmentId.value,
      "patient_id": selectedPatientId.value,
      "patient_name": selectedPatientName.value,
      "date": DateFormat('yyyy-MM-dd').format(selectedDate.value),
      "time_slot": {
        "start": startTime.value,
        "end": endTime.value,
      },
      "visit_type": selectedVisitType.value,
    };

    print('body: $body');

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
        Get.back();
        print('response body: ${response.body}');
        _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar appointments
        _fetchAppointmentsForDaySlots(selectedDate.value); // Refresh dialog slots
        clearAppointmentSelection();
        fetchPatientAppointments();
      } else {
        Get.snackbar('Error', 'Failed to update appointment: ${response.body}');
        print('error response body: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', 'Error updating appointment: $e');
    }
  }

  void handleSaveAppointment() {
    if (isEditMode.value) {
      updateAppointment();
    } else {
      bookAppointment();
    }
  }
}











