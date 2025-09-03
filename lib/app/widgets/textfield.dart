import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final RxBool? isPasswordHidden;
  final Widget? prefixWidget;


  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.isPasswordHidden,
    this.prefixWidget,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );

    Widget textField({bool obscure = false, VoidCallback? onToggle}) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          prefix: prefixWidget,
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
          ),
          errorBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscure ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: onToggle,
          )
              : null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),

        //  Use Obx only when isPasswordHidden is not null
        if (isPassword && isPasswordHidden != null)
          Obx(() => textField(
            obscure: isPasswordHidden!.value,
            onToggle: () {
              isPasswordHidden!.value = !isPasswordHidden!.value;
            },
          ))
        else
          textField(obscure: isPassword), // normal non-reactive field
      ],
    );
  }
}
