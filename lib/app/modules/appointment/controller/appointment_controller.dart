// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import '../../../data/models/appointment_model.dart';
// import '../../../data/models/staff_list_model.dart';
// import '../../../data/models/user_list_model.dart';
// import '../../../global/tokenStorage.dart';
// import '../../../utils/api_constants.dart';
//
// enum AppointmentFilterDateRange {
//   all, // Added 'all' to represent no date filter
//   thisMonth,
//   lastMonth,
//   thisWeek,
//   custom,
// }
//
// class AppointmentController extends GetxController {
//   /// Observables
//   var isLoading = false.obs;
//   var doctors = <StaffListModel>[].obs;
//   var patients = <UserListModel>[].obs;
//   var appointments = <AppointmentModel>[].obs; // This list will hold the fetched appointments for the patient_appointments_page
//
//   var allDayAppointments = <CalendarAppointment>[].obs; // All appointments for the month/range for calendar view
//
//   var skip = 0.obs; // For doctors pagination
//   final int pageSize = 10;
//   var hasMore = true.obs; // For doctors pagination
//
//   // Rx variables for calendar state and booking details
//   var selectedDate = DateTime.now().obs;
//   var availableSlots = <TimeSlot>[].obs;
//   var bookedSlots = <Event>[].obs;
//   var startTime = "".obs;
//   var endTime = "".obs;
//   var selectedPatientId = "".obs;
//   var selectedPatientName = "".obs;
//   var selectedVisitType = "".obs;
//   var selectedStaffId = "".obs; // This is used for the calendar view to filter by doctor
//
//   var selectedAppointmentId = Rxn<String>();
//
//   var saveEnabled = false.obs;
//   var isEditMode = false.obs;
//
//   var editingStatuses = <String, String>{}.obs;
//
//   // Search and Filter specific for PatientAppointmentsPage
//   final TextEditingController searchController = TextEditingController();
//   var currentSearchQuery = ''.obs;
//   var currentFilterStatus = ''.obs; // For status filter dropdown (e.g., PENDING, CONFIRMED, CANCELLED)
//   var currentFilterDateRange = AppointmentFilterDateRange.all.obs;
//   var filterFromDate = Rxn<DateTime>();
//   var filterToDate = Rxn<DateTime>();
//   var selectedFilterStaffId = ''.obs;
//
//   final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');
//
//
//   // Rx workers to manage reactions
//   late Worker _selectedDateWorker;
//   late Worker _selectedStaffIdWorker;
//   static const int maxAppointmentsPerDayDisplay = 2;
//   /// Scroll controller for infinite scroll (for doctors list)
//   final scrollController = ScrollController();
//
//   @override
//   // void onInit() {
//   //   super.onInit();
//   //
//   //   fetchDoctors(clear: true);
//   //   fetchPatients();
//   //   fetchPatientAppointments(); // Fetch appointments for the patient_appointments_page on startup
//   //
//   //   // Listen to search and filter changes to re-fetch appointments
//   //   ever(currentSearchQuery, (_) => fetchPatientAppointments());
//   //   ever(currentFilterStatus, (_) => fetchPatientAppointments());
//   //   ever(currentFilterDateRange, (_) => fetchPatientAppointments());
//   //   ever(filterFromDate, (_) => fetchPatientAppointments());
//   //   ever(filterToDate, (_) => fetchPatientAppointments());
//   //
//   //
//   //   // React to selectedDate changes to fetch day appointments and relevant range appointments
//   //   _selectedDateWorker = ever(selectedDate, (DateTime date) {
//   //     if (selectedStaffId.value.isNotEmpty) {
//   //       _fetchAppointmentsForDay(date); // Always fetch day's slots
//   //       _fetchAppointmentsForRange(date); // Fetch appointments for the calendar display range
//   //     }
//   //   });
//   //
//   //   // React to selectedStaffId changes to fetch appointments for the default selectedDate
//   //   _selectedStaffIdWorker = ever(selectedStaffId, (String staffId) {
//   //     if (staffId.isNotEmpty) {
//   //       selectedDate.refresh(); // This triggers _selectedDateWorker
//   //     } else {
//   //       allDayAppointments.clear();
//   //       availableSlots.clear();
//   //       bookedSlots.clear();
//   //     }
//   //   });
//   //
//   //   scrollController.addListener(() {
//   //     if (scrollController.position.pixels >=
//   //         scrollController.position.maxScrollExtent - 200 &&
//   //         !isLoading.value &&
//   //         hasMore.value) {
//   //       fetchDoctors();
//   //     }
//   //   });
//   // }
//
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // Fetch doctors first, then patients, then appointments
//     // We use .then() to ensure doctors are fetched before trying to use doctors.first.id
//     fetchDoctors(clear: true).then((_) {
//       fetchPatients();
//       // After doctors are fetched, ensure selectedFilterStaffId is set if doctors are available
//       if (doctors.isNotEmpty && selectedFilterStaffId.value.isEmpty) {
//         selectedFilterStaffId.value = doctors.first.id ?? '';
//       }
//       fetchPatientAppointments(); // Fetch appointments for the patient_appointments_page on startup
//     });
//
//     // Listen to search and filter changes to re-fetch appointments
//     ever(currentSearchQuery, (_) => fetchPatientAppointments());
//     ever(currentFilterStatus, (_) => fetchPatientAppointments());
//     // Only react to date range changes if it's not the initial 'all' state being set
//     ever(currentFilterDateRange, (range) {
//       // This ensures that the initial setting of 'all' doesn't trigger an unnecessary re-fetch
//       // unless it's explicitly changed by the user.
//       if (range != AppointmentFilterDateRange.all || (filterFromDate.value != null || filterToDate.value != null)) {
//         fetchPatientAppointments();
//       }
//     });
//     ever(filterFromDate, (_) => fetchPatientAppointments());
//     ever(filterToDate, (_) => fetchPatientAppointments());
//
//
//     // React to selectedDate changes to fetch day appointments and relevant range appointments
//     _selectedDateWorker = ever(selectedDate, (DateTime date) {
//       if (selectedStaffId.value.isNotEmpty) {
//         // _fetchAppointmentsForDay(date); // Always fetch day's slots
//         _fetchAppointmentsForRange(date); // Fetch appointments for the calendar display range
//       }
//     });
//
//     // React to selectedStaffId changes to fetch appointments for the default selectedDate
//     _selectedStaffIdWorker = ever(selectedStaffId, (String staffId) {
//       if (staffId.isNotEmpty) {
//         selectedDate.refresh(); // This triggers _selectedDateWorker
//       } else {
//         allDayAppointments.clear();
//         availableSlots.clear();
//         bookedSlots.clear();
//       }
//     });
//
//     scrollController.addListener(() {
//       if (scrollController.position.pixels >=
//           scrollController.position.maxScrollExtent - 200 &&
//           !isLoading.value &&
//           hasMore.value) {
//         fetchDoctors();
//       }
//     });
//   }
//
//   @override
//   void onClose() {
//     _selectedDateWorker.dispose();
//     _selectedStaffIdWorker.dispose();
//     scrollController.dispose();
//     searchController.dispose();
//     super.onClose();
//   }
//
//   void setSelectedStaff(String staffId) {
//     if (selectedStaffId.value != staffId) {
//       selectedStaffId.value = staffId;
//       selectedDate.value = DateTime.now();
//     }
//   }
//
//   void updateSaveEnabled() {
//     saveEnabled.value = startTime.isNotEmpty &&
//         endTime.isNotEmpty &&
//         selectedPatientId.isNotEmpty &&
//         selectedVisitType.isNotEmpty;
//   }
//
//   String _formatTime(String time) {
//     if (time.contains(':')) {
//       return time;
//     }
//     try {
//       final format12 = DateFormat('h:mm a');
//       final format24 = DateFormat('HH:mm');
//       final dateTime = format12.parse(time);
//       return format24.format(dateTime);
//     } catch (e) {
//       return time;
//     }
//   }
//
//   /// API: Fetch Doctors
//   Future<void> fetchDoctors({bool clear = false}) async {
//     if (isLoading.value) return;
//
//     try {
//       isLoading.value = true;
//       if (clear) {
//         skip.value = 0;
//         hasMore.value = true;
//         doctors.clear();
//       }
//
//       final token = await TokenStorage.getToken();
//
//       final uri = Uri.parse(ApiConstants.GET_DOCTOR).replace(
//         queryParameters: {
//           "skip": skip.value.toString(),
//           "limit": pageSize.toString(),
//         },
//       );
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         if (data["success"] == 1 && data["body"]?["rows"] != null) {
//           final List<dynamic> rows = data["body"]["rows"];
//           final fetchedDoctors = rows
//               .map((e) => StaffListModel.fromJson(e as Map<String, dynamic>))
//               .toList();
//
//           doctors.addAll(fetchedDoctors);
//
//           if (fetchedDoctors.length < pageSize) {
//             hasMore.value = false;
//           } else {
//             skip.value += pageSize;
//           }
//         }
//       } else {
//         Get.snackbar("Error", "Failed to fetch doctors (${response.statusCode})");
//       }
//     } catch (e) {
//       Get.snackbar("Exception", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// API: Fetch Patients (Users) - Needed for patient names in cards
//   Future<void> fetchPatients() async {
//     try {
//       final token = await TokenStorage.getToken();
//       final response = await http.get(
//         Uri.parse(ApiConstants.GET_PATIENTS),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["success"] == 1 && data["body"] != null) {
//           final List<dynamic> list = data["body"];
//           patients.assignAll(list.map((e) => UserListModel.fromJson(e)).toList());
//         }
//       }
//     } catch (e) {
//       Get.snackbar("Exception", e.toString());
//     }
//   }
//
//   /// API: Fetch ALL Appointments for the Patient Appointments Page (Admin View) with filters
//   Future<void> fetchPatientAppointments() async {
//     isLoading.value = true;
//     try {
//       final token = await TokenStorage.getToken();
//       final Map<String, String> queryParams = {};
//
//       // Apply search query
//       if (currentSearchQuery.value.isNotEmpty) {
//         queryParams['q'] = currentSearchQuery.value;
//       }
//
//       DateTime? effectiveFromDate;
//       DateTime? effectiveToDate;
//
//       switch (currentFilterDateRange.value) {
//         case AppointmentFilterDateRange.all:
//         // No date filter - leave effectiveFromDate and effectiveToDate null
//           break;
//         case AppointmentFilterDateRange.thisMonth:
//           effectiveFromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
//           effectiveToDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
//           break;
//         case AppointmentFilterDateRange.lastMonth:
//           final now = DateTime.now();
//           effectiveFromDate = DateTime(now.year, now.month - 1, 1);
//           effectiveToDate = DateTime(now.year, now.month, 0);
//           break;
//         case AppointmentFilterDateRange.thisWeek:
//           final now = DateTime.now();
//           effectiveFromDate = now.subtract(Duration(days: now.weekday - 1)); // Monday
//           effectiveToDate = effectiveFromDate.add(const Duration(days: 6)); // Sunday
//           break;
//         case AppointmentFilterDateRange.custom:
//           effectiveFromDate = filterFromDate.value;
//           effectiveToDate = filterToDate.value;
//           break;
//       }
//
//       if (effectiveFromDate != null) {
//         queryParams['from'] = DateFormat('yyyy-MM-dd').format(effectiveFromDate);
//       }
//       if (effectiveToDate != null) {
//         queryParams['to'] = DateFormat('yyyy-MM-dd').format(effectiveToDate);
//       }
//
//       if (selectedFilterStaffId.value.isEmpty && doctors.isNotEmpty) {
//         // If it's still empty and doctors are loaded, set it to the first doctor's ID
//         selectedFilterStaffId.value = doctors.first.id ?? '';
//       }
//
//       // Check if a staff is selected for filtering on this page. If not, we cannot proceed.
//       // If your API supports fetching appointments without a staffId, you can adjust this.
//       if (selectedFilterStaffId.value.isEmpty) {
//         Get.snackbar("Info", "No staff selected to fetch appointments. Please select a staff member or ensure doctors are loaded.");
//         isLoading.value = false;
//         return;
//       }
//
//       // Check if a staff is selected for filtering on this page
//       // String staffIdPath = selectedFilterStaffId.value;
//       // if (staffIdPath.isEmpty) {
//       //   if (doctors.isNotEmpty) {
//       //     staffIdPath = doctors.first.id ?? '';
//       //   } else {
//       //     Get.snackbar("Info", "No doctors available to filter appointments.");
//       //     isLoading.value = false;
//       //     return;
//       //   }
//       // }
//
//       // Construct the URI with the staff ID in the path and query parameters
//       final uri = Uri.parse("${ApiConstants.GET_APPOINTMENT_LIST}/${selectedFilterStaffId.value}").replace(
//           queryParameters: queryParams);
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["success"] == 1 && data["body"] != null) {
//           final List<dynamic> list = data["body"];
//           List<AppointmentModel> fetchedAppointments = list.map((e) => AppointmentModel.fromJson(e)).toList();
//
//           // --- CRITICAL OPTIMIZATION: Enrich appointments with names here ---
//           List<AppointmentModel> enrichedAppointments = [];
//           for (var appointment in fetchedAppointments) {
//             // Find patient details
//             final patient = patients.firstWhereOrNull((p) => p.id == appointment.patientId);
//             final patientFirstName = patient?.firstname ?? 'Unknown';
//             final patientLastName = patient?.lastname ?? 'Patient';
//
//             // Find staff details
//             final staff = doctors.firstWhereOrNull((d) => d.id == appointment.staffId);
//             final staffFirstName = staff?.firstname ?? 'Unknown';
//             final staffLastName = staff?.lastname ?? 'Staff';
//
//             // Create a new AppointmentModel or modify the existing one if mutable
//             // For this example, let's assume we modify properties directly if AppointmentModel is mutable
//             // OR, if immutable, create a new one with additional fields if you extend it
//             // For simplicity, let's just use the local variables for display in the UI
//
//             // If your AppointmentModel can be extended or has optional fields for names,
//             // you would populate them here.
//             // For instance, if AppointmentModel had `patientFullName` and `staffFullName`:
//             // appointment.patientFullName = '$patientFirstName $patientLastName'.trim();
//             // appointment.staffFullName = '$staffFirstName $staffLastName'.trim();
//
//             enrichedAppointments.add(appointment); // Add the processed appointment
//           }
//           appointments.assignAll(enrichedAppointments);
//           // appointments.assignAll(list.map((e) => AppointmentModel.fromJson(e)).toList());
//         } else{
//           appointments.clear();
//         }
//       } else {
//         Get.snackbar("Error", "Failed to fetch all appointments (${response.statusCode})");
//         appointments.clear();
//       }
//     } catch (e) {
//       Get.snackbar("Exception", "Error fetching all appointments: $e");
//       appointments.clear();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//   // --- Filtering Methods ---
//   void applySearch(String query) {
//     currentSearchQuery.value = query;
//   }
//
//   void setStatusFilter(String status) {
//     currentFilterStatus.value = status;
//   }
//
//   void setDateRangeFilter(AppointmentFilterDateRange range) {
//     currentFilterDateRange.value = range;
//     if (range != AppointmentFilterDateRange.custom) {
//       filterFromDate.value = null; // Clear custom dates
//       filterToDate.value = null;
//     }
//   }
//
//   Future<void> showCustomDateRangePicker(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//       initialDateRange: filterFromDate.value != null && filterToDate.value != null
//           ? DateTimeRange(start: filterFromDate.value!, end: filterToDate.value!)
//           : null,
//     );
//
//     if (picked != null) {
//       filterFromDate.value = picked.start;
//       filterToDate.value = picked.end;
//       currentFilterDateRange.value = AppointmentFilterDateRange.custom;
//     }
//   }
//
//   void clearFilters() {
//     searchController.clear();
//     currentSearchQuery.value = '';
//     currentFilterStatus.value = '';
//     currentFilterDateRange.value = AppointmentFilterDateRange.all;
//     filterFromDate.value = null;
//     filterToDate.value = null;
//   }
//
//
//   /// API: Fetch appointments for a given date range (month, week, or day) for Calendar view
//   Future<void> _fetchAppointmentsForRange(DateTime date) async {
//     if (selectedStaffId.value.isEmpty) {
//       allDayAppointments.clear();
//       return;
//     }
//
//     isLoading.value = true;
//     try {
//       final token = await TokenStorage.getToken();
//       DateTime fetchStartDate;
//       DateTime fetchEndDate;
//
//       fetchStartDate = DateTime(date.year, date.month, 1);
//       fetchEndDate = DateTime(date.year, date.month + 1, 0);
//       // print( "api route ===> ${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/${selectedStaffId.value}");
//       final uri = Uri.parse(
//           "${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/${selectedStaffId.value}")
//           .replace(queryParameters: {
//         "from": DateFormat('yyyy-MM-dd').format(fetchStartDate),
//         "to": DateFormat('yyyy-MM-dd').format(fetchEndDate),
//       });
//       print( "api route ===> ${uri}");
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["success"] == 1 && data["body"] != null) {
//           final List<dynamic> daysData = data["body"];
//           final List<CalendarAppointment> fetchedAppointments = [];
//           for (var dayJson in daysData) {
//             final DayAppointments dayAppts = DayAppointments.fromJson(dayJson);
//
//             for (var event in dayAppts.events) {
//               try {
//                 final appointmentDate = DateTime.parse(dayAppts.date);
//                 // Ensure time parts are parsed correctly. `_formatTime` handles conversion to HH:mm.
//                 final startParts = _formatTime(event.start).split(':');
//                 final endParts = _formatTime(event.end).split(':');
//
//                 final startTime = DateTime(
//                   appointmentDate.year,
//                   appointmentDate.month,
//                   appointmentDate.day,
//                   int.parse(startParts[0]),
//                   int.parse(startParts[1]),
//                 );
//                 final endTime = DateTime(
//                   appointmentDate.year,
//                   appointmentDate.month,
//                   appointmentDate.day,
//                   int.parse(endParts[0]),
//                   int.parse(endParts[1]),
//                 );
//
//                 fetchedAppointments.add(
//                   CalendarAppointment(
//                     eventName: event.title,
//                     // eventName: "${DateFormat('HH:mm').format(startTime)}-${DateFormat('HH:mm').format(endTime)}",
//                     from: startTime,
//                     to: endTime,
//                     background: (event.type == 'booked' && event.status == 'PENDING')
//                         ? Colors.orange
//                         : (event.type == 'booked' && event.status == 'CONFIRMED') ? Colors.green:
//                     (event.type == 'leave') ? Colors.grey:
//                     Colors.red,
//
//                     appointmentId: event.id,
//                     patientId: event.patientId,
//                     visitType: event.visitType,
//                     status: event.status,
//                   ),
//                 );
//               } catch (e) {
//                 print("Error parsing event time for ${event.title}: $e");
//               }
//             }
//           }
//           allDayAppointments.assignAll(fetchedAppointments);
//         }
//       } else {
//         Get.snackbar(
//             "Error", "Failed to fetch appointments (${response.statusCode})");
//       }
//     } catch (e) {
//       Get.snackbar("Exception", "Error fetching appointments for range: $e");
//       print('Exception error fetching appointments for range: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// API: Fetch available/booked slots for a specific day for Calendar view
//   // Future<void> _fetchAppointmentsForDay(DateTime date) async {
//   //   if (selectedStaffId.value.isEmpty) {
//   //     availableSlots.clear();
//   //     bookedSlots.clear();
//   //     return;
//   //   }
//   //
//   //   isLoading.value = true;
//   //   try {
//   //     final token = await TokenStorage.getToken();
//   //     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//   //
//   //     final uri = Uri.parse(
//   //         "${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/${selectedStaffId.value}")
//   //         .replace(queryParameters: {
//   //       "from": formattedDate,
//   //       "to": formattedDate,
//   //     });
//   //
//   //     final response = await http.get(
//   //       uri,
//   //       headers: {
//   //         'Authorization': 'Bearer $token',
//   //         'Content-Type': 'application/json',
//   //       },
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body);
//   //       if (data["success"] == 1 && data["body"] != null) {
//   //         final List<dynamic> daysData = data["body"];
//   //         if (daysData.isNotEmpty) {
//   //           final DayAppointments dayAppts = DayAppointments.fromJson(daysData[0]);
//   //           availableSlots.assignAll(dayAppts.slots.available);
//   //           bookedSlots.assignAll(
//   //               dayAppts.events); // Use events for booked slots to get full info
//   //         } else {
//   //           availableSlots.clear();
//   //           bookedSlots.clear();
//   //         }
//   //       }
//   //     } else {
//   //       Get.snackbar(
//   //           "Error", "Failed to fetch day slots (${response.statusCode})");
//   //     }
//   //   } catch (e) {
//   //     Get.snackbar("Exception", "Error fetching day slots: $e");
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }
//
//   /// API: Update Appointment Status (used on Patient Appointments Page)
//   Future<void> updateAppointmentStatus(String appointmentId, String status, String patientId, String creatorId) async {
//     isLoading.value = true;
//     Get.dialog(
//       const Center(child: CircularProgressIndicator()),
//       barrierDismissible: false,
//     );
//     try {
//       final token = await TokenStorage.getToken();
//       final body = {
//         "reference_id": appointmentId,
//         "patient_id": patientId,
//         "creator_id": creatorId, // This might be the doctor's ID or admin's ID
//         "status": status
//       };
//       final response = await http.put(
//         Uri.parse(ApiConstants.UPDATE_APPOINTMENT_STATUS),
//         headers: { "Authorization": "Bearer $token",
//           "Content-Type": "application/json",},
//         body: jsonEncode(body),
//       );
//       Get.back(); // Dismiss loading dialog
//       if (response.statusCode == 200) {
//         Get.snackbar("Success", "Appointment $status successfully");
//         // Refresh the list of patient appointments after an update
//         await fetchPatientAppointments();
//         // Clear the editing status for this appointment
//         editingStatuses.remove(appointmentId);
//       } else {
//         final errorData = jsonDecode(response.body);
//         Get.snackbar("Error", "Failed to update appointment: ${errorData["msg"] ?? response.statusCode}");
//       }
//     } catch (e) {
//       Get.back(); // Dismiss loading dialog
//       Get.snackbar("Exception", "Error updating appointment status: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void setEditingStatus(String appointmentId, String status) {
//     editingStatuses[appointmentId] = status;
//   }
//
//   String getEditingStatus(String appointmentId, String defaultStatus) {
//     return editingStatuses[appointmentId] ?? defaultStatus;
//   }
//
//
//   void selectTimeSlot(TimeSlot slot) {
//     startTime.value = slot.start ?? "";
//     endTime.value = slot.end ?? "";
//     selectedAppointmentId.value = null; // Clear if previously selected for edit
//     isEditMode.value = false;
//     updateSaveEnabled();
//   }
//
//   void selectExistingAppointment(CalendarAppointment appointment) {
//     isEditMode.value = true;
//     selectedAppointmentId.value = appointment.appointmentId;
//     startTime.value = DateFormat('HH:mm').format(appointment.from);
//     endTime.value = DateFormat('HH:mm').format(appointment.to);
//     selectedPatientId.value = appointment.patientId ?? "";
//     selectedVisitType.value = appointment.visitType ?? "";
//
//     final selectedPatient =
//     patients.firstWhereOrNull((p) => p.id == appointment.patientId);
//     selectedPatientName.value = (selectedPatient != null)
//         ? "${selectedPatient.firstname ?? ''} ${selectedPatient.lastname ?? ''}"
//         : "";
//
//     updateSaveEnabled();
//   }
//
//   void clearAppointmentSelection() {
//     isEditMode.value = false;
//     selectedAppointmentId.value = null;
//     startTime.value = "";
//     endTime.value = "";
//     selectedPatientId.value = "";
//     selectedPatientName.value = "";
//     selectedVisitType.value = "";
//     updateSaveEnabled();
//   }
//
//   Future<void> bookAppointment() async {
//     isLoading.value = true;
//     final appointment = AppointmentModel(
//       patientId: selectedPatientId.value,
//       patientName: selectedPatientName.value,
//       staffId: selectedStaffId.value,
//       date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
//       timeSlot: TimeSlot(start: startTime.value, end: endTime.value),
//       visitType: selectedVisitType.value,
//     );
//
//     final token = await TokenStorage.getToken();
//     final url = Uri.parse(ApiConstants.CREATE_APPOINTMENT);
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(appointment.toJson()),
//       );
//
//       isLoading.value = false;
//
//       print('book appointment response ==> ${response.body}');
//       print('status code ==> ${response.statusCode}');
//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Appointment booked successfully!');
//         Get.back(); // Close dialog
//         print('success');
//         _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar appointments for the current range
//         clearAppointmentSelection();
//         fetchPatientAppointments(); // Also refresh the list of all appointments
//       } else {
//         Get.snackbar('Error', 'Failed to book appointment: ${response.body}');
//       }
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('Exception', 'Error booking appointment: $e');
//     }
//   }
//
//   Future<void> updateAppointment() async {
//     if (selectedAppointmentId.value == null) {
//       Get.snackbar('Error', 'No appointment selected for update.');
//       return;
//     }
//
//     isLoading.value = true;
//
//     final token = await TokenStorage.getToken();
//     final url = Uri.parse(ApiConstants.UPDATE_APPOINTMENT);
//
//     final body = {
//       "reference_id": selectedAppointmentId.value, // 👈 backend expects this
//       "patient_id": selectedPatientId.value,
//       "patient_name": selectedPatientName.value,
//       "date": DateFormat('yyyy-MM-dd').format(selectedDate.value),
//       "time_slot": {
//         "start": startTime.value, // ensure 24hr format
//         "end": endTime.value,
//       },
//       "visit_type": selectedVisitType.value,
//     };
//
//     print('body: $body');
//
//     try {
//       final response = await http.put(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(body),
//       );
//
//       isLoading.value = false;
//
//       print('status code ==> ${response.statusCode}');
//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Appointment updated successfully!');
//         Get.back(); // Close dialog
//         print('response body: ${response.body}');
//         _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar appointments for the current range
//         clearAppointmentSelection();
//         fetchPatientAppointments(); // Also refresh the list of all appointments
//       } else {
//         Get.snackbar('Error', 'Failed to update appointment: ${response.body}');
//         print('error response body: ${response.body}');
//       }
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('Exception', 'Error updating appointment: $e');
//     }
//   }
//
//   // Handle saving (book or update)
//   void handleSaveAppointment() {
//     if (isEditMode.value) {
//       updateAppointment();
//     } else {
//       bookAppointment();
//     }
//   }
// }
//
// class AppointmentDataSource extends CalendarDataSource {
//   AppointmentDataSource(List<CalendarAppointment> source) {
//     appointments = source;
//   }
//
//   @override
//   DateTime getStartTime(int index) {
//     return _getAppointmentData(index).from;
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     return _getAppointmentData(index).to;
//   }
//
//   @override
//   String getSubject(int index) {
//     return _getAppointmentData(index).eventName;
//   }
//
//   @override
//   Color getColor(int index) {
//     return _getAppointmentData(index).background;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return _getAppointmentData(index).isAllDay;
//   }
//
//   CalendarAppointment _getAppointmentData(int index) {
//     final dynamic appointment = appointments![index];
//     late final CalendarAppointment appointmentData;
//     if (appointment is CalendarAppointment) {
//       appointmentData = appointment;
//     }
//     return appointmentData;
//   }
// }
//







