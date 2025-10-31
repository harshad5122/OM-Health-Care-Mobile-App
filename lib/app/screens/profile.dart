import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/user/controller/profile_controller.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/dropdown.dart';
import '../widgets/textfield.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          Obx(() => TextButton(
            // onPressed: controller.toggleEdit,
            onPressed: () {
              if (controller.isEditing.value) {
                controller.updateUserProfile(); // call API on save
              } else {
                controller.toggleEdit();
              }
            },
            child: Text(
              controller.isEditing.value ? "Save" : "Edit Profile",
              style: const TextStyle(color: Colors.white),
            ),
          )),
        ],
      ),
      drawer: CustomDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Personal Information
                const Text(
                  "Personal Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Column(
                    children: [
                      controller.isEditing.value
                          ? CustomTextField(
                        label: "First Name",
                        hint: "Enter First Name",
                        controller: controller.firstNameController,
                      )
                          : _buildReadOnly("First Name",
                          controller.firstNameController.text),
                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? CustomTextField(
                        label: "Last Name",
                        hint: "Enter Last Name",
                        controller: controller.lastNameController,
                      )
                          : _buildReadOnly("Last Name",
                          controller.lastNameController.text),
                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? CustomTextField(
                        label: "Email",
                        hint: "Enter Email",
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      )
                          : _buildReadOnly(
                          "Email", controller.emailController.text),
                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? CustomTextField(
                        label: "Phone Number",
                        hint: "Enter Phone Number",
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                      )
                          : _buildReadOnly(
                          "Phone Number", controller.phoneController.text),
                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: controller.dob.value ??
                                DateTime(2000, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controller.dob.value = picked;
                          }
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: "Date of Birth",
                            hint: controller.dob.value == null
                                ? "Select DOB"
                                : "${controller.dob.value!.day}-${controller.dob.value!.month}-${controller.dob.value!.year}",
                            controller: TextEditingController(),
                          ),
                        ),
                      )
                          : _buildReadOnly(
                          "Date of Birth",
                          controller.dob.value == null
                              ? "-"
                              : "${controller.dob.value!.day}-${controller.dob.value!.month}-${controller.dob.value!.year}"),
                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? CustomDropdown(
                        label: "Gender",
                        value: controller.selectedGender.value,
                        items: controller.genders,
                        onChanged: (val) =>
                        controller.selectedGender.value = val ?? "",
                      )
                          : _buildReadOnly(
                          "Gender", controller.selectedGender.value),
                    ],
                  )),
                ),
                const SizedBox(height: 20),

                // Section: Address Information
                const Text(
                  "Address Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Column(
                    children: [
                      controller.isEditing.value
                          ? CustomTextField(
                        label: "Address",
                        hint: "Enter Address",
                        controller: controller.addressController,
                      )
                          : _buildReadOnly(
                          "Address", controller.addressController.text),
                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? CustomTextField(
                        label: "City",
                        hint: "Enter City",
                        controller: controller.cityController,
                      )
                          : _buildReadOnly("City", controller.cityController.text),

                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? CustomDropdown(
                        label: "State",
                        value: controller.selectedState.value,
                        items: controller
                            .states[controller.selectedCountry.value] ??
                            [],
                        onChanged: (val) =>
                        controller.selectedState.value = val ?? "",
                      )
                          : _buildReadOnly(
                          "State", controller.selectedState.value),
                      const SizedBox(height: 12),
                      controller.isEditing.value
                          ? CustomDropdown(
                        label: "Country",
                        value: controller.selectedCountry.value,
                        items: controller.countries,
                        onChanged: (val) =>
                        controller.selectedCountry.value = val ?? "",
                      )
                          : _buildReadOnly(
                          "Country", controller.selectedCountry.value),
                    ],
                  )),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildReadOnly(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
