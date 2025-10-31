import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/controllers/date_selector_controller.dart';
import '../modules/appointment/controller/appointment_controller.dart';
import '../widgets/custom_list_page2.dart';
import '../widgets/select_date_bottomsheet.dart';

enum PatientStatusOption {
  CONTINUE,
  ALTERNATE,
  DISCONTINUE,
  WEEKLY,
  DISCHARGE,
  OBSERVATION,
}

class PatientsPage extends StatefulWidget {
  PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final AppointmentController controller = Get.put(AppointmentController());

  // final controller = Get.put(AppointmentController());
  final DateSelectorController dateSelectorController = Get.put(DateSelectorController());

  final TextEditingController searchController = TextEditingController();
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPatients(clear: true);
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!controller.isLoadingPatients.value && controller.hasMore.value) {
        controller.fetchPatients();
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }


  String formatRange(DateTime from, DateTime to) {
    final f = DateFormat('dd MMM yyyy');
    return '${f.format(from)} - ${f.format(to)}';
  }

  // --- Show Patient Status BottomSheet ---
  void _showStatusSelectionBottomSheet(BuildContext context) {
    // Use Get.find<YourController>() if the controller isn't directly available in scope.
    // Assuming 'controller' is the correct instance here.
    // final controller = Get.find<YourController>();
    final options = PatientStatusOption.values;

    // Use Get.bottomSheet for the modern design and easy control
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Filter by Patient Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey,),

            // Status List - Uses Obx to react to changes in currentFilterStatus
            Flexible(
              child: SingleChildScrollView(
                child: Obx(() => Column(
                  children: options.map((statusOption) {
                    final statusText = statusOption.name;
                    final isSelected =
                    controller.currentFilterStatus.contains(statusText);

                    return CheckboxListTile(
                      title: Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: isSelected ? Get.theme.primaryColor : Colors.black87,
                        ),
                      ),
                      value: isSelected,
                      activeColor: Get.theme.primaryColor,
                      onChanged: (val) {
                        if (val == true) {
                          if (!controller.currentFilterStatus.contains(statusText)) {
                            controller.currentFilterStatus.add(statusText);
                          }
                        } else {
                          controller.currentFilterStatus.remove(statusText);
                        }
                        // Since we update the RxList directly, no local setState is needed.
                      },
                    );
                  }).toList(),
                )),
              ),
            ),
            // const Divider(height: 8, thickness: 1),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Clear / Cancel Button (Outlined) - Clears the filter locally before dismissing
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Option 1: Just cancel/dismiss without changing anything
                        // Get.back();

                        // Option 2 (Recommended for a Clear/Cancel button): Clear the filter and dismiss
                        controller.currentFilterStatus.clear();
                        Get.back();
                        // Assuming you call the fetch function after clearing the filter
                        // controller.fetchPatients();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Save / Apply Button (Primary Color)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Dismiss the sheet
                        // Assuming you call the fetch function after closing the sheet
                        // controller.fetchPatients();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply Filter',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Show Date Range BottomSheet ---
  void _showDateRangeSelectionBottomSheet(BuildContext context) {

    Get.bottomSheet(
      SelectDateBottomSheet(
        onDateRangeSelected: (option, fromDate, toDate) {
          // Update the LeaveController's filter dates
          controller.currentFilterDateRange.value = option;
          controller.filterFromDate.value = fromDate;
          controller.filterToDate.value = toDate;
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(16)),
      ),
    );

    // showModalBottomSheet(
    //   context: context,
    //   builder: (BuildContext bc) {
    //     return ListView(
    //       shrinkWrap: true,
    //       children: options.entries.map((entry) {
    //         return ListTile(
    //           title: Text(entry.key),
    //           onTap: () async {
    //             Navigator.pop(context);
    //             final option = entry.value;
    //
    //             if (option == DateRangeOption.custom) {
    //               final from = await showDatePicker(
    //                 context: context,
    //                 initialDate: DateTime.now(),
    //                 firstDate: DateTime(2020),
    //                 lastDate: DateTime(2100),
    //               );
    //               if (from == null) return;
    //
    //               final to = await showDatePicker(
    //                 context: context,
    //                 initialDate: from,
    //                 firstDate: from,
    //                 lastDate: DateTime(2100),
    //               );
    //               if (to != null) {
    //                 controller.customFrom.value = from;
    //                 controller.customTo.value = to;
    //                 controller.dateRangeOption.value = DateRangeOption.custom;
    //               }
    //             } else {
    //               controller.dateRangeOption.value = option;
    //             }
    //
    //             // ❌ Do not call fetchPatients() here
    //             // ✅ Only update the state so UI shows correct range
    //           },
    //         );
    //       }).toList(),
    //     );
    //   },
    // );
  }

  Future<void> _fetchPatients() async {
    await controller.fetchPatients(clear: true);
  }

  void _showEditPatientBottomSheet(BuildContext context, dynamic patient) {
    // Use RxString for local state management that works with Obx
    // 'dynamic patient' is assumed to have properties like patientStatus, firstname, etc.
    final RxString selectedStatus = RxString(patient.patientStatus ?? '');
    final statusOptions = PatientStatusOption.values;

    // Custom Widget for a clean single info block (reused from previous answer)
    Widget _buildInfoBlock(String label, String value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    // Use Get.bottomSheet for the modern, professional look
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Update Patient Status',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Patient Details Section (Two Rows)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50, // Light background for the info card
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Row 1: Name and Phone
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoBlock('Patient Name',
                            '${patient.firstname ?? ''} ${patient.lastname ?? ''}'),
                      ),
                      Expanded(
                        child: _buildInfoBlock('Phone', patient.phone ?? 'N/A'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 2: Email and Address (Simplified)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoBlock('Email', patient.email ?? 'N/A'),
                      ),
                      Expanded(
                        child: _buildInfoBlock('City, Country', '${patient.city ?? ''}, ${patient.country ?? ''}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status Dropdown
            const Text(
              'Change Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // DropdownButtonFormField is wrapped in Obx to react to selectedStatus changes
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<PatientStatusOption>(
                  value: statusOptions.firstWhereOrNull(
                          (e) => e.name == selectedStatus.value),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Get.theme.primaryColor),
                  decoration: const InputDecoration(
                    border: InputBorder.none, // Remove default border
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: statusOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedStatus.value = value.name;
                  },
                ),
              ),
            )),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(), // Dismiss bottom sheet
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Update Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Dismiss the sheet before async call to prevent context issues
                        await controller.updatePatientStatus(patient.id ?? '', selectedStatus.value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.patients.isEmpty) {
        controller.fetchPatients();
      }
    });

    return Obx(
          () => CustomListPage2(
            scrollController: scrollController,
        appBarTitle: 'Patients',
        isLoading: controller.isLoadingPatients.value,
        showInitialMessage:
        controller.patients.isEmpty && !controller.isLoadingPatients.value,
        itemCount: controller.patients.length,
        itemBuilder: (context, index) {
          final patient = controller.patients[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3, // Subtle shadow
            child: Column(
              children: [
                // 1. TOP SECTION: Patient Name, Status & Edit Button
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${patient.firstname ?? ''} ${patient.lastname ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: patient.patientStatus == '' ? Colors.grey : Get.theme.primaryColor,
                        ),
                        padding: EdgeInsets.zero, // removes default padding
                        constraints: const BoxConstraints(), // removes default min size (48x48)
                        visualDensity: VisualDensity.compact,
                        onPressed: patient.patientStatus == ''
                            ? null
                            : () => _showEditPatientBottomSheet(context, patient),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 10, thickness: 1, indent: 16, endIndent: 16), // Separator

                // 2. MIDDLE SECTION: Visit and Appointment Counts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Visit Count
                      Row(
                        children: [
                           Text('Visits :', style: TextStyle(fontSize: 15, color: Colors.grey.shade900)),
                          Text(
                            ' ${patient.visitCount ?? 0}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                        ],
                      ),
                      // Separator
                      Container(width: 1, height: 30, color: Colors.grey.shade400),
                      // Total Appointments
                      Row(
                        children: [

                          Text('Appointments :', style: TextStyle(fontSize: 15, color: Colors.grey.shade900)),
                          Text(
                            ' ${patient.totalAppointments ?? 0}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16), // Separator

                // 3. BOTTOM SECTION: Contact Info (Email, Phone, Address) with Copy Icons
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      Text(
                        'Email: ${patient.email ?? '-'}',
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 8),

                      // Phone number (copyable)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Phone: ${patient.phone ?? '-'}',
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: patient.phone ?? ''),
                              );
                              Get.snackbar('Copied', 'Phone number copied to clipboard', snackPosition: SnackPosition.BOTTOM);
                            },
                          ),
                        ],
                      ),

                      // Address (copyable)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Address: ${patient.address ?? ''}, ${patient.city ?? ''}, ${patient.state ?? ''}, ${patient.country ?? ''}',
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: '${patient.address ?? ''}, ${patient.city ?? ''}, ${patient.state ?? ''}, ${patient.country ?? ''}',
                                ),
                              );
                              Get.snackbar('Copied', 'Address copied to clipboard', snackPosition: SnackPosition.BOTTOM);
                            },
                          ),
                        ],
                      ),
                      // Remaining details (if needed, simplified)
                      Text('Patient Status: ${patient.patientStatus ?? 0}', style: const TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },

        // --- Callbacks ---
        onSearch: _fetchPatients,
        onClear: () {
          controller.currentFilterStatus.value = [];
          searchController.clear();
        },
        onSelectStatus: () => _showStatusSelectionBottomSheet(context),
        onSelectDateRange: () =>
            _showDateRangeSelectionBottomSheet(context),
        onSearchChanged: (value) {
          controller.currentSearchQuery.value = value;
        },

        // --- Display texts ---
        selectedStatusText: controller.currentFilterStatus.isEmpty
            ? 'Select Status'
            : controller.currentFilterStatus.join(', '),
        selectedDateRangeText: _formatDateRangeOption(controller.currentFilterDateRange.value),
        formattedDateRange:
        formatRange(controller.fromDate, controller.toDate),
        searchController: searchController,
      ),
    );
  }

  String _formatDateRangeOption(DateRangeOption option) {
    switch (option) {
      case DateRangeOption.thisMonth:
        return 'This Month';
      case DateRangeOption.lastMonth:
        return 'Last Month';
      case DateRangeOption.thisWeek:
        return 'This Week';
      case DateRangeOption.custom:
        return 'Custom Range';
      default:
        return option.name.capitalizeFirst ?? 'Select Range';
    }
  }
}
