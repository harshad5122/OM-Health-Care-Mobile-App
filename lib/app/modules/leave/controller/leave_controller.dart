import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/global/global.dart';
import 'package:om_health_care_app/app/utils/api_constants.dart';

import '../../../data/models/leave_model.dart';
import '../../../data/models/staff_list_model.dart';
import '../../../global/tokenStorage.dart';
import '../../appointment/controller/appointment_controller.dart';


class LeaveController extends GetxController {

  final appointmentController = Get.put(AppointmentController());
  // final AppointmentController appointmentController = Get.find();

  // Observables for Apply Leave form
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  RxString selectedLeaveType = 'FULL_DAY'.obs; // Default leave type
  TextEditingController reasonController = TextEditingController();
  RxBool isLoading = false.obs;
  // RxString staffId = '68ca45a3dbe480fa706215a5'.obs;
  RxString staffName = ''.obs; // Replace with actual staff name from auth

  // Observables for Leave Records
  var leaveRecords = <LeaveRecord>[].obs;
  var isFetchingRecords = false.obs;

  RxString adminId = ''.obs;
  RxString adminName = ''.obs;

  // var doctors = <StaffListModel>[].obs;
  final selectedDoctor = Rxn<StaffListModel>(); // Using StaffListModel for consistency
  final dateRangeOption = DateRangeOption.thisMonth.obs;
  final customFrom = Rxn<DateTime>();
  final customTo = Rxn<DateTime>();

  final currentFilterDateRange = DateRangeOption.thisMonth.obs;
  final filterFromDate = Rxn<DateTime>();
  final filterToDate = Rxn<DateTime>();

  final staffId = ''.obs;

  var loggedInUserId = ''.obs;
  var loggedInUserName = ''.obs;
  var isAdmin = false.obs;

  RxBool isEditMode = false.obs;
  Rx<LeaveRecord?> editingLeave = Rx<LeaveRecord?>(null);
  RxString selectedStatus = 'PENDING'.obs;

  DateTime get fromDate {
    return filterFromDate.value ?? DateTime.now();
  }

