import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class ProfileController extends GetxController {
  // Edit mode state
  var isEditing = false.obs;
  var isLoading = false.obs;

  // Personal Information
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final dob = Rxn<DateTime>();
  var selectedGender = "".obs;

  // Address Information
  final addressController = TextEditingController();
  var selectedCity = "".obs;
  var selectedState = "".obs;
  var selectedCountry = "".obs;

  // Dropdown Data
  final genders = ["Male", "Female", "Other"];
  final countries = ["India", "USA", "UK"];
  final states = {
    "India": ["Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu",
      "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal", "Andaman and Nicobar Islands", "Chandigarh", "Dadra and Nagar Haveli and Daman and Diu", "Delhi", "Jammu and Kashmir", "Ladakh", "Lakshadweep", "Puducherry"],
    "USA": ["California", "Texas", "New York"],
    "UK": ["London", "Manchester"],
  };
  // final cities = {
  //   "Gujarat": ["Ahmedabad", "Surat", "Rajkot"],
  //   "Maharashtra": ["Mumbai", "Pune"],
  //   "Delhi": ["New Delhi"],
  //   "California": ["Los Angeles", "San Francisco"],
  //   "Texas": ["Houston", "Dallas"],
  //   "New York": ["New York City", "Buffalo"],
  //   "London": ["London City"],
  //   "Manchester": ["Manchester City"],
  // };

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  /// Fetch Profile API
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();

      print("Token from storage => $token");

      if (token == null) {
        Get.snackbar("Error", "No token found. Please login again.",
            // backgroundColor: Colors.red, colorText: Colors.white
        );
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.GET_USER_PROFILE),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      print("Profile API Response => $data");

      if (response.statusCode == 200 && (data["success"] == 1)) {
        final user = data["body"];

        // ✅ Set controllers from API
        firstNameController.text = user["firstname"] ?? "";
        lastNameController.text = user["lastname"] ?? "";
        emailController.text = user["email"] ?? "";
        phoneController.text = user["phone"] ?? "";
        addressController.text = user["address"] ?? "";

        selectedGender.value = (user["gender"] ?? "").toLowerCase();
        selectedCountry.value = user["country"] ?? "";
        selectedState.value = user["state"] ?? "";
        // selectedCity.value = user["city"] ?? "";
        cityController.text = user["city"] ?? "";

        if (user["dob"] != null && user["dob"].toString().isNotEmpty) {
          dob.value = DateTime.tryParse(user["dob"]);
        }
      } else {
        Get.snackbar("Error", data["msg"] ?? "Failed to load profile",
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

  /// UPDATE PROFILE API
  Future<void> updateUserProfile() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();

      if (token == null) {
        Get.snackbar("Error", "No token found. Please login again.",
            // backgroundColor: Colors.red, colorText: Colors.white
        );
        return;
      }

      final body = {
        "firstname": firstNameController.text.trim(),
        "lastname": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "country": selectedCountry.value,
        "state": selectedState.value,
        // "city": selectedCity.value,
        "city": cityController.text.trim(),
        "gender": selectedGender.value.toLowerCase(),
        "dob": dob.value?.toIso8601String(),
      };

      print("Update body => $body");

      final response = await http.put(
        Uri.parse(ApiConstants.UPDATE_USER_PROFILE),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print("Update API Response => $data");

      if (response.statusCode == 200 && (data["success"] == 1)) {
        Get.snackbar("Success", data["msg"] ?? "Profile updated successfully",
            // backgroundColor: Colors.green, colorText: Colors.white
        );

        // update local values
        isEditing.value = false;
        fetchUserProfile(); // refresh with updated data
      } else {
        Get.snackbar("Error", data["msg"] ?? "Update failed",
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
