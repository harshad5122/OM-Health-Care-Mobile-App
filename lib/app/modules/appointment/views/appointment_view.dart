
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/staff_list_model.dart';
import '../controller/appointment_controller.dart';
import 'booking_calendar_view.dart';

class AppointmentView extends StatelessWidget {
  const AppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.doctors.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.doctors.isEmpty) {
                return const Center(child: Text("No doctors available"));
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchDoctors(clear: true),
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.doctors.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < controller.doctors.length) {
                      final StaffListModel doctor = controller.doctors[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dr. ${doctor.firstname ?? ''} ${doctor.lastname ?? ''}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                doctor.specialization ?? "No specialization",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey[700]),
                              ),
                              if (doctor.workExperienceLastHospital != null)
                                Text(
                                  doctor.workExperienceLastHospital!,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              if (doctor.address != null || doctor.phone != null)
                                Text(
                                  "${doctor.address ?? ''} - ${doctor.phone ?? ''}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.selectedStaffId.value = doctor.id ?? "";
                                    Get.to(() =>
                                        BookingCalenderView(doctor: doctor));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Get.theme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                  ),
                                  child: const Text(
                                    'Book Appointment',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}



