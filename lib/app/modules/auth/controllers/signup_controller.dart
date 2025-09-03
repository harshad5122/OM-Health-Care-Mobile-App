import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  void register() {
    if (formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar("Error", "Passwords do not match",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      // TODO: API call for registration
      Get.snackbar("Success", "Account Registered Successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    }
  }
}
