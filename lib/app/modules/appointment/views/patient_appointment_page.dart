//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../../global/global.dart';
// import '../controller/appointment_controller.dart';
// import '../../../data/models/appointment_model.dart';
// import '../../../data/models/user_list_model.dart'; // Import UserListModel
//
// class PatientAppointmentsPage extends StatelessWidget {
//   final AppointmentController controller = Get.put(AppointmentController());
//
//   PatientAppointmentsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Patient Appointments'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => controller.fetchPatientAppointments(),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               _buildSearchBar(),
//               const SizedBox(height: 10),
//               _buildFilterButtons(context),
//               const SizedBox(height: 10),
//               _buildSelectedDateRangeDisplay(),
//               Expanded(
//                 child: Obx(() {
//                   if (controller.isLoading.value && controller.appointments.isEmpty) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (controller.appointments.isEmpty) {
//                     return RefreshIndicator(
//                       onRefresh: () async => controller.fetchPatientAppointments(),
//                       child: ListView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         children: const [
//                           SizedBox(height: 120),
//                           Center(child: Text('No appointments found.')),
//                         ],
//                       ),
//                     );
//                   }
//
//                   return RefreshIndicator(
//                     onRefresh: () async => controller.fetchPatientAppointments(),
//                     child: ListView.builder(
//                       itemCount: controller.appointments.length,
//                       itemBuilder: (context, index) {
//                         final appointment = controller.appointments[index];
//                         return _buildAppointmentCard(context, appointment);
//                       },
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return TextField(
//       controller: controller.searchController,
//       textInputAction: TextInputAction.search,
//       onSubmitted: (query) => controller.applySearch(query),
//       decoration: InputDecoration(
//         hintText: 'Search by patient or staff name',
//         isDense: true,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.search, color: Colors.blueGrey),
//           onPressed: () => controller.applySearch(controller.searchController.text),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       ),
//     );
//   }
//
//   Widget _buildFilterButtons(BuildContext context) {
//     return Obx(
//           () => PopupMenuButton<AppointmentFilterDateRange>(
//         onSelected: (value) {
//           if (value == AppointmentFilterDateRange.custom) {
//             controller.showCustomDateRangePicker(context);
//           } else {
//             controller.setDateRangeFilter(value);
//           }
//         },
//         itemBuilder: (context) => [
//           const PopupMenuItem(value: AppointmentFilterDateRange.all, child: Text('All Dates')),
//           const PopupMenuItem(value: AppointmentFilterDateRange.thisMonth, child: Text('This Month')),
//           const PopupMenuItem(value: AppointmentFilterDateRange.lastMonth, child: Text('Last Month')),
//           const PopupMenuItem(value: AppointmentFilterDateRange.thisWeek, child: Text('This Week')),
//           const PopupMenuItem(value: AppointmentFilterDateRange.custom, child: Text('Custom Date Range')),
//         ],
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//             color: Colors.white,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.calendar_today, color: Colors.blueGrey),
//               const SizedBox(width: 8),
//               Text(
//                 _getDateRangeDisplayText(),
//                 style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
//               ),
//               const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getDateRangeDisplayText() {
//     switch (controller.currentFilterDateRange.value) {
//       case AppointmentFilterDateRange.all:
//         return 'Filter by Date';
//       case AppointmentFilterDateRange.thisMonth:
//         return 'This Month';
//       case AppointmentFilterDateRange.lastMonth:
//         return 'Last Month';
//       case AppointmentFilterDateRange.thisWeek:
//         return 'This Week';
//       case AppointmentFilterDateRange.custom:
//         if (controller.filterFromDate.value != null && controller.filterToDate.value != null) {
//           return '${controller.displayDateFormat.format(controller.filterFromDate.value!)} - ${controller.displayDateFormat.format(controller.filterToDate.value!)}';
//         }
//         return 'Custom Date Range';
//     }
//   }
//
//   Widget _buildSelectedDateRangeDisplay() {
//     return Obx(() {
//       final hasDateFilter = controller.currentFilterDateRange.value != AppointmentFilterDateRange.all &&
//           (controller.filterFromDate.value != null || controller.filterToDate.value != null);
//       if (hasDateFilter || controller.currentSearchQuery.value.isNotEmpty || controller.currentFilterStatus.value.isNotEmpty) {
//         return Padding(
//           padding: const EdgeInsets.only(top: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Flexible(
//                 child: Text(
//                   'Filters: ${controller.currentSearchQuery.value.isNotEmpty ? 'Search: "${controller.currentSearchQuery.value}" | ' : ''}'
//                       '${controller.currentFilterStatus.value.isNotEmpty ? 'Status: ${controller.currentFilterStatus.value} | ' : ''}'
//                       '${hasDateFilter ? 'Date: ${_getDateRangeDisplayText()}' : ''}',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 2,
//                 ),
//               ),
//               TextButton(
//                 onPressed: controller.clearFilters,
//                 child: const Text('Clear All'),
//               )
//             ],
//           ),
//         );
//       }
//       return const SizedBox.shrink();
//     });
//   }
//
//
//   Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment) {
//     // Attempt to find the patient and staff details from the loaded lists
//     final patient = controller.patients.firstWhereOrNull((p) => p.id == appointment.patientId);
//     final staff = controller.doctors.firstWhereOrNull((d) => d.id == appointment.staffId);
//
//     final patientName = patient != null
//         ? '${patient.firstname ?? ''} ${patient.lastname ?? ''}'.trim()
//         : 'Unknown Patient';
//     final staffName = staff != null
//         ? '${staff.firstname ?? ''} ${staff.lastname ?? ''}'.trim()
//         : 'Unknown Staff';
//
//     final currentStatus = controller.getEditingStatus(
//       appointment.id ?? '', // Use appointment.id for consistency
//       appointment.status ?? 'PENDING',
//     );
//
//     final String creatorId = Global.userId?? ''; // <<< IMPORTANT: Replace with actual logged-in user ID
//
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               patientName,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Get.theme.primaryColor),
//             ),
//             if (staffName.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Text(
//                 'with Dr. $staffName',
//                 style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
//               ),
//             ],
//             const Divider(height: 16, thickness: 1),
//             _infoRow("Date", appointment.date != null ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment.date!)) : 'N/A'),
//             _infoRow("Time", '${appointment.timeSlot?.start ?? 'N/A'} - ${appointment.timeSlot?.end ?? 'N/A'}'),
//             _infoRow("Visit Type", appointment.visitType ?? 'N/A'),
//             // const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Text("Status: ", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
//                 Expanded(
//                   child: Obx(() => DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       isExpanded: true,
//                       value: controller.getEditingStatus(appointment.id ?? '', appointment.status ?? 'PENDING'),
//                       items: ['PENDING', 'CONFIRMED', 'CANCELLED']
//                           .map((s) => DropdownMenuItem(value: s, child: Text(s)))
//                           .toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           controller.setEditingStatus(appointment.id ?? '', val);
//                         }
//                       },
//                       style: const TextStyle(color: Colors.black54),
//                       dropdownColor: Colors.white,
//                     ),
//                   )),
//                 ),
//               ],
//             ),
//             // const SizedBox(height: 16),
//             Align(
//               alignment: Alignment.centerRight,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (appointment.id != null) {
//                     controller.updateAppointmentStatus(
//                       appointment.id!,
//                       controller.getEditingStatus(appointment.id!, appointment.status ?? 'PENDING'), // Get the potentially edited status
//                       appointment.patientId ?? '',
//                       creatorId,
//                     );
//                   } else {
//                     Get.snackbar("Error", "Appointment ID is missing.");
//                   }
//                 },
//                 child: const Text('Save Status'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _infoRow(String label, String value) {
//     if (value == 'N/A' || value.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "$label: ",
//             style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
//           ),
//           Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
//         ],
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:intl/intl.dart';
// // import '../controller/appointment_controller.dart';
// // import '../../../data/models/appointment_model.dart';
// // import '../../../data/models/user_list_model.dart'; // Import UserListModel
// //
// // class PatientAppointmentsPage extends StatelessWidget {
// //   final AppointmentController controller = Get.put(AppointmentController());
// //
// //   PatientAppointmentsPage({super.key}); // Corrected constructor
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Patient Appointments'),
// //         centerTitle: true,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.refresh),
// //             onPressed: () => controller.fetchPatientAppointments(),
// //           ),
// //         ],
// //       ),
// //       body: Obx(() {
// //         if (controller.isLoading.value && controller.appointments.isEmpty) {
// //           return const Center(child: CircularProgressIndicator());
// //         }
// //
// //         if (controller.appointments.isEmpty) {
// //           return RefreshIndicator(
// //             onRefresh: () async => controller.fetchPatientAppointments(),
// //             child: ListView(
// //               physics: const AlwaysScrollableScrollPhysics(),
// //               children: const [
// //                 SizedBox(height: 120),
// //                 Center(child: Text('No appointments found.')),
// //               ],
// //             ),
// //           );
// //         }
// //
// //         return RefreshIndicator(
// //           onRefresh: () async => controller.fetchPatientAppointments(),
// //           child: ListView.builder(
// //             padding: const EdgeInsets.all(12),
// //             itemCount: controller.appointments.length,
// //             itemBuilder: (context, index) {
// //               final appointment = controller.appointments[index];
// //               return _buildAppointmentCard(context, appointment);
// //             },
// //           ),
// //         );
// //       }),
// //     );
// //   }
// //
// //   Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment) {
// //     final patient = controller.patients.firstWhereOrNull((p) => p.id == appointment.patientId);
// //     final patientName = patient != null
// //         ? '${patient.firstname ?? ''} ${patient.lastname ?? ''}'
// //         : 'Unknown Patient';
// //
// //     // Get the current editing status for this appointment, or its default status
// //     final currentStatus = controller.getEditingStatus(
// //       appointment.appointmentId ?? '', // Using appointment.id now as it's the unique identifier
// //       appointment.status ?? 'PENDING',
// //     );
// //
// //     // Assuming the 'creator_id' for updateAppointmentStatus should be the current logged-in user's ID
// //     // You'll need to replace "YOUR_LOGGED_IN_USER_ID" with the actual ID from your authentication system.
// //     const String creatorId = "YOUR_LOGGED_IN_USER_ID"; // <<< IMPORTANT: Replace this
// //
// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //       elevation: 4,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               patientName,
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Get.theme.primaryColor),
// //             ),
// //             const Divider(height: 16, thickness: 1),
// //             _infoRow("Appointment Date", appointment.date ?? 'N/A'),
// //             _infoRow("Start Time", appointment.timeSlot?.start ?? 'N/A'),
// //             _infoRow("End Time", appointment.timeSlot?.end ?? 'N/A'),
// //             _infoRow("Visit Type", appointment.visitType ?? 'N/A'),
// //             const SizedBox(height: 8),
// //             Row(
// //               children: [
// //                 const Text("Status: ", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
// //                 Expanded(
// //                   child: DropdownButtonHideUnderline(
// //                     child: DropdownButton<String>(
// //                       isExpanded: true,
// //                       value: currentStatus,
// //                       items: ['PENDING', 'CONFIRMED', 'CANCELLED']
// //                           .map((s) => DropdownMenuItem(value: s, child: Text(s)))
// //                           .toList(),
// //                       onChanged: (val) {
// //                         if (val != null) {
// //                           controller.setEditingStatus(appointment.appointmentId ?? '', val);
// //                         }
// //                       },
// //                       style: const TextStyle(color: Colors.black54),
// //                       dropdownColor: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             Align(
// //               alignment: Alignment.centerRight,
// //               child: ElevatedButton(
// //                 onPressed: () {
// //                   if (appointment.appointmentId != null) {
// //                     controller.updateAppointmentStatus(
// //                       appointment.appointmentId!,
// //                       currentStatus,
// //                       appointment.patientId ?? '',
// //                       creatorId,
// //                     );
// //                   } else {
// //                     Get.snackbar("Error", "Appointment ID is missing.");
// //                   }
// //                 },
// //                 child: const Text('Save Status'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _infoRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 2),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             "$label: ",
// //             style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
// //           ),
// //           Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
// //         ],
// //       ),
// //     );
// //   }
// // }







