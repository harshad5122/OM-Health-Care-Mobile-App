import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/staff/controller/add_doctor_controller.dart';
import '../widgets/phone_field.dart';
import '../widgets/textfield.dart';
import '../widgets/dropdown.dart';

class AddDoctorPage extends StatelessWidget {
  final controller = Get.put(AddDoctorController());

  AddDoctorPage({super.key});

  Widget sectionCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text("Add Doctor")
        title: Obx(() =>
            Text(controller.isEditMode.value ? "Edit Doctor" : "Add Doctor")),
        backgroundColor: Get.theme.primaryColor,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              // Personal Info
              sectionCard("Personal Information", [
                CustomTextField(
                    label: "First Name*",
                    hint: "Enter first name",
                    controller: controller.firstNameController),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Last Name*",
                    hint: "Enter last name",
                    controller: controller.lastNameController),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Email*",
                    hint: "Enter email",
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),

                PhoneField(
                  label: "Mobile Number",
                  countryCode: controller.countryCode,
                  phoneController: controller.phoneController,
                  validator: (val) =>
                  val!.isEmpty ? "Mobile number is required" : null,
                ),
                const SizedBox(height: 12),
                Obx(() {
                  return GestureDetector(
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
                            ? "Select date of birth"
                            : "${controller.dob.value!.day}-${controller.dob.value!.month}-${controller.dob.value!.year}",
                        controller: TextEditingController(),
                        prefixIcon: Icons.calendar_today,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() => CustomDropdown(
                  label: "Gender*",
                  value: controller.selectedGender.value.isEmpty
                      ? null
                      : controller.selectedGender.value,
                  items: controller.genders,
                  onChanged: (val) =>
                  controller.selectedGender.value = val ?? "",
                  validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
                )),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Qualification*",
                    hint: "Enter qualification",
                    controller: controller.qualificationController),
                const SizedBox(height: 12),
                Obx(() => CustomDropdown(
                  label: "Specialization*",
                  value: controller.selectedSpecialization.value.isEmpty
                      ? null
                      : controller.selectedSpecialization.value,
                  items: controller.specializations,
                  onChanged: (val) =>
                  controller.selectedSpecialization.value = val ?? "",
                  validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
                )),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Occupation*",
                    hint: "Enter occupation",
                    controller: controller.occupationController),
                const SizedBox(height: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Professional Status*",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    // const SizedBox(height: 6),
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero, // remove horizontal padding
                            title: const Text("Fresher"),
                            value: "fresher",
                            dense: true, // reduce height
                            visualDensity: VisualDensity.compact, // tighten spacing
                            groupValue: controller.professionalStatus.value,
                            onChanged: (val) =>
                            controller.professionalStatus.value = val.toString(),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Experienced"),
                            value: "experienced",
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            groupValue: controller.professionalStatus.value,
                            onChanged: (val) =>
                            controller.professionalStatus.value = val.toString(),
                          ),
                        ),
                      ],
                    )),
                  ],
                )

              ]),

              // Work Experience (only if experienced)
              Obx(() => controller.professionalStatus.value == "experienced"
                  ? sectionCard("Work Experience", [
                CustomTextField(
                    label: "Total Years of Experience*",
                    hint: "e.g. 5",
                    controller: controller.totalYearsController,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Last Hospital/Clinic Name*",
                    hint: "Enter hospital name",
                    controller: controller.lastHospitalController),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Position Held*",
                    hint: "Enter position",
                    controller: controller.positionController),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Hospital/Clinic Address*",
                    hint: "Enter address",
                    controller: controller.workHospitalAddressController),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: "Country*",
                  value: controller.workCountry.value.isEmpty
                      ? null
                      : controller.workCountry.value,
                  items: controller.countries,
                  onChanged: (val) =>
                  controller.workCountry.value = val ?? "",
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: "State*",
                  value: controller.workState.value.isEmpty
                      ? null
                      : controller.workState.value,
                  items: controller.states[
                  controller.workCountry.value.isEmpty
                      ? "India"
                      : controller.workCountry.value] ??
                      [],
                  onChanged: (val) =>
                  controller.workState.value = val ?? "",
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: "City*",
                  value: controller.workCity.value.isEmpty
                      ? null
                      : controller.workCity.value,
                  items: controller.cities[
                  controller.workState.value.isEmpty
                      ? "Gujarat"
                      : controller.workState.value] ??
                      [],
                  onChanged: (val) =>
                  controller.workCity.value = val ?? "",
                ),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Pincode*",
                    hint: "Enter pincode",
                    controller: controller.workPincodeController,
                    keyboardType: TextInputType.number),
              ])
                  : const SizedBox()),

              // Address Info
              sectionCard("Address Information", [
                CustomTextField(
                    label: "Address*",
                    hint: "Enter address",
                    controller: controller.addressController),
                const SizedBox(height: 12),
                Obx(() => CustomDropdown(
                  label: "Country*",
                  value: controller.selectedCountry.value.isEmpty
                      ? null
                      : controller.selectedCountry.value,
                  items: controller.countries,
                  onChanged: (val) =>
                  controller.selectedCountry.value = val ?? "",
                )),
                const SizedBox(height: 12),
                Obx(() => CustomDropdown(
                  label: "State*",
                  value: controller.selectedState.value.isEmpty
                      ? null
                      : controller.selectedState.value,
                  items: controller.states[
                  controller.selectedCountry.value.isEmpty
                      ? "India"
                      : controller.selectedCountry.value] ??
                      [],
                  onChanged: (val) =>
                  controller.selectedState.value = val ?? "",
                )),
                const SizedBox(height: 12),
                Obx(() => CustomDropdown(
                  label: "City*",
                  value: controller.selectedCity.value.isEmpty
                      ? null
                      : controller.selectedCity.value,
                  items: controller.cities[
                  controller.selectedState.value.isEmpty
                      ? "Gujarat"
                      : controller.selectedState.value] ??
                      [],
                  onChanged: (val) =>
                  controller.selectedCity.value = val ?? "",
                )),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Pincode*",
                    hint: "Enter pincode",
                    controller: controller.pincodeController,
                    keyboardType: TextInputType.number),
              ]),

              // Family Details
              sectionCard("Family Details", [
                CustomTextField(
                    label: "Father’s Name*",
                    hint: "Enter father’s name",
                    controller: controller.fatherNameController),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Father’s Contact*",
                    hint: "Enter contact",
                    controller: controller.fatherContactController,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                CustomTextField(
                  label: "Father’s Occupation*",
                  hint: "Enter father’s occupation",
                  controller: controller.fatherOccupationController,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  label: "Mother’s Name*",
                  hint: "Enter mother’s name",
                  controller: controller.motherNameController,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  label: "Mother’s Contact*",
                  hint: "Enter contact",
                  controller: controller.motherContactController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  label: "Mother’s Occupation*",
                  hint: "Enter mother’s occupation",
                  controller: controller.motherOccupationController,
                ),
              ]),

              // Permanent Address
              sectionCard("Permanent Address", [
                Obx(() => CheckboxListTile(
                  value: controller.sameAsCurrent.value,
                  title: const Text("Same as current address"),
                  onChanged: (val) {
                    controller.toggleSameAsCurrent(val ?? false);
                  },
                  // onChanged: (val) =>
                  // controller.sameAsCurrent.value = val ?? false,
                )),
                if (!controller.sameAsCurrent.value) ...[
                  CustomTextField(
                      label: "Address*",
                      hint: "Enter address",
                      controller: controller.permAddressController),
                  const SizedBox(height: 12),
                  // CustomDropdown(
                  //   label: "Country*",
                  //   value: controller.permCountry.value.isEmpty
                  //       ? null
                  //       : controller.permCountry.value,
                  //   items: controller.countries,
                  //   onChanged: (val) =>
                  //   controller.permCountry.value = val ?? "",
                  // ),

                  Obx(() => CustomDropdown(
                    label: "Country*",
                    value: controller.permCountry.value.isEmpty
                        ? null
                        : controller.permCountry.value,
                    items: controller.countries,
                    onChanged: (val) =>
                    controller.permCountry.value = val ?? "",
                  )),
                  const SizedBox(height: 12),
                  // CustomDropdown(
                  //   label: "State*",
                  //   value: controller.permState.value.isEmpty
                  //       ? null
                  //       : controller.permState.value,
                  //   items: controller.states[
                  //   controller.permCountry.value.isEmpty
                  //       ? "India"
                  //       : controller.permCountry.value] ??
                  //       [],
                  //   onChanged: (val) =>
                  //   controller.permState.value = val ?? "",
                  // ),

                  Obx(() => CustomDropdown(
                    label: "State*",
                    value: controller.permState.value.isEmpty
                        ? null
                        : controller.permState.value,
                    items: controller.states[
                    controller.permCountry.value.isEmpty
                        ? "India"
                        : controller.permCountry.value] ??
                        [],
                    onChanged: (val) =>
                    controller.permState.value = val ?? "",
                  )),
                  const SizedBox(height: 12),
                  // CustomDropdown(
                  //   label: "City*",
                  //   value: controller.permCity.value.isEmpty
                  //       ? null
                  //       : controller.permCity.value,
                  //   items: controller.cities[
                  //   controller.permState.value.isEmpty
                  //       ? "Gujarat"
                  //       : controller.permState.value] ??
                  //       [],
                  //   onChanged: (val) =>
                  //   controller.permCity.value = val ?? "",
                  // ),
                  Obx(() => CustomDropdown(
                    label: "City*",
                    value: controller.permCity.value.isEmpty
                        ? null
                        : controller.permCity.value,
                    items: controller.cities[
                    controller.permState.value.isEmpty
                        ? "Gujarat"
                        : controller.permState.value] ??
                        [],
                    onChanged: (val) =>
                    controller.permCity.value = val ?? "",
                  )),
                  const SizedBox(height: 12),
                  CustomTextField(
                      label: "Pincode*",
                      hint: "Enter pincode",
                      controller: controller.permPincodeController,
                      keyboardType: TextInputType.number),
                ]
              ]),

              // Emergency Contact
              sectionCard("Emergency Contact", [
                CustomTextField(
                    label: "Contact Person Name*",
                    hint: "Enter name",
                    controller: controller.emergencyNameController),
                const SizedBox(height: 12),
                Obx(() => CustomDropdown(
                  label: "Relation*",
                  value: controller.emergencyRelation.value.isEmpty
                      ? null
                      : controller.emergencyRelation.value,
                  items: controller.relations,
                  onChanged: (val) =>
                  controller.emergencyRelation.value = val ?? "",
                )),
                const SizedBox(height: 12),
                CustomTextField(
                    label: "Contact Number*",
                    hint: "Enter number",
                    controller: controller.emergencyContactController,
                    keyboardType: TextInputType.phone),
              ]),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  children: [
                    // Clear Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.clearForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Clear",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Save Doctor Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.saveDoctor,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.transparent, // for gradient
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).merge(
                          ButtonStyle(
                            // Add gradient background
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
                            elevation: WidgetStateProperty.all(0),
                            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Obx(() => Text(
                              controller.isEditMode.value
                                  ? "Update Doctor"
                                  : "Save Doctor",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )),
                            // const Text(
                            //   "Save Doctor",
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w700,
                            //     color: Colors.white,
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
