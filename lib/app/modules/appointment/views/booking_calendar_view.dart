
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  CalendarView _calendarView = CalendarView.month;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppointmentController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setSelectedStaff(widget.doctor.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Appointment Date")),
      body: Column(
        children: [
          _buildViewSelectionButtons(),
          Expanded(
            child: Obx(() {
              return SfCalendar(
                view: _calendarView,
                dataSource: AppointmentDataSource(controller.allDayAppointments.toList()),
                initialSelectedDate: controller.selectedDate.value,
                // --- FIX STARTS HERE ---
                monthViewSettings: _calendarView == CalendarView.month
                    ? MonthViewSettings(
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
                )
                    : const MonthViewSettings(), // Provide a default/empty MonthViewSettings object

                // monthViewSettings: MonthViewSettings(
                //   appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                //   showAgenda: false,
                //   appointmentDisplayCount: AppointmentController.maxAppointmentsPerDayDisplay,
                // ),

                // --- FIX ENDS HERE ---
                timeSlotViewSettings: _calendarView == CalendarView.week || _calendarView == CalendarView.day
                    ? const TimeSlotViewSettings(
                  startHour: 9,
                  endHour: 18,
                  timeIntervalHeight: 60,
                  timeInterval: Duration(minutes: 60),
                  dateFormat: 'd',
                  dayFormat: 'EEE',
                )
                    : const TimeSlotViewSettings(), // Provide a default/empty TimeSlotViewSettings object for month view
                appointmentTextStyle: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                onSelectionChanged: (CalendarSelectionDetails details) {
                  if (details.date != null) {
                    controller.selectedDate.value = details.date!;
                    controller.clearAppointmentSelection();
                  }
                },
                monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                  final bool isPastDate = details.date.isBefore(
                    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: isPastDate ? Colors.grey.shade200 : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        '${details.date.day}',
                        style: TextStyle(
                          color: isPastDate ? Colors.grey : Colors.black,
                          fontWeight: details.date.day == DateTime.now().day &&
                              details.date.month == DateTime.now().month &&
                              details.date.year == DateTime.now().year
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },


                onTap: (CalendarTapDetails details) {
                  if (details.date != null &&
                      !details.date!.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
                    if (details.appointments != null && details.appointments!.isNotEmpty) {
                      final CalendarAppointment tappedAppointment =
                      details.appointments!.first as CalendarAppointment;
                      controller.selectedDate.value = tappedAppointment.from;
                      controller.selectExistingAppointment(tappedAppointment);
                      Get.dialog(BookAppointmentCustomDialog(
                        controller: controller,
                        isEdit: true,
                      ));
                    } else {
                      controller.selectedDate.value = details.date!;
                      controller.clearAppointmentSelection();
                      Get.dialog(BookAppointmentCustomDialog(
                        controller: controller,
                        isEdit: false,
                      ));
                    }
                  }
                },
                // onTap: (CalendarTapDetails details) {
                //   if (details.appointments != null && details.appointments!.isNotEmpty) {
                //     final CalendarAppointment tappedAppointment = details.appointments!.first as CalendarAppointment;
                //     controller.selectedDate.value = tappedAppointment.from;
                //     controller.selectExistingAppointment(tappedAppointment);
                //     Get.dialog(BookAppointmentCustomDialog(
                //       controller: controller,
                //       isEdit: true,
                //     ));
                //   } else if (details.date != null) {
                //     controller.selectedDate.value = details.date!;
                //     controller.clearAppointmentSelection();
                //     Get.dialog(BookAppointmentCustomDialog(
                //       controller: controller,
                //       isEdit: false,
                //     ));
                //   }
                // },
                onViewChanged: (ViewChangedDetails details) {
                  if (details.visibleDates.isNotEmpty) {
                    DateTime newDisplayDate = details.visibleDates[details.visibleDates.length ~/ 2];
                    if (controller.selectedDate.value.month != newDisplayDate.month ||
                        controller.selectedDate.value.year != newDisplayDate.year) {
                      controller.selectedDate.value = newDisplayDate;
                    }
                  }
                },
              );
            }),
          ),
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

  Widget _buildViewSelectionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SegmentedButton<CalendarView>(
        segments: const <ButtonSegment<CalendarView>>[
          ButtonSegment<CalendarView>(
            value: CalendarView.month,
            label: Text('Month'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment<CalendarView>(
            value: CalendarView.week,
            label: Text('Week'),
            icon: Icon(Icons.calendar_view_week),
          ),
          ButtonSegment<CalendarView>(
            value: CalendarView.day,
            label: Text('Day'),
            icon: Icon(Icons.calendar_view_day),
          ),
        ],
        selected: <CalendarView>{_calendarView},
        onSelectionChanged: (Set<CalendarView> newSelection) {
          setState(() {
            _calendarView = newSelection.first;
            _updateAppointmentsForCurrentView();
          });
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: Get.theme.primaryColor,
          selectedForegroundColor: Colors.white,
        ),
      ),
    );
  }

  void _updateAppointmentsForCurrentView() {
    controller.selectedDate.refresh();
  }
}