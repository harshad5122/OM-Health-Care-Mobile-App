import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/staff/controller/add_doctor_controller.dart';
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
      appBar: AppBar(title: const Text("Add Doctor")),
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                          label: "Country Code*",
                          hint: "+91",
                          controller: controller.countryCodeController),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: CustomTextField(
                          label: "Phone Number*",
                          hint: "Enter phone number",
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone),
                    ),
                  ],
                ),
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
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: const Text("Fresher"),
                        value: "fresher",
                        groupValue: controller.professionalStatus.value,
                        onChanged: (val) =>
                        controller.professionalStatus.value =
                            val.toString(),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: const Text("Experienced"),
                        value: "experienced",
                        groupValue: controller.professionalStatus.value,
                        onChanged: (val) =>
                        controller.professionalStatus.value =
                            val.toString(),
                      ),
                    ),
                  ],
                )),
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
              ]),

              // Permanent Address
              sectionCard("Permanent Address", [
                Obx(() => CheckboxListTile(
                  value: controller.sameAsCurrent.value,
                  title: const Text("Same as current address"),
                  onChanged: (val) =>
                  controller.sameAsCurrent.value = val ?? false,
                )),
                if (!controller.sameAsCurrent.value) ...[
                  CustomTextField(
                      label: "Address*",
                      hint: "Enter address",
                      controller: controller.permAddressController),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    label: "Country*",
                    value: controller.permCountry.value.isEmpty
                        ? null
                        : controller.permCountry.value,
                    items: controller.countries,
                    onChanged: (val) =>
                    controller.permCountry.value = val ?? "",
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
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
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
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
                  ),
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
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                        onPressed: controller.clearForm,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400),
                        child: const Text("Clear"),
                      )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ElevatedButton(
                        onPressed: controller.saveDoctor,
                        child: const Text("Save Doctor"),
                      )),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
