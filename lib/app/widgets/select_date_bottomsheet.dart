import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../data/controllers/date_selector_controller.dart';
import '../modules/appointment/controller/appointment_controller.dart';


class SelectDateBottomSheet extends StatelessWidget {
  final DateSelectorController dateSelectorController = Get.put(DateSelectorController());
  // final AppointmentController appointmentController = Get.find<AppointmentController>(); // Get the existing instance
  final Function(DateRangeOption, DateTime?, DateTime?) onDateRangeSelected;
  final VoidCallback? onFetchData;

  // SelectDateBottomSheet({super.key}); // Added key for good practice
  SelectDateBottomSheet({
    super.key,
    required this.onDateRangeSelected,
    this.onFetchData, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.6,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select date",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Get.theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: dateSelectorController.dateRanges.length,
                        itemBuilder: (context, index) {
                          final dateRange = dateSelectorController.dateRanges[index];
                          final bool isCustom = dateRange['label'] == 'Custom date range';

                          return Column(
                            children: [
                              Obx(() {
                                return ListTile(
                                  title: Text(dateRange['label']!),
                                  subtitle: Text(dateRange['range']!),
                                  trailing:
                                  dateSelectorController.selectedDateLabel.value == dateRange['label']
                                      ?  Icon(Icons.check, color: Get.theme.primaryColor)
                                      : null,
                                  onTap: () {
                                    dateSelectorController.selectDateLabel(dateRange['label']!);
                                    if (!isCustom) {
                                      // Only close if it's not custom, custom handles its own closing via 'Done' button
                                      // and will update appointmentController before closing.
                                      // Let's ensure the AppointmentController is updated before closing for non-custom.
                                      _triggerDateRangeSelectedCallback();
                                      // _updateAppointmentControllerDates();
                                      Get.back();
                                    }
                                  },
                                );
                              }),
                              if (isCustom)
                                Obx(() {
                                  return dateSelectorController.isCustomDatePickerOpen.value
                                      ? _buildCustomDatePicker(context)
                                      : const SizedBox();
                                }),
                            ],
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomDatePicker(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      // Use dateSelectorController for custom dates
      DateTime displayDate = dateSelectorController.customStartDate.value ?? DateTime.now();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SfDateRangePicker(
              initialDisplayDate: displayDate,
              backgroundColor: theme.scaffoldBackgroundColor,
              todayHighlightColor: theme.hintColor,
              selectionColor: Colors.green,
              rangeSelectionColor: theme.focusColor,
              startRangeSelectionColor: theme.primaryColor,
              endRangeSelectionColor: theme.primaryColor,
              headerStyle: DateRangePickerHeaderStyle(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                dateSelectorController.customStartDate.value, // Use custom dates
                dateSelectorController.customEndDate.value,   // Use custom dates
              ),
              minDate: DateTime(2000),
              maxDate: DateTime.now(), // Max date should probably be today or a future date for appointments
              monthCellStyle: const DateRangePickerMonthCellStyle(
                todayTextStyle: TextStyle(color: Colors.black),
                blackoutDateTextStyle: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  final PickerDateRange range = args.value;
                  // Update dateSelectorController's custom dates
                  dateSelectorController.customStartDate.value = range.startDate;
                  dateSelectorController.customEndDate.value = range.endDate;
                  dateSelectorController.updateCustomDateRange(); // This also updates selectedFrom/ToDate
                }
              }),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: dateSelectorController.customStartDate.value != null
                        ? DateFormat('MMM dd, yyyy').format(dateSelectorController.customStartDate.value!)
                        : '',
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today),
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: dateSelectorController.customEndDate.value != null
                        ? DateFormat('MMM dd, yyyy').format(dateSelectorController.customEndDate.value!)
                        : '',
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today),
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      if (dateSelectorController.selectedFromDate.value != null &&
                          dateSelectorController.selectedToDate.value != null) {
                        // When "Done" is pressed for custom date range, update the AppointmentController
                        _triggerDateRangeSelectedCallback();
                        //_updateAppointmentControllerDates();
                        Get.back(); // Close the bottom sheet
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                        backgroundColor: Get.theme.primaryColor),
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
            ),
          ),
        ],
      );
    });
  }

  // New method to update AppointmentController's filter dates
  // void _updateAppointmentControllerDates() {
  //   appointmentController.currentFilterDateRange.value = dateSelectorController.selectedDateRangeOption.value;
  //   appointmentController.filterFromDate.value = dateSelectorController.selectedFromDate.value;
  //   appointmentController.filterToDate.value = dateSelectorController.selectedToDate.value;
  //  // appointmentController.fetchPatientAppointments(); // Fetch new appointments with the selected range
  // }
  void _triggerDateRangeSelectedCallback() {
    onDateRangeSelected(
      dateSelectorController.selectedDateRangeOption.value,
      dateSelectorController.selectedFromDate.value,
      dateSelectorController.selectedToDate.value,
    );
    onFetchData?.call(); // Call the optional fetch callback
  }
}