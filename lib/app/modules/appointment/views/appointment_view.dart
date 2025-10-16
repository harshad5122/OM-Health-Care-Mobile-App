//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../data/models/staff_list_model.dart';
// import '../controller/appointment_controller.dart';
// import 'booking_calendar_view.dart';
//
// class AppointmentView extends StatelessWidget {
//   const AppointmentView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AppointmentController());
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Book Appointment"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value && controller.doctors.isEmpty) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (controller.doctors.isEmpty) {
//                 return const Center(child: Text("No doctors available"));
//               }
//
//               return RefreshIndicator(
//                 onRefresh: () => controller.fetchDoctors(clear: true),
//                 child: ListView.builder(
//                   controller: controller.scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: controller.doctors.length +
//                       (controller.hasMore.value ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index < controller.doctors.length) {
//                       final StaffListModel doctor = controller.doctors[index];
//
//                       return Card(
//                         elevation: 3,
//                         margin: const EdgeInsets.symmetric(vertical: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Dr. ${doctor.firstname ?? ''} ${doctor.lastname ?? ''}",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Get.theme.primaryColor,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 doctor.specialization ?? "No specialization",
//                                 style: TextStyle(
//                                     fontSize: 15, color: Colors.grey[700]),
//                               ),
//                               if (doctor.workExperienceLastHospital != null)
//                                 Text(
//                                   doctor.workExperienceLastHospital!,
//                                   style: TextStyle(
//                                       fontSize: 14, color: Colors.grey[600]),
//                                 ),
//                               if (doctor.address != null || doctor.phone != null)
//                                 Text(
//                                   "${doctor.address ?? ''} - ${doctor.phone ?? ''}",
//                                   style: TextStyle(
//                                       fontSize: 14, color: Colors.grey[600]),
//                                 ),
//                               const SizedBox(height: 15),
//                               Align(
//                                 alignment: Alignment.bottomRight,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     controller.selectedStaffId.value = doctor.id ?? "";
//                                     Get.to(() =>
//                                         BookingCalenderView(doctor: doctor));
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Get.theme.primaryColor,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8)),
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 10),
//                                   ),
//                                   child: const Text(
//                                     'Book Appointment',
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 15),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     } else {
//                       return const Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Center(child: CircularProgressIndicator()),
//                       );
//                     }
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/staff_list_model.dart';
import '../controller/appointment_controller.dart';
import 'booking_calendar_view.dart';

class AppointmentView extends StatelessWidget {
  const AppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentController controller = Get.put(AppointmentController());

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
                              if (doctor.workExperienceTotalYears != null)
                                Text(
                                  "${doctor.workExperienceTotalYears!.toString()}  years experienced as a ${doctor.workExperiencePosition}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              if (doctor.qualification != null || doctor.gender != null)
                                Text(
                                  "${doctor.qualification ?? ''} - ${doctor.gender ?? ''}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              if (doctor.address != null || doctor.city != null || doctor.state != null || doctor.country != null || doctor.pincode != null )
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.0, right: 5),
                                      child: Icon(Icons.location_on, color: Colors.grey[600], size: 16,),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${doctor.address ?? ''} , ${doctor.city ?? ''} ${doctor.state ?? ''}, ${doctor.country ?? ''} - ${doctor.pincode ?? ''}",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              if (doctor.phone != null )
                                Wrap(
                                  children: [
                                    Icon(Icons.phone, color: Colors.grey[600], size: 16,),
                                    SizedBox(width: 5,),
                                    Text(
                                      "${doctor.phone ?? ''}",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              if (doctor.email != null)
                                Wrap(
                                  children: [
                                    Icon(Icons.email, color: Colors.grey[600], size: 16,),
                                    SizedBox(width: 5,),
                                    Text(
                                      "${doctor.email ?? ''}",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.setSelectedStaff(doctor.id ?? "");
                                    Get.to(() => BookingCalenderView(doctor: doctor));
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
