import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/appointment_controller.dart';

class BookAppointmentCustomDialog extends StatelessWidget {
  final AppointmentController controller;
  final bool isEdit;

  const BookAppointmentCustomDialog({
    super.key,
    required this.controller,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    controller.isEditMode.value = isEdit;

    // return Dialog(
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Available Slots",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ),
              const SizedBox(height: 4),
              // Use a simple Wrap of Chips for available slots to keep them selectable
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableSlots.isEmpty
                    ? [const Chip(label: Text('No available slots for this day'))]
                    : controller.availableSlots.map((slot) {
                  bool isSelected = controller.startTime.value == slot.start &&
                      controller.endTime.value == slot.end &&
                      !controller.isEditMode.value; // Only selectable if not in edit mode initially
                  return ChoiceChip(
                    label: Text("${slot.start} - ${slot.end}"),
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

              // Booked Slots Display (VIEW-ONLY, NOT CLICKABLE)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Booked Slots",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.bookedSlots.isEmpty
                    ? [const Text('No booked slots for this day')]
                    : controller.bookedSlots.map((event) {
                  Color backgroundColor;
                  Color textColor = Colors.white;

                  // Determine color based on event type and status
                  if (event.type == 'booked') {
                    if (event.status == 'PENDING') {
                      backgroundColor = Colors.orange.shade400;
                    } else if (event.status == 'CONFIRMED') {
                      backgroundColor = Colors.green.shade600; // Use a darker red for booked
                    } else { // CANCELLED or other status
                      backgroundColor = Colors.grey.shade600;
                    }
                  } else if (event.type == 'leave') {
                    backgroundColor = Colors.blueGrey.shade600; // Distinct color for leave
                  } else {
                    backgroundColor = Colors.red.shade400; // Default red
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      // Display event title, which often contains time, or format specific times
                      event.title, // e.g., "15:30-16:30"
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
                      controller: TextEditingController(text: controller.startTime.value),
                      decoration: _inputDecoration(
                        "Start Time",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
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
              // End Time
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(text: controller.endTime.value),
                      decoration: _inputDecoration(
                        "End Time",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
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

              DropdownButtonFormField<String>(
                value: controller.selectedPatientId.value.isEmpty ? null : controller.selectedPatientId.value,
                items: controller.patients.map((patient) {
                  final label = "${patient.firstname ?? ''} ${patient.lastname ?? ''}";
                  return DropdownMenuItem(
                    value: patient.id ?? "",
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (id) {
                  controller.selectedPatientId.value = id ?? "";
                  final selected = controller.patients.firstWhereOrNull((p) => p.id == id);
                  controller.selectedPatientName.value =
                  (selected != null) ? "${selected.firstname ?? ''} ${selected.lastname ?? ''}" : "";
                  controller.updateSaveEnabled();
                },
                decoration: _inputDecoration("Select Patient"),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: controller.selectedVisitType.value.isEmpty ? null : controller.selectedVisitType.value,
                items: const [
                  DropdownMenuItem(value: "CLINIC", child: Text("CLINIC")),
                  DropdownMenuItem(value: "HOME", child: Text("HOME")),
                ],
                onChanged: (v) {
                  controller.selectedVisitType.value = v ?? "";
                  controller.updateSaveEnabled();
                },
                decoration: _inputDecoration("Visit Type"),
              ),
              const SizedBox(height: 12),

              // Action Buttons
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

  // Common decoration function
  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

}