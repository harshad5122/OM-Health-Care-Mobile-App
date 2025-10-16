import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/models/patients_model.dart';
import '../modules/appointment/controller/appointment_controller.dart';
import '../widgets/custom_list_page.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final controller = Get.put(AppointmentController());

  @override
  void dispose() {
    Get.delete<AppointmentController>();
    super.dispose();
  }

  String formatRange(DateTime from, DateTime to) {
    final f = DateFormat('dd MMM yyyy');
    return '${f.format(from)} - ${f.format(to)}';
  }

  // The logic for showing bottom sheets stays here because it's tied to this specific controller
  void _showDoctorSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Obx(() => controller.doctors.isEmpty
            ? const Center(child: Text("No doctors found."))
            : ListView.builder(
          itemCount: controller.doctors.length,
          itemBuilder: (context, index) {
            final doc = controller.doctors[index];
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
    // The build method is now very simple. It just provides data to the common widget.
    return Obx(() => CustomListPage(
      appBarTitle: 'Appointments',
      isLoading: controller.isLoadingPatients.value,
      // Show the initial message if the patient list is empty AND no search has been performed
      showInitialMessage: controller.patients.isEmpty && controller.selectedDoctor.value == null,
      itemCount: controller.patients.length,
      onSearch: () {
        if (controller.selectedDoctor.value == null) {
          Get.snackbar(
            'Validation Error',
            'Please select a doctor before searching.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          controller.fetchPatients();
        }
      },
      onClear: controller.clearFiltersAndPatients,
      onSelectDoctor: () => _showDoctorSelectionBottomSheet(context),
      onSelectDateRange: () => _showDateRangeSelectionBottomSheet(context),
      selectedDoctorText: controller.selectedDoctor.value != null
          ? "${controller.selectedDoctor.value!.firstname} ${controller.selectedDoctor.value!.lastname}"
          : "",
      selectedDateRangeText: controller.dateRangeOption.value.toString().split('.').last.replaceAll('this', 'This '),
      formattedDateRange: formatRange(controller.fromDate, controller.toDate),

      // THIS IS THE PART THAT IS UNIQUE TO THE APPOINTMENTS PAGE
      itemBuilder: (context, index) {
        final PatientModel p = controller.patients[index];
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
                  Text('Patient Name: ${p.fullName}',
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Email: ${p.email}'),
                  Text('Phone: ${p.phone}'),
                  Text('Address: ${p.address}'),
                  Text('Visit Count: ${p.visitCount}'),
                  Text('Total Appointments: ${p.totalAppointments}'),
                  if (p.patientStatus != '')
                    Text('Patient Status: ${p.patientStatus}')
                ]),
          ),
        );
      },
    ));
  }
}