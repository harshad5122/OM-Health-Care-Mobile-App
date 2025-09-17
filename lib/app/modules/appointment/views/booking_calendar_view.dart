// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../data/models/staff_list_model.dart';
// import '../controller/appointment_controller.dart';
// import '../widgets/book_appointment_custom_dialog.dart';
//
// class BookingCalenderView extends StatelessWidget {
//   final StaffListModel doctor;
//   const BookingCalenderView({super.key, required this.doctor});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AppointmentController());
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Choose Appointment Date")),
//       body: Column(
//         children: [
//           SizedBox(height: 8),
//           CalendarWidget(controller: controller),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.selectedDate.value.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
//                 Get.dialog(BookAppointmentCustomDialog(controller: controller));
//               }
//             },
//             child: Text("Book Appointment"),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // This widget builds the calendar grid view and disables past dates.
// class CalendarWidget extends StatelessWidget {
//   final AppointmentController controller;
//   const CalendarWidget({Key? key, required this.controller}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//       return CalendarDatePicker(
//         initialDate: DateTime.now(),
//         firstDate: DateTime.now(),
//         lastDate: DateTime(DateTime.now().year + 1),
//         onDateChanged: (date) {
//           controller.selectedDate.value = date;
//         },
//       );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:intl/intl.dart'; // For date formatting
//
// import '../../../data/models/staff_list_model.dart';
// import '../../../data/models/appointment_model.dart'; // Import DayAppointments and CalendarAppointment
// import '../controller/appointment_controller.dart';
// import '../widgets/book_appointment_custom_dialog.dart';
//
// class BookingCalenderView extends StatelessWidget {
//   final StaffListModel doctor;
//   const BookingCalenderView({super.key, required this.doctor});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AppointmentController());
//     controller.selectedStaffId.value = doctor.id ?? ''; // Set the doctor ID in the controller
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Choose Appointment Date")),
//       body: Column(
//         children: [
//           _buildDoctorInfo(doctor),
//           Expanded(
//             child: Obx(() {
//               return SfCalendar(
//                 view: CalendarView.month,
//                 dataSource: AppointmentDataSource(controller.allDayAppointments.toList()),
//                 initialSelectedDate: controller.selectedDate.value,
//                 monthViewSettings: const MonthViewSettings(
//                   appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
//                   showAgenda: true, // Shows appointments for the selected day below the calendar
//                   agendaStyle: AgendaStyle(
//                     backgroundColor: Color(0xFFF0F0F0),
//                     dayTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     dateTextStyle: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
//                   ),
//                 ),
//                 onSelectionChanged: (CalendarSelectionDetails details) {
//                   if (details.date != null) {
//                     controller.selectedDate.value = details.date!;
//                     controller.clearAppointmentSelection(); // Clear previous dialog selections
//                   }
//                 },
//                 onTap: (CalendarTapDetails details) {
//                   if (details.appointments != null && details.appointments!.isNotEmpty) {
//                     // Tapped on an existing appointment
//                     final CalendarAppointment tappedAppointment = details.appointments!.first as CalendarAppointment;
//                     controller.selectedDate.value = tappedAppointment.from; // Set selected date to appointment date
//                     controller.selectExistingAppointment(tappedAppointment);
//                     Get.dialog(BookAppointmentCustomDialog(
//                       controller: controller,
//                       isEdit: true,
//                     ));
//                   } else if (details.date != null) {
//                     // Tapped on a date without an existing appointment
//                     controller.selectedDate.value = details.date!;
//                     controller.clearAppointmentSelection();
//                     Get.dialog(BookAppointmentCustomDialog(
//                       controller: controller,
//                       isEdit: false,
//                     ));
//                   }
//                 },
//               );
//             }),
//           ),
//           Obx(() => controller.isLoading.value
//               ? const CircularProgressIndicator()
//               : const SizedBox.shrink()),
//           // The "Book Appointment" button is now handled by tapping a date or slot
//           // So this button can be removed or repurposed if needed.
//           // For now, I'm removing it as the dialog will open on tap.
//           // ElevatedButton(
//           //   onPressed: () {
//           //     if (controller.selectedDate.value.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
//           //       controller.clearAppointmentSelection();
//           //       Get.dialog(BookAppointmentCustomDialog(controller: controller));
//           //     }
//           //   },
//           //   child: Text("Book Appointment"),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDoctorInfo(StaffListModel doctor) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Dr. ${doctor.firstname ?? ''} ${doctor.lastname ?? ''}",
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             doctor.specialization ?? 'General Physician',
//             style: const TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           Text(
//             "${doctor.workExperienceTotalYears ?? 0} years experienced",
//             style: const TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//           // Add other doctor details as needed from your doctor object
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../data/models/staff_list_model.dart';
import '../../../data/models/appointment_model.dart'; // Import DayAppointments and CalendarAppointment
import '../controller/appointment_controller.dart';
import '../widgets/book_appointment_custom_dialog.dart';

class BookingCalenderView extends StatefulWidget {
  final StaffListModel doctor;
  const BookingCalenderView({super.key, required this.doctor});

  @override
  State<BookingCalenderView> createState() => _BookingCalenderViewState();
}

