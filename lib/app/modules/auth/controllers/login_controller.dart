import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  // State
  var isPhoneLogin = true.obs;
  var isOtpSent = false.obs;

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

  void sendOtp() {
    if (phoneFormKey.currentState!.validate()) {
      isOtpSent.value = true;
      Get.snackbar("OTP Sent", "Verification code sent to ${phoneController.text}");
    }
  }

  void verifyOtp() {
    if (otpFormKey.currentState!.validate()) {
      Get.offAllNamed("/home"); // redirect after login success
    }
  }

  void loginWithEmail() {
    if (emailFormKey.currentState!.validate()) {
      Get.offAllNamed("/dashboard");
    }
  }
}
