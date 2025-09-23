import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/utils/api_constants.dart';

import '../../../data/models/leave_model.dart';
import '../../../global/tokenStorage.dart';


class LeaveController extends GetxController {
  final String baseUrl = "http://localhost:3005/api"; // Your API base URL

  // Observables for Apply Leave form
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  RxString selectedLeaveType = 'FULL_DAY'.obs; // Default leave type
  TextEditingController reasonController = TextEditingController();
  RxBool isLoading = false.obs;
  RxString staffId = '68ca45a3dbe480fa706215a5'.obs; // Replace with actual staff ID from auth
  RxString staffName = 'abce'.obs; // Replace with actual staff name from auth

  // Observables for Leave Records
  RxList<LeaveRecord> leaveRecords = <LeaveRecord>[].obs;
  RxBool isFetchingRecords = false.obs;

  RxBool isEditMode = false.obs;
  Rx<LeaveRecord?> editingLeave = Rx<LeaveRecord?>(null);
  RxString selectedStatus = 'PENDING'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaveRecords();
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
    DateTime initialDate = DateTime.now();
    if (isStart && startDate.value != null) {
      initialDate = startDate.value!;
    } else if (!isStart && endDate.value != null) {
      initialDate = endDate.value!;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for historical applications
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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

    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.CREATE_LEAVE),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "staff_id": staffId.value,
          "staff_name": staffName.value,
          "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
          "end_date": DateFormat('yyyy-MM-dd').format(endDate.value!),
          "leave_type": selectedLeaveType.value,
          "full_day": selectedLeaveType.value == 'FULL_DAY', // Adjust based on your logic for half-day
          "reason": reasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        final createLeaveResponse = createLeaveResponseFromJson(response.body);
        if (createLeaveResponse.success == 1) {
          Get.snackbar('Success', createLeaveResponse.msg,);
          // Clear form and refresh records
          _resetApplyLeaveForm();
          fetchLeaveRecords();
        } else {
          Get.snackbar('Error', createLeaveResponse.msg, );
        }
      } else {
        Get.snackbar('Error', 'Failed to apply leave. Status code: ${response.statusCode}', );
      }
    } catch (e) {
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
    update();
  }

  // --- Leave Records Methods ---
  Future<void> fetchLeaveRecords() async {
    isFetchingRecords.value = true;
    try {
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.GET_LEAVE}/${staffId.value}'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

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
    startDate.value = record.startDate;
    endDate.value = record.endDate;
    selectedLeaveType.value = record.leaveType;
    reasonController.text = record.reason;
    selectedStatus.value = record.status; // populate status
  }

}
