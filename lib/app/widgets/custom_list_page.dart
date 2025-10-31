import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomListPage extends StatelessWidget {
  final String appBarTitle;
  final bool isLoading;
  final bool showInitialMessage;
  final String noDataMessage;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  // Callbacks for buttons and fields
  final void Function()? onSearch;
  final void Function()? onClear;
  // final VoidCallback onSelectDoctor;
  final void Function()? onSelectDoctor;
  final VoidCallback onSelectDateRange;

  // Text values for display
  final String selectedDoctorText;
  final String selectedDateRangeText;
  final String formattedDateRange;
  final ScrollController? scrollController;

  const CustomListPage({
    super.key,
    required this.appBarTitle,
    required this.isLoading,
    required this.showInitialMessage,
    this.noDataMessage = 'No data found for the selected criteria',
    required this.itemCount,
    required this.itemBuilder,
    required this.onSearch,
    required this.onClear,
    required this.onSelectDoctor,
    required this.onSelectDateRange,
    required this.selectedDoctorText,
    required this.selectedDateRangeText,
    required this.formattedDateRange,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Filter section
              Row(
                children: [
          if (onSelectDoctor != null) ...[
                  Expanded(
                    child: TextFormField(
                      // Using a key forces the UI to rebuild the field with the new value
                      key: Key(selectedDoctorText),
                      initialValue: selectedDoctorText,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Doctor',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: onSelectDoctor,
                    ),
                  ),
                  const SizedBox(width: 10),
          ],
                  Expanded(
                    child: TextFormField(
                      key: Key(selectedDateRangeText),
                      initialValue: selectedDateRangeText,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date Range',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: onSelectDateRange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Search/Clear section
            if (onSearch != null || onClear != null) ...[
              Column(
                children: [
                  Text(
                    'Date Range: $formattedDateRange',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('Search'),
                          onPressed: onSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Get.theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                          onPressed: onClear,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

              if (onSearch == null && onClear == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Date Range: $formattedDateRange',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),

              // List section
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the main body content
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (showInitialMessage) {
      return const Center(child: Text('Please select filters and click search'));
    }
    if (itemCount == 0) {
      return Center(child: Text(noDataMessage));
    }
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      controller: scrollController,
    );
  }
}