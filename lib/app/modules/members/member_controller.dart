// lib/controllers/members_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../data/models/staff_list_model.dart';
import '../../data/models/user_list_model.dart';
import '../../global/tokenStorage.dart';
import '../../utils/api_constants.dart';


enum MemberTab { users, doctors }

class MembersController extends GetxController {
  // UI / filter state
  var activeTab = MemberTab.users.obs;
  final TextEditingController searchController = TextEditingController();
  var fromDate = Rx<DateTime?>(null);
  var toDate = Rx<DateTime?>(null);

  // Paging state
  final int pageSize = 10;
  var usersSkip = 0.obs;
  var doctorsSkip = 0.obs;
  var usersHasMore = true.obs;
  var doctorsHasMore = true.obs;
  var isLoading = false.obs; // global loading for API calls

  // Data stores (reactive)
  final RxList<UserListModel> users = <UserListModel>[].obs;
  final RxList<StaffListModel> doctors = <StaffListModel>[].obs;

  // Scroll controller will be managed by the UI, but its listener will call controller methods
  final DateFormat displayFormat = DateFormat('dd MMM yyyy');
  final DateFormat apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    fetchInitial();
  }

  // --- Data fetching and pagination ---
  Future<void> fetchInitial() async {
    users.clear();
    doctors.clear();
    usersSkip.value = 0;
    doctorsSkip.value = 0;
    usersHasMore.value = true;
    doctorsHasMore.value = true;
    await fetchCurrentTab(clear: true);
  }

  Future<void> fetchCurrentTab({bool clear = false}) async {
    if (activeTab.value == MemberTab.users) {
      await fetchUsers(clear: clear);
    } else {
      await fetchDoctors(clear: clear);
    }
  }

  Future<void> fetchNextPage() async {
    if (activeTab.value == MemberTab.users) {
      if (usersHasMore.value) await fetchUsers();
    } else {
      if (doctorsHasMore.value) await fetchDoctors();
    }
  }

  Future<void> fetchUsers({bool clear = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      if (clear) {
        usersSkip.value = 0;
        usersHasMore.value = true;
      }
      final token = await TokenStorage.getToken();
      final Map<String, String> params = {
        'skip': usersSkip.value.toString(),
        'limit': pageSize.toString(),
      };
      final search = searchController.text.trim();
      if (search.isNotEmpty) params['search'] = search;
      if (fromDate.value != null) {
        params['from_date'] = apiFormat.format(fromDate.value!);
      }
      if (toDate.value != null) {
        params['to_date'] = apiFormat.format(toDate.value!);
      }

      final uri = Uri.parse(ApiConstants.GET_USER_LIST).replace(queryParameters: params);
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == 1 && data['body'] != null) {
          final body = data['body'];

          List<UserListModel> fetched = [];

          if (body is List) {
            fetched = body
                .map((e) => UserListModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (body is Map && body['rows'] is List) {
            fetched = (body['rows'] as List)
                .map((e) => UserListModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else {
            print("Unexpected body format: $body");
          }

          if (clear) {
            users.assignAll(fetched);
          } else {
            users.addAll(fetched);
          }

          if (fetched.length < pageSize) {
            usersHasMore.value = false;
          } else {
            usersSkip.value += pageSize;
          }
        } else {
          if (clear) users.clear();
          usersHasMore.value = false;
        }
      } else {
        Get.snackbar('Error', 'Failed to load users (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Exception', e.toString());
      print('Exception====> ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDoctors({bool clear = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      if (clear) {
        doctorsSkip.value = 0;
        doctorsHasMore.value = true;
      }
      final token = await TokenStorage.getToken();
      final Map<String, String> params = {
        'skip': doctorsSkip.value.toString(),
        'limit': pageSize.toString(),
      };
      final search = searchController.text.trim();
      if (search.isNotEmpty) params['search'] = search;
      if (fromDate.value != null) {
        params['from_date'] = apiFormat.format(fromDate.value!);
      }
      if (toDate.value != null) {
        params['to_date'] = apiFormat.format(toDate.value!);
      }

      final uri = Uri.parse(ApiConstants.GET_DOCTOR).replace(queryParameters: params);
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == 1 &&
            data['body'] != null &&
            data['body']['rows'] != null) {
          final List<dynamic> body = data['body']['rows'] as List<dynamic>;
          final fetched = body.map((e) => StaffListModel.fromJson(e as Map<String, dynamic>)).toList();
          if (clear) {
            doctors.assignAll(fetched);
          } else {
            doctors.addAll(fetched);
          }
          if (fetched.length < pageSize) {
            doctorsHasMore.value = false;
          } else {
            doctorsSkip.value += pageSize;
          }
        } else {
          if (clear) doctors.clear();
          doctorsHasMore.value = false;
        }
      } else {
        Get.snackbar('Error', 'Failed to load doctors (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Exception', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Filter helpers ---
  void selectFilterThisMonth() {
    final now = DateTime.now();
    fromDate.value = DateTime(now.year, now.month, 1);
    toDate.value = DateTime(now.year, now.month + 1, 0);
    applyFiltersAndSearch();
  }

  void selectFilterLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    fromDate.value = DateTime(lastMonth.year, lastMonth.month, 1);
    toDate.value = DateTime(lastMonth.year, lastMonth.month + 1, 0);
    applyFiltersAndSearch();
  }

  void selectFilterLastWeek() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(Duration(days: now.weekday + 6));
    final lastWeekEnd = lastWeekStart.add(Duration(days: 6));
    fromDate.value = DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day);
    toDate.value = DateTime(lastWeekEnd.year, lastWeekEnd.month, lastWeekEnd.day);
    applyFiltersAndSearch();
  }

  Future<void> pickCustomFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      fromDate.value = picked;
    }
  }

  Future<void> pickCustomToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      toDate.value = picked;
    }
  }

  void onDateRangeSelected(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      fromDate.value = args.value.startDate;
      toDate.value = args.value.endDate;
    }
    // No need to apply filters here, it will be done when the date picker dialog is closed
  }

  Future<void> showCustomDateRangePicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date Range'),
          content: SizedBox(
            width: 300, // Adjust width as needed
            height: 300, // Adjust height as needed
            child: SfDateRangePicker(
              onSelectionChanged: onDateRangeSelected,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(fromDate.value, toDate.value),
              maxDate: DateTime.now(), // Prevent selecting future dates if needed
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                applyFiltersAndSearch();
                Get.back(); // Close dialog
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void applyFiltersAndSearch() {
    // resets paging and fetches
    if (activeTab.value == MemberTab.users) {
      usersSkip.value = 0;
      usersHasMore.value = true;
    } else {
      doctorsSkip.value = 0;
      doctorsHasMore.value = true;
    }
    fetchCurrentTab(clear: true);
  }

  void clearFilters() {
    fromDate.value = null;
    toDate.value = null;
    applyFiltersAndSearch();
  }

  void setActiveTab(MemberTab tab) {
    if (activeTab.value != tab) {
      activeTab.value = tab;
      fetchCurrentTab(clear: true);
    }
  }

  // void editUser(UserListModel user) {
  //   Get.snackbar('Edit User', 'Editing user: ${user.firstname} ${user.lastname}');
  //   // Implement actual navigation to edit screen or show a form
  // }

  /// Edit user flow:
  /// - Navigate to AddUser page with arguments:
  ///    { 'isEdit': true, 'userId': <id> }
  /// - The AddUserController should detect 'isEdit' and call GET user-by-id,
  ///   populate form, and perform update when Save is pressed.
  /// - After AddUserPage is popped with a "true" result (meaning updated),
  ///   this controller refreshes current list.
  void editUser(UserListModel user) async {
    if (user.id == null || user.id!.isEmpty) {
      Get.snackbar('Error', 'User id not available');
      return;
    }

    try {
      // Navigate to add user page in edit mode and wait for result.
      // Using the literal route string '/addUser' — if you prefer AppRoutes.addUser,
      // replace '/addUser' with AppRoutes.addUser and import AppRoutes.
      final result = await Get.toNamed(
        '/addUser',
        arguments: {
          'isEdit': true,
          'userId': user.id,
        },
      );

      // If the add/edit page returns true (indicating a successful update),
      // refresh current tab list.
      if (result == true) {
        fetchCurrentTab(clear: true);
      }
    } catch (e) {
      print('Error navigating to edit page: $e');
      Get.snackbar('Error', 'Could not open edit page');
    }
  }

  void deleteUser(UserListModel user) {
    Get.defaultDialog(
      title: 'Delete User',
      middleText: 'Are you sure you want to delete ${user.firstname} ${user.lastname}?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        // Implement actual delete logic
        Get.back(); // Close dialog
        try {
          final token = await TokenStorage.getToken();
          final uri = Uri.parse("${ApiConstants.DELET_USER}/${user.id}");
          final response = await http.delete(uri, headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });

          final data = jsonDecode(response.body);
          if (response.statusCode == 200 && data['success'] == 1) {
            Get.snackbar('Success', data['msg'] ?? 'User deleted');
            fetchUsers(clear: true);
          } else {
            Get.snackbar('Error', data['msg'] ?? 'Failed to delete user');
          }
        } catch (e) {
          Get.snackbar('Exception', e.toString());
        }
        // Get.snackbar('Deleted', '${user.firstname} ${user.lastname} deleted');
        fetchUsers(clear: true); // Refresh list
      },
    );
  }

  // void editStaff(StaffListModel staff) {
  //   Get.snackbar('Edit Staff', 'Editing staff: ${staff.firstname} ${staff.lastname}');
  //   // Implement actual navigation to edit screen or show a form
  // }

  void editStaff(StaffListModel staff) async {
    if (staff.id == null || staff.id!.isEmpty) {
      Get.snackbar('Error', 'Staff id not available');
      return;
    }

    try {
      // Navigate to AddDoctorPage in edit mode and wait for result
      final result = await Get.toNamed(
        '/addDoctor', // or AppRoutes.addDoctor if you have it defined
        arguments: {
          'isEdit': true,
          'staffId': staff.id,
        },
      );

      // If edit was successful, refresh staff list
      if (result == true) {
        fetchCurrentTab(clear: true);
      }
    } catch (e) {
      print('Error navigating to edit staff page: $e');
      Get.snackbar('Error', 'Could not open edit staff page');
    }
  }


  void deleteStaff(StaffListModel staff) {
    Get.defaultDialog(
      title: 'Delete Staff',
      middleText: 'Are you sure you want to delete ${staff.firstname} ${staff.lastname}?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        // Implement actual delete logic
        Get.back(); // Close dialog
        try {
          final token = await TokenStorage.getToken();
          final uri = Uri.parse("${ApiConstants.DELETE_DOCTOR}/${staff.id}");
          final response = await http.delete(uri, headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });

          final data = jsonDecode(response.body);
          if (response.statusCode == 200 && data['success'] == 1) {
            Get.snackbar('Success', data['msg'] ?? 'Doctor deleted');
            fetchDoctors(clear: true);
          } else {
            Get.snackbar('Error', data['msg'] ?? 'Failed to delete doctor');
          }
        } catch (e) {
          Get.snackbar('Exception', e.toString());
        }
        // Get.snackbar('Deleted', '${staff.firstname} ${staff.lastname} deleted');
        fetchDoctors(clear: true); // Refresh list
      },
    );
  }

  // Dispose of controllers
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}