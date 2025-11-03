import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Only Syncfusion
import 'package:om_health_care_app/app/global/global.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/patients_model.dart';
import '../../../data/models/staff_list_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

enum DateRangeOption { thisMonth, lastMonth, thisWeek, custom }

class AppointmentController extends GetxController {
  /// Observables
  var isLoading = false.obs;
  final isLoadingPatients = false.obs;
  var doctors = <StaffListModel>[].obs;
  var patients = <PatientModel>[].obs;
  var appointments = <AppointmentModel>[].obs; // For the list view appointments

  var doctorSchedule = <DayAppointments>[].obs;
  var scheduleMap = <String, DayAppointments>{}.obs;

  // New: List of Syncfusion Appointment objects for the calendar
  var sfCalendarAppointments = <Appointment>[].obs;

  var skip = 0.obs;
  final int pageSize = 10;
  var hasMore = true.obs;

  var selectedDate = DateTime.now().obs;
  var isPastSelectedDate = false.obs;


  var availableSlots = <TimeSlot>[].obs; // This will hold available slots for the selectedDate
  var bookedSlots = <Event>[].obs; // This will hold booked events for the selectedDate (from DayAppointments)
  var startTime = "".obs;
  var endTime = "".obs;
  var selectedPatientId = "".obs;
  var selectedPatientName = "".obs;
  var selectedVisitType = "".obs;
  var selectedStaffId = "".obs;

  var leaveStartTime = "".obs;
  var leaveEndTime = "".obs;

  var selectedAppointmentId = Rxn<String>();

  final selectedDoctor = Rxn<StaffListModel>();
  final dateRangeOption = DateRangeOption.thisMonth.obs;

  var saveEnabled = false.obs;
  var isEditMode = false.obs;

  var editingStatuses = <String, String>{}.obs;

  final TextEditingController searchController = TextEditingController();
  var currentSearchQuery = ''.obs;
  var currentFilterStatus = <String>[].obs;

  var currentFilterDateRange = DateRangeOption.thisMonth.obs;
  var filterFromDate = Rxn<DateTime>();
  var filterToDate = Rxn<DateTime>();
  var selectedFilterStaffId = ''.obs;

  final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  final DateFormat _displayTimeFormat12Hour = DateFormat('hh:mm a');
  final DateFormat _apiTimeFormat24Hour = DateFormat('HH:mm');

  late Worker _selectedDateWorker;
  final scrollController = ScrollController();

  final customFrom = Rxn<DateTime>();
  final customTo = Rxn<DateTime>();

  var appointmentsSkip = 0.obs;
  final int appointmentsPageSize = 20;
  var appointmentsHasMore = true.obs;

  final selectedStatus = ''.obs;


  String formatTimeForDisplay(String? time24Hour) {
    if (time24Hour == null || time24Hour.isEmpty) return '';
    try {
      final dateTime = _apiTimeFormat24Hour.parse(time24Hour);
      return _displayTimeFormat12Hour.format(dateTime);
    } catch (e) {
      print("Error formatting time for display: $e (Input: $time24Hour)");
      return time24Hour ?? ''; // Fallback
    }
  }

  String parseDisplayTimeForApi(String? time12Hour) {
    if (time12Hour == null || time12Hour.isEmpty) return '';
    try {
      final dateTime = _displayTimeFormat12Hour.parse(time12Hour);
      return _apiTimeFormat24Hour.format(dateTime);
    } catch (e) {
      print("Error parsing display time for API: $e (Input: $time12Hour)");
      return time12Hour ?? ''; // Fallback, assuming it might already be 24-hour
    }
  }



