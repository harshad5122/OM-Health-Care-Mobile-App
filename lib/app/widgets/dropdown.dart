import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool enabled; // Added 'enabled' parameter
  final String? hintText; // Added 'hintText' parameter for custom hint
  final VoidCallback? onTap;
  final Future<void> Function()? onScrollToEnd;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  this.enabled = true, // Default to true
  this.hintText, // Optional hintText
  this.onTap,
    this.onScrollToEnd,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );

    if (onScrollToEnd != null) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 50) {
          onScrollToEnd!();
        }
      });
    }


    String resolvedHint = hintText ?? "Select ${label.replaceAll('*', '').trim()}";
    final List<String> lowerCaseItems = items.map((e) => e.toLowerCase()).toList();

    // Convert the current backend value to lowercase for checking
    final String? lowerCaseValue = value?.toLowerCase();

    // Determine the actual item to display in the dropdown if a match is found (case-insensitive)
    final String? resolvedDisplayValue = (value != null && value!.isNotEmpty && lowerCaseValue != null && lowerCaseItems.contains(lowerCaseValue))
    // If a match is found, find the correctly-cased item from the original list to display.
        ? items.firstWhere((item) => item.toLowerCase() == lowerCaseValue)
        : null;


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
          // value: (value != null && items.contains(value)) ? value : null,
          value: resolvedDisplayValue,
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
            // "$label",   // Example: "Select Country"
          resolvedHint,
            style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w400),
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
          // onChanged: onChanged,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          onTap: onTap,
        ),
      ],
    );
  }
}