class _BookingCalenderViewState extends State<BookingCalenderView> {
  late AppointmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AppointmentController());

    // Defer assignment & fetching until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedStaffId.value = widget.doctor.id ?? '';
      controller.setSelectedStaff(widget.doctor.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(AppointmentController());
    // controller.selectedStaffId.value = widget.doctor.id ?? ''; // Set the doctor ID in the controller
    // controller.setSelectedStaff(widget.doctor.id ?? ''); // Ensure this triggers initial fetch

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Appointment Date")),
      body: Column(
        children: [
          // _buildDoctorInfo(doctor),
          Expanded(
            child: Obx(() {
              return SfCalendar(
                view: CalendarView.month,
                dataSource: AppointmentDataSource(controller.allDayAppointments.toList()),
                initialSelectedDate: controller.selectedDate.value,
                // Change MonthViewSettings for inline display
                // monthViewSettings: MonthViewSettings(
                //   // Display appointments directly within the date cells
                //   appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                //   // You can customize the style of the text for these appointments
                //   appointmentTextStyle: const TextStyle(
                //     fontSize: 12,
                //     color: Colors.white, // Or a color that contrasts with your appointment background
                //   ),
                //   // If you still want an agenda for selected dates, keep showAgenda true
                //   // But the primary request is to show them on the day cells.
                //   showAgenda: false, // Set to false if you only want inline events, true if you want both
                //   agendaStyle: const AgendaStyle(
                //     backgroundColor: Color(0xFFF0F0F0),
                //     dayTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                //     dateTextStyle: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                //   ),
                // ),
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                  showAgenda: false,
                  agendaStyle: const AgendaStyle(
                    backgroundColor: Color(0xFFF0F0F0),
                    dayTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    dateTextStyle: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                  ),
                  monthCellStyle: MonthCellStyle(
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ),

                onSelectionChanged: (CalendarSelectionDetails details) {
                  if (details.date != null) {
                    controller.selectedDate.value = details.date!;
                    controller.clearAppointmentSelection(); // Clear previous dialog selections
                  }
                },
                onTap: (CalendarTapDetails details) {
                  if (details.appointments != null && details.appointments!.isNotEmpty) {
                    // Tapped on an existing appointment
                    final CalendarAppointment tappedAppointment = details.appointments!.first as CalendarAppointment;
                    controller.selectedDate.value = tappedAppointment.from; // Set selected date to appointment date
                    controller.selectExistingAppointment(tappedAppointment);
                    Get.dialog(BookAppointmentCustomDialog(
                      controller: controller,
                      isEdit: true,
                    ));
                  } else if (details.date != null) {
                    // Tapped on a date without an existing appointment
                    controller.selectedDate.value = details.date!;
                    controller.clearAppointmentSelection();
                    Get.dialog(BookAppointmentCustomDialog(
                      controller: controller,
                      isEdit: false,
                    ));
                  }
                },
              );
            }),
          ),
          Obx(() => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo(StaffListModel doctor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dr. ${doctor.firstname ?? ''} ${doctor.lastname ?? ''}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            doctor.specialization ?? 'General Physician',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            "${doctor.workExperienceTotalYears ?? 0} years experienced",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
//
// import '../../../data/models/calendar_even_model.dart';
// import '../../../data/models/doctor_appointment_event_model.dart';
// import '../../../data/models/staff_list_model.dart';
// import '../controller/appointment_controller.dart';
// import '../widgets/book_appointment_custom_dialog.dart';

// class BookingCalenderView extends StatelessWidget {
//   final StaffListModel doctor;
//   const BookingCalenderView({super.key, required this.doctor});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AppointmentController());
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Choose Appointment Date")),
//       body: Obx(() {
//         final events = buildCalendarEvents(controller.appointmentDays);
//         return SfCalendar(
//           view: CalendarView.month,
//           dataSource: EventDataSource(events),
//           initialDisplayDate: DateTime.now(),
//           monthViewSettings: MonthViewSettings(
//             showAgenda: true,
//             agendaViewHeight: 200,
//             appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
//           ),
//           onTap: (CalendarTapDetails details) {
//             if(details.targetElement == CalendarElement.appointment) {
//               // Show details: appointment, type, status, etc
//               showDialog(context: context, builder: (_) => BookAppointmentCustomDialog(controller: controller));
//             }
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           Get.dialog(BookAppointmentCustomDialog(controller: controller));
//         },
//       ),
//     );
//   }
//
//   List<CalendarEvent> buildCalendarEvents(List<DoctorAppointmentDay> days) {
//     final List<CalendarEvent> events = [];
//     for (var day in days) {
//       for (var e in day.events) {
//         final start = DateTime.parse("${day.date}T${e.start}");
//         final end = DateTime.parse("${day.date}T${e.end}");
//         Color color;
//         if (e.type == "booked") color = Colors.orange;
//         else if (e.type == "leave") color = Colors.red;
//         else color = Colors.blue;
//
//         events.add(CalendarEvent(
//           eventName: e.title,
//           from: start,
//           to: end,
//           background: color,
//           isAllDay: false,
//           type: e.type,
//           status: e.status,
//           visitType: e.visitType,
//         ));
//       }
//       // Optionally add slots as events, color-coded differently
//     }
//     return events;
//   }
//
// }
