import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomListPage2 extends StatelessWidget {
  final String appBarTitle;
  final bool isLoading;
  final bool showInitialMessage;
  final String noDataMessage;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  // --- Filters and Callbacks ---
  final void Function()? onSearch;
  final void Function()? onClear;
  final VoidCallback onSelectStatus;
  final VoidCallback onSelectDateRange;
  final void Function(String)? onSearchChanged;

  // --- Display Values ---
  final String selectedStatusText;
  final String selectedDateRangeText;
  final String formattedDateRange;
  final TextEditingController searchController;

  const CustomListPage2({
    super.key,
    required this.appBarTitle,
    required this.isLoading,
    required this.showInitialMessage,
    this.noDataMessage = 'No data found for the selected criteria',
    required this.itemCount,
    required this.itemBuilder,
    required this.onSearch,
    required this.onClear,
    required this.onSelectStatus,
    required this.onSelectDateRange,
    required this.selectedStatusText,
    required this.selectedDateRangeText,
    required this.formattedDateRange,
    required this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // --- Filter Row: Status + Date Range ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: Key(selectedStatusText),
                    initialValue: selectedStatusText,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Status',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    onTap: onSelectStatus,
                  ),
                ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 12),

            // --- Search Bar ---
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by patient name or details',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged?.call('');
                  },
                ),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 15),

            // --- Date Range Display + Buttons ---
            Column(
              children: [
                Text(
                  'Date Range: $formattedDateRange',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
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

            // --- List Section ---
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

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
    );
  }
}
