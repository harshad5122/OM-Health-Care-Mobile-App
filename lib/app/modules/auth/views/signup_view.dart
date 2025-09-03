import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/dropdown.dart';
import '../../../widgets/phone_field.dart';
import '../../../widgets/textfield.dart';
import '../controllers/signup_controller.dart';


class SignupView extends StatelessWidget {
  final SignupController controller = Get.put(SignupController());

  SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Create Your Account",
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: Get.theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    "Please fill in your details to get started",
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // First Name
                  CustomTextField(
                    label: "First Name",
                    hint: "Enter your first name",
                    controller: controller.firstNameController,
                    validator: (val) =>
                    val!.isEmpty ? "First Name is required" : null,
                  ),
                  const SizedBox(height: 15),

                  // Last Name
                  CustomTextField(
                    label: "Last Name",
                    hint: "Enter your last name",
                    controller: controller.lastNameController,
                    validator: (val) =>
                    val!.isEmpty ? "Last Name is required" : null,
                  ),
                  const SizedBox(height: 15),

                  // Phone Field
                  PhoneField(
                    label: "Mobile Number",
                    countryCode: controller.countryCode,
                    phoneController: controller.phoneController,
                    validator: (val) =>
                    val!.isEmpty ? "Mobile number is required" : null,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  CustomTextField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                    val!.isEmpty ? "Email is required" : null,
                  ),
                  const SizedBox(height: 15),

                  // Password
                  CustomTextField(
                    label: "Password",
                    hint: "Enter your password",
                    controller: controller.passwordController,
                    isPassword: true,
                    validator: (val) =>
                    val!.isEmpty ? "Password is required" : null,
                    isPasswordHidden: controller.isPasswordHidden,
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  CustomTextField(
                    label: "Confirm Password",
                    hint: "Re-enter your password",
                    controller: controller.confirmPasswordController,
                    isPassword: true,
                    validator: (val) =>
                    val!.isEmpty ? "Confirm Password is required" : null,
                    isPasswordHidden: controller.isConfirmPasswordHidden,
                  ),
                  const SizedBox(height: 15),

                  // Address
                  CustomTextField(
                    label: "Address",
                    hint: "Enter your address",
                    controller: controller.addressController,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => CustomDropdown(
                          label: "Country",
                          value: controller.selectedCountry.value,
                          items: controller.countries,
                          onChanged: (val) {
                            controller.selectedCountry.value = val ?? "";
                            controller.selectedState.value = "";
                            controller.selectedCity.value = "";
                          },
                          validator: (val) =>
                          val == null || val.isEmpty ? "Country is required" : null,
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => CustomDropdown(
                          label: "State",
                          value: controller.selectedState.value,
                          items: controller.states[controller.selectedCountry.value] ?? [],
                          onChanged: (val) {
                            controller.selectedState.value = val ?? "";
                            controller.selectedCity.value = "";
                          },
                          validator: (val) =>
                          val == null || val.isEmpty ? "State is required" : null,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Row 2: City + Gender
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => CustomDropdown(
                          label: "City",
                          value: controller.selectedCity.value,
                          items: controller.cities[controller.selectedState.value] ?? [],
                          onChanged: (val) {
                            controller.selectedCity.value = val ?? "";
                          },
                          validator: (val) =>
                          val == null || val.isEmpty ? "City is required" : null,
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => CustomDropdown(
                          label: "Gender",
                          value: controller.selectedGender.value,
                          items: controller.genders,
                          onChanged: (val) {
                            controller.selectedGender.value = val ?? "";
                          },
                          validator: (val) =>
                          val == null || val.isEmpty ? "Gender is required" : null,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: controller.register,
                      child: Text(
                        "Register Account",
                        style: TextStyle(color: Get.theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Get.toNamed("/login"),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Get.theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
