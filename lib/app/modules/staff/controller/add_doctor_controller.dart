import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class AddDoctorController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Personal Info
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  // final countryCodeController = TextEditingController(text: "+91");
  final countryCode = "+91".obs;
  final phoneController = TextEditingController();
  final dob = Rxn<DateTime>();
  var selectedGender = "".obs;
  final qualificationController = TextEditingController();
  var selectedSpecialization = "".obs;
  final occupationController = TextEditingController();
  var professionalStatus = "experienced".obs;

  // Work Experience
  final totalYearsController = TextEditingController();
  final lastHospitalController = TextEditingController();
  final positionController = TextEditingController();
  final workHospitalAddressController = TextEditingController();
  final workCityController = TextEditingController();
  // var workCity = "".obs;
  var workState = "".obs;
  var workCountry = "".obs;
  final workPincodeController = TextEditingController();

  // Address Info
  final addressController = TextEditingController();
  // var selectedCity = "".obs;
  final cityController = TextEditingController();
  var selectedState = "".obs;
  var selectedCountry = "India".obs;
  final pincodeController = TextEditingController();

  // Family
  final fatherNameController = TextEditingController();
  final fatherContactController = TextEditingController();
  final fatherOccupationController = TextEditingController();
  final motherNameController = TextEditingController();
  final motherContactController = TextEditingController();
  final motherOccupationController = TextEditingController();

  // Permanent Address
  var sameAsCurrent = false.obs;
  final permAddressController = TextEditingController();
  final permCityController = TextEditingController();
  // var permCity = "".obs;
  var permState = "".obs;
  var permCountry = "".obs;
  final permPincodeController = TextEditingController();

  // Emergency Contact
  final emergencyNameController = TextEditingController();
  var emergencyRelation = "".obs;
  final emergencyContactController = TextEditingController();

  // Dropdown options
  final genders = ["Male", "Female", "Other"];
  final specializations = [
    "Cardiologist",
    "Dermatology",
    "Pediatrics",
    "Physiotherapy"
    "Neurology",
    "Gynecology"
    "Orthopedic",
    "General Medicine"
  ];
  final relations = ["Spouse", "Parent", "Sibling", "Other"];
  final countries = ["India", "USA", "UK"];
  final states = {
    "India": [
      "Andhra Pradesh",
      "Arunachal Pradesh",
      "Assam",
      "Bihar",
      "Chhattisgarh",
      "Goa",
      "Gujarat",
      "Haryana",
      "Himachal Pradesh",
      "Jharkhand",
      "Karnataka",
      "Kerala",
      "Madhya Pradesh",
      "Maharashtra",
      "Manipur",
      "Meghalaya",
      "Mizoram",
      "Nagaland",
      "Odisha",
      "Punjab",
      "Rajasthan",
      "Sikkim",
      "Tamil Nadu",
      "Telangana",
      "Tripura",
      "Uttar Pradesh",
      "Uttarakhand",
      "West Bengal",
      "Andaman and Nicobar Islands",
      "Chandigarh",
      "Dadra and Nagar Haveli and Daman and Diu",
      "Delhi",
      "Jammu and Kashmir",
      "Ladakh",
      "Lakshadweep",
      "Puducherry"
    ],
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

  // Edit mode
  String? doctorId;
  var isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['isEdit'] == true) {
      doctorId = Get.arguments['staffId'];
      isEditMode.value = true;
      if (doctorId != null) {
        fetchDoctorById(doctorId!);
      }
    }
  }

  /// Fetch doctor details by ID
  Future<void> fetchDoctorById(String id) async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse("${ApiConstants.GET_DOCTOR_BY_ID}/$id");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"] != null) {
          _fillForm(data["body"]);
        } else {
          Get.snackbar("Error", "Failed to fetch doctor details");
        }
      } else {
        Get.snackbar("Error", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  /// Fill form with doctor data
  void _fillForm(Map<String, dynamic> doctor) {
    firstNameController.text = doctor["firstname"] ?? "";
    lastNameController.text = doctor["lastname"] ?? "";
    emailController.text = doctor["email"] ?? "";
    phoneController.text = doctor["phone"] ?? "";
    countryCode.value = doctor["countryCode"] ?? "+91";
    dob.value = doctor["dob"] != null ? DateTime.tryParse(doctor["dob"]) : null;
    selectedGender.value = doctor["gender"] ?? "";
    qualificationController.text = doctor["qualification"] ?? "";
    selectedSpecialization.value = doctor["specialization"] ?? "";
    occupationController.text = doctor["occupation"] ?? "";
    professionalStatus.value = doctor["professionalStatus"] ?? "experienced";

    // Work exp
    if (doctor["workExperience"] != null) {
      final work = doctor["workExperience"];
      totalYearsController.text = work["totalYears"]?.toString() ?? "";
      lastHospitalController.text = work["lastHospital"] ?? "";
      positionController.text = work["position"] ?? "";
      if (work["workAddress"] != null) {
        final addr = work["workAddress"];
        workHospitalAddressController.text = addr["hospitalName"] ?? "";
        // workCity.value = addr["city"] ?? "";
        workCityController.text = addr["city"] ?? "";
        workState.value = addr["state"] ?? "";
        workCountry.value = addr["country"] ?? "";
        workPincodeController.text = addr["pincode"] ?? "";
      }
    }

    // Address
    addressController.text = doctor["address"] ?? "";
    // selectedCity.value = doctor["city"] ?? "";
    cityController.text = doctor["city"] ?? "";
    selectedState.value = doctor["state"] ?? "";
    selectedCountry.value = doctor["country"] ?? "";
    pincodeController.text = doctor["pincode"] ?? "";

    // Family
    if (doctor["familyDetails"] != null) {
      final fam = doctor["familyDetails"];
      if (fam["father"] != null) {
        fatherNameController.text = fam["father"]["name"] ?? "";
        fatherContactController.text = fam["father"]["contact"] ?? "";
        fatherOccupationController.text = fam["father"]["occupation"] ?? "";
      }
      if (fam["mother"] != null) {
        motherNameController.text = fam["mother"]["name"] ?? "";
        motherContactController.text = fam["mother"]["contact"] ?? "";
        motherOccupationController.text = fam["mother"]["occupation"] ?? "";
      }
      if (fam["permanentAddress"] != null) {
        final perm = fam["permanentAddress"];
        permAddressController.text = perm["line1"] ?? "";
        // permCity.value = perm["city"] ?? "";
        permCityController.text = perm["city"] ?? "";
        permState.value = perm["state"] ?? "";
        permCountry.value = perm["country"] ?? "";
        permPincodeController.text = perm["pincode"] ?? "";
      }
      sameAsCurrent.value = fam["sameAsPermanent"] ?? false;
      if (fam["emergencyContact"] != null) {
        final em = fam["emergencyContact"];
        emergencyNameController.text = em["name"] ?? "";
        emergencyRelation.value = em["relation"] ?? "";
        emergencyContactController.text = em["contact"] ?? "";
      }
    }
  }



  void clearForm() {
    formKey.currentState?.reset();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    qualificationController.clear();
    occupationController.clear();
    totalYearsController.clear();
    lastHospitalController.clear();
    positionController.clear();
    workHospitalAddressController.clear();
    workCityController.clear();
    workPincodeController.clear();
    addressController.clear();
    cityController.clear();
    pincodeController.clear();
    fatherNameController.clear();
    fatherContactController.clear();
    fatherOccupationController.clear();
    motherNameController.clear();
    motherContactController.clear();
    motherOccupationController.clear();
    permAddressController.clear();
    permCityController.clear();
    permPincodeController.clear();
    emergencyNameController.clear();
    emergencyContactController.clear();

    dob.value = null;
    selectedGender.value = "";
    selectedSpecialization.value = "";
    professionalStatus.value = "experienced";
    // selectedCity.value = "";
    selectedState.value = "";
    selectedCountry.value = "";
    // workCity.value = "";
    workState.value = "";
    workCountry.value = "";
    // permCity.value = "";
    permState.value = "";
    permCountry.value = "";
    emergencyRelation.value = "";
    sameAsCurrent.value = false;
  }

  void toggleSameAsCurrent(bool value) {
    sameAsCurrent.value = value;

    if (value) {
      // Copy current address info into permanent address fields
      permAddressController.text = addressController.text;
      permCountry.value = selectedCountry.value;
      permState.value = selectedState.value;
      // permCity.value = selectedCity.value;
      permCityController.text = cityController.text;
      permPincodeController.text = pincodeController.text;
    } else {
      // Clear if unchecked (optional)
      permAddressController.clear();
      permCountry.value = "";
      permState.value = "";
      // permCity.value = "";
      permCityController.clear();
      permPincodeController.clear();
    }
  }



  // void saveDoctor() async {
  //   if (!formKey.currentState!.validate()) return;
  //
  //   final doctorData = {
  //     "firstname": firstNameController.text,
  //     "lastname": lastNameController.text,
  //     "email": emailController.text,
  //     "countryCode": countryCode.value,
  //     "phone": phoneController.text,
  //     "dob": dob.value?.toIso8601String().split("T")[0], // yyyy-MM-dd
  //     "gender": selectedGender.value,
  //     "role": 3, // fixed role for doctor
  //     "qualification": qualificationController.text,
  //     "specialization": selectedSpecialization.value,
  //     "occupation": occupationController.text,
  //     "professionalStatus": professionalStatus.value,
  //     "workExperience": professionalStatus.value == "experienced"
  //         ? {
  //       "totalYears": int.tryParse(totalYearsController.text) ?? 0,
  //       "lastHospital": lastHospitalController.text,
  //       "position": positionController.text,
  //       "workAddress": {
  //         "hospitalName": workHospitalAddressController.text,
  //         "city": workCity.value,
  //         "state": workState.value,
  //         "country": workCountry.value,
  //         "pincode": workPincodeController.text,
  //       }
  //     }
  //         : null,
  //     "address": addressController.text,
  //     "city": selectedCity.value,
  //     "state": selectedState.value,
  //     "country": selectedCountry.value,
  //     "pincode": pincodeController.text,
  //     "familyDetails": {
  //       "father": {
  //         "name": fatherNameController.text,
  //         "contact": fatherContactController.text,
  //         "occupation": fatherOccupationController.text,
  //       },
  //       "mother": {
  //         "name": motherNameController.text,
  //         "contact": motherContactController.text,
  //         "occupation": motherOccupationController.text,
  //       },
  //       "permanentAddress": {
  //         "line1": permAddressController.text,
  //         "city": permCity.value,
  //         "state": permState.value,
  //         "country": permCountry.value,
  //         "pincode": permPincodeController.text,
  //       },
  //       "sameAsPermanent": sameAsCurrent.value,
  //       "emergencyContact": {
  //         "name": emergencyNameController.text,
  //         "relation": emergencyRelation.value,
  //         "contact": emergencyContactController.text,
  //       }
  //     }
  //   };
  //
  //   try {
  //     Get.dialog(
  //       const Center(child: CircularProgressIndicator()),
  //       barrierDismissible: false,
  //     );
  //
  //
  //     final token = await TokenStorage.getToken();
  //
  //     final response = await http.post(
  //       Uri.parse(ApiConstants.ADD_DOCTOR),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode(doctorData),
  //     );
  //
  //     Get.back(); // close loading dialog
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //
  //       if (data["success"] == 1) {
  //         Get.snackbar("Success", data["msg"],
  //             // backgroundColor: Colors.green, colorText: Colors.white
  //         );
  //
  //         clearForm();
  //       } else {
  //         Get.snackbar("Error", data["msg"] ?? "Something went wrong",
  //             // backgroundColor: Colors.red.shade100,
  //             // colorText: Colors.red.shade900
  //         );
  //       }
  //     } else {
  //       Get.snackbar("Error", "Failed with code ${response.statusCode}",
  //           // backgroundColor: Colors.red.shade100,
  //           // colorText: Colors.red.shade900
  //       );
  //     }
  //   } catch (e) {
  //     Get.back();
  //     Get.snackbar("Error", e.toString(),
  //         // backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900
  //     );
  //   }
  // }

  /// Save or update doctor
  Future<void> saveDoctor() async {
    if (!formKey.currentState!.validate()) return;

    final doctorData = {
      "firstname": firstNameController.text,
      "lastname": lastNameController.text,
      "email": emailController.text,
      "countryCode": countryCode.value,
      "phone": phoneController.text,
      "dob": dob.value?.toIso8601String().split("T")[0],
      "gender": selectedGender.value,
      "role": 3,
      "qualification": qualificationController.text,
      "specialization": selectedSpecialization.value,
      "occupation": occupationController.text,
      "professionalStatus": professionalStatus.value,
      "workExperience": professionalStatus.value == "experienced"
          ? {
        "totalYears": int.tryParse(totalYearsController.text) ?? 0,
        "lastHospital": lastHospitalController.text,
        "position": positionController.text,
        "workAddress": {
          "hospitalName": workHospitalAddressController.text,
          "city": workCityController.text,
          "state": workState.value,
          "country": workCountry.value,
          "pincode": workPincodeController.text,
        }
      }
          : null,
      "address": addressController.text,
      "city": cityController.text,
      "state": selectedState.value,
      "country": selectedCountry.value,
      "pincode": pincodeController.text,
      "familyDetails": {
        "father": {
          "name": fatherNameController.text,
          "contact": fatherContactController.text,
          "occupation": fatherOccupationController.text,
        },
        "mother": {
          "name": motherNameController.text,
          "contact": motherContactController.text,
          "occupation": motherOccupationController.text,
        },
        "permanentAddress": {
          "line1": permAddressController.text,
          "city": permCityController.text,
          "state": permState.value,
          "country": permCountry.value,
          "pincode": permPincodeController.text,
        },
        "sameAsPermanent": sameAsCurrent.value,
        "emergencyContact": {
          "name": emergencyNameController.text,
          "relation": emergencyRelation.value,
          "contact": emergencyContactController.text,
        }
      }
    };

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final token = await TokenStorage.getToken();
      http.Response response;

      if (isEditMode.value && doctorId != null) {
        // EDIT doctor
        final url = Uri.parse("${ApiConstants.EDIT_DOCTOR}/$doctorId");
        response = await http.put(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(doctorData),
        );
      } else {
        // ADD doctor
        final url = Uri.parse(ApiConstants.ADD_DOCTOR);
        response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(doctorData),
        );
      }

      Get.back(); // close loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (isEditMode.value) {
          if (data["success"] == 1 || data["code"] == 200) {
            // Get.snackbar("Success", data["msg"] ?? "Doctor updated successfully");
            Get.back(result: true);
            // Get.toNamed("/member");
          } else {
            Get.snackbar("Error", data["msg"] ?? "Failed to update doctor");
          }
        } else {
          if (data["success"] == 1) {
            Get.snackbar("Success", data["msg"] ?? "Doctor added successfully");
            clearForm();
          } else {
            Get.snackbar("Error", data["msg"] ?? "Failed to add doctor");
          }
        }
      } else {
        Get.snackbar("Error", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

}
