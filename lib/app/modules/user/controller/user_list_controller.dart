import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/user_list_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class UserListController extends GetxController {
  /// Observables
  var isLoading = false.obs;

  var userList = <UserListModel>[].obs;
  var adminList = <UserListModel>[].obs;
  var staffList = <UserListModel>[].obs;

  final searchText = ''.obs;
  var filteredUserList = <UserListModel>[].obs;
  var filteredAdminList = <UserListModel>[].obs;
  var filteredStaffList = <UserListModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // React to searchText changes
    ever(searchText, (_) => filterUsers());
  }

  /// Filter logic
  void filterUsers() {
    final query = searchText.value.toLowerCase();

    if (query.isEmpty) {
      filteredUserList.assignAll(userList);
      filteredAdminList.assignAll(adminList);
      filteredStaffList.assignAll(staffList);
    } else {
      filteredUserList.assignAll(
        userList.where((u) =>
        (u.firstname?.toLowerCase().contains(query) ?? false) ||
            (u.lastname?.toLowerCase().contains(query) ?? false) ||
            (u.email?.toLowerCase().contains(query) ?? false)),
      );
      filteredAdminList.assignAll(
        adminList.where((u) =>
        (u.firstname?.toLowerCase().contains(query) ?? false) ||
            (u.lastname?.toLowerCase().contains(query) ?? false) ||
            (u.email?.toLowerCase().contains(query) ?? false)),
      );
      filteredStaffList.assignAll(
        staffList.where((u) =>
        (u.firstname?.toLowerCase().contains(query) ?? false) ||
            (u.lastname?.toLowerCase().contains(query) ?? false) ||
            (u.email?.toLowerCase().contains(query) ?? false)),
      );
    }
  }

  /// Fetch User List
  Future<void> fetchUserList() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.GET_USER_LIST),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];
        userList.value = body.map((e) => UserListModel.fromJson(e)).toList();
        filterUsers();
      } else {
        Get.snackbar("Error", "Failed to load user list");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch Admin List
  Future<void> fetchAdminList() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.GET_ADMIN_LIST),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];
        adminList.value = body.map((e) => UserListModel.fromJson(e)).toList();
        filterUsers();
      } else {
        Get.snackbar("Error", "Failed to load admin list");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch Staff List
  Future<void> fetchStaffList() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.GET_STAFF_LIST),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];
        staffList.value = body.map((e) => UserListModel.fromJson(e)).toList();
        filterUsers();
      } else {
        Get.snackbar("Error", "Failed to load staff list");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}