  DateTime get toDate {
    return filterToDate.value ?? DateTime.now();
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    // fetchLeaveRecords();
    // appointmentController.fetchDoctors();
    _updateFilterDatesForOption(DateRangeOption.thisMonth);

    // React to changes in currentFilterDateRange and update filterFromDate/filterToDate accordingly
    ever(currentFilterDateRange, (DateRangeOption option) {
      if (option != DateRangeOption.custom) {
        _updateFilterDatesForOption(option);
      }
      // fetchLeaveRecords();
    });
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
        to = from.add(const Duration(days: 6));
        break;
      case DateRangeOption.custom:
      // For custom, filterFromDate and filterToDate are directly set by DateSelectorController
        return; // No need to calculate here, values are already set
    }
    filterFromDate.value = from;
    filterToDate.value = to;
  }

  void selectDoctor(StaffListModel? d) {
    selectedDoctor.value = d;
  }

  void clearFiltersAndLeaves() {
    selectedDoctor.value = null;
    // dateRangeOption.value = DateRangeOption.thisMonth;
    currentFilterDateRange.value = DateRangeOption.thisMonth;
    _updateFilterDatesForOption(DateRangeOption.thisMonth);
    leaveRecords.clear();
  }

  // --- Apply Leave Methods ---
  void setStartDate(DateTime date) {
    startDate.value = date;
    if (endDate.value != null && startDate.value!.isAfter(endDate.value!)) {
      endDate.value = date; // Ensure end date is not before start date
    }
    update();
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
    if (startDate.value != null && endDate.value!.isBefore(startDate.value!)) {
      startDate.value = date; // Ensure start date is not after end date
    }
    update();
  }

  void setSelectedLeaveType(String? type) {
    if (type != null) {
      selectedLeaveType.value = type;
      update();
    }
  }

  Future<void> selectDate(BuildContext context, bool isStart) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;
    if (isStart && startDate.value != null) {
      initialDate = startDate.value!;
    } else if (!isStart && endDate.value != null) {
      initialDate = endDate.value!;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      // firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for historical applications
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (BuildContext context, Widget? child) {
        // Optional: make it match your app’s theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        setStartDate(picked);
      } else {
        setEndDate(picked);
      }
    }
  }


  Future<void> applyLeave() async {
    if (startDate.value == null || endDate.value == null || reasonController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields.',);
      return;
    }

    if (adminId.value.isEmpty || adminName.value.isEmpty) {
      Get.snackbar('Error', 'Please select an Admin.');
      return;
    }

    bool hasConflict = await _isLeaveConflict(startDate.value!, endDate.value!, selectedLeaveType.value);
    if (hasConflict) {
      Get.snackbar('Error', 'A leave already exists for this date and leave type.');
      return;
    }


    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();

      final requestBody = {
        "staff_id": Global.staffId,
        "staff_name": '${Global.userFirstname} ${Global.userLastname}',
        "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
        "end_date":  DateFormat('yyyy-MM-dd').format(endDate.value!),
        "reason": reasonController.text,
        "leave_type": selectedLeaveType.value,
        "admin_id": adminId.value,
        "admin_name": adminName.value,
      };

      print("Body: ${json.encode(requestBody)}");


      final response = await http.post(
        Uri.parse(ApiConstants.CREATE_LEAVE),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );


      if (response.statusCode == 200) {
        final createLeaveResponse = createLeaveResponseFromJson(response.body);
        if (createLeaveResponse.success == 1) {
          Get.snackbar('Success', 'Leave applied successfully!',);
          // Clear form and refresh records
          _resetApplyLeaveForm();
          fetchLeaveRecords();
          // Get.back();
          await Future.delayed(const Duration(milliseconds: 800));
          if (Get.isOverlaysOpen == false) {
            Get.back();
          }
        } else {
          Get.snackbar('Error', createLeaveResponse.msg, );
        }
      } else {
        Get.snackbar('Error', 'Failed to apply leave. Status code: ${response.statusCode}', );
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred: $e', );
    } finally {
      isLoading.value = false;
    }
  }

  void _resetApplyLeaveForm() {
    startDate.value = null;
    endDate.value = null;
    selectedLeaveType.value = 'FULL_DAY';
    reasonController.clear();
    adminId.value = '';
    adminName.value = '';
    update();
  }

  Future<void> _loadUserData() async {
    // Example: Fetching user details from storage
    loggedInUserId.value = Global.userId??'';
    loggedInUserName.value = '${Global.userFirstname} ${Global.userLastname}';
    final role = Global.role;
    isAdmin.value = (role == 2);

    if (role == 3) {
      // Create a minimal StaffListModel for the logged-in doctor
      selectedDoctor.value = StaffListModel(
        id: loggedInUserId.value,
        firstname: Global.userFirstname ?? '',
        lastname: Global.userLastname ?? '',
      );

      // Automatically fetch doctor’s leave records
      fetchLeaveRecords();
    }
  }

  // --- Leave Records Methods ---
  Future<void> fetchLeaveRecords() async {

    isFetchingRecords.value = true;
    try {
      final token = await TokenStorage.getToken();

      if (filterFromDate.value == null || filterToDate.value == null) {
        Get.snackbar('Error', 'Date range not selected for leave records.');
        isFetchingRecords.value = false;
        return;
      }


      final from = DateFormat('yyyy-MM-dd').format(filterFromDate.value!);
      final to = DateFormat('yyyy-MM-dd').format(filterToDate.value!);


      String? staffIdForRequest;
      if (isAdmin.value) {
        staffIdForRequest = selectedDoctor.value?.id;
        if (staffIdForRequest == null || staffIdForRequest.isEmpty) {
          Get.snackbar('Validation Error', 'Please select a doctor to view their leave records.');
          isFetchingRecords.value = false;
          return;
        }
      } else { // Doctor (Global.role == 3)
        staffIdForRequest = Global.staffId;
        if (staffIdForRequest == null || staffIdForRequest.isEmpty) {
          Get.snackbar('Error', 'Your Staff ID is missing to fetch leave records.');
          isFetchingRecords.value = false;
          return;
        }
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.GET_LEAVE}/$staffIdForRequest').replace(
            queryParameters: {
              'from': from,
              'to': to,
            }
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print('uri==> ${Uri.parse('${ApiConstants.GET_LEAVE}/$staffIdForRequest').replace(
          queryParameters: {
            'from': from,
            'to': to,
          }
      )}');
      if (response.statusCode == 200) {
        final leaveModel = leaveModelFromJson(response.body);
        if (leaveModel.success == 1) {
          leaveRecords.value = leaveModel.body;
        } else {
          Get.snackbar('Error', 'Failed to fetch leave records: ${leaveModel.msg}', );
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch leave records. Status code: ${response.statusCode}', );
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching records: $e', );
    } finally {
      isFetchingRecords.value = false;
    }
  }

  Future<void> updateLeave(String leaveId) async {
    if (startDate.value == null || endDate.value == null || reasonController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields.');
      return;
    }

    bool hasConflict = await _isLeaveConflict(startDate.value!, endDate.value!, selectedLeaveType.value);
    if (hasConflict) {
      Get.snackbar('Error', 'Another leave already exists on this date and leave type.');
      return;
    }

    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      final response = await http.put(
        Uri.parse("${ApiConstants.UPDATE_LEAVE}/$leaveId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
          "end_date": DateFormat('yyyy-MM-dd').format(endDate.value!),
          "leave_type": selectedLeaveType.value,
          "reason": reasonController.text,
          "status": selectedStatus.value, // include status in update
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Leave updated successfully.');
        _resetApplyLeaveForm();
        fetchLeaveRecords();
        isEditMode.value = false;
      } else {
        Get.snackbar('Error', 'Failed to update leave. Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLeave(String leaveId) async {
    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      final response = await http.delete(
        Uri.parse("${ApiConstants.DELETE_LEAVE}/$leaveId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Leave deleted successfully.');
        fetchLeaveRecords();
      } else {
        Get.snackbar('Error', 'Failed to delete leave. Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void startEditing(LeaveRecord record) {
    isEditMode.value = true;
    editingLeave.value = record;
    startDate.value = record.startDate.toLocal();
    endDate.value = record.endDate.toLocal();
    selectedLeaveType.value = record.leaveType;
    reasonController.text = record.reason;
    selectedStatus.value = record.status; // populate status
  }

  Future<bool> _isLeaveConflict(DateTime start, DateTime end, String leaveType) async {
    try {
      final token = await TokenStorage.getToken();
      final staffIdForRequest = Global.staffId;

      final response = await http.get(
        Uri.parse('${ApiConstants.GET_LEAVE}/$staffIdForRequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final leaveModel = leaveModelFromJson(response.body);
        if (leaveModel.success == 1) {
          for (final leave in leaveModel.body) {
            // Skip cancelled or rejected leaves if your API returns them
            if (leave.status.toUpperCase() == 'REJECTED' ||
                leave.status.toUpperCase() == 'CANCELLED') continue;

            final bool overlaps = !(end.isBefore(leave.startDate) || start.isAfter(leave.endDate));

            if (overlaps) {
              // Conflict cases
              if (leave.leaveType == 'FULL_DAY' || leaveType == 'FULL_DAY') {
                return true;
              }

              if (leave.leaveType == leaveType) {
                return true;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error checking leave conflict: $e');
    }
    return false;
  }

}
