import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDoctorController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Personal Info
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final countryCodeController = TextEditingController(text: "+91");
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
  var workCity = "".obs;
  var workState = "".obs;
  var workCountry = "".obs;
  final workPincodeController = TextEditingController();

  // Address Info
  final addressController = TextEditingController();
  var selectedCity = "".obs;
  var selectedState = "".obs;
  var selectedCountry = "".obs;
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
  var permCity = "".obs;
  var permState = "".obs;
  var permCountry = "".obs;
  final permPincodeController = TextEditingController();

  // Emergency Contact
  final emergencyNameController = TextEditingController();
  var emergencyRelation = "".obs;
  final emergencyContactController = TextEditingController();

  // Dropdown options
  final genders = ["male", "female", "other", "prefer not to say"];
  final specializations = [
    "Cardiologist",
    "Dermatologist",
    "Neurologist",
    "Orthopedic",
    "General"
  ];
  final relations = ["spouse", "parent", "sibling", "other"];
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
    workPincodeController.clear();
    addressController.clear();
    pincodeController.clear();
    fatherNameController.clear();
    fatherContactController.clear();
    fatherOccupationController.clear();
    motherNameController.clear();
    motherContactController.clear();
    motherOccupationController.clear();
    permAddressController.clear();
    permPincodeController.clear();
    emergencyNameController.clear();
    emergencyContactController.clear();

    dob.value = null;
    selectedGender.value = "";
    selectedSpecialization.value = "";
    professionalStatus.value = "experienced";
    selectedCity.value = "";
    selectedState.value = "";
    selectedCountry.value = "";
    workCity.value = "";
    workState.value = "";
    workCountry.value = "";
    permCity.value = "";
    permState.value = "";
    permCountry.value = "";
    emergencyRelation.value = "";
    sameAsCurrent.value = false;
  }

  void saveDoctor() {
    if (!formKey.currentState!.validate()) return;

    final doctorData = {
      "firstname": firstNameController.text,
      "lastname": lastNameController.text,
      "email": emailController.text,
      "countryCode": countryCodeController.text,
      "phone": phoneController.text,
      "dob": dob.value?.toIso8601String(),
      "gender": selectedGender.value,
      "qualification": qualificationController.text,
      "specialization": selectedSpecialization.value,
      "occupation": occupationController.text,
      "professionalStatus": professionalStatus.value,
      "workExperience": professionalStatus.value == "experienced"
          ? {
        "totalYears": int.tryParse(totalYearsController.text),
        "lastHospital": lastHospitalController.text,
        "position": positionController.text,
        "workAddress": {
          "hospitalName": workHospitalAddressController.text,
          "city": workCity.value,
          "state": workState.value,
          "country": workCountry.value,
          "pincode": workPincodeController.text,
        },
      }
          : null,
      "address": addressController.text,
      "city": selectedCity.value,
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
          "city": permCity.value,
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

    print("Doctor Data => $doctorData");

    // TODO: Call your API here with doctorData
    Get.snackbar("Success", "Doctor saved successfully",
        backgroundColor: Colors.green, colorText: Colors.white);
  }
}