  @override
  void onInit() {
    super.onInit();
    _updateFilterDatesForOption(DateRangeOption.thisMonth);

    ever(currentFilterDateRange, (DateRangeOption option) {
      if (option != DateRangeOption.custom) { // Custom dates are handled directly by DateSelectorController
        _updateFilterDatesForOption(option);
      }
    });

    // _selectedDateWorker = ever(selectedDate, _updateUIForSelectedDate);
    _selectedDateWorker = ever(selectedDate, (date) {
      _updateUIForSelectedDate(date);
      // Determine if the selected date is in the past (before today)
      final today = DateTime.now();
      isPastSelectedDate.value = date.isBefore(DateTime(today.year, today.month, today.day));
    });

    // Initial load for doctors and patient appointments list
    // fetchDoctors(clear: true).then((_) {
    //   if (doctors.isNotEmpty && selectedFilterStaffId.value.isEmpty) {
    //     selectedFilterStaffId.value = doctors.first.id ?? '';
    //   }
    //   // fetchPatientAppointments(); // This is for the list view appointments
    // });
    fetchDoctors(clear: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
        // When close to bottom, try to fetch more
        if (!isLoading.value && hasMore.value) {
          fetchDoctors();
        }
      }
    });

  }

  @override
  void onClose() {
    _selectedDateWorker.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _updateFilterDatesForOption(DateRangeOption option) {
    final now = DateTime.now();
    DateTime from;
    DateTime to;

    switch (option) {
      case DateRangeOption.thisMonth:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0);
        break;
      case DateRangeOption.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        from = lastMonthStart;
        to = DateTime(lastMonthStart.year, lastMonthStart.month + 1, 0);
        break;
      case DateRangeOption.thisWeek:
        from = now.subtract(Duration(days: now.weekday - 1));
        to = from.add(const Duration(days: 6)); // Assuming a full 7-day week from start
        break;
      case DateRangeOption.custom:
      // For custom, filterFromDate and filterToDate are directly set by DateSelectorController
        return; // No need to calculate here, values are already set
    }
    filterFromDate.value = from;
    filterToDate.value = to;
  }

  DateTime get fromDate {
    // If filterFromDate is null (e.g., initial state or error), provide a fallback.
    // However, with proper initialization, it shouldn't be null.
    return filterFromDate.value ?? DateTime.now();
  }

  DateTime get toDate {
    // If filterToDate is null, provide a fallback.
    return filterToDate.value ?? DateTime.now();
  }

  bool isDoctorOnLeaveForSelectedDate() {
    final selected = selectedDate.value;
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selected);

    leaveStartTime.value = "";
    leaveEndTime.value = "";

    try {
      // Find the DayAppointments that matches the selected date
      final dayAppointment = doctorSchedule.firstWhereOrNull(
            (day) => day.date == selectedDateStr,
      );

      if (dayAppointment == null) return false;

      // Check if that day has any 'leave' type events
      // final hasLeaveEvent = dayAppointment.events.any(
      //       (event) => event.type.toLowerCase() == 'leave',
      // );
      final leaveEvent = dayAppointment.events.firstWhereOrNull(
            (event) => event.type.toLowerCase() == 'leave',
      );

      if (leaveEvent != null) {
        // FOUND LEAVE: Store its times and return true
        leaveStartTime.value = leaveEvent.start ?? "";
        leaveEndTime.value = leaveEvent.end ?? "";

        print("Checking leave for date: $selectedDateStr → true (Leave event found)");
        return true;
      }

      // Log for debugging
      print("Checking leave for date: $selectedDateStr → false (No leave event)");

      // return hasLeaveEvent;
      return false;
    } catch (e) {
      print("Error checking doctor leave for selected date: $e");
      return false;
    }
  }


  Future<void> setSelectedStaff(String staffId) async{
    if (selectedStaffId.value == staffId) {

      if (doctorSchedule.isNotEmpty && scheduleMap.isNotEmpty) {
        _populateSfCalendarEvents(); // Populate Syncfusion events
        _updateUIForSelectedDate(selectedDate.value);
        return;
      }
    }

    selectedStaffId.value = staffId;
    selectedFilterStaffId.value = staffId; // Keep this in sync if needed elsewhere
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day); // Set to today

    // Fetch data for the current month when a staff is selected
    await  fetchDataForMonth(selectedDate.value);
  }

  Future<void> fetchDataForMonth(DateTime monthDate) async {
      print('enter start');
    if (selectedStaffId.value.isEmpty) return;
    print('enter here');
    if (isLoading.value) return;
    print('enter now');
    isLoading.value = true;
    try {
      final from = _apiDateFormat.format(DateTime(monthDate.year, monthDate.month, 1));
      final to = _apiDateFormat.format(DateTime(monthDate.year, monthDate.month + 1, 0));

      await _fetchDoctorScheduleAndPatients(selectedStaffId.value, from, to);

      // After data is fetched, update the calendar dots and bottom list for the currently selected date
      _populateSfCalendarEvents(); // Populate Syncfusion events
      _updateUIForSelectedDate(selectedDate.value);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchDoctorScheduleAndPatients(
      String staffId, String from, String to) async {
    try {
      print('enter _fetchDoctorScheduleAndPatients');
      final token = await TokenStorage.getToken();
      final uri = Uri.parse(
          "${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/$staffId")
          .replace(queryParameters: {"from": from, "to": to});
      print("get appointment by doctor api route===>$uri");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('get appointment by doctor response body ===> ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"] != null) {
          final List<dynamic> scheduleList = data["body"];
          final List<DayAppointments> newSchedule = [];

          for (var item in scheduleList) {
            if (item != null && item is Map<String, dynamic>) {
              try {
                newSchedule.add(DayAppointments.fromJson(item));
              } catch (e) {
                print("--- FAILED TO PARSE ONE APPOINTMENT ---");
                print("Error: $e. \nItem was: $item");
                print("--------------------------------------");
              }
            } else {
              print("Skipping invalid item in schedule list: $item");
            }
          }
          doctorSchedule.assignAll(newSchedule);

          // Populate the map for quick lookup
          scheduleMap.clear();
          for (var day in newSchedule) {
            if (day.date != null) {
              scheduleMap[day.date!] = day;
            }
          }

          // Fetch patients after schedule data is available
          await _fetchAssignedPatients(staffId);

        } else {
          doctorSchedule.clear();
          scheduleMap.clear();
          patients.clear();
          Get.snackbar("API Error", data["msg"] ?? "Failed to load schedule");
        }
      } else {
        Get.snackbar(
            "Error", "Failed to fetch schedule (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Exception", "Error fetching schedule: $e");
      print("Error fetching schedule: $e");
    }
  }


  Future<void> _fetchAssignedPatients(String staffId) async {
      print('enter here');
    isLoadingPatients.value = true;
    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse(
          "${ApiConstants.BASE_URL}/get-patients-by-assign-doctor")
          .replace(queryParameters: {'doctor_id': staffId});

      print('get assign patient uri ::: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
print('patient response:: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"] != null) {
          final List<dynamic> patientList = data["body"];
          patients.assignAll(patientList
              .map((e) => PatientModel.fromMap(e as Map<String, dynamic>))
              .toList());
        } else {
          patients.clear();
        }
      }
    } catch (e) {
      Get.snackbar("Exception", "Error fetching patients: $e");
    } finally {
      isLoadingPatients.value = false;
    }
  }

  void _populateSfCalendarEvents() {
    sfCalendarAppointments.clear();

    for (var day in doctorSchedule) {
      final date = _apiDateFormat.parse(day.date!);

      bool hasGrey = false;
      bool hasGreen = false;
      bool hasOrange = false;

      // ---------------------------------
      // Case 1: Leave slots → Grey dot
      // ---------------------------------
      if (day.slots.leave.isNotEmpty && !hasGrey) {
        for (var leaveSlot in day.slots.leave) {
          final startParts = leaveSlot.start?.split(':') ?? [];
          final endParts = leaveSlot.end?.split(':') ?? [];

          if (startParts.length == 2 && endParts.length == 2) {
            final startTime = DateTime(date.year, date.month, date.day,
                int.parse(startParts[0]), int.parse(startParts[1]));
            final endTime = DateTime(date.year, date.month, date.day,
                int.parse(endParts[0]), int.parse(endParts[1]));

            sfCalendarAppointments.add(
              Appointment(
                startTime: startTime,
                endTime: endTime,
                subject: "Doctor on Leave",
                color: Colors.grey,
                notes: jsonEncode({
                  "status": "leave",
                  "visitType": "leave",
                }),
              ),
            );
            hasGrey = true; // ✅ mark added
            break; // stop after 1 grey appointment for this day
          }
        }
      }

      // ---------------------------------
      // Case 2: Booked events → Green or Orange dots
      // ---------------------------------
      if (day.events.isNotEmpty) {
        for (var event in day.events) {
          try {
            if (event.type == 'leave') continue; // skip leave-type events

            final startParts = event.start.split(':');
            final endParts = event.end.split(':');

            final startTime = DateTime(
              date.year,
              date.month,
              date.day,
              int.parse(startParts[0]),
              int.parse(startParts[1]),
            );

            final endTime = DateTime(
              date.year,
              date.month,
              date.day,
              int.parse(endParts[0]),
              int.parse(endParts[1]),
            );

            // Determine color based on booking status
            if (event.status == 'CONFIRMED' && !hasGreen) {
              sfCalendarAppointments.add(
                Appointment(
                  startTime: startTime,
                  endTime: endTime,
                  subject: event.title,
                  color: Colors.green,
                  notes: jsonEncode({
                    "status": event.status,
                    "visitType": event.visitType,
                    "type": event.type,
                    "patientId": event.patientId,
                    "patientName": event.patientName,
                    "appointmentId": event.id,
                  }),
                ),
              );
              hasGreen = true; // ✅ only one green per day
            } else if (event.status != 'CONFIRMED' && !hasOrange) {
              sfCalendarAppointments.add(
                Appointment(
                  startTime: startTime,
                  endTime: endTime,
                  subject: event.title,
                  color: Colors.orange,
                  notes: jsonEncode({
                    "status": event.status,
                    "visitType": event.visitType,
                    "type": event.type,
                    "patientId": event.patientId,
                    "patientName": event.patientName,
                    "appointmentId": event.id,
                  }),
                ),
              );
              hasOrange = true; // ✅ only one orange per day
            }

            // Stop early if all 3 types already added
            if (hasGreen && hasOrange && hasGrey) break;
          } catch (e) {
            print("Error adding event appointment: $e");
          }
        }
      }
    }
  }


  Appointment _createSfAppointmentFromEvent(Event event, DateTime appointmentDate) {
    DateTime start = appointmentDate;
    DateTime end = appointmentDate;

    try {
      final formattedStartTime = _formatTime(event.start);
      final formattedEndTime = _formatTime(event.end);

      final startParts = formattedStartTime.split(':');
      final endParts = formattedEndTime.split(':');

      start = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        int.tryParse(startParts[0]) ?? 0,
        int.tryParse(startParts[1]) ?? 0,
      );
      end = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        int.tryParse(endParts[0]) ?? 0,
        int.tryParse(endParts[1]) ?? 0,
      );
    } catch (e) {
      print("Error parsing event time or data for ${event.title}: $e");
    }

    Color eventColor = Colors.red; // Default to red
    if (event.type == 'booked') {
      if (event.status == 'PENDING') {
        eventColor = Colors.orange.shade400;
      } else if (event.status == 'CONFIRMED') {
        eventColor = Colors.green.shade600;
      } else if (event.status == 'COMPLETED') {
        eventColor = Get.theme.primaryColor;
      }
    } else if (event.type == 'leave') {
      eventColor = Colors.grey.shade600;
    }

    // Store the full AppointmentModel as JSON in notes for easy retrieval
    final appointmentModel = AppointmentModel(
      appointmentId: event.id,
      patientId: event.patientId,
      patientName: event.patientName,
      visitType: event.visitType,
      date: _apiDateFormat.format(appointmentDate),
      timeSlot: TimeSlot(start: event.start, end: event.end),
      status: event.status,
      staffId: selectedStaffId.value,
    );

    return Appointment(
      startTime: start,
      endTime: end,
      subject: event.patientName ?? event.title, // Use patient name if available
      color: eventColor,
      isAllDay: false,
      notes: jsonEncode(appointmentModel.toJson()),
    );
  }


  void _updateUIForSelectedDate(DateTime date) {
    final dateString = _apiDateFormat.format(date);
    final dayData = scheduleMap[dateString];

    if (dayData != null) {
      availableSlots.assignAll(dayData.slots.available);
      bookedSlots.assignAll(dayData.events);
    } else {
      availableSlots.clear();
      bookedSlots.clear();
    }
  }

  void onMonthChanged(DateTime date) {
    // Determine the month of the first day in the currently loaded doctorSchedule
    if (doctorSchedule.isNotEmpty) {
      try {
        final firstDayDate = _apiDateFormat.parse(doctorSchedule.first.date!);
        if (firstDayDate.year == date.year && firstDayDate.month == date.month) {
          // The data for this month is already loaded
          return;
        }
      } catch (e) {
        print("Error parsing first day date from doctorSchedule: $e");
        // Proceed to fetch if parsing fails
      }
    }
    // Fetch data for the new month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isLoading.value) {
        fetchDataForMonth(date);
      }
    });
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

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '00:00';
    if (time.contains(':') && time.split(':').length == 2) {
      return time;
    }
    try {
      final format12 = DateFormat('h:mm a');
      final format24 = DateFormat('HH:mm');
      final dateTime = format12.parse(time);
      return format24.format(dateTime);
    } catch (e) {
      return '00:00'; // Fallback to a valid format
    }
  }

  /// API: Fetch Doctors (Unchanged)
  Future<void> fetchDoctors({
    bool clear = false,
    String search = '',
    String fromDate = '',
    String toDate = '',
  }) async {
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
  Future<void> fetchPatients({bool clear = false}) async {
    if (isLoadingPatients.value) return;
    try {
      isLoadingPatients.value = true;
      // skip.value = 0;
      // hasMore.value = true;

      if (clear) {
        skip.value = 0;
        hasMore.value = true;
        patients.clear();
      }

      if (!hasMore.value) return;

      if (filterFromDate.value == null || filterToDate.value == null) {
        Get.snackbar("Error", "Date range not selected for patients.");
        isLoadingPatients.value = false;
        return;
      }

      final from = DateFormat('yyyy-MM-dd').format(filterFromDate.value!);
      final to = DateFormat('yyyy-MM-dd').format(filterToDate.value!);

      final token = await TokenStorage.getToken();

      final doctorId = (Global.role == 3)
          ? Global.staffId
          : selectedDoctor.value?.id ?? '';

      if (doctorId!.isEmpty) {
        Get.snackbar("Error", "Doctor not selected");
        isLoadingPatients.value = false;
        return;
      }

      final queryParams = {
        'doctor_id': doctorId,
        'from_date': from,
        'to_date': to,
        'limit': pageSize.toString(),
        'skip': skip.value.toString(),
        'search': currentSearchQuery.value,
      };

      if (currentFilterStatus.isNotEmpty) {
        queryParams['patient_status'] = currentFilterStatus.join(', ');
      }

      final uri = Uri.parse(ApiConstants.GET_PATIENTS).replace(
        queryParameters: queryParams,
      );

      print('get patient api url : ${uri}');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('get patient api response : ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"]?["rows"] != null) {
          final rows = List<Map<String, dynamic>>.from(data['body']['rows']);
          final newPatients = rows.map((e) => PatientModel.fromMap(e)).toList();
          // patients.assignAll(rows.map((e) => PatientModel.fromMap(e)).toList());
          // patients.assignAll(newPatients);
          if (clear) {
            patients.assignAll(newPatients);
          } else {
            patients.addAll(newPatients);
          }

          // if (newPatients.length < pageSize) {
          //   hasMore.value = false;
          // }
          final totalCount = data["body"]["total_count"] ?? 0;
          if (patients.length >= totalCount || newPatients.length < pageSize) {
            hasMore.value = false;
          } else {
            skip.value += pageSize;
          }
        } else {
          // patients.clear();
          // hasMore.value = false;
          if (clear) patients.clear();
          hasMore.value = false;

        }
      }else {
        Get.snackbar("Error", "Failed to fetch patients (${response.statusCode})");
        hasMore.value = false;
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
      // patients.clear();
      hasMore.value = false;
    } finally {
      isLoadingPatients.value = false;
    }
  }



  void selectDoctor(StaffListModel? d) {
    selectedDoctor.value = d;
  }

  void changeDateRange(DateRangeOption option) {
    dateRangeOption.value = option;
    if (option != DateRangeOption.custom) {
      customFrom.value = null;
      customTo.value = null;
    }
  }

  void setCustomRange(DateTime from, DateTime to) {
    customFrom.value = from;
    customTo.value = to;
  }

  Future<void> fetchPatientAppointments({bool clear = false}) async {
    // isLoading.value = true;
    // if (isLoading.value) return;
    try {
      isLoading.value = true;

      if (clear) {
        appointmentsSkip.value = 0;
        appointmentsHasMore.value = true;
        appointments.clear();
      }

      if (!appointmentsHasMore.value) return;

      final token = await TokenStorage.getToken();
      final Map<String, String> queryParams = {};

      if (currentSearchQuery.value.trim().isNotEmpty) {
        queryParams['search'] = currentSearchQuery.value.trim();
      }

      if (filterFromDate.value == null || filterToDate.value == null) {
        Get.snackbar("Error", "Date range not selected.");
        isLoading.value = false;
        return;
      }

      queryParams['from'] = DateFormat('yyyy-MM-dd').format(filterFromDate.value!);
      queryParams['to'] = DateFormat('yyyy-MM-dd').format(filterToDate.value!);


      if (currentFilterStatus.isNotEmpty) {
        queryParams['status'] = currentFilterStatus.join(',');
      }

      // queryParams['limit'] = '20';
      queryParams['skip'] = appointmentsSkip.value.toString();
      queryParams['limit'] = appointmentsPageSize.toString();

      String staffIdForRequest = '';

      if (Global.role == 3) {
        staffIdForRequest = Global.staffId ?? '';
      } else {
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

      final uri = Uri.parse(
          "${ApiConstants.GET_APPOINTMENT_LIST}/$staffIdForRequest")
          .replace(queryParameters: queryParams);

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
          // appointments.assignAll(list.map((e) => AppointmentModel.fromJson(e)).toList());
          final fetched = list.map((e) => AppointmentModel.fromJson(e)).toList();

          //  Append or Replace data
          if (clear) {
            appointments.assignAll(fetched);
          } else {
            appointments.addAll(fetched);
          }

          // Update skip and hasMore flags
          final totalCount = data["body"]["total_count"] ?? 0;
          if (appointments.length >= totalCount) {
            appointmentsHasMore.value = false;
          } else {
            appointmentsSkip.value += appointmentsPageSize;
          }
        } else {
          // appointments.clear();
          if (clear) appointments.clear();
          appointmentsHasMore.value = false;
        }
      } else {
        Get.snackbar(
            "Error", "Failed to fetch appointments (${response.statusCode})");
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

  // void applySearch(String query) {
  //   currentSearchQuery.value = query;
  // }

  // void setDateRangeFilter(DateRangeOption range) {
  //   currentFilterDateRange.value = range;
  //   if (range != DateRangeOption.custom) {
  //     filterFromDate.value = null;
  //     filterToDate.value = null;
  //   }
  // }

  // Future<void> showCustomDateRangePicker(BuildContext context) async {
  //   final DateTimeRange? picked = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     initialDateRange:
  //     filterFromDate.value != null && filterToDate.value != null
  //         ? DateTimeRange(start: filterFromDate.value!, end: filterToDate.value!)
  //         : null,
  //   );
  //
  //   if (picked != null) {
  //     filterFromDate.value = picked.start;
  //     filterToDate.value = picked.end;
  //     currentFilterDateRange.value = DateRangeOption.custom;
  //   }
  // }

  void clearFilters() {
    searchController.clear();
    currentSearchQuery.value = '';
    currentFilterStatus.value = [];
    currentFilterDateRange.value = DateRangeOption.thisMonth;
    filterFromDate.value = null;
    filterToDate.value = null;
    _updateFilterDatesForOption(DateRangeOption.thisMonth);
    fetchPatientAppointments(clear: true);
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status, String patientId, String creatorId) async {
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
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      Get.back();
      await Future.delayed(const Duration(milliseconds: 300));
      if (response.statusCode == 200) {

        Get.snackbar("Success", "Appointment $status successfully", snackPosition: SnackPosition.BOTTOM);

        await fetchPatientAppointments();
        editingStatuses.remove(appointmentId);
        // Refresh calendar view after status update
        fetchDataForMonth(selectedDate.value);

        Get.rootDelegate.popRoute();
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error",
            "Failed to update appointment: ${errorData["msg"] ?? response.statusCode}");
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

  Future<void> updatePatientStatus(String patientId, String newStatus) async {
    try {
      final token = await TokenStorage.getToken();
      final url =
      Uri.parse('${ApiConstants.UPDATE_PATIENT_STATUS}/$patientId');

      print('url ==> $url');

      final payload = {"patient_status": newStatus, "message": ""};

      print('payload==> ${payload}');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('response===> ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1) {
          Get.snackbar("Success", "Patient status updated successfully");
          await fetchPatients();
        } else {
          Get.snackbar("Error", data["msg"] ?? "Failed to update");
        }
      } else {
        Get.snackbar("Error", "Failed with status ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  bool _isTimeSlotBooked(String proposedStartTime, String proposedEndTime,
      {String? appointmentIdToExclude}) {
    if (proposedStartTime.isEmpty || proposedEndTime.isEmpty) {
      return false; // Cannot check if times are not selected
    }

    try {
      final DateFormat timeFormat = DateFormat('HH:mm');
      // final DateTime proposedStart = timeFormat.parse(proposedStartTime);
      // final DateTime proposedEnd = timeFormat.parse(proposedEndTime);
      final DateTime proposedStart = _apiTimeFormat24Hour.parse(proposedStartTime);
      final DateTime proposedEnd = _apiTimeFormat24Hour.parse(proposedEndTime);

      final DateTime newAppointmentStart = DateTime(
          selectedDate.value.year,
          selectedDate.value.month,
          selectedDate.value.day,
          proposedStart.hour,
          proposedStart.minute);
      final DateTime newAppointmentEnd = DateTime(
          selectedDate.value.year,
          selectedDate.value.month,
          selectedDate.value.day,
          proposedEnd.hour,
          proposedEnd.minute);

      for (var bookedEvent in bookedSlots) {
        if (appointmentIdToExclude != null && bookedEvent.id == appointmentIdToExclude) {
          continue;
        }

        // final DateTime bookedEventStart = timeFormat.parse(bookedEvent.start);
        // final DateTime bookedEventEnd = timeFormat.parse(bookedEvent.end);
        final DateTime bookedEventStart = _apiTimeFormat24Hour.parse(bookedEvent.start);
        final DateTime bookedEventEnd = _apiTimeFormat24Hour.parse(bookedEvent.end);

        final DateTime existingAppointmentStart = DateTime(
            selectedDate.value.year,
            selectedDate.value.month,
            selectedDate.value.day,
            bookedEventStart.hour,
            bookedEventStart.minute);
        final DateTime existingAppointmentEnd = DateTime(
            selectedDate.value.year,
            selectedDate.value.month,
            selectedDate.value.day,
            bookedEventEnd.hour,
            bookedEventEnd.minute);

        if (newAppointmentStart.isBefore(existingAppointmentEnd) &&
            newAppointmentEnd.isAfter(existingAppointmentStart)) {
          return true; // Conflict found
        }
      }
    } catch (e) {
      print("Error in _isTimeSlotBooked: $e");
      return true;
    }
    return false; // No conflict
  }

  // void validateAndSetTime(Function(String) setter, String newTime) {
  //   String tempStartTime = (setter == (val) => startTime.value = val) ? newTime : startTime.value;
  //   String tempEndTime = (setter == (val) => endTime.value = val) ? newTime : endTime.value;
  //
  //   if (tempStartTime.isNotEmpty && tempEndTime.isNotEmpty) {
  //     if (_isTimeSlotBooked(tempStartTime, tempEndTime, appointmentIdToExclude: isEditMode.value ? selectedAppointmentId.value : null)) {
  //       Get.snackbar(
  //         'Error',
  //         'This time slot overlaps with an existing appointment. Please choose another.',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red.shade400,
  //         colorText: Colors.white,
  //       );
  //       print('This time slot overlaps with an existing appointment. Please choose another.');
  //       return;
  //     }
  //   }
  //
  //   setter(newTime);
  //   updateSaveEnabled();
  // }

  void selectTimeSlot(TimeSlot slot) {
    if (_isTimeSlotBooked(slot.start ?? "", slot.end ?? "",
        appointmentIdToExclude: isEditMode.value ? selectedAppointmentId.value : null)) {
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

  void selectExistingAppointment(CalendarAppointment  appointment) {
    isEditMode.value = true;
    // final AppointmentModel originalApptModel = AppointmentModel.fromJson(jsonDecode(sfAppointment.notes!));

    selectedAppointmentId.value = appointment.appointmentId;
    // startTime.value = DateFormat('HH:mm').format(appointment.startTime);
    // endTime.value = DateFormat('HH:mm').format(appointment.endTime);
    startTime.value = _apiTimeFormat24Hour.format(appointment.startTime);
    endTime.value = _apiTimeFormat24Hour.format(appointment.endTime);
    selectedPatientId.value = appointment.patientId ?? "";
    selectedVisitType.value = appointment.visitType ?? "";

    final selectedPatient = patients.firstWhereOrNull((p) => p.id == appointment.patientId);
    // selectedPatientName.value = (selectedPatient != null)
    //     ? "${selectedPatient.firstname ?? ''} ${selectedPatient.lastname ?? ''}"
    //     : "";
    selectedPatientName.value = (selectedPatient != null)
        ? selectedPatient.fullName ?? ''
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

    print('visit type select ==> ${selectedVisitType}');

    final appointment = AppointmentModel(
      patientId: selectedPatientId.value,
      patientName: selectedPatientName.value,
      staffId: selectedStaffId.value,
      // date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
      date: _apiDateFormat.format(selectedDate.value),
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
        // Get.back();
        Get.rootDelegate.popRoute();
        print('success');
        // Refresh data for the current month after booking
        fetchDataForMonth(selectedDate.value);
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
    // if (selectedAppointmentId.value == null) {
    //   Get.snackbar('Error', 'No appointment selected for update.');
    //   return;
    // }
    if (selectedAppointmentId.value == null || selectedAppointmentId.value!.isEmpty) {
      Get.snackbar('Error', 'Cannot update appointment: ID is missing.');
      isLoading.value = false;
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
        // Get.back();
        Get.rootDelegate.popRoute();
        print('response body: ${response.body}');
        // Refresh data for the current month after updating
        fetchDataForMonth(selectedDate.value);
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