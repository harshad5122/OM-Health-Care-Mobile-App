import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/global/global.dart';

import '../../../data/models/appointment_model.dart';
import '../../../widgets/custom_list_page2.dart';
import '../../../widgets/select_date_bottomsheet.dart';
import '../controller/appointment_controller.dart';

class PatientAppointmentsPage extends StatefulWidget {
  PatientAppointmentsPage({super.key});

  @override
  State<PatientAppointmentsPage> createState() => _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsPage> {
  final controller = Get.put(AppointmentController());

  final TextEditingController searchController = TextEditingController();

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    // Fetch first batch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPatientAppointments(clear: true);
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      // When user scrolls near bottom, load more
      if (!controller.isLoading.value && controller.hasMore.value) {
        controller.fetchPatientAppointments();
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  String formatRange(DateTime from, DateTime to) {
    final f = DateFormat('dd MMM yyyy');
    return '${f.format(from)} - ${f.format(to)}';
  }

  void _showDateRangeSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SelectDateBottomSheet(
        onDateRangeSelected: (option, fromDate, toDate) {
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
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 First time: call API when screen loads
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (controller.appointments.isEmpty) {
    //     controller.fetchPatientAppointments(clear: true);
    //   }
    // });

    return Obx(() => CustomListPage2(
      scrollController: scrollController,
      appBarTitle: 'Patient Appointments',
      isLoading: controller.isLoading.value,
      showInitialMessage: controller.appointments.isEmpty && !controller.isLoading.value,
      itemCount: controller.appointments.length,
      itemBuilder: (context, index) {
        final appointment = controller.appointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Adjust margin for separation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // Removed border side for a cleaner 'floating' look
          ),
          elevation: 3, // Add subtle shadow for professionalism
          child: Column(
            children: [
              // 1. TOP SECTION: Patient Name & Edit Button
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.patientName ?? 'Unknown Patient',
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
                        color: appointment.status == 'COMPLETED' ? Colors.grey : Get.theme.primaryColor,
                      ),
                      onPressed: appointment.status == 'COMPLETED'
                          ? null
                          : () => _showUpdateBottomSheet(context, appointment),
                    ),
                  ],
                ),
              ),
              const Divider(height: 10, thickness: 1, indent: 16, endIndent: 16), // Separator

              // 2. MIDDLE SECTION: Key Details (Date, Time, Visit Type)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Date & Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _formatLocalDate(appointment.date),
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          '${_formatTime(appointment.timeSlot?.start)} - ${_formatTime(appointment.timeSlot?.end)}',
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 2: Visit Type
                    Row(
                      children: [
                        const Icon(Icons.person_pin_circle, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Visit Type: ${appointment.visitType ?? '-'}',
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. BOTTOM SECTION: Status & Copy Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50, // Distinct background for the action area
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Tag
                    Row(
                      children: [
                        const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            appointment.status ?? 'N/A',
                            style: TextStyle(
                              color: _getStatusColor(appointment.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 10),

                    // Phone number (copyable)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Phone: ${appointment.patientPhone ?? '-'}',
                            style:  TextStyle(fontSize: 14, color: Colors.grey.shade900),
                          ),
                        ),
                        IconButton(
                          icon:  Icon(Icons.copy, size: 18, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: appointment.patientPhone ?? ''),
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
                            'Address: ${appointment.patientAddress}, ${appointment.patientCity}, ${appointment.patientState}, ${appointment.patientCountry}',
                            style:  TextStyle(fontSize: 14, color: Colors.grey.shade900),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: '${appointment.patientAddress ?? ''}, ${appointment.patientCity ?? ''}, ${appointment.patientState ?? ''}, ${appointment.patientCountry ?? ''}',
                              ),
                            );
                            Get.snackbar('Copied', 'Address copied to clipboard', snackPosition: SnackPosition.BOTTOM);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },

      onSearch: () {
        controller.currentSearchQuery.value = searchController.text;
        controller.fetchPatientAppointments(clear: true);
      },

      onClear:controller.clearFilters,
      //     () {
      //   controller.clearFilters();
      // },
      onSelectStatus: () async {
         await _showStatusBottomSheet(context);
      },
      // onSelectStatus: () => _showStatusBottomSheet(context),
      onSelectDateRange: () => _showDateRangeSelectionBottomSheet(context),
      onSearchChanged: (value) {
        controller.currentSearchQuery.value = value;
      },


      selectedStatusText: controller.currentFilterStatus.isEmpty
          ? 'Select Status'
          : controller.currentFilterStatus.join(', '),
      selectedDateRangeText:
      _formatDateRangeOption(controller.currentFilterDateRange.value),
      formattedDateRange: formatRange(controller.fromDate, controller.toDate),
      searchController: searchController,
    ));
  }

  Future<void> _showStatusBottomSheet(BuildContext context) async {
    final options = ['CONFIRMED', 'CANCELLED', 'COMPLETED',]; // Added more typical statuses for completeness

    final selectedStatuses = List<String>.from(controller.currentFilterStatus);

    final result = await Get.bottomSheet<List<String>>(

      StatefulBuilder(
        builder: (context, setState) {
          return Container(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Divider(height: 20, thickness: 1, color: Colors.grey,),


                // Status List
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: options.map((status) {
                        final isSelected = selectedStatuses.contains(status);
                        return CheckboxListTile(
                          title: Text(
                            status,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: isSelected ? Get.theme.primaryColor : Colors.black87,
                            ),
                          ),
                          value: isSelected,
                          activeColor: Get.theme.primaryColor,
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
                ),
                // const Divider(height: 8, thickness: 1),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Cancel Button (Outlined)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: null), // Dismiss with null result
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
                      // Apply Button (Primary Color)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(result: selectedStatuses), // Apply filter and dismiss
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
          );
        },
      ),
      isScrollControlled: true, // Allows the sheet to take up more than half the screen if needed
    );

    if (result != null) {
      controller.currentFilterStatus.assignAll(result);
    }
  }

  Future<void> _showUpdateBottomSheet(
      BuildContext context, AppointmentModel appointment) async {


    // String initialStatus = appointment.status ?? 'CONFIRMED';
    controller.selectedStatus.value = appointment.status ?? 'CONFIRMED';
    // Use a map for status display for better color/styling later
    final statusOptions = ['CONFIRMED', 'CANCELLED', 'COMPLETED'];

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          // String selectedStatus = initialStatus;

          // Custom Widget for a clean single info block
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

          return Container(
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
                  'Update Appointment Status',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Appointment Details Section (Two Rows)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50, // Light background for the info card
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Row 1: Patient Name and Date
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoBlock('Patient Name', appointment.patientName ?? 'N/A'),
                          ),
                          Expanded(
                            child: _buildInfoBlock('Date',  _formatLocalDate(appointment.date) ?? 'N/A'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row 2: Time and Visit Type
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoBlock(
                                'Time Slot',
                                '${_formatTime(appointment.timeSlot?.start) ?? 'N/A'} - ${_formatTime(appointment.timeSlot?.end) ?? 'N/A'}'
                            ),
                          ),
                          Expanded(
                            child: _buildInfoBlock('Visit Type', appointment.visitType ?? 'N/A'),
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

                Obx(() {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          // value: selectedStatus,
                          value: controller.selectedStatus.value,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: Get.theme.primaryColor),
                          items: statusOptions
                              .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedStatus.value = value;
                            }
                          },
                          // onChanged: (value) {
                          //   if (value != null) {
                          //     setState(() {
                          //       selectedStatus = value;
                          //     });
                          //   }
                          // },
                        ),
                      ),
                    );
                  }
                ),

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

                      // Save Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // if (selectedStatus != initialStatus) {
                            //   await controller.updateAppointmentStatus(
                            //       appointment.id!, selectedStatus, appointment.patientId ?? '', Global.userId??'');
                            // }
                            if (controller.selectedStatus.value !=
                                (appointment.status ?? 'CONFIRMED')) {
                              await controller.updateAppointmentStatus(
                                appointment.id!,
                                controller.selectedStatus.value,
                                appointment.patientId ?? '',
                                Global.userId ?? '',
                              );
                            }
                            // Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Get.theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
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

  String _formatLocalDate(String? utcString) {
    if (utcString == null || utcString.isEmpty) return '-';
    try {
      final utcDate = DateTime.parse(utcString);
      final localDate = utcDate.toLocal();
      return DateFormat('dd-MM-yyyy').format(localDate);
    } catch (e) {
      return '-';
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '-';
    try {
      final parsedTime = DateFormat('HH:mm').parse(timeString); // 24-hour to DateTime
      return DateFormat('hh:mm a').format(parsedTime); // Convert to 12-hour with AM/PM
    } catch (e) {
      return '-';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green.shade700;
      case 'CONFIRMED':
        return Colors.blue.shade700;
      case 'PENDING':
        return Colors.orange.shade700;
      case 'CANCELLED':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}
