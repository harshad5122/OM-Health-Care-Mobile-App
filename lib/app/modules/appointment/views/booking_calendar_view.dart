
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calendar_view/calendar_view.dart';

import '../../../data/models/staff_list_model.dart';
import '../../../data/models/appointment_model.dart';
import '../controller/appointment_controller.dart';
import '../widgets/book_appointment_custom_dialog.dart';

enum MyCalendarViewType { month, week, day }

class BookingCalenderView extends StatefulWidget {
  final StaffListModel doctor;

  const BookingCalenderView({super.key, required this.doctor});

  @override
  State<BookingCalenderView> createState() => _BookingCalenderViewState();
}

class _BookingCalenderViewState extends State<BookingCalenderView> {
  late final AppointmentController controller;

  MyCalendarViewType _calendarView = MyCalendarViewType.month;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppointmentController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setSelectedStaff(widget.doctor.id ?? '');
    });
  }

  // ---------- Calendar view switcher ----------
  Widget _buildCalendarViewWidget() {
    switch (_calendarView) {
      case MyCalendarViewType.month:
        return MonthView<CalendarAppointment>(
          controller: controller.eventController,
          // MonthView.onEventTap provides List<CalendarEventData<T>>
          onEventTap: (events, date) {
            print('enter this tap event');
            // _handleEventTapList(events, date);
            _handleEventTapSingle(events, date);
          },
          // MonthView.onCellTap provides List<CalendarEventData<T>>
          onCellTap: (events, date) {
            print('enter this tap cell');
            _handleDateTap(date, []);
          },

          cellBuilder: (date, events, isToday, isInMonth, hideDaysNotInMonth) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            // The first visible month in the grid (depends on navigation)
            final currentVisibleMonth = date.month;

            // Determine if this cell belongs to the visible month
            final isCurrentMonthCell = isInMonth;
            bool isDisabled = false;
            if (!isCurrentMonthCell) {
              // Always disable days from prev/next month
              isDisabled = true;
            } else if (date.month == today.month && date.year == today.year) {
              // Current month → disable only past dates
              if (date.isBefore(today)) {
                isDisabled = true;
              }
            } else {
              // Future months → all days inside month enabled
              isDisabled = false;
            }
            final isPastDate = date.isBefore(
              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
            );

            // Filter events for this specific cell that belong to the current month
            final relevantEvents = events.where((event) => event.date.month == date.month).toList();
            const int maxDisplayedEvents = 2;
            final List<CalendarEventData<CalendarAppointment>> eventsToDisplay = relevantEvents.take(maxDisplayedEvents).toList();
            final int remainingEventsCount = relevantEvents.length - eventsToDisplay.length;

            return Container(
              decoration: BoxDecoration(
                color: (isDisabled || isPastDate)  ? Colors.grey.shade200 : Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isDisabled && isPastDate ? Colors.grey : Colors.black,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Display events
                  // if (!isDisabled)
                  Expanded(
                    child: SingleChildScrollView( // Make events scrollable if too many
                      physics: const NeverScrollableScrollPhysics(), // Prevent dialog scrolling
                      child: Column(

                        children: [
                          ...eventsToDisplay.map((event) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: event.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                event.title, // Display the title from CalendarEventData
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8, // Smaller font for month view
                                  overflow: TextOverflow.ellipsis, // Handle long titles
                                ),
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          if (remainingEventsCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                '+${remainingEventsCount} more',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case MyCalendarViewType.week:
        return WeekView<CalendarAppointment>(
          controller: controller.eventController,
          // WeekView.onEventTap provides a single CalendarEventData<T>
          onEventTap: (event, date) { // 'event' here is single, not a list
            // _handleEventTapSingle(event, date);
            _handleEventTapList(event, date);
          },
          onDateTap: (date) {
            _handleDateTap(date, []);
          },
          onDateLongPress: (date) {
            _handleDateTap(date, []); // No events involved in this type of tap
          },
          eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
            final event = events.isNotEmpty ? events.first : null;

            if (event == null) return const SizedBox.shrink();

            return Container(
              decoration: BoxDecoration(
                color: event.color, // 🔹 Event background color
                borderRadius: BorderRadius.circular(8), // 🔹 Rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2), // 🔹 Padding inside the event box
              child: Center(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // 🔹 Text color
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            );
          },

        );

      case MyCalendarViewType.day:
        return DayView<CalendarAppointment>(
          controller: controller.eventController,
          // DayView.onEventTap provides a single CalendarEventData<T>
          onEventTap: (event, date) { // 'event' here is single, not a list
            // _handleEventTapSingle(event, date);
            _handleEventTapList(event, date);
          },
          onDateTap: (date) {
            _handleDateTap(date, []);
          },
          onDateLongPress: (date) {
            _handleDateTap(date, []); // No events involved in this type of tap
          },
          eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
            final event = events.isNotEmpty ? events.first : null;

            if (event == null) return const SizedBox.shrink();

            return Container(
              decoration: BoxDecoration(
                color: event.color, // 🔹 Event background color
                borderRadius: BorderRadius.circular(8), // 🔹 Rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2), // 🔹 Padding inside the event box
              child: Center(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // 🔹 Text color
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        );

      default:
      // Fallback
        return MonthView<CalendarAppointment>(
          controller: controller.eventController,
          onEventTap: (events, date) {
            // _handleEventTapList(events, date);
            _handleEventTapSingle(events, date);
          },
          onCellTap: (events, date) {
            _handleDateTap(date, events);
          },
        );
    }
  }

  // ---------- Helpers ----------

  // New helper for when a single event is tapped (WeekView, DayView)
  void _handleEventTapSingle(CalendarEventData<CalendarAppointment> eventData, DateTime date) {
    if (eventData.event != null) {
      final CalendarAppointment tappedAppointment = eventData.event!;
      controller.selectedDate.value = date;
      controller.selectExistingAppointment(tappedAppointment);

      // Get.dialog(BookAppointmentCustomDialog(
      //   controller: controller,
      //   isEdit: true,
      // ));
      Get.bottomSheet( // Changed from Get.dialog
        BookAppointmentCustomDialog(
          controller: controller,
          isEdit: true,
        ),
        isScrollControlled: true, // Allows the bottom sheet to take full height if needed
        backgroundColor: Colors.white, // Set a background color for the bottom sheet
        shape: const RoundedRectangleBorder( // Optional: Add rounded corners
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      );
    }
  }

  // Existing helper for when a list of events is provided (MonthView)
  void _handleEventTapList(List<CalendarEventData<CalendarAppointment>> events, DateTime date) {
    if (events.isNotEmpty) {
      final CalendarAppointment tappedAppointment = events.first.event!;
      controller.selectedDate.value = date;
      controller.selectExistingAppointment(tappedAppointment);

      // Get.dialog(BookAppointmentCustomDialog(
      //   controller: controller,
      //   isEdit: true,
      // ));
      Get.bottomSheet( // Changed from Get.dialog
        BookAppointmentCustomDialog(
          controller: controller,
          isEdit: true,
        ),
        isScrollControlled: true, // Allows the bottom sheet to take full height if needed
        backgroundColor: Colors.white, // Set a background color for the bottom sheet
        shape: const RoundedRectangleBorder( // Optional: Add rounded corners
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      );
    }
  }

  void _handleDateTap(DateTime date, List<CalendarEventData<CalendarAppointment>> events) {
    // don’t allow past date selection
    if (date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      return;
    }

    // This handles taps on empty cells/background
    controller.selectedDate.value = date;
    controller.clearAppointmentSelection();

    // Get.dialog(BookAppointmentCustomDialog(
    //   controller: controller,
    //   isEdit: false,
    // ));
    Get.bottomSheet( // Changed from Get.dialog
      BookAppointmentCustomDialog(
        controller: controller,
        isEdit: false,
      ),
      isScrollControlled: true, // Allows the bottom sheet to take full height if needed
      backgroundColor: Colors.white, // Set a background color for the bottom sheet
      shape: const RoundedRectangleBorder( // Optional: Add rounded corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Appointment Date")),
      body: Column(
        children: [
          _buildViewSelectionButtons(),
          Expanded(
            child: CalendarControllerProvider<CalendarAppointment>(
              controller: controller.eventController,
              child:
                _buildCalendarViewWidget(),

            ),
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
      child: SegmentedButton<MyCalendarViewType>(
        segments: const <ButtonSegment<MyCalendarViewType>>[
          ButtonSegment<MyCalendarViewType>(
            value: MyCalendarViewType.month,
            label: Text('Month'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment<MyCalendarViewType>(
            value: MyCalendarViewType.week,
            label: Text('Week'),
            icon: Icon(Icons.calendar_view_week),
          ),
          ButtonSegment<MyCalendarViewType>(
            value: MyCalendarViewType.day,
            label: Text('Day'),
            icon: Icon(Icons.calendar_view_day),
          ),
        ],
        selected: <MyCalendarViewType>{_calendarView},
        onSelectionChanged: (Set<MyCalendarViewType> newSelection) {
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
    controller.selectedDate.refresh(); // trigger worker in controller
  }
}