import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/global/global.dart';

import '../../../data/models/appointment_model.dart';
import '../../../widgets/custom_list_page2.dart';
import '../controller/appointment_controller.dart';

class PatientAppointmentsPage extends StatelessWidget {
  PatientAppointmentsPage({super.key});

  final controller = Get.put(AppointmentController());
  final TextEditingController searchController = TextEditingController();

  String formatRange(DateTime from, DateTime to) {
    final f = DateFormat('dd MMM yyyy');
    return '${f.format(from)} - ${f.format(to)}';
  }

  // void _showStatusBottomSheet(BuildContext context) {
  //   final options = ['All', 'CONFIRMED', 'COMPLETED', 'CANCELLED'];
  //
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext bc) {
  //       return SafeArea(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: options.map((status) {
  //             return ListTile(
  //               title: Text(status),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 controller.currentFilterStatus.value =
  //                 status == 'All' ? '' : status.toUpperCase();
  //               },
  //             );
  //           }).toList(),
  //         ),
  //       );
  //     },
  //   );
  // }
  //

  void _showDateRangeSelectionBottomSheet(BuildContext context) {
    final options = {
      'This Month': DateRangeOption.thisMonth,
      'Last Month': DateRangeOption.lastMonth,
      'This Week': DateRangeOption.thisWeek,
      'Custom': DateRangeOption.custom,
    };

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return ListView(
          children: options.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              onTap: () async {
                Navigator.of(context).pop();
                if (entry.value == DateRangeOption.custom) {
                  final from = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (from == null) return;
                  final to = await showDatePicker(
                    context: context,
                    initialDate: from,
                    firstDate: from,
                    lastDate: DateTime(2100),
                  );
                  if (to != null) {
                    controller.currentFilterDateRange.value = DateRangeOption.custom;
                    controller.filterFromDate.value = from;
                    controller.filterToDate.value = to;
                  }
                } else {
                  controller.currentFilterDateRange.value = entry.value;
                }
              },
            );
          }).toList(),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // 🔹 First time: call API when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.appointments.isEmpty) {
        controller.fetchPatientAppointments();
      }
    });

    return Obx(() => CustomListPage2(
      appBarTitle: 'Patient Appointments',
      isLoading: controller.isLoading.value,
      showInitialMessage: controller.appointments.isEmpty && !controller.isLoading.value,
      itemCount: controller.appointments.length,
      itemBuilder: (context, index) {
        final appointment = controller.appointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Patient name + Edit icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appointment.patientName ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: appointment.status == 'COMPLETED'
                          ? null
                          : () => _showUpdateDialog(context, appointment),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Appointment Date
                Text(
                  'Appointment Date: ${appointment.date ?? '-'}',
                  style: const TextStyle(fontSize: 14),
                ),
                // const SizedBox(height: 8),

                // Start Time & End Time, Visit Type

                    Text('Start Time: ${appointment.timeSlot?.start ?? '-'}'),
                    Text('End Time: ${appointment.timeSlot?.end ?? '-'}'),
                    Text('Visit Type: ${appointment.visitType ?? '-'}'),

                // const SizedBox(height: 8),

                // Phone number (copyable)
                Row(
                  children: [
                    Text('Patient Phone: ${appointment.patientPhone ?? '-'}'),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: appointment.patientPhone ?? ''),
                        );
                        Get.snackbar('Copied', 'Phone number copied to clipboard');
                      },
                    ),
                  ],
                ),
                // const SizedBox(height: 4),

                // Address (copyable)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Patient Address: ${appointment.patientAddress}, ${appointment.patientCity}, ${appointment.patientState}, ${appointment.patientCountry}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: appointment.patientAddress ?? ''),
                        );
                        Get.snackbar('Copied', 'Address copied to clipboard');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Status
                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(appointment.status ?? '-'),
                  ],
                ),
              ],
            ),
          ),
        );
      },

      // itemBuilder: (context, index) {
      //   final appointment = controller.appointments[index];
      //   return Card(
      //     margin: const EdgeInsets.symmetric(vertical: 6),
      //     child: ListTile(
      //       title: Text(appointment.patientName ?? 'Unknown'),
      //       subtitle: Text(
      //         '${appointment.date ?? ''} | ${appointment.timeSlot ?? ''}\nStatus: ${appointment.status ?? 'N/A'}',
      //       ),
      //       isThreeLine: true,
      //       leading: const Icon(Icons.calendar_month),
      //     ),
      //   );
      // },

      // 🔹 Callbacks
      // onSearch: () => controller.fetchPatientAppointments(),
      onSearch: () {
        controller.currentSearchQuery.value = searchController.text;
        controller.fetchPatientAppointments();
      },
      // onClear: () {
      //   controller.clearFilters();
      //   searchController.clear();
      // },
      onClear: () {
        searchController.clear();
        controller.currentSearchQuery.value = '';
        controller.currentFilterStatus.value = [];
        controller.currentFilterDateRange.value = DateRangeOption.thisMonth;
        controller.filterFromDate.value = null;
        controller.filterToDate.value = null;
        controller.fetchPatientAppointments();
      },
      onSelectStatus: () async {
        final selected = await _showStatusDialog(context);
        // if (selected != null) {
        //   controller.currentFilterStatus.value = selected == 'All' ? '' : selected.toUpperCase();
        // }
      },
      // onSelectStatus: () => _showStatusBottomSheet(context),
      onSelectDateRange: () => _showDateRangeSelectionBottomSheet(context),
      onSearchChanged: (value) {
        controller.currentSearchQuery.value = value;
      },

      // 🔹 Display texts
      // selectedStatusText: controller.currentFilterStatus.value.isEmpty
      //     ? 'All'
      //     : controller.currentFilterStatus.value,
      selectedStatusText: controller.currentFilterStatus.isEmpty
          ? 'Select Status'
          : controller.currentFilterStatus.join(', '),
      selectedDateRangeText:
      controller.currentFilterDateRange.value.name.capitalize ?? 'Select Range',
      // formattedDateRange: controller.getFormattedDateRange(),
      formattedDateRange: formatRange(controller.fromDate, controller.toDate),
      searchController: searchController,
    ));
  }

  Future<void> _showStatusDialog(BuildContext context) async {
    final options = ['CONFIRMED', 'CANCELLED', 'COMPLETED'];
    final selectedStatuses = List<String>.from(controller.currentFilterStatus);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Status'),
            content: SingleChildScrollView(
              child: Column(
                children: options.map((status) {
                  final isSelected = selectedStatuses.contains(status);
                  return CheckboxListTile(
                    title: Text(status),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedStatuses.add(status);
                        } else {
                          selectedStatuses.remove(status);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, selectedStatuses),
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      controller.currentFilterStatus.assignAll(result);
    }
  }


  Future<void> _showUpdateDialog(
      BuildContext context, AppointmentModel appointment) async {
    String selectedStatus = appointment.status ?? 'CONFIRMED';
    final statusOptions = ['CONFIRMED', 'CANCELLED', 'COMPLETED'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Appointment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appointment Date: ${appointment.date ?? ''}'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text('Patient Name: ${appointment.patientName ?? ''}')),
                  Expanded(child: Text('Visit Type: ${appointment.visitType ?? ''}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text('Start Time: ${appointment.timeSlot?.start ?? ''}')),
                  Expanded(child: Text('End Time: ${appointment.timeSlot?.end ?? ''}')),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: statusOptions
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Call your controller update method here
                await controller.updateAppointmentStatus(
                    appointment.id!, selectedStatus, appointment.patientId ?? '', Global.userId??'');
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
