import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
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
        // Label same as CustomTextField
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          isExpanded: true,
          // value: value?.isEmpty == true ? null : value,
          value: (value != null && items.contains(value)) ? value : null,
          decoration: InputDecoration(
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: inputBorder.copyWith(
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: inputBorder.copyWith(
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          hint: Text(
            "$label",   // Example: "Select Country"
            style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
