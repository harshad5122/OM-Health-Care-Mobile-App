import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/appointment_controller.dart';

// Assuming AppointmentController, Patient, etc., are defined elsewhere.
// import 'path/to/your/controller.dart';

class BookAppointmentCustomDialog extends StatelessWidget {
  final AppointmentController controller;
  final bool isEdit;

  const BookAppointmentCustomDialog({
    super.key,
    required this.controller,
    this.isEdit = false,
  });

  // Helper function to format 24-hour time string to 12-hour AM/PM string
  String _formatTimeTo12Hour(String time24) {
    if (time24.isEmpty) return '';
    try {
      final DateTime time = DateFormat('HH:mm').parse(time24);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return time24; // Return original string if format is incorrect
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.isEditMode.value = isEdit;

    final patientItems = controller.patients
        .map((patient) {
      final label = patient.fullName ?? 'Unknown Patient';
      return DropdownMenuItem(
        value: patient.id,
        child: Text(label),
      );
    })
        .toSet()
        .toList();

    final String? currentValue = controller.selectedPatientId.value;
    final bool isCurrentValueInList = currentValue == null || currentValue.isEmpty
        ? false
        : patientItems.any((item) => item.value == currentValue);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final bool isPastDateSelected = controller.isPastSelectedDate.value;
        final bool shouldDisableInteractions = isPastDateSelected && isEdit;
        final bool isDoctorOnLeave =
        controller.isDoctorOnLeaveForSelectedDate();

        final bool isEditingLeaveEvent = isEdit && controller.selectedPatientId.value.isEmpty;
        final bool showLeaveMessage = (isEdit && isDoctorOnLeave) && isEditingLeaveEvent;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.isEditMode.value ? "Edit Appointment" : "Book Appointment",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text("Selected Date: ${DateFormat('dd MMMM, yyyy').format(controller.selectedDate.value)}"),
              const SizedBox(height: 8),

              // Available Slots Display
              if (!isPastDateSelected || !isEdit)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Available Slots",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ),
              if (!isPastDateSelected || !isEdit)
                const SizedBox(height: 4),
              if (!isPastDateSelected || !isEdit )
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.availableSlots.isEmpty
                      ? [const Chip(label: Text('No available slots for this day'))]
                      : controller.availableSlots.map((slot) {
                    bool isSelected = controller.startTime.value == slot.start &&
                        controller.endTime.value == slot.end &&
                        !controller.isEditMode.value;
                    return ChoiceChip(
                      // MODIFIED: Format the time for display
                      label: Text("${_formatTimeTo12Hour(slot.start!)} - ${_formatTimeTo12Hour(slot.end!)}"),
                      selected: isSelected,
                      selectedColor: Colors.green.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectTimeSlot(slot);
                        } else {
                          controller.clearAppointmentSelection();
                        }
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),

              if (!showLeaveMessage || !isEdit)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Booked Slots",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
                  ),
                ),
              if (!showLeaveMessage || !isEdit)
                const SizedBox(height: 4),
              if (!showLeaveMessage || !isEdit)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.bookedSlots.isEmpty
                      ? [const Text('No booked slots for this day')]
                      : controller.bookedSlots.map((event) {
                    Color backgroundColor;
                    Color textColor = Colors.white;

                    if (event.type == 'booked') {
                      if (event.status == 'PENDING') {
                        backgroundColor = Colors.orange.shade400;
                      } else if (event.status == 'CONFIRMED') {
                        backgroundColor = Colors.green.shade600;
                      } else {
                        backgroundColor = Colors.grey.shade600;
                      }
                    } else if (event.type == 'leave') {
                      backgroundColor = Colors.blueGrey.shade600;
                    } else {
                      backgroundColor = Colors.red.shade400;
                    }

                    // MODIFIED: Format the booked slot time string
                    String formattedTitle = event.title;
                    if (event.title.contains('-')) {
                      final parts = event.title.split('-');
                      if (parts.length == 2) {
                        formattedTitle = '${_formatTimeTo12Hour(parts[0])} - ${_formatTimeTo12Hour(parts[1])}';
                      }
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        formattedTitle,
                        style: TextStyle(color: textColor, fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Start Time and End Time fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      // MODIFIED: Format the time for display
                      controller: TextEditingController(text: _formatTimeTo12Hour(controller.startTime.value)),
                      enabled: !shouldDisableInteractions,
                      style: const TextStyle(color: Colors.black),
                      decoration: _inputDecoration(
                        "Start Time",
                        labelStyle: shouldDisableInteractions
                            ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)
                            : const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          color: shouldDisableInteractions ? Colors.black : Get.theme.iconTheme.color,
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                controller.startTime.value.isNotEmpty
                                    ? DateFormat('HH:mm').parse(controller.startTime.value)
                                    : DateTime.now(),
                              ),
                            );
                            if (picked != null) {
                              final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              controller.startTime.value = formatted;
                              controller.updateSaveEnabled();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      // MODIFIED: Format the time for display
                      controller: TextEditingController(text: _formatTimeTo12Hour(controller.endTime.value)),
                      enabled: !shouldDisableInteractions,
                      style: const TextStyle(color: Colors.black),
                      decoration: _inputDecoration(
                        "End Time",
                        labelStyle: shouldDisableInteractions
                            ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)
                            : const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          color: shouldDisableInteractions ? Colors.black : Get.theme.iconTheme.color,
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                controller.endTime.value.isNotEmpty
                                    ? DateFormat('HH:mm').parse(controller.endTime.value)
                                    : DateTime.now(),
                              ),
                            );
                            if (picked != null) {
                              final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              controller.endTime.value = formatted;
                              controller.updateSaveEnabled();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (!showLeaveMessage)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: isCurrentValueInList ? currentValue : null,
                      items: patientItems,
                      onChanged: shouldDisableInteractions
                          ? null
                          : (id) {
                        controller.selectedPatientId.value = id ?? "";
                        final selected = controller.patients.firstWhereOrNull((p) => p.id == id);
                        controller.selectedPatientName.value = (selected != null) ? (selected.fullName ?? '') : "";
                        controller.updateSaveEnabled();
                      },
                      style: const TextStyle(color: Colors.black),
                      iconEnabledColor: Colors.black,
                      iconDisabledColor: Colors.black,
                      decoration: _inputDecoration("Select Patient",
                          labelStyle: shouldDisableInteractions
                              ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)
                              : const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: controller.selectedVisitType.value.isEmpty ? null : controller.selectedVisitType.value,
                      items: const [
                        DropdownMenuItem(value: "CLINIC", child: Text("CLINIC", style: TextStyle(color: Colors.black))),
                        DropdownMenuItem(value: "HOME", child: Text("HOME", style: TextStyle(color: Colors.black))),
                      ],
                      onChanged: shouldDisableInteractions
                          ? null
                          :  (v) {
                        controller.selectedVisitType.value = v ?? "";
                        controller.updateSaveEnabled();
                      },
                      style: const TextStyle(color: Colors.black),
                      iconEnabledColor: Colors.black,
                      iconDisabledColor: Colors.black,
                      decoration: _inputDecoration("Visit Type",
                          labelStyle: shouldDisableInteractions
                              ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)
                              : const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "The doctor will not be available on",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Selected Date: ${DateFormat('dd MMMM, yyyy').format(controller.selectedDate.value)}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      Text(
                        // MODIFIED: Format the leave time for display
                        "from: ${_formatTimeTo12Hour(controller.leaveStartTime.value)} - to: ${_formatTimeTo12Hour(controller.leaveEndTime.value)}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              if (!shouldDisableInteractions && !showLeaveMessage)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.clearAppointmentSelection();
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.saveEnabled.value
                          ? () => controller.handleSaveAppointment()
                          : null,
                      child: Text(controller.isEditMode.value ? "Update" : "Save"),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon,  TextStyle? labelStyle}) {
    return InputDecoration(
      labelText: label,
      labelStyle: labelStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      suffixIcon: suffixIcon,
    );
  }
}