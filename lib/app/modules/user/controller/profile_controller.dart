import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  // Edit mode state
  var isEditing = false.obs;

  // Personal Information
  final firstNameController = TextEditingController(text: "John");
  final lastNameController = TextEditingController(text: "Doe");
  final emailController = TextEditingController(text: "john.doe@example.com");
  final phoneController = TextEditingController(text: "+91 9876543210");
  final dob = Rxn<DateTime>();
  var selectedGender = "Male".obs;

  // Address Information
  final addressController = TextEditingController(text: "123 Street");
  var selectedCity = "Ahmedabad".obs;
  var selectedState = "Gujarat".obs;
  var selectedCountry = "India".obs;

  // Dropdown Data
  final genders = ["Male", "Female", "Other"];
  final countries = ["India", "USA", "UK"];
  final states = {
    "India": ["Gujarat", "Maharashtra", "Delhi"],
    "USA": ["California", "Texas", "New York"],
    "UK": ["London", "Manchester"],
  };
  final cities = {
    "Gujarat": ["Ahmedabad", "Surat", "Rajkot"],
    "Maharashtra": ["Mumbai", "Pune"],
    "Delhi": ["New Delhi"],
    "California": ["Los Angeles", "San Francisco"],
    "Texas": ["Houston", "Dallas"],
    "New York": ["New York City", "Buffalo"],
    "London": ["London City"],
    "Manchester": ["Manchester City"],
  };

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }
}
