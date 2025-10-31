import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../modules/appointment/controller/appointment_controller.dart'; // Ensure DateRangeOption is correctly defined here or in a global file

class DateSelectorController extends GetxController {
  final selectedDateLabel = "This month".obs;
  final dateRanges = <Map<String, String>>[].obs;
  final isCustomDatePickerOpen = false.obs;

  final customStartDate = Rxn<DateTime>();
  final customEndDate = Rxn<DateTime>();

  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  final selectedDateRangeOption = DateRangeOption.thisMonth.obs;
  final selectedFromDate = Rxn<DateTime>();
  final selectedToDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    generateDateRanges();
    _updateSelectedDatesBasedOnLabel(selectedDateLabel.value);
  }

  void generateDateRanges() {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    // Removed calculation for lastWeekStart and lastWeekEnd as 'Last week' is removed

    dateRanges.assignAll([
      {
        'label': 'This month',
        'range': '${_formatDate(DateTime(now.year, now.month, 1))} - ${_formatDate(now)}',
        'option': DateRangeOption.thisMonth.name,
      },
      {
        'label': 'Last month',
        'range': '${_formatDate(DateTime(now.year, now.month - 1, 1))} - ${_formatDate(DateTime(now.year, now.month, 0))}', // End of last month
        'option': DateRangeOption.lastMonth.name,
      },
      {
        'label': 'This week',
        'range': '${_formatDate(thisWeekStart)} - ${_formatDate(now)}',
        'option': DateRangeOption.thisWeek.name,
      },
      {
        'label': 'Custom date range',
        'range': '${_formatDate(now.subtract(Duration(days: 30)))} - ${_formatDate(now)}', // Default for custom
        'option': DateRangeOption.custom.name,
      },
    ]);
  }

  void selectDateLabel(String label) {
    selectedDateLabel.value = label;
    _updateSelectedDatesBasedOnLabel(label);

    if (label == 'Custom date range') {
      toggleCustomDatePicker(true);
    } else {
      toggleCustomDatePicker(false); // Hide custom picker if another option is chosen
    }
  }

  void _updateSelectedDatesBasedOnLabel(String label) {
    final now = DateTime.now();
    DateTime from;
    DateTime to;
    DateRangeOption option;

    switch (label) {
      case 'This week':
        from = now.subtract(Duration(days: now.weekday - 1));
        to = now;
        option = DateRangeOption.thisWeek;
        break;
    // Removed 'Last Month' case from here, as you only want 'Last month' and 'Last week' is removed
      case 'This month':
        from = DateTime(now.year, now.month, 1);
        to = now;
        option = DateRangeOption.thisMonth;
        break;
      case 'Last month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        from = lastMonth;
        to = DateTime(lastMonth.year, lastMonth.month + 1, 0); // End of last month
        option = DateRangeOption.lastMonth;
        break;
      case 'Custom date range':
      // For custom, the dates are set directly by the picker
      // If no custom dates are selected yet, default to a sensible range
        from = customStartDate.value ?? now.subtract(Duration(days: 30));
        to = customEndDate.value ?? now;
        option = DateRangeOption.custom;
        break;
      default:
        from = DateTime(now.year, now.month, 1); // Default to this month
        to = now;
        option = DateRangeOption.thisMonth;
    }

    selectedFromDate.value = from;
    selectedToDate.value = to;
    selectedDateRangeOption.value = option;

    // Update customStartDate/EndDate if selecting a predefined range
    // This ensures consistency if the user then switches to custom
    customStartDate.value = selectedFromDate.value;
    customEndDate.value = selectedToDate.value;

    // Update the 'range' display for custom if it's currently selected
    if (label == 'Custom date range') {
      updateCustomDateRange();
    }
  }

  void toggleCustomDatePicker(bool open) {
    isCustomDatePickerOpen.value = open;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void updateCustomDateRange() {
    // Update selectedFromDate and selectedToDate based on custom picker values
    // This is crucial for the AppointmentController to get the correct custom dates
    selectedFromDate.value = customStartDate.value;
    selectedToDate.value = customEndDate.value;
    selectedDateRangeOption.value = DateRangeOption.custom;

    final formattedStart = customStartDate.value != null
        ? _formatDate(customStartDate.value!)
        : '';
    final formattedEnd = customEndDate.value != null
        ? _formatDate(customEndDate.value!)
        : '';

    final range = '$formattedStart - $formattedEnd';

    final customDateRangeIndex = dateRanges.indexWhere(
          (element) => element['label'] == 'Custom date range',
    );
    if (customDateRangeIndex != -1) {
      dateRanges[customDateRangeIndex]['range'] = range;
      dateRanges.refresh();
    }
  }

  void resetSelection() {
    isCustomDatePickerOpen.value = false;
    // Keeping this commented as per your previous code, but typically you'd reset to a default.
    // _updateSelectedDatesBasedOnLabel("This month");
  }
}