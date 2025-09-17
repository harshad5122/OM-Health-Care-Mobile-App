// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../controller/appointment_controller.dart';
// //
// // class BookAppointmentCustomDialog extends StatelessWidget {
// //   final AppointmentController controller;
// //   final bool showMultiple;
// //   const BookAppointmentCustomDialog({Key? key, required this.controller, this.showMultiple = false}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Dialog(
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         child: Obx(() {
// //           return Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text("Book Appointment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
// //               SizedBox(height: 12),
// //               Text("Selected Date: ${controller.selectedDate.value.toLocal().toString().substring(0, 10)}"),
// //               SizedBox(height: 8),
// //               Align(
// //                 alignment: Alignment.centerLeft,
// //                 child: Text("Available Slots"),
// //               ),
// //               // Replace below with dynamic slot widgets
// //               Wrap(
// //                 spacing: 8,
// //                 children: controller.availableSlots.isEmpty
// //                     ? [Chip(label: Text('08:00 - 20:00'))]
// //                     : controller.availableSlots.map((slot) => Chip(label: Text(slot))).toList(),
// //               ),
// //               SizedBox(height: 8),
// //               Align(
// //                 alignment: Alignment.centerLeft,
// //                 child: Text("Booked Slots"),
// //               ),
// //               Wrap(
// //                 spacing: 8,
// //                 children: controller.bookedSlots.isEmpty
// //                     ? [Text('No booked slots')]
// //                     : controller.bookedSlots.map((slot) => Chip(label: Text(slot))).toList(),
// //               ),
// //               SizedBox(height: 16),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: TextField(
// //                       readOnly: true,
// //                       decoration: InputDecoration(
// //                         labelText: "Start Time",
// //                         suffixIcon: IconButton(
// //                           icon: Icon(Icons.access_time),
// //                           onPressed: () async {
// //                             TimeOfDay? picked = await showTimePicker(
// //                                 context: context, initialTime: TimeOfDay.now()
// //                             );
// //                             if (picked != null) {
// //                               controller.startTime.value = picked.format(context);
// //                               controller.updateSaveEnabled();
// //                             }
// //                           },
// //                         ),
// //                       ),
// //                       controller: TextEditingController(text: controller.startTime.value),
// //                     ),
// //                   ),
// //                   SizedBox(width: 8),
// //                   Expanded(
// //                     child: TextField(
// //                       readOnly: true,
// //                       decoration: InputDecoration(
// //                         labelText: "End Time",
// //                         suffixIcon: IconButton(
// //                           icon: Icon(Icons.access_time),
// //                           onPressed: () async {
// //                             TimeOfDay? picked = await showTimePicker(
// //                                 context: context, initialTime: TimeOfDay.now()
// //                             );
// //                             if (picked != null) {
// //                               controller.endTime.value = picked.format(context);
// //                               controller.updateSaveEnabled();
// //                             }
// //                           },
// //                         ),
// //                       ),
// //                       controller: TextEditingController(text: controller.endTime.value),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 8),
// //               DropdownButtonFormField<String>(
// //                 value: controller.selectedPatientId.value.isEmpty ? null : controller.selectedPatientId.value,
// //                 items: controller.patients.map((patient) {
// //                   final label = "${patient.firstname ?? ''} ${patient.lastname ?? ''}";
// //                   return DropdownMenuItem(
// //                     child: Text(label),
// //                     value: patient.id ?? "",
// //                   );
// //                 }).toList(),
// //                 onChanged: (id) {
// //                   controller.selectedPatientId.value = id ?? "";
// //                   // Find and store patient name
// //                   final selected = controller.patients.firstWhereOrNull((p) => p.id == id);
// //                   controller.selectedPatientName.value =
// //                   (selected != null) ? "${selected.firstname ?? ''} ${selected.lastname ?? ''}" : "";
// //                   controller.updateSaveEnabled();
// //                 },
// //                 decoration: InputDecoration(labelText: "Select Patient"),
// //               ),
// //               SizedBox(height: 8),
// //               DropdownButtonFormField<String>(
// //                 value: controller.selectedVisitType.value.isEmpty ? null : controller.selectedVisitType.value,
// //                 items: [
// //                   DropdownMenuItem(child: Text("CLINIC"), value: "CLINIC"),
// //                   DropdownMenuItem(child: Text("HOME"), value: "HOME"),
// //                 ],
// //                 onChanged: (v) {
// //                   controller.selectedVisitType.value = v ?? "";
// //                   controller.updateSaveEnabled();
// //                 },
// //                 decoration: InputDecoration(labelText: "Visit Type"),
// //               ),
// //               SizedBox(height: 12),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.end,
// //                 children: [
// //                   TextButton(
// //                     child: Text('Cancel'),
// //                     onPressed: () => Get.back(),
// //                   ),
// //                   SizedBox(width: 8),
// //                   ElevatedButton(
// //                     onPressed: controller.saveEnabled.value
// //                         ? () => controller.bookAppointment()
// //                         : null,
// //                     child: Text("Save"),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           );
// //         }),
// //       ),
// //     );
// //   }
// // }
//
//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart'; // For date formatting
//
// import '../controller/appointment_controller.dart';
// import '../../../data/models/appointment_model.dart'; // Import TimeSlot and Event
//
// class BookAppointmentCustomDialog extends StatelessWidget {
//   final AppointmentController controller;
//   final bool isEdit; // Flag to indicate if it's for editing an existing appointment
//
//   const BookAppointmentCustomDialog({
//     super.key,
//     required this.controller,
//     this.isEdit = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Set edit mode in controller based on dialog's isEdit flag
//     controller.isEditMode.value = isEdit;
//
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Obx(() {
//           return SingleChildScrollView( // Added to prevent overflow on small screens
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   controller.isEditMode.value ? "Edit Appointment" : "Book Appointment",
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                 ),
//                 const SizedBox(height: 12),
//                 Text("Selected Date: ${DateFormat('dd MMMM, yyyy').format(controller.selectedDate.value)}"),
//                 const SizedBox(height: 8),
//
//                 // Available Slots
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Available Slots",
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: controller.availableSlots.isEmpty
//                       ? [const Chip(label: Text('No available slots for this day'))]
//                       : controller.availableSlots.map((slot) {
//                     bool isSelected = controller.startTime.value == slot.start &&
//                         controller.endTime.value == slot.end &&
//                         !controller.isEditMode.value; // Only highlight if not in edit mode
//                     return ChoiceChip(
//                       label: Text("${slot.start} - ${slot.end}"),
//                       selected: isSelected,
//                       selectedColor: Colors.green.shade100,
//                       onSelected: (selected) {
//                         if (selected) {
//                           controller.selectTimeSlot(slot);
//                         } else {
//                           controller.clearAppointmentSelection();
//                         }
//                       },
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Booked Slots (from Events API response)
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Booked Slots",
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: controller.bookedSlots.isEmpty
//                       ? [const Text('No booked slots for this day')]
//                       : controller.bookedSlots.map((event) {
//                     bool isSelected = controller.selectedAppointmentId.value == event.id;
//                     return ChoiceChip(
//                       label: Text(event.title),
//                       selected: isSelected,
//                       selectedColor: Colors.red.shade100,
//                       onSelected: (selected) {
//                         if (selected) {
//                           // Find the corresponding CalendarAppointment to fill details
//                           final calAppt = controller.allDayAppointments.firstWhereOrNull(
//                                 (appt) => appt.appointmentId == event.id,
//                           );
//                           if (calAppt != null) {
//                             controller.selectExistingAppointment(calAppt);
//                           }
//                         } else {
//                           controller.clearAppointmentSelection();
//                         }
//                       },
//                       avatar: CircleAvatar(
//                         backgroundColor: Colors.redAccent,
//                         child: Text(event.status[0]), // First letter of status
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Start Time and End Time fields
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         readOnly: true,
//                         controller: TextEditingController(text: controller.startTime.value),
//                         decoration: InputDecoration(
//                           labelText: "Start Time",
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.access_time),
//                             onPressed: () async {
//                               TimeOfDay? picked = await showTimePicker(
//                                 context: context,
//                                 initialTime: TimeOfDay.fromDateTime(
//                                   controller.startTime.value.isNotEmpty
//                                       ? DateFormat('HH:mm').parse(controller.startTime.value)
//                                       : DateTime.now(),
//                                 ),
//                               );
//                               if (picked != null) {
//                                 controller.startTime.value = picked.format(context);
//                                 controller.updateSaveEnabled();
//                               }
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         readOnly: true,
//                         controller: TextEditingController(text: controller.endTime.value),
//                         decoration: InputDecoration(
//                           labelText: "End Time",
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.access_time),
//                             onPressed: () async {
//                               TimeOfDay? picked = await showTimePicker(
//                                 context: context,
//                                 initialTime: TimeOfDay.fromDateTime(
//                                   controller.endTime.value.isNotEmpty
//                                       ? DateFormat('HH:mm').parse(controller.endTime.value)
//                                       : DateTime.now(),
//                                 ),
//                               );
//                               if (picked != null) {
//                                 controller.endTime.value = picked.format(context);
//                                 controller.updateSaveEnabled();
//                               }
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//
//                 // Select Patient Dropdown
//                 DropdownButtonFormField<String>(
//                   value: controller.selectedPatientId.value.isEmpty ? null : controller.selectedPatientId.value,
//                   items: controller.patients.map((patient) {
//                     final label = "${patient.firstname ?? ''} ${patient.lastname ?? ''}";
//                     return DropdownMenuItem(
//                       value: patient.id ?? "",
//                       child: Text(label),
//                     );
//                   }).toList(),
//                   onChanged: (id) {
//                     controller.selectedPatientId.value = id ?? "";
//                     final selected = controller.patients.firstWhereOrNull((p) => p.id == id);
//                     controller.selectedPatientName.value =
//                     (selected != null) ? "${selected.firstname ?? ''} ${selected.lastname ?? ''}" : "";
//                     controller.updateSaveEnabled();
//                   },
//                   decoration: const InputDecoration(labelText: "Select Patient"),
//                 ),
//                 const SizedBox(height: 8),
//
//                 // Visit Type Dropdown
//                 DropdownButtonFormField<String>(
//                   value: controller.selectedVisitType.value.isEmpty ? null : controller.selectedVisitType.value,
//                   items: const [
//                     DropdownMenuItem(value: "CLINIC", child: Text("CLINIC")),
//                     DropdownMenuItem(value: "HOME", child: Text("HOME")),
//                   ],
//                   onChanged: (v) {
//                     controller.selectedVisitType.value = v ?? "";
//                     controller.updateSaveEnabled();
//                   },
//                   decoration: const InputDecoration(labelText: "Visit Type"),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Action Buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         controller.clearAppointmentSelection(); // Clear selected values on cancel
//                         Get.back();
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     const SizedBox(width: 8),
//                     if (controller.isEditMode.value) ...[
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                         onPressed: () {},
//                         // controller.selectedAppointmentId.value != null
//                         //     ? () => controller.deleteAppointment()
//                         //     : null,
//                         child: const Text("Delete", style: TextStyle(color: Colors.white)),
//                       ),
//                       const SizedBox(width: 8),
//                     ],
//                     ElevatedButton(
//                       onPressed: controller.saveEnabled.value
//                           ? () => controller.handleSaveAppointment()
//                           : null,
//                       child: Text(controller.isEditMode.value ? "Update" : "Save"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../controller/appointment_controller.dart';
import '../../../data/models/appointment_model.dart'; // Import TimeSlot and Event

class BookAppointmentCustomDialog extends StatelessWidget {
  final AppointmentController controller;
  final bool isEdit; // Flag to indicate if it's for editing an existing appointment

  const BookAppointmentCustomDialog({
    super.key,
    required this.controller,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    // Set edit mode in controller based on dialog's isEdit flag
    controller.isEditMode.value = isEdit;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
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

                // Available Slots
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Available Slots",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ),
                const SizedBox(height: 4),
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

                // Booked Slots (from Events API response)
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
                    bool isSelected = controller.selectedAppointmentId.value == event.id;
                    return ChoiceChip(
                      label: Text(event.title),
                      selected: isSelected,
                      selectedColor: Colors.red.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          final calAppt = controller.allDayAppointments.firstWhereOrNull(
                                (appt) => appt.appointmentId == event.id,
                          );
                          if (calAppt != null) {
                            controller.selectExistingAppointment(calAppt);
                          }
                        } else {
                          controller.clearAppointmentSelection();
                        }
                      },
                      avatar: CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Text(event.status[0]),
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
                        decoration: InputDecoration(
                          labelText: "Start Time",
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
                                // Format to 24-hour string (HH:mm)
                                final String formattedTime =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                controller.startTime.value = formattedTime;
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
                        controller: TextEditingController(text: controller.endTime.value),
                        decoration: InputDecoration(
                          labelText: "End Time",
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
                                // Format to 24-hour string (HH:mm)
                                final String formattedTime =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                controller.endTime.value = formattedTime;
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

                // Select Patient Dropdown
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
                  decoration: const InputDecoration(labelText: "Select Patient"),
                ),
                const SizedBox(height: 8),

                // Visit Type Dropdown
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
                  decoration: const InputDecoration(labelText: "Visit Type"),
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
                    // if (controller.isEditMode.value) ...[
                    //   ElevatedButton(
                    //     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    //     onPressed: () {
                    //
                    //     },
                    //     // controller.selectedAppointmentId.value != null
                    //     //     ? () => controller.deleteAppointment()
                    //     //     : null,
                    //     child: const Text("Delete", style: TextStyle(color: Colors.white)),
                    //   ),
                    //   const SizedBox(width: 8),
                    // ],
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
      ),
    );
  }
}