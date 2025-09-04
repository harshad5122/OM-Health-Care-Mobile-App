import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class AddUserController extends GetxController {
  // Personal Info controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dob = Rxn<DateTime>();

  // Address controllers
  final addressController = TextEditingController();

  // Reactive values
  var gender = "".obs;
  var countryCode = "+91".obs;
  var city = "".obs;
  var state = "".obs;
  var country = "".obs;

  // Dropdown data
  final genders = ["Male", "Female", "Other"];
  final countries = ["India", "USA", "UK", "Australia"];
  final states = ["Gujarat", "Maharashtra", "Texas", "California", "London"];
  final cities = ["Ahmedabad", "Mumbai", "Houston", "Los Angeles", "Manchester"];

  // Save user method
  Future<void> saveUser() async{
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        gender.value.isEmpty ||
        phoneController.text.isEmpty ||
        dob.value == null ||
        addressController.text.isEmpty ||
        city.value.isEmpty ||
        state.value.isEmpty ||
        country.value.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields",
          snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: Colors.red.shade100,
          // colorText: Colors.red.shade900
      );
      return;
    }

    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse(ApiConstants.ADD_USER);

      final body = {
        "firstname": firstNameController.text.trim(),
        "lastname": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "gender": gender.value.toLowerCase(),
        "dob": dob.value!.toIso8601String(),
        "address": addressController.text.trim(),
        "city": city.value,
        "state": state.value,
        "country": country.value,
        "countryCode": countryCode.value,
      };

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      };
      final response = await http.post(url,
          headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data["status"] == true) {
          Get.snackbar("Success", data["message"] ?? "User created successfully",
              snackPosition: SnackPosition.BOTTOM,
              // backgroundColor: Colors.green.shade100,
              // colorText: Colors.green.shade900
          );

          clearForm();
        } else {
          Get.snackbar("Error", data["message"] ?? "Failed to add user",
              snackPosition: SnackPosition.BOTTOM,
              // backgroundColor: Colors.red.shade100,
              // colorText: Colors.red.shade900
          );
        }
      } else {
        Get.snackbar("Error", "Server error: ${response.statusCode}",
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.red.shade100,
            // colorText: Colors.red.shade900
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: Colors.red.shade100,
          // colorText: Colors.red.shade900
      );
    }
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    dob.value = null;
    addressController.clear();
    gender.value = "";
    city.value = "";
    state.value = "";
    country.value = "";
  }
}
