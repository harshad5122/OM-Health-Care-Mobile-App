//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:calendar_view/calendar_view.dart';
//
// import '../../../data/models/staff_list_model.dart';
// import '../../../data/models/appointment_model.dart';
// import '../controller/appointment_controller.dart';
// import '../widgets/book_appointment_custom_dialog.dart';
//
// enum MyCalendarViewType { month, week, day }
//
// class BookingCalenderView extends StatefulWidget {
//   final StaffListModel doctor;
//
//   const BookingCalenderView({super.key, required this.doctor});
//
//   @override
//   State<BookingCalenderView> createState() => _BookingCalenderViewState();
// }
//
// class _BookingCalenderViewState extends State<BookingCalenderView> {
//   late final AppointmentController controller;
//
//   MyCalendarViewType _calendarView = MyCalendarViewType.month;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.find<AppointmentController>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.setSelectedStaff(widget.doctor.id ?? '');
//     });
//   }
//
//   // ---------- Calendar view switcher ----------
//   Widget _buildCalendarViewWidget() {
//     switch (_calendarView) {
//       case MyCalendarViewType.month:
//         return MonthView<CalendarAppointment>(
//           controller: controller.eventController,
//           // MonthView.onEventTap provides List<CalendarEventData<T>>
//           onEventTap: (events, date) {
//             print('enter this tap event');
//             // _handleEventTapList(events, date);
//             _handleEventTapSingle(events, date);
//           },
//           // MonthView.onCellTap provides List<CalendarEventData<T>>
//           onCellTap: (events, date) {
//             print('enter this tap cell');
//             _handleDateTap(date, []);
//           },
//
//           cellBuilder: (date, events, isToday, isInMonth, hideDaysNotInMonth) {
//             final now = DateTime.now();
//             final today = DateTime(now.year, now.month, now.day);
//
//             // The first visible month in the grid (depends on navigation)
//             final currentVisibleMonth = date.month;
//
//             // Determine if this cell belongs to the visible month
//             final isCurrentMonthCell = isInMonth;
//             bool isDisabled = false;
//             if (!isCurrentMonthCell) {
//               // Always disable days from prev/next month
//               isDisabled = true;
//             } else if (date.month == today.month && date.year == today.year) {
//               // Current month → disable only past dates
//               if (date.isBefore(today)) {
//                 isDisabled = true;
//               }
//             } else {
//               // Future months → all days inside month enabled
//               isDisabled = false;
//             }
//             final isPastDate = date.isBefore(
//               DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
//             );
//
//             // Filter events for this specific cell that belong to the current month
//             final relevantEvents = events.where((event) => event.date.month == date.month).toList();
//             const int maxDisplayedEvents = 2;
//             final List<CalendarEventData<CalendarAppointment>> eventsToDisplay = relevantEvents.take(maxDisplayedEvents).toList();
//             final int remainingEventsCount = relevantEvents.length - eventsToDisplay.length;
//
//             return Container(
//               decoration: BoxDecoration(
//                 color: (isDisabled || isPastDate)  ? Colors.grey.shade200 : Colors.white,
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Column(
//                 children: [
//                   Align(
//                     alignment: Alignment.topCenter,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
//                       child: Text(
//                         '${date.day}',
//                         style: TextStyle(
//                           color: isDisabled && isPastDate ? Colors.grey : Colors.black,
//                           fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Display events
//                   // if (!isDisabled)
//                   Expanded(
//                     child: SingleChildScrollView( // Make events scrollable if too many
//                       physics: const NeverScrollableScrollPhysics(), // Prevent dialog scrolling
//                       child: Column(
//
//                         children: [
//                           ...eventsToDisplay.map((event) {
//                             return Container(
//                               margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
//                               padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
//                               decoration: BoxDecoration(
//                                 color: event.color,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 event.title, // Display the title from CalendarEventData
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 8, // Smaller font for month view
//                                   overflow: TextOverflow.ellipsis, // Handle long titles
//                                 ),
//                                 maxLines: 1,
//                               ),
//                             );
//                           }).toList(),
//                           if (remainingEventsCount > 0)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 2.0),
//                               child: Text(
//                                 '+${remainingEventsCount} more',
//                                 style: TextStyle(
//                                   color: Colors.grey.shade700,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//
//       case MyCalendarViewType.week:
//         return WeekView<CalendarAppointment>(
//           controller: controller.eventController,
//           // WeekView.onEventTap provides a single CalendarEventData<T>
//           onEventTap: (event, date) { // 'event' here is single, not a list
//             // _handleEventTapSingle(event, date);
//             _handleEventTapList(event, date);
//           },
//           onDateTap: (date) {
//             _handleDateTap(date, []);
//           },
//           onDateLongPress: (date) {
//             _handleDateTap(date, []); // No events involved in this type of tap
//           },
//           eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
//             final event = events.isNotEmpty ? events.first : null;
//
//             if (event == null) return const SizedBox.shrink();
//
//             return Container(
//               decoration: BoxDecoration(
//                 color: event.color, // 🔹 Event background color
//                 borderRadius: BorderRadius.circular(8), // 🔹 Rounded corners
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 2), // 🔹 Padding inside the event box
//               child: Center(
//                 child: Text(
//                   event.title,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white, // 🔹 Text color
//                     overflow: TextOverflow.clip,
//                   ),
//                 ),
//               ),
//             );
//           },
//
//         );
//
//       case MyCalendarViewType.day:
//         return DayView<CalendarAppointment>(
//           controller: controller.eventController,
//           // DayView.onEventTap provides a single CalendarEventData<T>
//           onEventTap: (event, date) { // 'event' here is single, not a list
//             // _handleEventTapSingle(event, date);
//             _handleEventTapList(event, date);
//           },
//           onDateTap: (date) {
//             _handleDateTap(date, []);
//           },
//           onDateLongPress: (date) {
//             _handleDateTap(date, []); // No events involved in this type of tap
//           },
//           eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
//             final event = events.isNotEmpty ? events.first : null;
//
//             if (event == null) return const SizedBox.shrink();
//
//             return Container(
//               decoration: BoxDecoration(
//                 color: event.color, // 🔹 Event background color
//                 borderRadius: BorderRadius.circular(8), // 🔹 Rounded corners
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 2), // 🔹 Padding inside the event box
//               child: Center(
//                 child: Text(
//                   event.title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white, // 🔹 Text color
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//
//       default:
//       // Fallback
//         return MonthView<CalendarAppointment>(
//           controller: controller.eventController,
//           onEventTap: (events, date) {
//             // _handleEventTapList(events, date);
//             _handleEventTapSingle(events, date);
//           },
//           onCellTap: (events, date) {
//             _handleDateTap(date, events);
//           },
//         );
//     }
//   }
//
//   // ---------- Helpers ----------
//
//   // New helper for when a single event is tapped (WeekView, DayView)
//   void _handleEventTapSingle(CalendarEventData<CalendarAppointment> eventData, DateTime date) {
//     if (eventData.event != null) {
//       final CalendarAppointment tappedAppointment = eventData.event!;
//       controller.selectedDate.value = date;
//       controller.selectExistingAppointment(tappedAppointment);
//
//       // Get.dialog(BookAppointmentCustomDialog(
//       //   controller: controller,
//       //   isEdit: true,
//       // ));
//       Get.bottomSheet( // Changed from Get.dialog
//         BookAppointmentCustomDialog(
//           controller: controller,
//           isEdit: true,
//         ),
//         isScrollControlled: true, // Allows the bottom sheet to take full height if needed
//         backgroundColor: Colors.white, // Set a background color for the bottom sheet
//         shape: const RoundedRectangleBorder( // Optional: Add rounded corners
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//       );
//     }
//   }
//
//   // Existing helper for when a list of events is provided (MonthView)
//   void _handleEventTapList(List<CalendarEventData<CalendarAppointment>> events, DateTime date) {
//     if (events.isNotEmpty) {
//       final CalendarAppointment tappedAppointment = events.first.event!;
//       controller.selectedDate.value = date;
//       controller.selectExistingAppointment(tappedAppointment);
//
//       // Get.dialog(BookAppointmentCustomDialog(
//       //   controller: controller,
//       //   isEdit: true,
//       // ));
//       Get.bottomSheet( // Changed from Get.dialog
//         BookAppointmentCustomDialog(
//           controller: controller,
//           isEdit: true,
//         ),
//         isScrollControlled: true, // Allows the bottom sheet to take full height if needed
//         backgroundColor: Colors.white, // Set a background color for the bottom sheet
//         shape: const RoundedRectangleBorder( // Optional: Add rounded corners
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//       );
//     }
//   }
//
//   void _handleDateTap(DateTime date, List<CalendarEventData<CalendarAppointment>> events) {
//     // don’t allow past date selection
//     if (date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
//       return;
//     }
//
//     // This handles taps on empty cells/background
//     controller.selectedDate.value = date;
//     controller.clearAppointmentSelection();
//
//     // Get.dialog(BookAppointmentCustomDialog(
//     //   controller: controller,
//     //   isEdit: false,
//     // ));
//     Get.bottomSheet( // Changed from Get.dialog
//       BookAppointmentCustomDialog(
//         controller: controller,
//         isEdit: false,
//       ),
//       isScrollControlled: true, // Allows the bottom sheet to take full height if needed
//       backgroundColor: Colors.white, // Set a background color for the bottom sheet
//       shape: const RoundedRectangleBorder( // Optional: Add rounded corners
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//     );
//   }
//
//   // ---------- Build ----------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Choose Appointment Date")),
//       body: Column(
//         children: [
//           _buildViewSelectionButtons(),
//           Expanded(
//             child: CalendarControllerProvider<CalendarAppointment>(
//               controller: controller.eventController,
//               child:
//                 _buildCalendarViewWidget(),
//
//             ),
//           ),
//           Obx(() => controller.isLoading.value
//               ? const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: CircularProgressIndicator(),
//           )
//               : const SizedBox.shrink()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildViewSelectionButtons() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: SegmentedButton<MyCalendarViewType>(
//         segments: const <ButtonSegment<MyCalendarViewType>>[
//           ButtonSegment<MyCalendarViewType>(
//             value: MyCalendarViewType.month,
//             label: Text('Month'),
//             icon: Icon(Icons.calendar_view_month),
//           ),
//           ButtonSegment<MyCalendarViewType>(
//             value: MyCalendarViewType.week,
//             label: Text('Week'),
//             icon: Icon(Icons.calendar_view_week),
//           ),
//           ButtonSegment<MyCalendarViewType>(
//             value: MyCalendarViewType.day,
//             label: Text('Day'),
//             icon: Icon(Icons.calendar_view_day),
//           ),
//         ],
//         selected: <MyCalendarViewType>{_calendarView},
//         onSelectionChanged: (Set<MyCalendarViewType> newSelection) {
//           setState(() {
//             _calendarView = newSelection.first;
//             _updateAppointmentsForCurrentView();
//           });
//         },
//         style: SegmentedButton.styleFrom(
//           selectedBackgroundColor: Get.theme.primaryColor,
//           selectedForegroundColor: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   void _updateAppointmentsForCurrentView() {
//     controller.selectedDate.refresh(); // trigger worker in controller
//   }
// }











