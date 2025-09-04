import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../global/global.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class ChangePasswordController extends GetxController {
  // Form Key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final newPasswordController = TextEditingController();
  final retypePasswordController = TextEditingController();

  // State
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isRetypePasswordHidden = true.obs;

  /// CHANGE PASSWORD
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {

      final token = await TokenStorage.getToken();

      final body = {
        "newPassword": newPasswordController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(ApiConstants.CHANGE_PASSWORD),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print("changePassword response => $data");

      if (response.statusCode == 200 &&
          (data["success"] == 1 || data["success"] == true)) {
        Get.snackbar("Success", data["message"] ?? "Password changed successfully",
            snackPosition: SnackPosition.BOTTOM);

        // After password reset → go to dashboard
        Get.offAllNamed("/login");
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to change password",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
