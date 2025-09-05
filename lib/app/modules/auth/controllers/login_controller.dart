import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../global/global.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class LoginController extends GetxController {
  // State
  var isPhoneLogin = true.obs;
  var isOtpSent = false.obs;
  var isLoading = false.obs;

  // Form Keys
  final phoneFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();

  // Controllers
  final countryCode = "+91".obs;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Actions
  void toggleLoginMethod(bool phoneLogin) {
    isPhoneLogin.value = phoneLogin;
    isOtpSent.value = false;
  }

  /// LOGIN WITH EMAIL
  Future<void> loginWithEmail() async {
    if (!emailFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final body = {
        "loginType": "email",
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(ApiConstants.SIGNIN),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print("login response => $data");

      if (response.statusCode == 200 &&
          (data["success"] == 1 || data["success"] == true)) {


        // Save token
        final token = data["body"]["token"];
        if (token != null) {
          await TokenStorage.saveToken(token);
        }

        print('login token ==>  $token');

        // Save user details globally
        final user = data["body"];
        if (user != null) {
          Global.userId = user["_id"];
          Global.userFirstname = user["firstname"];
          Global.userLastname = user["lastname"];
          Global.email = user["email"];
          Global.phone = user["phone"];
          Global.role = user["role"];
        }
        print('login user first name => ${Global.userFirstname}');
        print('login addedByAdmin => ${user["addedByAdmin"]}');


        Get.snackbar("Success", data["msg"] ?? "Login successful",
          snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.green, colorText: Colors.white
        );
        if (user["addedByAdmin"] == true && user["isPasswordChanged"] == true) {
          Get.offAllNamed("/change-password");
        } else {
          Get.offAllNamed("/dashboard");
        }
        // Get.offAllNamed("/dashboard");
      } else {
        Get.snackbar("Error", data["msg"] ?? "Invalid credentials",
            // backgroundColor: Colors.red, colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          // backgroundColor: Colors.red, colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar("Error", "Phone number is missing");
      return;
    }
    await sendOtp();
  }

  /// SEND OTP (phone login step 1)
  Future<void> sendOtp() async {
    // if (!phoneFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final body = {
        "loginType": "phone",
        "countryCode": countryCode.value,
        "phone": phoneController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(ApiConstants.SIGNIN),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print("sendOtp response => $data");

      if (response.statusCode == 200 &&
          (data["success"] == 1 || data["success"] == true)) {
        isOtpSent.value = true;
        Get.snackbar("OTP Sent",
          data["body"] ?? "OTP sent successfully",
            // backgroundColor: Colors.green, colorText: Colors.white
        );
      } else {
        Get.snackbar("Error", data["msg"] ?? "Failed to send OTP",
            // backgroundColor: Colors.red, colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          // backgroundColor: Colors.red, colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// VERIFY OTP (phone login step 2)
  Future<void> verifyOtp() async {
    if (!otpFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final body = {
        // "loginType": "phone",
        "countryCode": countryCode.value,
        "phone": phoneController.text.trim(),
        "otp": otpController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(ApiConstants.VERIFY_OTP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print("verifyOtp response => $data");

      if (response.statusCode == 200 &&
          (data["success"] == 1 || data["success"] == true)) {

        // Save token
        final token = data["body"]["token"];
        if (token != null) {
          await TokenStorage.saveToken(token);
        }

        // Save user details globally
        final user = data["body"];
        if (user != null) {
          Global.userId = user["_id"];
          Global.userFirstname = user["firstname"];
          Global.userLastname = user["lastname"];
          Global.email = user["email"];
          Global.phone = user["phone"];
          Global.role = user["role"];
        }

        Get.snackbar("Success", data["msg"] ?? "Login successful",
          snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.green, colorText: Colors.white
        );
        Get.offAllNamed("/dashboard");
      } else {
        Get.snackbar("Error", data["msg"] ?? "Invalid OTP",
            // backgroundColor: Colors.red, colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          // backgroundColor: Colors.red, colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

}
