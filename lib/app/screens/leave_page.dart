import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/data/models/leave_model.dart';
import 'package:om_health_care_app/app/data/models/staff_list_model.dart';
import 'package:om_health_care_app/app/global/global.dart';
import 'package:om_health_care_app/app/modules/appointment/controller/appointment_controller.dart';
import 'package:om_health_care_app/app/modules/leave/controller/leave_controller.dart';
import 'package:om_health_care_app/app/widgets/custom_list_page.dart';

import '../data/controllers/date_selector_controller.dart';
import '../modules/leave/view/leave_management_page.dart';
import '../widgets/select_date_bottomsheet.dart';

extension DateRangeOptionExtension on DateRangeOption {
  String toDisplayString() {
    switch (this) {
      case DateRangeOption.thisMonth:
        return 'This Month';
      case DateRangeOption.lastMonth:
        return 'Last Month';
      case DateRangeOption.thisWeek:
        return 'This Week';
      case DateRangeOption.custom:
        return 'Custom Range';
      default:
        return this.name.capitalizeFirst ?? 'Select Range';
    }
  }
}

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final controller = Get.put(LeaveController());
  final appointmentController = Get.put(AppointmentController());
  final DateSelectorController dateSelectorController = Get.put(DateSelectorController());


  @override
  void dispose() {
    Get.delete<LeaveController>();
    Get.delete<DateSelectorController>();
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
    // final options = {
    //   'This Month': DateRangeOption.thisMonth,
    //   'Last Month': DateRangeOption.lastMonth,
    //   'This Week': DateRangeOption.thisWeek,
    //   'Custom': DateRangeOption.custom,
    // };

    // showModalBottomSheet(
    //   context: context,
    //   builder: (BuildContext bc) {
    //     return ListView(
    //       children: options.entries.map((entry) {
    //         return ListTile(
    //           title: Text(entry.key),
    //           onTap: () async {
    //             Navigator.of(context).pop();
    //             final option = entry.value;
    //             if (option == DateRangeOption.custom) {
    //               final from = await showDatePicker(
    //                   context: context,
    //                   initialDate: DateTime.now(),
    //                   firstDate: DateTime(2020),
    //                   lastDate: DateTime(2100));
    //               if (from == null) return;
    //               final to = await showDatePicker(
    //                   context: context,
    //                   initialDate: from,
    //                   firstDate: from,
    //                   lastDate: DateTime(2100));
    //               if (to != null) {
    //                 controller.setCustomRange(from, to);
    //               }
    //             } else {
    //               controller.changeDateRange(option);
    //             }
    //           },
    //         );
    //       }).toList(),
    //     );
    //   },
    // );
    Get.bottomSheet(
      SelectDateBottomSheet(
        onDateRangeSelected: (option, fromDate, toDate) {
          // Update the LeaveController's filter dates
          controller.currentFilterDateRange.value = option;
          controller.filterFromDate.value = fromDate;
          controller.filterToDate.value = toDate;
          // The `ever` listener in LeaveController.onInit will automatically call fetchLeaveRecords()
          // when `currentFilterDateRange` changes. So, an explicit fetch here is optional but can be added
          // if you need more immediate control.
          // controller.fetchLeaveRecords(); // Optional, depending on `ever` listener behavior
        },
        // onFetchData: () {
        //   // This explicit fetch ensures the data is reloaded after the bottom sheet closes
        //   controller.fetchLeaveRecords();
        // },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.leaveRecords.isEmpty && !controller.isFetchingRecords.value && !controller.isAdmin.value) {
        // If it's a doctor, fetch immediately
        controller.fetchLeaveRecords();
      } else if (controller.isAdmin.value && controller.selectedDoctor.value != null && controller.leaveRecords.isEmpty && !controller.isFetchingRecords.value) {
        // If admin and a doctor is pre-selected (or was previously selected), fetch
        controller.fetchLeaveRecords();
      }
    });

    return Obx(() => CustomListPage(
      appBarTitle: 'Leaves',
      isLoading: controller.isFetchingRecords.value,
      showInitialMessage: controller.leaveRecords.isEmpty && controller.selectedDoctor.value == null,
      itemCount: controller.leaveRecords.length,

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
      :() {
        // For non-admin (doctors), search might just re-fetch with current filters
        controller.fetchLeaveRecords();
      },
          // : null,
      // onClear: controller.clearFiltersAndLeaves,
      onClear: controller.isAdmin.value
          ? controller.clearFiltersAndLeaves
      :() {
        // For non-admin, clear just date range, leave the doctor pre-selected (which is themselves)
        controller.currentFilterDateRange.value = DateRangeOption.thisMonth;
        controller.fetchLeaveRecords();
      },
          // : null,

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
      selectedDateRangeText: controller.currentFilterDateRange.value.toDisplayString(),
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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${leave.status}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: leave.status == 'CONFIRMED' ? Get.theme.primaryColor : leave.status == 'CANCELLED' ? Colors.deepOrange : Colors.green)),
                    // const Divider(),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${f.format(leave.startDate.toLocal())} to ${f.format(leave.endDate.toLocal())}',
                    ),
                    const SizedBox(height: 4),
                    Text('Reason: ${leave.reason}'),
                    if (leave.adminName != null && leave.adminName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Approved by: ${leave.adminName}'),
                    ],
                    Text('Status: ${leave.status.toLowerCase()}'),
                    const SizedBox(height: 4),
                    Text('Leave type: ${leave.leaveType.replaceAll('_', ' ')}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                if(Global.role == 3)
                Positioned(
                  top: 0,
                  right: 0,
                  child:PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),

                    itemBuilder: (BuildContext context) {
                      // Start with an empty list of menu items
                      final List<PopupMenuEntry<String>> menuItems = [];

                      // CONDITION: Only add the 'Edit' option if the status is "PENDING"
                      if (leave.status == 'PENDING') {
                        menuItems.add(
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 10),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        );
                      }

                      // ALWAYS ADD 'Delete': This will be the only option
                      // if the status is not "PENDING".
                      menuItems.add(
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      );

                      // Return the final list of items to display
                      return menuItems;
                    },

                    onSelected: (value) {
                      if (value == 'edit') {
                        controller.isEditMode.value = true;
                        controller.editingLeave.value = leave;

                        // Pre-fill all fields
                        controller.startDate.value = leave.startDate.toLocal();
                        controller.endDate.value = leave.endDate.toLocal();
                        controller.selectedLeaveType.value = leave.leaveType;
                        controller.reasonController.text = leave.reason;
                        controller.adminId.value = leave.adminId ?? '';
                        controller.adminName.value = leave.adminName ?? '';
                        controller.selectedStatus.value = leave.status;

                        Get.to(() => LeaveManagementPage());
                      }
                      else if (value == 'delete') {
                        Get.dialog(
                          Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  Text(
                                    "Delete Leave",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Get.theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Are you sure you want to delete this leave?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Get.back(),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            controller.deleteLeave(leave.id);
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Get.theme.primaryColor,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    ));
  }
}