import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_view/calendar_view.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/staff_list_model.dart';
import '../../../data/models/user_list_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

enum AppointmentFilterDateRange {
  all,
  thisMonth,
  lastMonth,
  thisWeek,
  custom,
}

class AppointmentController extends GetxController {
  /// Observables
  var isLoading = false.obs;
  var doctors = <StaffListModel>[].obs;
  var patients = <UserListModel>[].obs;
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

  var saveEnabled = false.obs;
  var isEditMode = false.obs;

  var editingStatuses = <String, String>{}.obs;

  final TextEditingController searchController = TextEditingController();
  var currentSearchQuery = ''.obs;
  var currentFilterStatus = ''.obs;
  var currentFilterDateRange = AppointmentFilterDateRange.all.obs;
  var filterFromDate = Rxn<DateTime>();
  var filterToDate = Rxn<DateTime>();
  var selectedFilterStaffId = ''.obs;

  var allDayAppointments = <CalendarAppointment>[].obs;

  final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');

  late Worker _selectedDateWorker;
  late Worker _selectedStaffIdWorker;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    fetchDoctors(clear: true).then((_) {
      fetchPatients();
      if (doctors.isNotEmpty && selectedFilterStaffId.value.isEmpty) {
        selectedFilterStaffId.value = doctors.first.id ?? '';
      }
      fetchPatientAppointments();
    });

