import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/staff_list_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';
import '../../members/member_controller.dart';

class AddUserController extends GetxController {
  // Personal Info controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dob = Rxn<DateTime>();

  // Address controllers
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  final MembersController memberController = Get.put(MembersController());

  RxList<StaffListModel> doctorList = <StaffListModel>[].obs;
  RxString selectedDoctorName = ''.obs;

  var isPageLoading = true.obs;


  // Reactive values
  var gender = "".obs;
  var countryCode = "+91".obs;
  // var city = "".obs;
  var state = "".obs;
  var country = "".obs;

  // Dropdown data
  final genders = ["Male", "Female", "Other"];
  final countries = ["India", "USA", "UK", "Australia"];
  final states = [ // All Indian States
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
  ];
  // final cities = ["Ahmedabad", "Mumbai", "Houston", "Los Angeles", "Manchester"];

  // Edit mode
  String? userId;
  var isEditMode = false.obs;

  var isLoadingDoctorsForDropdown = false.obs;
  // var hasFetchedDoctorsOnce = false.obs;
  var hasFetchedDoctorsSuccessfully = false.obs;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });

  }

  Future<void> _initialize() async {
    try {
      if (!Get.isRegistered<MembersController>()) {
        Get.put(MembersController());
      }

      // Always fetch doctors on page load
      await fetchDoctorsForDropdown();

      // If edit mode
      if (Get.arguments != null && Get.arguments['userId'] != null) {
        userId = Get.arguments['userId'];
        isEditMode.value = true;
        await fetchUserById(userId!);
      }
    } catch (e) {
      Get.snackbar("Error", "Initialization failed: $e");
    } finally {
      isPageLoading.value = false;
    }
  }

  Future<void> fetchDoctorsForDropdown() async {
    if (isLoadingDoctorsForDropdown.value) return;

    isLoadingDoctorsForDropdown.value = true;
    try {
      print("Fetching doctors for dropdown...");
      await memberController.fetchDoctors(clear: true, fetchAll: true);

      doctorList.assignAll(memberController.doctors);
      hasFetchedDoctorsSuccessfully.value = doctorList.isNotEmpty;
      print("Fetched ${doctorList.length} doctors for dropdown.");
    } catch (e) {
      print("Error fetching doctors: $e");
      Get.snackbar("Error", "Failed to load doctors: $e");
    } finally {
      isLoadingDoctorsForDropdown.value = false;
    }
  }

  /// Fetch user by ID for edit mode
  Future<void> fetchUserById(String id) async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse("${ApiConstants.GET_USER_BY_ID}/$id");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == 1 && data["body"] != null) {
          final user = data["body"];
          _fillForm(user);
        } else {
          Get.snackbar("Error", "Failed to fetch user details");
        }
      } else {
        Get.snackbar("Error", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  /// Fill form fields with existing user data
  void _fillForm(Map<String, dynamic> user) {
    firstNameController.text = user["firstname"] ?? "";
    lastNameController.text = user["lastname"] ?? "";
    emailController.text = user["email"] ?? "";
    phoneController.text = user["phone"] ?? "";
    gender.value = user["gender"] ?? "";
    addressController.text = user["address"] ?? "";
    // city.value = user["city"] ?? "";
    cityController.text = user["city"] ?? "";
    state.value = user["state"] ?? "";
    country.value = user["country"] ?? "";
    countryCode.value = user["countryCode"] ?? "+91";

    if (user["dob"] != null) {
      dob.value = DateTime.tryParse(user["dob"]);
    }

    final String doctorId = user["assign_doctor"] ?? ""; // Get the ID
    if (doctorId.isNotEmpty && doctorList.isNotEmpty) {
      // Find the doctor in the list by their ID
      final matchingDoctor = doctorList.firstWhere(
            (doc) => doc.id == doctorId,
        orElse: () => StaffListModel(), // return an empty model if not found
      );

      if (matchingDoctor.id != null) {
        // Set the observable to the doctor's NAME
        selectedDoctorName.value = "${matchingDoctor.firstname} ${matchingDoctor.lastname}";
      } else {
        print("Warning: Assigned doctor with ID $doctorId not found in doctorList.");
        selectedDoctorName.value = "";
      }
    }else if (doctorId.isNotEmpty && doctorList.isEmpty) {
      print("Warning: Doctor list is empty, cannot pre-select assigned doctor for ID $doctorId.");
      // This indicates a potential issue if `fetchDoctorsForDropdown` failed.
      selectedDoctorName.value = "";
    }
  }





  Future<void> saveUser() async {
    if (!_validateForm()) return;

    String doctorIdToSend = "";
    if (selectedDoctorName.value.isNotEmpty) {
      final matchingDoctor = doctorList.firstWhere(
            (doc) => "${doc.firstname} ${doc.lastname}" == selectedDoctorName.value,
        orElse: () => StaffListModel(),
      );
      if (matchingDoctor.id != null) {
        doctorIdToSend = matchingDoctor.id!;
      } else {
        print("Error: Could not find doctor ID for name ${selectedDoctorName.value}");
        Get.snackbar("Error", "Invalid doctor selected.");
        return;
      }
    }

    try {
      isLoadingDoctorsForDropdown.value = true;
      final token = await TokenStorage.getToken();
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      };

      final body = {
        "firstname": firstNameController.text.trim(),
        "lastname": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "gender": gender.value.toLowerCase(),
        "dob": dob.value!.toIso8601String(),
        "address": addressController.text.trim(),
        // "city": city.value,
        "city": cityController.text.trim(),
        "state": state.value,
        "country": country.value,
        "countryCode": countryCode.value,
        "assign_doctor": doctorIdToSend,
      };

      http.Response response;

      if (isEditMode.value && userId != null) {
        // EDIT existing user
        final url = Uri.parse("${ApiConstants.EDIT_USER}/$userId");
        response = await http.put(url, headers: headers, body: jsonEncode(body));
      } else {
        // ADD new user
        final url = Uri.parse(ApiConstants.ADD_USER);
        response = await http.post(url, headers: headers, body: jsonEncode(body));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (isEditMode.value) {
          if (data["success"] == 1 || data["code"] == 200) {
            // Get.snackbar("Success", data["msg"] ?? "User updated successfully",
            //     snackPosition: SnackPosition.BOTTOM);
            Get.back(result: true);
            // Get.toNamed("/member");
            // Get.off(() => MembersPage());
            // Get.back(result: true);
          } else {
            Get.snackbar("Error", data["msg"] ?? "Failed to update user",
                snackPosition: SnackPosition.BOTTOM);
          }
        } else {
          if (data["status"] == true) {
            Get.snackbar("Success", data["message"] ?? "User created successfully",
                snackPosition: SnackPosition.BOTTOM);
            clearForm();
          } else {
            Get.snackbar("Error", data["message"] ?? "Failed to add user",
                snackPosition: SnackPosition.BOTTOM);
          }
        }
      } else {
        Get.snackbar("Error", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }finally {
      isLoadingDoctorsForDropdown.value = false; // Reset loading state
    }
  }

  bool _validateForm() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        gender.value.isEmpty ||
        phoneController.text.isEmpty ||
        dob.value == null ||
        addressController.text.isEmpty ||
        // city.value.isEmpty ||
        cityController.text.isEmpty ||
        state.value.isEmpty ||
        country.value.isEmpty||
        selectedDoctorName.value.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    dob.value = null;
    addressController.clear();
    gender.value = "";
    // city.value = "";
    cityController.clear();
    state.value = "";
    country.value = "";
    selectedDoctorName.value = "";
    // hasFetchedDoctorsOnce.value = false;
    hasFetchedDoctorsSuccessfully.value = false;
    doctorList.clear();
  }
  void openDoctorSelectionSheet(BuildContext context) {
    Get.bottomSheet(

         Container(
          height: Get.height * 0.6,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Doctor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                        memberController.doctorsHasMore.value &&
                        !memberController.isLoading.value) {
                      // Infinite scroll fetch
                      memberController.fetchDoctors();
                    }
                    return false;
                  },
                  child: Obx(() {
                    if (isLoadingDoctorsForDropdown.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (doctorList.isEmpty) {
                      return const Center(child: Text("No doctors available"));
                    }
                    return ListView.builder(
                      itemCount: doctorList.length,
                      itemBuilder: (context, index) {
                        final doctor = doctorList[index];
                        return ListTile(
                          title: Text("${doctor.firstname} ${doctor.lastname}"),
                          onTap: () {
                            selectedDoctorName.value =
                            "${doctor.firstname} ${doctor.lastname}";
                            Get.back();
                          },
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

      isScrollControlled: true,
    );
  }

}
