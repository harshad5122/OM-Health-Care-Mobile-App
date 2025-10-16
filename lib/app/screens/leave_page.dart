import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/data/models/leave_model.dart';
import 'package:om_health_care_app/app/data/models/staff_list_model.dart';
import 'package:om_health_care_app/app/modules/appointment/controller/appointment_controller.dart';
import 'package:om_health_care_app/app/modules/leave/controller/leave_controller.dart';
import 'package:om_health_care_app/app/widgets/custom_list_page.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final controller = Get.put(LeaveController());
  final appointmentController = Get.put(AppointmentController());

  @override
  void dispose() {
    Get.delete<LeaveController>();
    super.dispose();
  }

  String formatRange(DateTime from, DateTime to) {
    final f = DateFormat('dd MMM yyyy');
    return '${f.format(from)} - ${f.format(to)}';
  }

  // Method to show the doctor selection bottom sheet
  void _showDoctorSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Obx(() => appointmentController.doctors.isEmpty
            ? const Center(child: Text("No doctors found."))
            : ListView.builder(
          itemCount: appointmentController.doctors.length,
          itemBuilder: (context, index) {
            final doc = appointmentController.doctors[index];
            return ListTile(
              title: Text("${doc.firstname} ${doc.lastname}"),
              onTap: () {
                controller.selectDoctor(doc);
                Navigator.of(context).pop();
              },
            );
          },
        ));
      },
    );
  }

  // Method to show the date range selection bottom sheet
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
                final option = entry.value;
                if (option == DateRangeOption.custom) {
                  final from = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100));
                  if (from == null) return;
                  final to = await showDatePicker(
                      context: context,
                      initialDate: from,
                      firstDate: from,
                      lastDate: DateTime(2100));
                  if (to != null) {
                    controller.setCustomRange(from, to);
                  }
                } else {
                  controller.changeDateRange(option);
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
    return Obx(() => CustomListPage(
      appBarTitle: 'Leaves',
      isLoading: controller.isFetchingRecords.value,
      showInitialMessage: controller.leaveRecords.isEmpty && controller.selectedDoctor.value == null,
      itemCount: controller.leaveRecords.length,
      // onSearch: () {
      //   // Add validation here as well for a better user experience
      //   if (controller.selectedDoctor.value == null) {
      //     Get.snackbar(
      //       'Validation Error',
      //       'Please select a doctor before searching.',
      //       snackPosition: SnackPosition.BOTTOM,
      //     );
      //   } else {
      //     controller.fetchLeaveRecords();
      //   }
      // },
      onSearch: controller.isAdmin.value
          ? () {
        if (controller.selectedDoctor.value == null) {
          Get.snackbar(
            'Validation Error',
            'Please select a doctor before searching.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          controller.fetchLeaveRecords();
        }
      }
          : null,
      // onClear: controller.clearFiltersAndLeaves,
      onClear: controller.isAdmin.value
          ? controller.clearFiltersAndLeaves
          : null,

      // Connect the doctor selection UI elements
      // onSelectDoctor: () => _showDoctorSelectionBottomSheet(context),
      onSelectDoctor: controller.isAdmin.value
          ? () => _showDoctorSelectionBottomSheet(context)
          : null,
      selectedDoctorText: controller.selectedDoctor.value != null
          ? "${controller.selectedDoctor.value!.firstname} ${controller.selectedDoctor.value!.lastname}"
          : "",
      // selectedDoctorText: controller.selectedDoctor.value != null
      //     ? "${controller.selectedDoctor.value!.firstname} ${controller.selectedDoctor.value!.lastname}"
      //     : "",

      // Date Range functionality
      onSelectDateRange: () => _showDateRangeSelectionBottomSheet(context),
      selectedDateRangeText: controller.dateRangeOption.value.toString().split('.').last.replaceAll('this', 'This '),
      formattedDateRange: formatRange(controller.fromDate, controller.toDate),

      // Card builder for leave records
      itemBuilder: (context, index) {
        final LeaveRecord leave = controller.leaveRecords[index];
        final f = DateFormat('dd MMM yyyy');
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${leave.status}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: leave.status == 'CONFIRMED' ? Colors.blue : leave.status == 'CANCELLED' ? Colors.deepOrange : Colors.green)),
                // const Divider(),
                const SizedBox(height: 4),
                Text('Date: ${f.format(leave.startDate)} to ${f.format(leave.endDate)}'),
                const SizedBox(height: 4),
                Text('Reason: ${leave.reason}'),
                if (leave.adminName != null && leave.adminName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Approved by: ${leave.adminName}'),
                ],
                const SizedBox(height: 4),
                Text('Leave type: ${leave.leaveType.replaceAll('_', ' ')}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    ));
  }
}