import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../modules/appointment/controller/appointment_controller.dart';
import '../widgets/custom_list_page2.dart';

enum PatientStatusOption {
  CONTINUE,
  ALTERNATE,
  DISCONTINUE,
  WEEKLY,
  DISCHARGE,
  OBSERVATION,
  ALL,
}

class PatientsPage extends StatelessWidget {
  PatientsPage({super.key});

  final controller = Get.put(AppointmentController());
  final TextEditingController searchController = TextEditingController();

  String formatRange(DateTime from, DateTime to) {
    final f = DateFormat('dd MMM yyyy');
    return '${f.format(from)} - ${f.format(to)}';
  }

  // --- Show Patient Status BottomSheet ---
  void _showStatusSelectionBottomSheet(BuildContext context) {
    final options = PatientStatusOption.values;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (context, setState) {
            // temp list to hold selection inside bottom sheet
            final selectedStatuses = List<String>.from(controller.currentFilterStatus);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...options.map((statusOption) {
                  final statusText = statusOption.name;
                  final isSelected = selectedStatuses.contains(statusText);
                  return CheckboxListTile(
                    title: Text(statusText),
                    value: selectedStatuses.contains(statusText),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          if (!selectedStatuses.contains(statusText)) selectedStatuses.add(statusText);
                        } else {
                          selectedStatuses.remove(statusText);
                        }
                      });
                    },
                  );
                }).toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        controller.currentFilterStatus.assignAll(selectedStatuses);
                        Navigator.pop(context);
                        controller.fetchPatients(); // Trigger API after selection
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }


  // --- Show Date Range BottomSheet ---
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
                Navigator.pop(context);
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
                    controller.customFrom.value = from;
                    controller.customTo.value = to;
                    controller.currentFilterDateRange.value = DateRangeOption.custom;
                  }
                } else {
                  controller.currentFilterDateRange.value = option;
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _fetchPatients() async {
    await controller.fetchPatients();
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
        appBarTitle: 'Patients',
        isLoading: controller.isLoadingPatients.value,
        showInitialMessage:
        controller.patients.isEmpty && !controller.isLoadingPatients.value,
        itemCount: controller.patients.length,
        itemBuilder: (context, index) {
          final patient = controller.patients[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${patient.firstname ?? ''} ${patient.lastname ?? ''}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('Patient Email	: ${patient.email ?? ''}'),
                  Text('Patient Phone	: ${patient.phone ?? ''}'),
                  Text(
                      'Patient Address: ${patient.address ?? ''}, ${patient.city ?? ''}, ${patient.state ?? ''}, ${patient.country ?? ''}'),
                  Text('Status: ${patient.patientStatus ?? ''}'),
                  Text('Visit Count: ${patient.visitCount ?? ''}'),
                  Text('Total Appointments: ${patient.totalAppointments ?? 0}'),
                  Text('Patient Status: ${patient.patientStatus ?? 0}'),
                ],
              ),
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
            ? 'All'
            : controller.currentFilterStatus.join(', '),
        selectedDateRangeText: controller.currentFilterDateRange.value.name
            .capitalize ??
            'Select Range',
        formattedDateRange:
        formatRange(controller.fromDate, controller.toDate),
        searchController: searchController,
      ),
    );
  }
}