import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../data/models/staff_list_model.dart';
import '../../../data/models/appointment_model.dart';
import '../controller/appointment_controller.dart';
import '../widgets/book_appointment_custom_dialog.dart';

class BookingCalenderView extends StatefulWidget {
  final StaffListModel doctor;

  const BookingCalenderView({super.key, required this.doctor});

  @override
  State<BookingCalenderView> createState() => _BookingCalenderViewState();
}

class _BookingCalenderViewState extends State<BookingCalenderView> {
  late final AppointmentController controller;

  /// Selected date shown on calendar / bottom list
  DateTime _selectedDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppointmentController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setSelectedStaff(widget.doctor.id ?? '');
      // If your controller stores currently selected date, keep it in sync:
      controller.selectedDate.value = _selectedDate;
    });
  }

  List<Appointment> _buildSfAppointments() {
    final List<Appointment> result = [];

    // ✅ Ensure we work with a normal list
    final List<AppointmentModel> appts = controller.appointments.toList();
    if (appts.isEmpty) return [];

    try {
      for (final a in appts) {
        DateTime start = DateTime.now();
        DateTime end = DateTime.now().add(const Duration(hours: 1));

        if (a.date != null && a.timeSlot != null) {
          try {
            final parsedDate = DateTime.tryParse(a.date!);
            if (parsedDate != null) {
              final startParts = a.timeSlot!.start?.split(':') ?? ['0', '0'];
              final endParts = a.timeSlot!.end?.split(':') ?? ['0', '0'];

              final startHour = int.tryParse(startParts[0]) ?? 0;
              final startMin = int.tryParse(startParts[1]) ?? 0;
              final endHour = int.tryParse(endParts[0]) ?? 0;
              final endMin = int.tryParse(endParts[1]) ?? 0;

              start = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, startHour, startMin);
              end = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, endHour, endMin);
            }
          } catch (e) {
            debugPrint('Error parsing date/time: $e');
          }
        }

        final subject = a.patientName ?? a.visitType ?? "Appointment";
        final color = _getColorForStatus(a.status);

        result.add(
          Appointment(
            startTime: start,
            endTime: end,
            subject: subject,
            color: color,
            notes: jsonEncode(a.toJson()), // store original model
          ),
        );
      }
    } catch (e) {
      debugPrint('Error mapping appointments for SfCalendar: $e');
    }

    return result;
  }

  /// Helper to assign color by status
  Color _getColorForStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }

  /// Filter appointments for a particular day (date has no time)
  List<Appointment> _appointmentsForDay(DateTime date, List<Appointment> all) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return all.where((a) {
      return a.startTime.isBefore(endOfDay) && a.endTime.isAfter(startOfDay);
    }).toList();
  }


  void _openBookingBottomSheet(BuildContext context, AppointmentController controller,
      {CalendarAppointment? existingAppointment}) {
    // If editing an existing appointment
    if (existingAppointment != null) {
      controller.selectExistingAppointment(existingAppointment);
    } else {
      controller.clearAppointmentSelection();
    }

    Get.bottomSheet(
      BookAppointmentCustomDialog(
        controller: controller,
        isEdit: existingAppointment != null,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBottomEventList(AppointmentController controller) {
    return Obx(() {
      if (controller.bookedSlots.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No appointments for this day.",
            style: TextStyle(fontSize: 14),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        itemCount: controller.bookedSlots.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final event = controller.bookedSlots[index];

          // Determine background color based on type/status
          Color bgColor;
          Color textColor = Colors.white;
          if (event.type == 'booked') {
            if (event.status == 'COMPLETED') {
              bgColor = Get.theme.primaryColor;
            } else if (event.status == 'CONFIRMED') {
              bgColor = Colors.green.shade600;
            } else {
              bgColor = Colors.grey.shade600;
            }
          } else if (event.type == 'leave') {
            bgColor = Colors.blueGrey.shade600;
          } else {
            bgColor = Colors.red.shade400;
          }

          return ListTile(
            tileColor: bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              event.title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "${event.start} - ${event.end}",
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
            ),
            onTap: () {
              // Optional: open booking bottom sheet to edit this appointment
              _openBookingBottomSheet(context, controller, existingAppointment: CalendarAppointment(
                  date: controller.selectedDate.value,
                appointmentId: event.id,
                patientId: event.patientId,
                visitType: event.visitType,
                startTime: DateFormat('HH:mm').parse(event.start ?? '00:00'),
                endTime: DateFormat('HH:mm').parse(event.end ?? '00:00'),
                title: event.title,

              ));
            },
          );
        },
      );
    });
  }


  /// Custom month cell builder: day number, dots for appointments, highlight selected date
  Widget _monthCellBuilder(BuildContext context, MonthCellDetails details) {
    final DateTime date = details.date;
    final bool isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final bool isSelected = date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    // Build dots based on appointments count for that day
    final allAppointments = _buildSfAppointments();
    final dayAppts = _appointmentsForDay(date, allAppointments);
    // show up to 3 dots with their colors
    final dots = dayAppts.take(3).map((a) => a.color ?? Colors.blue).toList();

    return GestureDetector(
      onTap: () {
        // Ignore taps on days outside current month? syncfusion passes details
        setState(() {
          _selectedDate = DateTime(date.year, date.month, date.day);
        });
        controller.selectedDate.value = _selectedDate;
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.12) : Colors.transparent,
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  // color: (details.isDateOutsideMonth || date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)))
                  //     ? Colors.grey
                  //     : Colors.black,
                  color: (details.date.month != details.visibleDates[10].month ||
                      date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)))
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),
            const Spacer(),
            // Dots row
            if (dots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dots
                      .map((c) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ))
                      .toList(),
                ),
              ),
            if (dayAppts.length > 3)
              Text('+${dayAppts.length - 3}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build appointments list reactively on each build. If your controller has reactive lists,
    // you may prefer to use Obx to rebuild only when needed.
    final allAppointments = _buildSfAppointments();
    final selectedDayAppointments = _appointmentsForDay(_selectedDate, allAppointments);

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Appointment Date")),
      body: Column(
        children: [
          // Calendar month view
          SizedBox(
            height: 420, // adjust to match screenshot's area
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: _AppointmentDataSource(allAppointments),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                showAgenda: false,
                // custom cell builder to show dots and selected highlight
              ),
              monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                return _monthCellBuilder(context, details);
              },
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell ||
                    details.targetElement == CalendarElement.appointment) {
                  final DateTime tappedDate = details.date ?? DateTime.now();
                  setState(() {
                    _selectedDate = DateTime(tappedDate.year, tappedDate.month, tappedDate.day);
                  });
                  controller.selectedDate.value = _selectedDate;

                  // If an appointment was tapped (Syncfusion returns appointments in args)
                  if (details.appointments != null && details.appointments!.isNotEmpty) {
                    final Appointment first = details.appointments!.first as Appointment;
                    final original = first.notes; // original model stored
                    // select and open bottomsheet in edit mode
                    // _openBookingBottomSheet(originalAppointmentModel: original, isEdit: true);
                    _openBookingBottomSheet(
                      context,
                      controller,
                      existingAppointment: CalendarAppointment(
                        appointmentId: original != null ? jsonDecode(original)['id'] : '',
                        patientId: original != null ? jsonDecode(original)['patientId'] : '',
                        visitType: original != null ? jsonDecode(original)['visitType'] : '',
                        startTime: original != null
                            ? DateFormat('HH:mm').parse(jsonDecode(original)['start'])
                            : DateTime.now(),
                        endTime: original != null
                            ? DateFormat('HH:mm').parse(jsonDecode(original)['end'])
                            : DateTime.now().add(const Duration(hours: 1)),
                        title: original != null ? jsonDecode(original)['title'] : 'Appointment',
                        date: (original != null && jsonDecode(original)['date'] != null)
                            ? DateTime.parse(jsonDecode(original)['date'])
                            : DateTime.now(),
                      ),
                    );
                  }
                }
              },
              // optional: month cell border and header customization
              headerHeight: 60,
              todayHighlightColor: Get.theme.primaryColor,
              showDatePickerButton: false,
            ),
          ),

          // Selected date indicator + bottom list
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Get.theme.primaryColor,
                  child: Text(
                    '${_selectedDate.day}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weekdayString(_selectedDate)}, ${_monthDayString(_selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text('${selectedDayAppointments.length} appointments'),
                  ],
                ),
              ],
            ),
          ),

          // Bottom list - scrollable
          Expanded(
            child: SingleChildScrollView(
              child: _buildBottomEventList(controller),
            ),
          ),

          // Loading indicator from controller if present
          Obx(() => controller.isLoading.value
              ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  String _weekdayString(DateTime d) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
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
class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
