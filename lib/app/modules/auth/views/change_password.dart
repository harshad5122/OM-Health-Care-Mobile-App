import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/textfield.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends StatelessWidget {
  final ChangePasswordController controller = Get.put(ChangePasswordController());

  ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          _buildContent(),
          if (controller.isLoading.value)
            const Center(child: CircularProgressIndicator()),
        ],
      );
    });
  }

  Widget _buildContent() {
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Change Password",
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your new password below",
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  /// New Password
                  CustomTextField(
                    label: 'New Password',
                    controller: controller.newPasswordController,
                    hint: "Enter new password",
                    isPassword: true,
                    isPasswordHidden: controller.isPasswordHidden,
                    validator: (val) =>
                    val!.isEmpty ? "New password is required" : null,
                  ),
                  const SizedBox(height: 15),

                  /// Retype Password
                  CustomTextField(
                    label: 'Retype New Password',
                    controller: controller.retypePasswordController,
                    hint: "Retype new password",
                    isPassword: true,
                    isPasswordHidden: controller.isRetypePasswordHidden,
                    validator: (val) {
                      if (val!.isEmpty) return "Please retype password";
                      if (val != controller.newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  /// Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: controller.changePassword,
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          color: Get.theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
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