    ever(currentSearchQuery, (_) => fetchPatientAppointments());
    ever(currentFilterStatus, (_) => fetchPatientAppointments());
    ever(currentFilterDateRange, (range) {
      if (range != AppointmentFilterDateRange.all || (filterFromDate.value != null || filterToDate.value != null)) {
        fetchPatientAppointments();
      }
    });
    ever(filterFromDate, (_) => fetchPatientAppointments());
    ever(filterToDate, (_) => fetchPatientAppointments());

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
    if (selectedStaffId.value != staffId) {
      selectedStaffId.value = staffId;
      selectedDate.value = DateTime.now();
    }
  }

  void updateSaveEnabled() {
    saveEnabled.value = startTime.isNotEmpty &&
        endTime.isNotEmpty &&
        selectedPatientId.isNotEmpty &&
        selectedVisitType.isNotEmpty;
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

  /// API: Fetch Patients (Users) - Needed for patient names in cards (Unchanged)
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

  /// API: Fetch ALL Appointments for the Patient Appointments Page (Admin View) with filters (Unchanged logic, just ensure models are null-safe)
  Future<void> fetchPatientAppointments() async {
    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      final Map<String, String> queryParams = {};

      if (currentSearchQuery.value.isNotEmpty) {
        queryParams['q'] = currentSearchQuery.value;
      }

      DateTime? effectiveFromDate;
      DateTime? effectiveToDate;

      switch (currentFilterDateRange.value) {
        case AppointmentFilterDateRange.all:
          break;
        case AppointmentFilterDateRange.thisMonth:
          effectiveFromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
          effectiveToDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
          break;
        case AppointmentFilterDateRange.lastMonth:
          final now = DateTime.now();
          effectiveFromDate = DateTime(now.year, now.month - 1, 1);
          effectiveToDate = DateTime(now.year, now.month, 0);
          break;
        case AppointmentFilterDateRange.thisWeek:
          final now = DateTime.now();
          effectiveFromDate = now.subtract(Duration(days: now.weekday - 1));
          effectiveToDate = effectiveFromDate.add(const Duration(days: 6));
          break;
        case AppointmentFilterDateRange.custom:
          effectiveFromDate = filterFromDate.value;
          effectiveToDate = filterToDate.value;
          break;
      }

      if (effectiveFromDate != null) {
        queryParams['from'] = DateFormat('yyyy-MM-dd').format(effectiveFromDate);
      }
      if (effectiveToDate != null) {
        queryParams['to'] = DateFormat('yyyy-MM-dd').format(effectiveToDate);
      }

      if (selectedFilterStaffId.value.isEmpty && doctors.isNotEmpty) {
        selectedFilterStaffId.value = doctors.first.id ?? '';
      }

      if (selectedFilterStaffId.value.isEmpty) {
        Get.snackbar("Info", "No staff selected to fetch appointments. Please select a staff member or ensure doctors are loaded.");
        isLoading.value = false;
        return;
      }

      final uri = Uri.parse("${ApiConstants.GET_APPOINTMENT_LIST}/${selectedFilterStaffId.value}").replace(
          queryParameters: queryParams);

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
          final List<dynamic> list = data["body"];
          List<AppointmentModel> fetchedAppointments = list.map((e) => AppointmentModel.fromJson(e)).toList();

          // Enrich appointments with names (logic unchanged)
          List<AppointmentModel> enrichedAppointments = [];
          for (var appointment in fetchedAppointments) {
            final patient = patients.firstWhereOrNull((p) => p.id == appointment.patientId);
            final staff = doctors.firstWhereOrNull((d) => d.id == appointment.staffId);
            // Assuming you add patientFullName/staffFullName to AppointmentModel or handle display separately
            enrichedAppointments.add(appointment);
          }
          appointments.assignAll(enrichedAppointments);
        } else {
          appointments.clear();
        }
      } else {
        Get.snackbar("Error", "Failed to fetch all appointments (${response.statusCode})");
        appointments.clear();
      }
    } catch (e) {
      Get.snackbar("Exception", "Error fetching all appointments: $e");
      appointments.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // --- Filtering Methods --- (Unchanged)
  void applySearch(String query) {
    currentSearchQuery.value = query;
  }

  void setStatusFilter(String status) {
    currentFilterStatus.value = status;
  }

  void setDateRangeFilter(AppointmentFilterDateRange range) {
    currentFilterDateRange.value = range;
    if (range != AppointmentFilterDateRange.custom) {
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
      currentFilterDateRange.value = AppointmentFilterDateRange.custom;
    }
  }

  void clearFilters() {
    searchController.clear();
    currentSearchQuery.value = '';
    currentFilterStatus.value = '';
    currentFilterDateRange.value = AppointmentFilterDateRange.all;
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













// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:calendar_view/calendar_view.dart'; // Changed import
// import '../../../data/models/appointment_model.dart';
// import '../../../data/models/staff_list_model.dart';
// import '../../../data/models/user_list_model.dart';
// import '../../../global/tokenStorage.dart';
// import '../../../utils/api_constants.dart';
//
// enum AppointmentFilterDateRange {
//   all,
//   thisMonth,
//   lastMonth,
//   thisWeek,
//   custom,
// }
//
// class AppointmentController extends GetxController {
//   /// Observables
//   var isLoading = false.obs;
//   var doctors = <StaffListModel>[].obs;
//   var patients = <UserListModel>[].obs;
//   var appointments = <AppointmentModel>[].obs;
//
//   // Use EventController from calendar_view
//   final EventController<CalendarAppointment> eventController = EventController<CalendarAppointment>();
//
//   var skip = 0.obs;
//   final int pageSize = 10;
//   var hasMore = true.obs;
//
//   var selectedDate = DateTime.now().obs;
//   var availableSlots = <TimeSlot>[].obs;
//   var bookedSlots = <Event>[].obs;
//   var startTime = "".obs;
//   var endTime = "".obs;
//   var selectedPatientId = "".obs;
//   var selectedPatientName = "".obs;
//   var selectedVisitType = "".obs;
//   var selectedStaffId = "".obs;
//
//   var selectedAppointmentId = Rxn<String>();
//
//   var saveEnabled = false.obs;
//   var isEditMode = false.obs;
//
//   var editingStatuses = <String, String>{}.obs;
//
//   final TextEditingController searchController = TextEditingController();
//   var currentSearchQuery = ''.obs;
//   var currentFilterStatus = ''.obs;
//   var currentFilterDateRange = AppointmentFilterDateRange.all.obs;
//   var filterFromDate = Rxn<DateTime>();
//   var filterToDate = Rxn<DateTime>();
//   var selectedFilterStaffId = ''.obs;
//
//   final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');
//
//   late Worker _selectedDateWorker;
//   late Worker _selectedStaffIdWorker;
//
//   final scrollController = ScrollController();
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     fetchDoctors(clear: true).then((_) {
//       fetchPatients();
//       if (doctors.isNotEmpty && selectedFilterStaffId.value.isEmpty) {
//         selectedFilterStaffId.value = doctors.first.id ?? '';
//       }
//       fetchPatientAppointments();
//     });
//
//     ever(currentSearchQuery, (_) => fetchPatientAppointments());
//     ever(currentFilterStatus, (_) => fetchPatientAppointments());
//     ever(currentFilterDateRange, (range) {
//       if (range != AppointmentFilterDateRange.all || (filterFromDate.value != null || filterToDate.value != null)) {
//         fetchPatientAppointments();
//       }
//     });
//     ever(filterFromDate, (_) => fetchPatientAppointments());
//     ever(filterToDate, (_) => fetchPatientAppointments());
//
//     _selectedDateWorker = ever(selectedDate, (DateTime date) {
//       if (selectedStaffId.value.isNotEmpty) {
//         _fetchAppointmentsForRange(date);
//       }
//     });
//
//     _selectedStaffIdWorker = ever(selectedStaffId, (String staffId) {
//       if (staffId.isNotEmpty) {
//         selectedDate.refresh();
//       } else {
//         eventController.removeWhere((event) => true); // Clear all events
//         availableSlots.clear();
//         bookedSlots.clear();
//       }
//     });
//
//     scrollController.addListener(() {
//       if (scrollController.position.pixels >=
//           scrollController.position.maxScrollExtent - 200 &&
//           !isLoading.value &&
//           hasMore.value) {
//         fetchDoctors();
//       }
//     });
//   }
//
//   @override
//   void onClose() {
//     _selectedDateWorker.dispose();
//     _selectedStaffIdWorker.dispose();
//     scrollController.dispose();
//     searchController.dispose();
//     super.onClose();
//   }
//
//   void setSelectedStaff(String staffId) {
//     if (selectedStaffId.value != staffId) {
//       selectedStaffId.value = staffId;
//       selectedDate.value = DateTime.now();
//     }
//   }
//
//   void updateSaveEnabled() {
//     saveEnabled.value = startTime.isNotEmpty &&
//         endTime.isNotEmpty &&
//         selectedPatientId.isNotEmpty &&
//         selectedVisitType.isNotEmpty;
//   }
//
//   // Helper to ensure time is in HH:mm format, handling potential nulls safely
//   String _formatTime(String? time) {
//     if (time == null || time.isEmpty) return '00:00'; // Default or handle as error
//     if (time.contains(':')) {
//       return time;
//     }
//     try {
//       // Try parsing 12-hour format
//       final format12 = DateFormat('h:mm a');
//       final format24 = DateFormat('HH:mm');
//       final dateTime = format12.parse(time);
//       return format24.format(dateTime);
//     } catch (e) {
//       // If 12-hour parsing fails, return original or default
//       return time;
//     }
//   }
//
//   /// API: Fetch Doctors (Unchanged)
//   Future<void> fetchDoctors({bool clear = false}) async {
//     if (isLoading.value) return;
//     try {
//       isLoading.value = true;
//       if (clear) {
//         skip.value = 0;
//         hasMore.value = true;
//         doctors.clear();
//       }
//       final token = await TokenStorage.getToken();
//       final uri = Uri.parse(ApiConstants.GET_DOCTOR).replace(
//         queryParameters: {
//           "skip": skip.value.toString(),
//           "limit": pageSize.toString(),
//         },
//       );
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["success"] == 1 && data["body"]?["rows"] != null) {
//           final List<dynamic> rows = data["body"]["rows"];
//           final fetchedDoctors = rows
//               .map((e) => StaffListModel.fromJson(e as Map<String, dynamic>))
//               .toList();
//           doctors.addAll(fetchedDoctors);
//           if (fetchedDoctors.length < pageSize) {
//             hasMore.value = false;
//           } else {
//             skip.value += pageSize;
//           }
//         }
//       } else {
//         Get.snackbar("Error", "Failed to fetch doctors (${response.statusCode})");
//       }
//     } catch (e) {
//       Get.snackbar("Exception", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// API: Fetch Patients (Users) - Needed for patient names in cards (Unchanged)
//   Future<void> fetchPatients() async {
//     try {
//       final token = await TokenStorage.getToken();
//       final response = await http.get(
//         Uri.parse(ApiConstants.GET_PATIENTS),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["success"] == 1 && data["body"] != null) {
//           final List<dynamic> list = data["body"];
//           patients.assignAll(list.map((e) => UserListModel.fromJson(e)).toList());
//         }
//       }
//     } catch (e) {
//       Get.snackbar("Exception", e.toString());
//     }
//   }
//
//   /// API: Fetch ALL Appointments for the Patient Appointments Page (Admin View) with filters (Unchanged logic, just ensure models are null-safe)
//   Future<void> fetchPatientAppointments() async {
//     isLoading.value = true;
//     try {
//       final token = await TokenStorage.getToken();
//       final Map<String, String> queryParams = {};
//
//       if (currentSearchQuery.value.isNotEmpty) {
//         queryParams['q'] = currentSearchQuery.value;
//       }
//
//       DateTime? effectiveFromDate;
//       DateTime? effectiveToDate;
//
//       switch (currentFilterDateRange.value) {
//         case AppointmentFilterDateRange.all:
//           break;
//         case AppointmentFilterDateRange.thisMonth:
//           effectiveFromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
//           effectiveToDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
//           break;
//         case AppointmentFilterDateRange.lastMonth:
//           final now = DateTime.now();
//           effectiveFromDate = DateTime(now.year, now.month - 1, 1);
//           effectiveToDate = DateTime(now.year, now.month, 0);
//           break;
//         case AppointmentFilterDateRange.thisWeek:
//           final now = DateTime.now();
//           effectiveFromDate = now.subtract(Duration(days: now.weekday - 1));
//           effectiveToDate = effectiveFromDate.add(const Duration(days: 6));
//           break;
//         case AppointmentFilterDateRange.custom:
//           effectiveFromDate = filterFromDate.value;
//           effectiveToDate = filterToDate.value;
//           break;
//       }
//
//       if (effectiveFromDate != null) {
//         queryParams['from'] = DateFormat('yyyy-MM-dd').format(effectiveFromDate);
//       }
//       if (effectiveToDate != null) {
//         queryParams['to'] = DateFormat('yyyy-MM-dd').format(effectiveToDate);
//       }
//
//       if (selectedFilterStaffId.value.isEmpty && doctors.isNotEmpty) {
//         selectedFilterStaffId.value = doctors.first.id ?? '';
//       }
//
//       if (selectedFilterStaffId.value.isEmpty) {
//         Get.snackbar("Info", "No staff selected to fetch appointments. Please select a staff member or ensure doctors are loaded.");
//         isLoading.value = false;
//         return;
//       }
//
//       final uri = Uri.parse("${ApiConstants.GET_APPOINTMENT_LIST}/${selectedFilterStaffId.value}").replace(
//           queryParameters: queryParams);
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["success"] == 1 && data["body"] != null) {
//           final List<dynamic> list = data["body"];
//           List<AppointmentModel> fetchedAppointments = list.map((e) => AppointmentModel.fromJson(e)).toList();
//
//           // Enrich appointments with names (logic unchanged)
//           List<AppointmentModel> enrichedAppointments = [];
//           for (var appointment in fetchedAppointments) {
//             final patient = patients.firstWhereOrNull((p) => p.id == appointment.patientId);
//             final staff = doctors.firstWhereOrNull((d) => d.id == appointment.staffId);
//             // Assuming you add patientFullName/staffFullName to AppointmentModel or handle display separately
//             enrichedAppointments.add(appointment);
//           }
//           appointments.assignAll(enrichedAppointments);
//         } else {
//           appointments.clear();
//         }
//       } else {
//         Get.snackbar("Error", "Failed to fetch all appointments (${response.statusCode})");
//         appointments.clear();
//       }
//     } catch (e) {
//       Get.snackbar("Exception", "Error fetching all appointments: $e");
//       appointments.clear();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // --- Filtering Methods --- (Unchanged)
//   void applySearch(String query) {
//     currentSearchQuery.value = query;
//   }
//
//   void setStatusFilter(String status) {
//     currentFilterStatus.value = status;
//   }
//
//   void setDateRangeFilter(AppointmentFilterDateRange range) {
//     currentFilterDateRange.value = range;
//     if (range != AppointmentFilterDateRange.custom) {
//       filterFromDate.value = null;
//       filterToDate.value = null;
//     }
//   }
//
//   Future<void> showCustomDateRangePicker(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//       initialDateRange: filterFromDate.value != null && filterToDate.value != null
//           ? DateTimeRange(start: filterFromDate.value!, end: filterToDate.value!)
//           : null,
//     );
//
//     if (picked != null) {
//       filterFromDate.value = picked.start;
//       filterToDate.value = picked.end;
//       currentFilterDateRange.value = AppointmentFilterDateRange.custom;
//     }
//   }
//
//   void clearFilters() {
//     searchController.clear();
//     currentSearchQuery.value = '';
//     currentFilterStatus.value = '';
//     currentFilterDateRange.value = AppointmentFilterDateRange.all;
//     filterFromDate.value = null;
//     filterToDate.value = null;
//   }
//
//   /// API: Fetch appointments for a given date range (month) for Calendar view
//   Future<void> _fetchAppointmentsForRange(DateTime date) async {
//     if (selectedStaffId.value.isEmpty) {
//       eventController.removeWhere((event) => true);
//       return;
//     }
//
//     isLoading.value = true;
//     try {
//       final token = await TokenStorage.getToken();
//       DateTime fetchStartDate = DateTime(date.year, date.month, 1);
//       DateTime fetchEndDate = DateTime(date.year, date.month + 1, 0);
//
//       final uri = Uri.parse(
//           "${ApiConstants.GET_APPOINTMENT_BY_DOCTOR}/${selectedStaffId.value}")
//           .replace(queryParameters: {
//         "from": DateFormat('yyyy-MM-dd').format(fetchStartDate),
//         "to": DateFormat('yyyy-MM-dd').format(fetchEndDate),
//       });
//
//       print("API route for calendar: $uri");
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["success"] == 1 && data["body"] != null) {
//           final List<dynamic> daysData = data["body"];
//           final List<CalendarEventData<CalendarAppointment>> fetchedCalendarEvents = [];
//
//           // Clear existing events for the current staff before adding new ones
//           eventController.removeWhere((event) => event.event?.appointmentId != null);
//
//
//           for (var dayJson in daysData) {
//             final DayAppointments dayAppts = DayAppointments.fromJson(dayJson);
//
//             for (var event in dayAppts.events) {
//               try {
//                 final appointmentDate = DateTime.parse(dayAppts.date);
//
//                 // Safely format time, handle null/empty strings
//                 final String formattedStartTime = _formatTime(event.start);
//                 final String formattedEndTime = _formatTime(event.end);
//
//                 // Split only if formatted time is valid
//                 final startParts = formattedStartTime.split(':');
//                 final endParts = formattedEndTime.split(':');
//
//                 // Ensure parts have at least two elements before parsing
//                 if (startParts.length < 2 || endParts.length < 2) {
//                   print("Skipping event due to invalid time format: ${event.title}");
//                   continue;
//                 }
//
//                 final startTime = DateTime(
//                   appointmentDate.year,
//                   appointmentDate.month,
//                   appointmentDate.day,
//                   int.tryParse(startParts[0]) ?? 0,
//                   int.tryParse(startParts[1]) ?? 0,
//                 );
//                 final endTime = DateTime(
//                   appointmentDate.year,
//                   appointmentDate.month,
//                   appointmentDate.day,
//                   int.tryParse(endParts[0]) ?? 0,
//                   int.tryParse(endParts[1]) ?? 0,
//                 );
//
//                 // Determine background color based on event type and status
//                 Color eventColor = Colors.red; // Default to red
//                 if (event.type == 'booked') {
//                   if (event.status == 'PENDING') {
//                     eventColor = Colors.orange;
//                   } else if (event.status == 'CONFIRMED') {
//                     eventColor = Colors.green;
//                   }
//                 } else if (event.type == 'leave') {
//                   eventColor = Colors.grey;
//                 }
//
//                 fetchedCalendarEvents.add(
//                   CalendarEventData<CalendarAppointment>(
//                     date: appointmentDate,
//                     startTime: startTime,
//                     endTime: endTime,
//                     title: event.title,
//                     description: event.title, // or more detailed description
//                     color: eventColor,
//                     event: CalendarAppointment(
//                       date: appointmentDate,
//                       startTime: startTime,
//                       endTime: endTime,
//                       title: event.title,
//                       color: eventColor,
//                       appointmentId: event.id,
//                       patientId: event.patientId,
//                       visitType: event.visitType,
//                       status: event.status,
//                     ),
//                   ),
//                 );
//               } catch (e) {
//                 print("Error parsing event time or data for ${event.title}: $e");
//               }
//             }
//           }
//           eventController.addAll(fetchedCalendarEvents);
//         }
//       } else {
//         Get.snackbar("Error", "Failed to fetch appointments (${response.statusCode})");
//       }
//     } catch (e) {
//       Get.snackbar("Exception", "Error fetching appointments for range: $e");
//       print('Exception error fetching appointments for range: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//   /// API: Update Appointment Status (Unchanged logic, just ensure models are null-safe)
//   Future<void> updateAppointmentStatus(String appointmentId, String status, String patientId, String creatorId) async {
//     isLoading.value = true;
//     Get.dialog(
//       const Center(child: CircularProgressIndicator()),
//       barrierDismissible: false,
//     );
//     try {
//       final token = await TokenStorage.getToken();
//       final body = {
//         "reference_id": appointmentId,
//         "patient_id": patientId,
//         "creator_id": creatorId,
//         "status": status
//       };
//       final response = await http.put(
//         Uri.parse(ApiConstants.UPDATE_APPOINTMENT_STATUS),
//         headers: { "Authorization": "Bearer $token",
//           "Content-Type": "application/json",},
//         body: jsonEncode(body),
//       );
//       Get.back();
//       if (response.statusCode == 200) {
//         Get.snackbar("Success", "Appointment $status successfully");
//         await fetchPatientAppointments();
//         editingStatuses.remove(appointmentId);
//         _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar
//       } else {
//         final errorData = jsonDecode(response.body);
//         Get.snackbar("Error", "Failed to update appointment: ${errorData["msg"] ?? response.statusCode}");
//       }
//     } catch (e) {
//       Get.back();
//       Get.snackbar("Exception", "Error updating appointment status: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void setEditingStatus(String appointmentId, String status) {
//     editingStatuses[appointmentId] = status;
//   }
//
//   String getEditingStatus(String appointmentId, String defaultStatus) {
//     return editingStatuses[appointmentId] ?? defaultStatus;
//   }
//
//
//   void selectTimeSlot(TimeSlot slot) {
//     startTime.value = slot.start ?? "";
//     endTime.value = slot.end ?? "";
//     selectedAppointmentId.value = null;
//     isEditMode.value = false;
//     updateSaveEnabled();
//   }
//
//   void selectExistingAppointment(CalendarAppointment appointment) {
//     isEditMode.value = true;
//     selectedAppointmentId.value = appointment.appointmentId;
//     startTime.value = DateFormat('HH:mm').format(appointment.startTime!); // Use startTime from CalendarAppointment
//     endTime.value = DateFormat('HH:mm').format(appointment.endTime!);   // Use endTime from CalendarAppointment
//     selectedPatientId.value = appointment.patientId ?? "";
//     selectedVisitType.value = appointment.visitType ?? "";
//
//     final selectedPatient =
//     patients.firstWhereOrNull((p) => p.id == appointment.patientId);
//     selectedPatientName.value = (selectedPatient != null)
//         ? "${selectedPatient.firstname ?? ''} ${selectedPatient.lastname ?? ''}"
//         : "";
//
//     updateSaveEnabled();
//   }
//
//   void clearAppointmentSelection() {
//     isEditMode.value = false;
//     selectedAppointmentId.value = null;
//     startTime.value = "";
//     endTime.value = "";
//     selectedPatientId.value = "";
//     selectedPatientName.value = "";
//     selectedVisitType.value = "";
//     updateSaveEnabled();
//   }
//
//   Future<void> bookAppointment() async {
//     isLoading.value = true;
//
//     // Ensure start/end times are parsed correctly
//     final parsedStartTime = DateFormat('HH:mm').parse(startTime.value);
//     final parsedEndTime = DateFormat('HH:mm').parse(endTime.value);
//
//     // Combine selected date with time parts
//     final appointmentStartTime = DateTime(selectedDate.value.year, selectedDate.value.month,
//         selectedDate.value.day, parsedStartTime.hour, parsedStartTime.minute);
//     final appointmentEndTime = DateTime(selectedDate.value.year, selectedDate.value.month,
//         selectedDate.value.day, parsedEndTime.hour, parsedEndTime.minute);
//
//     final appointment = AppointmentModel(
//       patientId: selectedPatientId.value,
//       patientName: selectedPatientName.value,
//       staffId: selectedStaffId.value,
//       date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
//       timeSlot: TimeSlot(start: startTime.value, end: endTime.value),
//       visitType: selectedVisitType.value,
//     );
//
//     final token = await TokenStorage.getToken();
//     final url = Uri.parse(ApiConstants.CREATE_APPOINTMENT);
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(appointment.toJson()),
//       );
//
//       isLoading.value = false;
//
//       print('book appointment response ==> ${response.body}');
//       print('status code ==> ${response.statusCode}');
//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Appointment booked successfully!');
//         Get.back();
//         print('success');
//         _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar appointments
//         clearAppointmentSelection();
//         fetchPatientAppointments();
//       } else {
//         Get.snackbar('Error', 'Failed to book appointment: ${response.body}');
//       }
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('Exception', 'Error booking appointment: $e');
//     }
//   }
//
//   Future<void> updateAppointment() async {
//     if (selectedAppointmentId.value == null) {
//       Get.snackbar('Error', 'No appointment selected for update.');
//       return;
//     }
//
//     isLoading.value = true;
//
//     final token = await TokenStorage.getToken();
//     final url = Uri.parse(ApiConstants.UPDATE_APPOINTMENT);
//
//     final body = {
//       "reference_id": selectedAppointmentId.value,
//       "patient_id": selectedPatientId.value,
//       "patient_name": selectedPatientName.value,
//       "date": DateFormat('yyyy-MM-dd').format(selectedDate.value),
//       "time_slot": {
//         "start": startTime.value,
//         "end": endTime.value,
//       },
//       "visit_type": selectedVisitType.value,
//     };
//
//     print('body: $body');
//
//     try {
//       final response = await http.put(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(body),
//       );
//
//       isLoading.value = false;
//
//       print('status code ==> ${response.statusCode}');
//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Appointment updated successfully!');
//         Get.back();
//         print('response body: ${response.body}');
//         _fetchAppointmentsForRange(selectedDate.value); // Refresh calendar appointments
//         clearAppointmentSelection();
//         fetchPatientAppointments();
//       } else {
//         Get.snackbar('Error', 'Failed to update appointment: ${response.body}');
//         print('error response body: ${response.body}');
//       }
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('Exception', 'Error updating appointment: $e');
//     }
//   }
//
//   void handleSaveAppointment() {
//     if (isEditMode.value) {
//       updateAppointment();
//     } else {
//       bookAppointment();
//     }
//   }
// }