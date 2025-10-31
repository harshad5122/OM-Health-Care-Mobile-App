import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../global/global.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class AuthController extends GetxController {
  var isPasswordHidden = true.obs;

  // Toggle between login with phone or email
  var isPhoneLogin = true.obs;

  // Phone login fields
  var countryCode = "+91".obs;
  var phoneNumber = "".obs;
  var name = "".obs;

  // Email login fields
  var email = "".obs;
  var passwordHidden = true.obs;

  // OTP
  var otpSent = false.obs;
  var otpCode = "".obs;

  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void switchLoginMethod(bool phoneSelected) {
    isPhoneLogin.value = phoneSelected;
    otpSent.value = false;
  }

  void sendOtp() {
    if (phoneNumber.value.isNotEmpty) {
      otpSent.value = true;
    }
  }

  void verifyOtp() {
    // Demo: OTP always "1234"
    if (otpCode.value == "1234") {
      Get.snackbar("Success", "Logged in successfully!");
    } else {
      Get.snackbar("Error", "Invalid OTP");
    }
  }

  void loginWithEmail() {
    if (email.value.isNotEmpty) {
      Get.snackbar("Success", "Logged in with Email");
    } else {
      Get.snackbar("Error", "Enter valid email/password");
    }
  }

  Future<void> logoutUser() async {
    Get.back(); // Close dialog first
    isLoading.value = true;

    try {
      final token = await TokenStorage.getToken();
      final userId = Global.userId;

      final body = {"userId": userId};

      final response = await http.post(
        Uri.parse(ApiConstants.USER_LOGOUT),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print("logout response => $data");

      if (response.statusCode == 200 &&
          (data["success"] == 1 || data["success"] == true)) {
        Get.snackbar(
          "Success",
          "Logged out successfully!",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        // Clear token or session data
        await TokenStorage.clearToken();

        // Redirect to login
        await Future.delayed(const Duration(milliseconds: 600));
        Get.offAllNamed("/login");
      } else {
        Get.snackbar(
          "Error",
          data["message"] ?? "Failed to logout",
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 10,
        );
      }
    } catch (e) {
      print("Logout error => $e");
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
