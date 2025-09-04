import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/api_constants.dart';

class SignupController extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();

  // Country/State/City dropdowns
  final selectedCountry = "".obs;
  final selectedState = "".obs;
  final selectedCity = "".obs;

  // Gender dropdown
  final selectedGender = "".obs;

  // Date of birth
  final dob = Rxn<DateTime>();

  // Country Code
  final countryCode = "+91".obs;

  // Example options
  final countries = ["India", "USA", "UK", "Australia"];
  final states = {
    "India": ["Gujarat", "Maharashtra", "Delhi"],
    "USA": ["California", "Texas", "Florida"],
    "UK": ["London", "Manchester"],
    "Australia": ["Sydney", "Melbourne"],
  };
  final cities = {
    "Gujarat": ["Ahmedabad", "Surat"],
    "Maharashtra": ["Mumbai", "Pune"],
    "Delhi": ["New Delhi"],
    "California": ["Los Angeles", "San Francisco"],
    "Texas": ["Houston", "Dallas"],
    "Florida": ["Miami", "Orlando"],
    "London": ["Central", "East London"],
    "Manchester": ["City Centre", "Salford"],
    "Sydney": ["Sydney CBD", "Parramatta"],
    "Melbourne": ["Melbourne CBD", "Geelong"],
  };

  final genders = ["Male", "Female", "Other"];

  // Password hidden toggle
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  // Submit
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match",
          snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: Colors.red,
          // colorText: Colors.white
      );
      return;
    }

    try {
      final body = {
        "firstname": firstNameController.text.trim(),
        "lastname": lastNameController.text.trim(),
        "countryCode": countryCode.value,
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "dob": dob.value?.toIso8601String(),
        "address": addressController.text.trim(),
        "country": selectedCountry.value,
        "state": selectedState.value,
        "city": selectedCity.value,
        "gender": selectedGender.value.toLowerCase(),
        "role": 1 // 👈 USER role (adjust if needed)
      };

      final response = await http.post(
        Uri.parse(ApiConstants.SIGNUP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      print('data==> $data');
      print('status code ==> ${response.statusCode}');
      if (response.statusCode == 200 && (data["success"] == 1 || data["success"] == true)) {
        Get.snackbar("Success", data["msg"] ?? "Registered Successfully!",
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.green,
            // colorText: Colors.white
        );

        // After success → redirect to login
        Get.offAllNamed("/login");
      } else {
        Get.snackbar("Error", data["msg"] ?? "Something went wrong",
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.red,
            // colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: Colors.red,
          // colorText: Colors.white
      );
    }
  }
}
