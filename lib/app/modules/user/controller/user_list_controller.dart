import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/user_list_model.dart';


class UserListController extends GetxController {
  /// Observables
  var isLoading = false.obs;

  var userList = <UserListModel>[].obs;
  var adminList = <UserListModel>[].obs;
  var staffList = <UserListModel>[].obs;

  /// Replace with your actual token (or fetch from storage)
  final String token = "YOUR_BEARER_TOKEN";

  final String baseUrl = "http://localhost:3005/api";

  /// Fetch User List
  Future<void> fetchUserList() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse("$baseUrl/user/list"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];
        userList.value = body.map((e) => UserListModel.fromJson(e)).toList();
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
      final response = await http.get(
        Uri.parse("$baseUrl/admin/list"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];
        adminList.value = body.map((e) => UserListModel.fromJson(e)).toList();
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
      final response = await http.get(
        Uri.parse("$baseUrl/staff/list"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];
        staffList.value = body.map((e) => UserListModel.fromJson(e)).toList();
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
