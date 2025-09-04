import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/phone_field.dart';
import '../../../widgets/textfield.dart';
import '../controllers/login_controller.dart';


class LoginView extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        return Stack(
          children: [
            _buildLoginContent(),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            // Scaffold(
            //   backgroundColor: Get.theme.scaffoldBackgroundColor,
            //   body: Center(
            //     child: SingleChildScrollView(
            //       child: Container(
            //         margin: const EdgeInsets.all(20),
            //         padding: const EdgeInsets.all(20),
            //         decoration: BoxDecoration(
            //           color: Get.theme.cardColor,
            //           borderRadius: BorderRadius.circular(12),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black.withOpacity(0.05),
            //               blurRadius: 10,
            //               spreadRadius: 2,
            //             )
            //           ],
            //         ),
            //         child: Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Text(
            //               "Access Your Account",
            //               style: Get.textTheme.titleLarge?.copyWith(
            //                 color: Get.theme.primaryColor,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             const SizedBox(height: 8),
            //             Text(
            //               "Please select your preferred login method.",
            //               style: Get.textTheme.bodyMedium?.copyWith(
            //                 color: Get.theme.hintColor,
            //               ),
            //               textAlign: TextAlign.center,
            //             ),
            //             const SizedBox(height: 20),
            //
            //             Obx(() => Container(
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               child: ToggleButtons(
            //                 isSelected: [
            //                   controller.isPhoneLogin.value,
            //                   !controller.isPhoneLogin.value,
            //                 ],
            //                 borderRadius: BorderRadius.circular(10),
            //                 renderBorder: false, // remove extra borders
            //                 fillColor: Get.theme.primaryColor, // selected button background
            //                 selectedColor: Colors.white, // selected text color
            //                 color: Colors.black, // unselected text color
            //                 constraints: const BoxConstraints(minHeight: 45, minWidth: 120),
            //                 onPressed: (index) {
            //                   controller.toggleLoginMethod(index == 0);
            //                 },
            //                 children: [
            //                   Container(
            //                     decoration: BoxDecoration(
            //                       color: controller.isPhoneLogin.value
            //                           ? Get.theme.primaryColor
            //                           : Get.theme.colorScheme.onPrimaryContainer,
            //                       // borderRadius: BorderRadius.circular(10),
            //                     ),
            //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //                     alignment: Alignment.center,
            //                     child: Text(
            //                       "Login with Phone",
            //                       style: TextStyle(
            //                         color: controller.isPhoneLogin.value ? Colors.white : Colors.black,
            //                       ),
            //                     ),
            //                   ),
            //                   Container(
            //                     decoration: BoxDecoration(
            //                       color: !controller.isPhoneLogin.value
            //                           ? Get.theme.primaryColor
            //                           : Get.theme.colorScheme.onPrimaryContainer,
            //                       // borderRadius: BorderRadius.circular(10),
            //                     ),
            //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //                     alignment: Alignment.center,
            //                     child: Text(
            //                       "Login with Email",
            //                       style: TextStyle(
            //                         color: !controller.isPhoneLogin.value ? Colors.white : Colors.black,
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             )),
            //
            //             const SizedBox(height: 20),
            //
            //             // Phone Login Flow
            //             Obx(() {
            //               if (controller.isPhoneLogin.value) {
            //                 return controller.isOtpSent.value
            //                     ? _otpForm()
            //                     : _phoneForm();
            //               } else {
            //                 return _emailForm();
            //               }
            //             }),
            //
            //             const SizedBox(height: 20),
            //
            //             // Footer
            //             Obx(() => controller.isPhoneLogin.value
            //                 ? const SizedBox()
            //                 : TextButton(
            //               onPressed: () => Get.toNamed("/forgot-password"),
            //               child: const Text("Forgot Password?"),
            //             )),
            //             const SizedBox(height: 10),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 const Text("Don’t have an account? "),
            //                 GestureDetector(
            //                   onTap: () => Get.toNamed("/signup"),
            //                   child: Text(
            //                     "Register Now",
            //                     style: TextStyle(
            //                       color: Get.theme.primaryColor,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                   ),
            //                 )
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        );
      }
    );
  }

  Widget _buildLoginContent() {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Access Your Account",
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please select your preferred login method.",
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Obx(() => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ToggleButtons(
                    isSelected: [
                      controller.isPhoneLogin.value,
                      !controller.isPhoneLogin.value,
                    ],
                    borderRadius: BorderRadius.circular(10),
                    renderBorder: false, // remove extra borders
                    fillColor: Get.theme.primaryColor, // selected button background
                    selectedColor: Colors.white, // selected text color
                    color: Colors.black, // unselected text color
                    constraints: const BoxConstraints(minHeight: 45, minWidth: 120),
                    onPressed: (index) {
                      controller.toggleLoginMethod(index == 0);
                    },
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: controller.isPhoneLogin.value
                              ? Get.theme.primaryColor
                              : Get.theme.colorScheme.onPrimaryContainer,
                          // borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          "Login with Phone",
                          style: TextStyle(
                            color: controller.isPhoneLogin.value ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: !controller.isPhoneLogin.value
                              ? Get.theme.primaryColor
                              : Get.theme.colorScheme.onPrimaryContainer,
                          // borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          "Login with Email",
                          style: TextStyle(
                            color: !controller.isPhoneLogin.value ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 20),

                // Phone Login Flow
                Obx(() {
                  if (controller.isPhoneLogin.value) {
                    return controller.isOtpSent.value
                        ? _otpForm()
                        : _phoneForm();
                  } else {
                    return _emailForm();
                  }
                }),

                const SizedBox(height: 20),

                // Footer
                Obx(() => controller.isPhoneLogin.value
                    ? const SizedBox()
                    : TextButton(
                  onPressed: () => Get.toNamed("/forgot-password"),
                  child: const Text("Forgot Password?"),
                )),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () => Get.toNamed("/signup"),
                      child: Text(
                        "Register Now",
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
    );
  }

  // Phone Form
  Widget _phoneForm() {
    return Form(
      key: controller.phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          PhoneField(
            label: 'Mobile Number',
            countryCode: controller.countryCode,
            phoneController: controller.phoneController,
            validator: (val) => val!.isEmpty ? "Mobile number is required" : null,
          ),

          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: controller.sendOtp,
              child: Text("Send OTP", style: TextStyle(color: Get.theme.colorScheme.onPrimary),),
            ),
          ),
        ],
      ),
    );
  }

  // OTP Form
  Widget _otpForm() {
    return Form(
      key: controller.otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Enter OTP',
            controller: controller.otpController,
            hint: "Enter 6-digit OTP",
            keyboardType: TextInputType.number,
            validator: (val) =>
            val!.length != 6 ? "Enter valid 6-digit OTP" : null,
          ),
          // const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.sendOtp,
              child: const Text("Resend OTP"),
            ),
          ),
          // const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
              ),
              onPressed: controller.verifyOtp,
              child: Text("Verify & Login", style: TextStyle(color: Get.theme.colorScheme.onPrimary),),
            ),
          ),
        ],
      ),
    );
  }

  // Email Form
  Widget _emailForm() {
    return Form(
      key: controller.emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text("Email Address"),
          const SizedBox(height: 5),
          CustomTextField(
            label: 'Email Address',
            controller: controller.emailController,
            hint: "Enter your email",
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
            val!.isEmpty ? "Email is required" : null,
          ),
          const SizedBox(height: 15),

          CustomTextField(
            label: 'Password',
            controller: controller.passwordController,
            hint: "Enter your password",
            isPassword: true,
            validator: (val) =>
            val!.isEmpty ? "Password is required" : null,
            isPasswordHidden: RxBool(false),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: controller.loginWithEmail,
              child: Text("Login", style: TextStyle(color: Get.theme.colorScheme.onPrimary),),
            ),
          ),
        ],
      ),
    );
  }
}
