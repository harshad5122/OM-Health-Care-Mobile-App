import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneField extends StatelessWidget {
  final String label;
  final RxString countryCode;
  final TextEditingController phoneController;
  final String? Function(String?)? validator;

  const PhoneField({
    super.key,
    required this.label,
    required this.countryCode,
    required this.phoneController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );

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
        Row(
          children: [
            // Country Code Dropdown
            Obx(() => Container(
              height: 48, // match CustomTextField height
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: countryCode.value,
                  style: const TextStyle(
                    color: Colors.black, // dropdown text color
                    fontSize: 14,
                  ),
                  items: ["+91", "+1", "+44", "+61"].map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(code),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) countryCode.value = val;
                  },
                ),
              ),
            )),

            const SizedBox(width: 10),

            // Phone Number TextField
            Expanded(
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: validator,
                decoration: InputDecoration(
                  hintText: "Enter mobile number",
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
