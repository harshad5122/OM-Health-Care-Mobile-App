
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
        title: Obx(() => Text(
          controller.isEditMode.value ? "Edit User" : "Add User",
        )),
        backgroundColor: Get.theme.primaryColor,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child:
             Obx(() {
               if (controller.isPageLoading.value) {
                 return const Center(child: CircularProgressIndicator());
               } else {
                 return SingleChildScrollView(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [

                       /// Personal Info Section
                       const Text(
                         "Personal Information",
                         style: TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                             color: Colors.black87),
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

                       // Gender Dropdown

                       Obx(() =>
                           CustomDropdown(
                             label: "Gender *",
                             value: controller.gender.value.isEmpty
                                 ? null
                                 : controller.gender.value,
                             items: controller.genders,
                             onChanged: (val) =>
                             controller.gender.value = val ?? "",
                           )),

                       const SizedBox(height: 12),

                       PhoneField(
                         label: "Phone *",
                         countryCode: controller.countryCode,
                         phoneController: controller.phoneController,
                       ),
                       const SizedBox(height: 12),


                       Obx(() {
                         final dob = controller.dob.value;
                         return GestureDetector(
                           onTap: () async {
                             DateTime? picked = await showDatePicker(
                               context: context,
                               initialDate: dob ?? DateTime(2000, 1, 1),
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
                               hint: dob == null
                                   ? "Select date of birth"
                                   : "${dob.day}-${dob.month}-${dob.year}",
                               controller: TextEditingController(
                                 text: dob == null
                                     ? ""
                                     : "${dob.day}-${dob.month}-${dob.year}",
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
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                             color: Colors.black87),
                       ),
                       const SizedBox(height: 12),

                       CustomTextField(
                         label: "Address *",
                         hint: "Enter address",
                         controller: controller.addressController,
                       ),
                       const SizedBox(height: 12),


                       Obx(() =>
                           CustomDropdown(
                             label: "Country *",
                             value: controller.country.value.isEmpty
                                 ? null
                                 : controller.country.value,
                             items: controller.countries,
                             onChanged: (val) =>
                             controller.country.value = val ?? "",
                           )),

                       const SizedBox(height: 12),


                       Obx(() =>
                           CustomDropdown(
                             label: "State *",
                             value: controller.state.value.isEmpty
                                 ? null
                                 : controller.state.value,
                             items: controller.states,
                             onChanged: (val) =>
                             controller.state.value = val ?? "",
                           )),

                       const SizedBox(height: 12),


                       // Obx(() =>
                       //     CustomDropdown(
                       //       label: "City *",
                       //       value: controller.city.value.isEmpty
                       //           ? null
                       //           : controller.city.value,
                       //       items: controller.cities,
                       //       onChanged: (val) =>
                       //       controller.city.value = val ?? "",
                       //     )),
                       CustomTextField(
                         label: "City *",
                         hint: "Enter city",
                         controller: controller.cityController, // Use the new controller
                         validator: (val) =>
                         val == null || val.isEmpty ? "City is required" : null,
                       ),

                       const SizedBox(height: 12),

                       Obx(() {
                         return GestureDetector(
                           onTap:  () async {
                             if (controller.doctorList.isEmpty) {
                               await controller.fetchDoctorsForDropdown();
                             }
                             controller.openDoctorSelectionSheet(context);
                           },
                           child: AbsorbPointer(
                             child: CustomTextField(
                               label: "Assign Doctor *",
                               hint: controller.selectedDoctorName.value.isEmpty
                                   ? "Select doctor"
                                   : controller.selectedDoctorName.value,
                               controller: TextEditingController(
                                 text: controller.selectedDoctorName.value,
                               ),
                               suffixIcon: Icons.arrow_drop_down,
                             ),
                           ),
                         );
                       }),

                       const SizedBox(height: 20),

                       // Buttons
                       Row(
                         children: [
                           Expanded(
                             child: ElevatedButton(
                               onPressed: controller.clearForm,
                               style: ElevatedButton.styleFrom(
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(12),
                                   side: BorderSide(
                                       color: Get.theme.primaryColor),
                                 ),
                                 padding: const EdgeInsets.symmetric(
                                     vertical: 12),
                               ),
                               child: const Text(
                                 "Clear",
                                 style: TextStyle(
                                     fontSize: 16, fontWeight: FontWeight.w600),
                               ),
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: ElevatedButton(
                               // onPressed: controller.saveUser,
                               onPressed: controller.isLoadingDoctorsForDropdown.value || controller.isPageLoading.value
                                   ? null
                                   : controller.saveUser,
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Get.theme.primaryColor,
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 padding: const EdgeInsets.symmetric(
                                     vertical: 12),
                               ),
                               child: Obx(
                                     () =>
                                     Text(
                                       controller.isEditMode.value
                                           ? "Update User"
                                           : "Save User",
                                       style: const TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.w700,
                                         color: Colors.white,
                                       ),
                                     ),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 );
               }
               }
             ),

      ),

    );
  }
}
