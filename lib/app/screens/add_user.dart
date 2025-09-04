import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/user/controller/add_user_controller.dart';
import '../widgets/phone_field.dart';
import '../widgets/textfield.dart';
import '../widgets/dropdown.dart';

class AddUserPage extends StatelessWidget {
  AddUserPage({super.key});

  final controller = Get.put(AddUserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
        backgroundColor: Get.theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Personal Info Section
            const Text(
              "Personal Information",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: "First Name *",
              hint: "Enter first name",
              controller: controller.firstNameController,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: "Last Name *",
              hint: "Enter last name",
              controller: controller.lastNameController,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: "Email *",
              hint: "Enter email",
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // Gender Dropdown with CustomDropdown
            Obx(() => CustomDropdown(
              label: "Gender *",
              value: controller.gender.value.isEmpty ? null : controller.gender.value,
              items: controller.genders,
              onChanged: (val) => controller.gender.value = val ?? "",
            )),
            const SizedBox(height: 12),

            PhoneField(
              label: "Phone *",
              countryCode: controller.countryCode,
              phoneController: controller.phoneController,
            ),
            const SizedBox(height: 12),

            // DOB Field
            // CustomTextField(
            //   label: "Date of Birth *",
            //   hint: "Select date of birth",
            //   controller: controller.dobController,
            //   prefixIcon: Icons.calendar_today,
            // ),
            Obx(() {
              return GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.dob.value ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    controller.dob.value = picked;
                  }
                },
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: "Date of Birth *",
                    hint: controller.dob.value == null
                        ? "Select date of birth"
                        : "${controller.dob.value!.day}-${controller.dob.value!.month}-${controller.dob.value!.year}",
                    controller: TextEditingController(
                      text: controller.dob.value == null
                          ? ""
                          : "${controller.dob.value!.day}-${controller.dob.value!.month}-${controller.dob.value!.year}",
                    ),
                    prefixIcon: Icons.calendar_today,
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            /// Address Section
            const Text(
              "Address",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: "Address *",
              hint: "Enter address",
              controller: controller.addressController,
            ),
            const SizedBox(height: 12),

            // Country Dropdown
            Obx(() => CustomDropdown(
              label: "Country *",
              value: controller.country.value.isEmpty ? null : controller.country.value,
              items: controller.countries,
              onChanged: (val) => controller.country.value = val ?? "",
            )),
            const SizedBox(height: 12),

            // State Dropdown
            Obx(() => CustomDropdown(
              label: "State *",
              value: controller.state.value.isEmpty ? null : controller.state.value,
              items: controller.states,
              onChanged: (val) => controller.state.value = val ?? "",
            )),
            const SizedBox(height: 12),

            // City Dropdown
            Obx(() => CustomDropdown(
              label: "City *",
              value: controller.city.value.isEmpty ? null : controller.city.value,
              items: controller.cities,
              onChanged: (val) => controller.city.value = val ?? "",
            )),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.clearForm,
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Get.theme.primaryColor)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Clear",  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Save User",  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
