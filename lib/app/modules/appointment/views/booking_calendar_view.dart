//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:om_health_care_app/app/global/global.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart'; // Only Syncfusion
// import '../../../data/models/staff_list_model.dart';
// import '../../../data/models/appointment_model.dart';
// import '../controller/appointment_controller.dart';
// import '../widgets/book_appointment_custom_dialog.dart';
//
// class BookingCalenderView extends StatefulWidget {
//   final StaffListModel? doctor;
//
//   const BookingCalenderView({super.key, this.doctor});
//
//   @override
//   State<BookingCalenderView> createState() => _BookingCalenderViewState();
// }
//
// class _BookingCalenderViewState extends State<BookingCalenderView> {
//   late final AppointmentController controller;
//   StaffListModel? selectedDoctor;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(AppointmentController());
//
//     controller.isLoading.value = false;
//     controller.isLoadingPatients.value = false;
//
//     final doctorArg = Get.arguments?["doctor"];
//     if (doctorArg != null && doctorArg is StaffListModel) {
//       selectedDoctor = doctorArg;
//     } else {
//       selectedDoctor = widget.doctor;
//     }
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async{
//       final String staffIdToLoad;
//       if (Global.role == 3) {
//         staffIdToLoad = Global.staffId ?? '';
//       } else {
//         staffIdToLoad =selectedDoctor?.id ?? '';
//       }
//
//       print("BookingCalenderView: Loading staff ID: $staffIdToLoad for Role: ${Global.role}");
//       if (staffIdToLoad.isNotEmpty) {
//         print('enter hereeeeee');
//         await controller.setSelectedStaff(staffIdToLoad);
//       } else {
//         print("Error: No Staff ID found to load appointments.");
//       }
//     });
//   }
//
//   /// Filter Syncfusion appointments for a particular day (date has no time)
//   List<Appointment> _sfAppointmentsForDay(DateTime date, List<Appointment> allSfAppointments) {
//
//     return allSfAppointments.where((a) {
//
//       return a.startTime.year == date.year &&
//           a.startTime.month == date.month &&
//           a.startTime.day == date.day;
//     }).toList();
//   }
//
//   void _openBookingBottomSheet(BuildContext context, AppointmentController controller,
//       {Appointment? existingSfAppointment}) {
//     if (existingSfAppointment != null && existingSfAppointment.notes != null) {
//       // Reconstruct CalendarAppointment from Syncfusion Appointment notes for your dialog
//       final AppointmentModel originalApptModel = AppointmentModel.fromJson(jsonDecode(existingSfAppointment.notes!));
//
//       print('Parsed originalApptModel appointmentId: ${originalApptModel.appointmentId}');
//
//
//       final CalendarAppointment tempCalendarAppt = CalendarAppointment(
//         date: existingSfAppointment.startTime, // Use startTime for the date
//         startTime: existingSfAppointment.startTime,
//         endTime: existingSfAppointment.endTime,
//         title: existingSfAppointment.subject,
//         color: existingSfAppointment.color,
//         appointmentId: originalApptModel.appointmentId,
//         patientId: originalApptModel.patientId,
//         visitType: originalApptModel.visitType,
//         patientName: originalApptModel.patientName,
//         status: originalApptModel.status,
//         type: originalApptModel.visitType == 'leave' ? 'leave' : 'booked', // Adjust type if needed
//       );
//
//       print('tempCalendarAppt appointmentId: ${tempCalendarAppt.appointmentId}');
//       controller.selectExistingAppointment(tempCalendarAppt);
//     } else {
//       controller.clearAppointmentSelection();
//     }
//
//     Get.bottomSheet(
//       BookAppointmentCustomDialog(
//         controller: controller,
//         isEdit: existingSfAppointment != null,
//       ),
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       backgroundColor: Colors.white,
//     );
//   }
//
//   Widget _buildBottomEventList(AppointmentController controller) {
//     return Obx(() {
//       if (controller.isLoading.value && controller.bookedSlots.isEmpty) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       if (controller.bookedSlots.isEmpty) {
//         return const Padding(
//           padding: EdgeInsets.all(16),
//           child: Text(
//             "No appointments for this day.",
//             style: TextStyle(fontSize: 14),
//           ),
//         );
//       }
//
//       return ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(), // Important for nested scroll
//         itemCount: controller.bookedSlots.length,
//         separatorBuilder: (_, __) => const Divider(height: 1),
//         itemBuilder: (context, index) {
//           final event = controller.bookedSlots[index];
//
//           Color bgColor;
//           Color textColor = Colors.white;
//           if (event.type == 'booked') {
//             if (event.status == 'COMPLETED') {
//               bgColor = Get.theme.primaryColor;
//             } else if (event.status == 'CONFIRMED') {
//               bgColor = Colors.green.shade600;
//             } else if (event.status == 'PENDING') {
//               bgColor = Colors.orange.shade400;
//             } else {
//               bgColor = Colors.grey.shade600;
//             }
//           } else if (event.type == 'leave') {
//             bgColor = Colors.blueGrey.shade600;
//           } else {
//             bgColor = Colors.red.shade400; // Fallback for unknown type
//           }
//
//           return ListTile(
//             tileColor: bgColor,
//             shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             title: Text(
//               event.title,
//               style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
//             ),
//             subtitle: Text(
//               // "${event.start} - ${event.end}",
//               "${controller.formatTimeForDisplay(event.start)} - ${controller.formatTimeForDisplay(event.end)}",
//               style:
//               TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
//             ),
//             onTap: () {
//
//               final Appointment sfAppointmentForDialog = Appointment(
//                 startTime: DateFormat('HH:mm').parse(event.start)
//                     .copyWith(year: controller.selectedDate.value.year, month: controller.selectedDate.value.month, day: controller.selectedDate.value.day),
//                 endTime: DateFormat('HH:mm').parse(event.end)
//                     .copyWith(year: controller.selectedDate.value.year, month: controller.selectedDate.value.month, day: controller.selectedDate.value.day),
//                 subject: event.title,
//                 color: bgColor, // Use the determined background color
//                 notes: jsonEncode(AppointmentModel(
//                   appointmentId: event.id,
//                   patientId: event.patientId,
//                   patientName: event.patientName,
//                   visitType: event.visitType,
//                   date: DateFormat('yyyy-MM-dd').format(controller.selectedDate.value),
//                   timeSlot: TimeSlot(start: event.start, end: event.end),
//                   status: event.status,
//                   staffId: controller.selectedStaffId.value,
//                 ).toJson()),
//               );
//
//               _openBookingBottomSheet(context, controller, existingSfAppointment: sfAppointmentForDialog);
//             },
//           );
//         },
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(Global.role == 3
//             ? "My Schedule"
//             : (widget.doctor?.firstname ?? "Doctor's") + " Schedule"),
//       ),
//       body: Column(
//         children: [
//
//           SizedBox(
//             height: 420,
//             child: Obx(() {
//
//               final List<Appointment> allSfAppointments = controller.sfCalendarAppointments.toList();
//
//               return SfCalendar(
//                 view: CalendarView.month,
//                 dataSource: AppointmentDataSource(allSfAppointments),
//                 monthViewSettings: const MonthViewSettings(
//                   appointmentDisplayMode: MonthAppointmentDisplayMode.none,
//                   showAgenda: false,
//                 ),
//                 onViewChanged: (ViewChangedDetails details) {
//                   final DateTime middleDate = details.visibleDates[details.visibleDates.length ~/ 2];
//                   controller.onMonthChanged(middleDate);
//                 },
//                 monthCellBuilder: (BuildContext context, MonthCellDetails details) {
//                   final eventsForDate = _sfAppointmentsForDay(details.date, allSfAppointments);
//                   final bool isSelectedDate = isSameDay(details.date, controller.selectedDate.value);
//
//                   final bool isPastDate = details.date.isBefore(DateTime(
//                       DateTime.now().year, DateTime.now().month, DateTime.now().day));
//
//
//
//                   return Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!, width: 0.5),
//                       color: isSelectedDate ? Get.theme.primaryColor.withOpacity(0.2) : null,
//                     ),
//                     child: Stack(
//                       children: [
//                         Positioned(
//                           top: 5,
//                           right: 5,
//                           child: Text(
//                             '${details.date.day}',
//                             style: TextStyle(
//                               color: details.date.month == controller.selectedDate.value.month
//                                   ? (isPastDate ? Colors.grey : Colors.black)
//                                   : Colors.grey,
//                             ),
//                           ),
//                         ),
//                         if (eventsForDate.isNotEmpty)
//                           Positioned(
//                             bottom: 5,
//                             left: 0,
//                             right: 0,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: eventsForDate.take(3).map((sfAppointment) {
//                                 Color dotColor = Colors.blue;
//                                 if (sfAppointment.notes != null) {
//                                   final AppointmentModel apptModel = AppointmentModel.fromJson(jsonDecode(sfAppointment.notes!));
//                                   if (apptModel.status == 'leave' || apptModel.visitType == 'leave') {
//                                     dotColor = Colors.grey;
//                                   } else if (apptModel.status == 'CONFIRMED') {
//                                     dotColor = Colors.green;
//                                   } else if (apptModel.status == 'PENDING') {
//                                     dotColor = Colors.orange;
//                                   } else if (apptModel.status == 'COMPLETED') {
//                                     dotColor = Get.theme.primaryColor;
//                                   }
//                                 }
//                                 return Container(
//                                   width: 5,
//                                   height: 5,
//                                   margin: const EdgeInsets.symmetric(horizontal: 1),
//                                   decoration: BoxDecoration(
//                                     color: dotColor,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//                 onTap: (CalendarTapDetails details) {
//                   if (details.targetElement == CalendarElement.calendarCell) {
//                     final DateTime tappedDate = details.date ?? DateTime.now();
//                     controller.selectedDate.value =
//                         DateTime(tappedDate.year, tappedDate.month, tappedDate.day);
//                   } else if (details.targetElement == CalendarElement.appointment) {
//                     final Appointment sfAppointment = details.appointments!.first as Appointment;
//                     _openBookingBottomSheet(context, controller, existingSfAppointment: sfAppointment);
//                   }
//                 },
//                 headerHeight: 60,
//                 todayHighlightColor: Get.theme.primaryColor,
//                 showDatePickerButton: false,
//               );
//             }),
//           ),
//
//
//           // Selected date indicator + bottom list
//           Obx(() {
//             final List<Appointment> allSfAppointments = controller.sfCalendarAppointments;
//             final selectedDaySfAppointments = _sfAppointmentsForDay(
//                 controller.selectedDate.value, allSfAppointments);
//
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Get.theme.primaryColor,
//                     child: Text(
//                       '${controller.selectedDate.value.day}',
//                       style: const TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${_weekdayString(controller.selectedDate.value)}, ${_monthDayString(controller.selectedDate.value)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 2),
//                       Text('${selectedDaySfAppointments.length} appointments'),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           }),
//
//           Expanded(
//             child: SingleChildScrollView(
//               child: _buildBottomEventList(controller),
//             ),
//           ),
//
//           Obx(() => controller.isLoading.value
//               ? const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: CircularProgressIndicator(),
//           )
//               : const SizedBox.shrink()),
//         ],
//       ),
//       floatingActionButton: Obx(() => (controller.isPastSelectedDate.value)
//     ? const SizedBox.shrink() // If selected date is in the past, hide the FAB
//         :
//     FloatingActionButton(
//         onPressed: () {
//           // Open the booking bottom sheet for a new appointment
//           _openBookingBottomSheet(context, controller);
//         },
//         child: const Icon(Icons.add),
//       ),
//       ),
//     );
//   }
//
//   bool isSameDay(DateTime dateA, DateTime dateB) {
//     return dateA.year == dateB.year &&
//         dateA.month == dateB.month &&
//         dateA.day == dateB.day;
//   }
//
//   String _weekdayString(DateTime d) {
//     const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//     return names[d.weekday % 7];
//   }
//
//   String _monthDayString(DateTime d) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return '${months[d.month - 1]} ${d.day}';
//   }
// }
//
// /// Simple CalendarDataSource wrapper for sfcalendar
// class AppointmentDataSource extends CalendarDataSource {
//   AppointmentDataSource(List<Appointment> source) {
//     appointments = source;
//   }
//
//   @override
//   DateTime getStartTime(int index) {
//     return appointments![index].startTime;
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     return appointments![index].endTime;
//   }
//
//   @override
//   String getSubject(int index) {
//     return appointments![index].subject;
//   }
//
//   @override
//   Color getColor(int index) {
//     return appointments![index].color;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return appointments![index].isAllDay;
//   }
// }
//
//





import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/global/global.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../data/models/staff_list_model.dart';
import '../../../data/models/appointment_model.dart';
import '../controller/appointment_controller.dart';
import '../widgets/book_appointment_custom_dialog.dart';

class BookingCalenderView extends StatefulWidget {
  final StaffListModel? doctor;

  const BookingCalenderView({super.key, this.doctor});

  @override
  State<BookingCalenderView> createState() => _BookingCalenderViewState();
}

class _BookingCalenderViewState extends State<BookingCalenderView> {
  late final AppointmentController controller;
  StaffListModel? selectedDoctor;
  // ADDED: CalendarController to control navigation and get the currently displayed month
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(AppointmentController());

    controller.isLoading.value = false;
    controller.isLoadingPatients.value = false;

    final doctorArg = Get.arguments?["doctor"];
    if (doctorArg != null && doctorArg is StaffListModel) {
      selectedDoctor = doctorArg;
    } else {
      selectedDoctor = widget.doctor;
    }

    // Set initial display date for the calendar controller
    _calendarController.displayDate = controller.selectedDate.value;

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final String staffIdToLoad;
      if (Global.role == 3) {
        staffIdToLoad = Global.staffId ?? '';
      } else {
        staffIdToLoad =selectedDoctor?.id ?? '';
      }

      print("BookingCalenderView: Loading staff ID: $staffIdToLoad for Role: ${Global.role}");
      if (staffIdToLoad.isNotEmpty) {
        print('enter hereeeeee');
        await controller.setSelectedStaff(staffIdToLoad);
      } else {
        print("Error: No Staff ID found to load appointments.");
      }
    });
  }

  /// Filter Syncfusion appointments for a particular day (date has no time)
  List<Appointment> _sfAppointmentsForDay(DateTime date, List<Appointment> allSfAppointments) {
    return allSfAppointments.where((a) {
      return a.startTime.year == date.year &&
          a.startTime.month == date.month &&
          a.startTime.day == date.day;
    }).toList();
  }

  void _openBookingBottomSheet(BuildContext context, AppointmentController controller,
      {Appointment? existingSfAppointment}) {
    if (existingSfAppointment != null && existingSfAppointment.notes != null) {
      // Reconstruct CalendarAppointment from Syncfusion Appointment notes for your dialog
      final AppointmentModel originalApptModel = AppointmentModel.fromJson(jsonDecode(existingSfAppointment.notes!));

      print('Parsed originalApptModel appointmentId: ${originalApptModel.appointmentId}');


      final CalendarAppointment tempCalendarAppt = CalendarAppointment(
        date: existingSfAppointment.startTime, // Use startTime for the date
        startTime: existingSfAppointment.startTime,
        endTime: existingSfAppointment.endTime,
        title: existingSfAppointment.subject,
        color: existingSfAppointment.color,
        appointmentId: originalApptModel.appointmentId,
        patientId: originalApptModel.patientId,
        visitType: originalApptModel.visitType,
        patientName: originalApptModel.patientName,
        status: originalApptModel.status,
        type: originalApptModel.visitType == 'leave' ? 'leave' : 'booked', // Adjust type if needed
      );

      print('tempCalendarAppt appointmentId: ${tempCalendarAppt.appointmentId}');
      controller.selectExistingAppointment(tempCalendarAppt);
    } else {
      controller.clearAppointmentSelection();
    }

    Get.bottomSheet(
      BookAppointmentCustomDialog(
        controller: controller,
        isEdit: existingSfAppointment != null,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
    );
  }

  // NEW: Helper method to handle the tap on the redesigned appointment card
  void _onAppointmentCardTap(CalendarAppointment event, AppointmentController controller, DateTime eventDateTime) {

    final String startTimeStr = DateFormat('HH:mm').format(event.startTime);
    final String endTimeStr = DateFormat('HH:mm').format(event.endTime);

    final Appointment sfAppointmentForDialog = Appointment(
      // startTime: DateFormat('HH:mm').parse(event.start)
      //     .copyWith(year: eventDateTime.year, month: eventDateTime.month, day: eventDateTime.day),
      // endTime: DateFormat('HH:mm').parse(event.end)
      //     .copyWith(year: eventDateTime.year, month: eventDateTime.month, day: eventDateTime.day),
      startTime: event.startTime,
      endTime: event.endTime,
      subject: event.title,
      color: Colors.transparent, // Color is not relevant for dialog open, but needed
      notes: jsonEncode(AppointmentModel(
        appointmentId: event.appointmentId,
        patientId: event.patientId,
        patientName: event.patientName,
        visitType: event.visitType,
        date: DateFormat('yyyy-MM-dd').format(eventDateTime),
        // timeSlot: TimeSlot(start: event.start, end: event.end),
        timeSlot: TimeSlot(start: startTimeStr, end: endTimeStr),
        status: event.status,
        staffId: controller.selectedStaffId.value,
      ).toJson()),
    );

    _openBookingBottomSheet(context, controller, existingSfAppointment: sfAppointmentForDialog);
  }

  // REDESIGNED: _buildBottomEventList to use card layout
  Widget _buildBottomEventList(AppointmentController controller) {
    return Obx(() {
      if (controller.bookedSlots.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "No appointments found for ${DateFormat('MMMM dd, yyyy').format(controller.selectedDate.value)}.",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.bookedSlots.length,
        itemBuilder: (context, index) {
          final event = controller.bookedSlots[index];

          Color dateBgColor;

          // Determine the color based on the status/type for the date box
          if (event.type == 'booked') {
            if (event.status == 'COMPLETED') {
              dateBgColor = Colors.lightBlue.shade100; // Light blue/teal for completed
            } else if (event.status == 'CONFIRMED') {
              dateBgColor = Colors.green.shade100; // Light green for confirmed
            } else if (event.status == 'PENDING') {
              dateBgColor = Colors.yellow.shade100; // Light yellow/amber for pending
            } else {
              dateBgColor = Colors.grey.shade300; // Fallback
            }
          } else if (event.type == 'leave') {
            dateBgColor = Colors.blueGrey.shade100; // Light blue-grey for leave
          } else {
            dateBgColor = Colors.red.shade100; // Fallback for unknown type
          }
          const Color dateTextColor = Colors.black87;

          // Recreate the full event date from selectedDate and the time
          // final DateTime eventDateTime = DateFormat('HH:mm').parse(event.start)
          //     .copyWith(year: controller.selectedDate.value.year, month: controller.selectedDate.value.month, day: controller.selectedDate.value.day);
          final DateTime selectedDate = controller.selectedDate.value;
          DateTime eventStartTime;
          DateTime eventEndTime;
          try {
            final startParts = event.start.split(':');
            eventStartTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(startParts[0]), int.parse(startParts[1]));

            final endParts = event.end.split(':');
            eventEndTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(endParts[0]), int.parse(endParts[1]));

          } catch (_) {
            eventStartTime = selectedDate;
            eventEndTime = selectedDate.add(const Duration(minutes: 30));
          }
          final DateTime eventDateTime = eventStartTime;

          return GestureDetector(
            // onTap: () {
            //   // Tap on the whole card opens the edit dialog
            //   // _onAppointmentCardTap(event, controller, eventDateTime);
            //   final CalendarAppointment calendarAppt = CalendarAppointment.fromEvent(event, controller.selectedDate.value);
            //   _onAppointmentCardTap(calendarAppt, controller, eventDateTime);
            // },
            onTap: () {

              final Appointment sfAppointmentForDialog = Appointment(
                startTime: DateFormat('HH:mm').parse(event.start)
                    .copyWith(year: controller.selectedDate.value.year, month: controller.selectedDate.value.month, day: controller.selectedDate.value.day),
                endTime: DateFormat('HH:mm').parse(event.end)
                    .copyWith(year: controller.selectedDate.value.year, month: controller.selectedDate.value.month, day: controller.selectedDate.value.day),
                subject: event.title,
                // color: bgColor, // Use the determined background color
                color: Colors.transparent,
                notes: jsonEncode(AppointmentModel(
                  appointmentId: event.id,
                  patientId: event.patientId,
                  patientName: event.patientName,
                  visitType: event.visitType,
                  date: DateFormat('yyyy-MM-dd').format(controller.selectedDate.value),
                  timeSlot: TimeSlot(start: event.start, end: event.end),
                  status: event.status,
                  staffId: controller.selectedStaffId.value,
                ).toJson()),
              );

              _openBookingBottomSheet(context, controller, existingSfAppointment: sfAppointmentForDialog);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Colored Date/Day Block (e.g., '12 Tue')
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: dateBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${eventDateTime.day}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: dateTextColor),
                        ),
                        Text(
                          _weekdayString(eventDateTime),
                          style: TextStyle(fontSize: 12, color: dateTextColor.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Center Patient Info (Name and Phone)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.type == "booked" ? event.patientName??'' : event.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Text(
                        //   ' ${event.type ?? ''}', // Patient ID used as a placeholder for phone number
                        //   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        // ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50, // Light blue background for time
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            // FIX: Format the calculated DateTime to match the "12.30 pm" look.
                            '${DateFormat('h:mm a').format(eventStartTime)} - ${DateFormat('h:mm a').format(eventEndTime)}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Get.theme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right Time and Options
                  // Row(
                  //   children: [
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //       decoration: BoxDecoration(
                  //         color: Colors.blue.shade50, // Light blue background for time
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       child: Text(
                  //         // FIX: Format the calculated DateTime to match the "12.30 pm" look.
                  //         DateFormat('h:mm a').format(eventStartTime),
                  //         style: TextStyle(
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w500,
                  //             color: Get.theme.primaryColor),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 4),
                  //     // const Icon(Icons.more_vert, color: Colors.grey, size: 24),
                  //     // The more_vert icon is visual only, the whole card is clickable
                  //   ],
                  // ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // NEW: Custom Calendar Header Widget
  Widget _buildCustomCalendarHeader(BuildContext context) {
    // Uses Obx to re-render the month/year when the displayDate changes

      final DateTime displayDate = _calendarController.displayDate ?? controller.selectedDate.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(displayDate).toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 24, color: Colors.black87),
                  onPressed: () {
                    _calendarController.backward!();
                    // Manually trigger month change logic if needed
                    if (_calendarController.displayDate != null) {
                      controller.onMonthChanged(_calendarController.displayDate!);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 24, color: Colors.black87),
                  onPressed: () {
                    _calendarController.forward!();
                    // Manually trigger month change logic if needed
                    if (_calendarController.displayDate != null) {
                      controller.onMonthChanged(_calendarController.displayDate!);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(Global.role == 3
            ? "My Schedule"
            : (widget.doctor?.firstname ?? "Doctor's") + " Schedule"),
      ),
      body: Column(
        children: [

          // REDESIGNED Calendar Section
          SizedBox(
            height: 380, // Reduced height to fit the custom header better
            child: Obx(() {

              final List<Appointment> allSfAppointments = controller.sfCalendarAppointments.toList();

              return Column(
                children: [
                  _buildCustomCalendarHeader(context), // Custom Header (matches image)

                  // SfCalendar
                  Expanded(
                    child: SfCalendar(
                      controller: _calendarController, // ADDED: Controller
                      view: CalendarView.month,
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.grey,
                ),

              ///            backgroundColor: Colors.blue,
              ///            dayTextStyle: TextStyle(color: Colors.grey, fontSize: 20),
              ///            dateTextStyle: TextStyle(color: Colors.grey, fontSize: 25)),
                  ),
                      dataSource: AppointmentDataSource(allSfAppointments),
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                        showAgenda: false,
                        dayFormat: 'EEE', // Show day names like MON, TUE etc.
                        numberOfWeeksInView: 6, // Ensure full month is visible
                        showTrailingAndLeadingDates: true,
                        // Custom style for day headers (Sun, Mon, Tue...)

                      ),
                      onViewChanged: (ViewChangedDetails details) {
                        final DateTime middleDate = details.visibleDates[details.visibleDates.length ~/ 2];
                        controller.onMonthChanged(middleDate);
                        // Update controller's display date for custom header refresh
                        _calendarController.displayDate = middleDate;
                      },
                      monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                        // All dots/indicators removed to match the clean UI of the image
                        final eventsForDate = _sfAppointmentsForDay(details.date, allSfAppointments);

                        final bool isSelectedDate = isSameDay(details.date, controller.selectedDate.value);
                        final bool isCurrentMonth = details.date.month == controller.selectedDate.value.month;

                        // NEW: Custom style to match the image's calendar grid look
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!, width: 0.5), // Subtle borders
                            color: Colors.white,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: isSelectedDate
                                      ? BoxDecoration(
                                    color: Colors.grey.shade200, // Blue circle for selected date (matches image)
                                    shape: BoxShape.circle,
                                  )
                                      : null,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${details.date.day}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelectedDate
                                          ? Colors.black87 // White text for selected date
                                          : isCurrentMonth
                                          ? Colors.black87 // Black for current month dates
                                          : Colors.grey, // Grey for outside dates
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              if (eventsForDate.isNotEmpty)
                                Positioned(
                                  bottom: 5,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: eventsForDate.take(3).map((sfAppointment) {
                                      Color dotColor = Colors.blue;
                                      if (sfAppointment.notes != null) {
                                        final AppointmentModel apptModel = AppointmentModel.fromJson(jsonDecode(sfAppointment.notes!));
                                        // Simplified color logic for dots
                                        if (apptModel.status == 'leave' || apptModel.visitType == 'leave') {
                                          dotColor = Colors.grey;
                                        } else if (apptModel.status == 'CONFIRMED') {
                                          dotColor = Colors.green;
                                        } else if (apptModel.status == 'PENDING') {
                                          dotColor = Colors.orange;
                                        } else if (apptModel.status == 'COMPLETED') {
                                          dotColor = Get.theme.primaryColor;
                                        }
                                      }
                                      return Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          color: dotColor,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),

                        );
                      },
                      onTap: (CalendarTapDetails details) {
                        if (details.targetElement == CalendarElement.calendarCell) {
                          final DateTime tappedDate = details.date ?? DateTime.now();
                          controller.selectedDate.value =
                              DateTime(tappedDate.year, tappedDate.month, tappedDate.day);
                          // Force calendar to re-render to update the blue circle
                          _calendarController.selectedDate = controller.selectedDate.value;
                        } else if (details.targetElement == CalendarElement.appointment) {
                          final Appointment sfAppointment = details.appointments!.first as Appointment;
                          _openBookingBottomSheet(context, controller, existingSfAppointment: sfAppointment);
                        }
                      },
                      headerHeight: 0, // HIDING the default header
                      todayHighlightColor: Colors.transparent,
                      showDatePickerButton: false,
                    ),
                  ),
                ],
              );
            }),
          ),


          // REDESIGNED Upcoming Appointments Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Upcoming Appointments" Header (matches image)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Appointments",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //     // Functionality remains the same, assuming 'See more' would open a full list
                      //     print('See more tapped');
                      //   },
                      //   style: TextButton.styleFrom(
                      //     padding: EdgeInsets.zero,
                      //     minimumSize: const Size(50, 30),
                      //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //   ),
                      //   child: Text("See more", style: TextStyle(color: Get.theme.primaryColor)),
                      // ),
                    ],
                  ),
                ),

                // Appointment List or Loading Indicator
                Obx(() => controller.isLoading.value && controller.bookedSlots.isEmpty
                    ? const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ))
                    : Expanded(
                  child: SingleChildScrollView(
                    child: _buildBottomEventList(controller), // Using the redesigned list builder
                  ),
                )
                ),
              ],
            ),
          ),
        ],
      ),

      // REDESIGNED Floating Action Button
      floatingActionButton: Obx(() => (controller.isPastSelectedDate.value)
          ? const SizedBox.shrink() // If selected date is in the past, hide the FAB
          :
      FloatingActionButton(
        onPressed: () {
          _openBookingBottomSheet(context, controller);
        },
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 28), // Add icon instead of "+"
      ),
      // FloatingActionButton.extended(
      //   onPressed: () {
      //     // Open the booking bottom sheet for a new appointment
      //     _openBookingBottomSheet(context, controller);
      //   },
      //   label: const Text(
      //     "+ Book Appointment",
      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //   ),
      //   icon: const SizedBox.shrink(),
      //   backgroundColor: Get.theme.primaryColor, // Use a solid blue color
      //   foregroundColor: Colors.white,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // ),
      ),
    );
  }

  bool isSameDay(DateTime dateA, DateTime dateB) {
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  String _weekdayString(DateTime d) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    // The DateTime.weekday returns 1 for Mon, ..., 7 for Sun. The array is 0-indexed starting with Sun.
    // d.weekday % 7 will be 1 for Mon, 2 for Tue, ..., 6 for Sat, 0 for Sun.
    // Need to adjust the index: (d.weekday) % 7 returns 1 for Mon, 0 for Sun. We want 0 for Sun, 1 for Mon.
    return names[d.weekday % 7];
  }

  String _monthDayString(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

/// Simple CalendarDataSource wrapper for sfcalendar
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}