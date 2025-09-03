import 'package:get/get.dart';

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
}
