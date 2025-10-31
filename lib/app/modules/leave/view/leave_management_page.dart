import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../message/controller/chat_user_controller.dart';
import '../controller/leave_controller.dart';

class LeaveManagementPage extends StatelessWidget {
  final LeaveController _leaveController = Get.put(LeaveController());
  final ChatUserController _chatUserController = Get.put(ChatUserController());

  LeaveManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (_chatUserController.adminList.isEmpty) {
      _chatUserController.fetchChatUsers();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_leaveController.isEditMode.value ? 'Edit Leave' : 'Apply Leave'),
        backgroundColor:
            Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApplyLeaveSection(context),
            const SizedBox(height: 30),
            // _buildLeaveRecordsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyLeaveSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // 'Apply Leave',
          _leaveController.isEditMode.value ? 'Edit Leave' : 'Apply Leave',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 20),
        // Start Date
        _buildDateSelectionField(
          context,
          label: 'Start Date',
          selectedDate: _leaveController.startDate,
          onTap: () => _leaveController.selectDate(context, true),
        ),
        const SizedBox(height: 15),
        // End Date
        _buildDateSelectionField(
          context,
          label: 'End Date',
          selectedDate: _leaveController.endDate,
          onTap: () => _leaveController.selectDate(context, false),
        ),
        const SizedBox(height: 15),
        // Leave Type
        Text(
          'Leave Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: _leaveController.selectedLeaveType.value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'FULL_DAY', child: Text('Full Day')),
              DropdownMenuItem(
                  value: 'FIRST_HALF', child: Text('First Half')),
              DropdownMenuItem(
                  value: 'SECOND_HALF', child: Text('Second Half')),
            ],
            onChanged: _leaveController.setSelectedLeaveType,
          ),
        ),
        const SizedBox(height: 15),

        Text(
          'Select Admin',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        Obx(() {
          if (_chatUserController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_chatUserController.adminList.isEmpty) {
            // Show a disabled-looking box if no admins are available
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("No admins available", style: TextStyle(color: Colors.grey)),
                  Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            );
          }


          return InkWell(
            // This InkWell is the new trigger
            onTap: () {
              // Call the helper function you created in step 1
              _showAdminBottomSheet(context);
            },
            child: Container(
              // This Container mimics the style of your old DropdownButtonFormField
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // This Obx ensures the selected admin's name updates on the button
                  Obx(() {
                    return Text(
                      // Check the adminName, not staffId
                      _leaveController.adminName.value.isEmpty
                          ? "Select an Admin" // Hint text
                          : _leaveController.adminName.value, // Selected name
                      style: TextStyle(
                        color: _leaveController.adminName.value.isEmpty
                            ? Colors.black// Hint text color
                            : Colors.black,
                      fontSize: 16,
                        fontWeight: FontWeight.w400
                      ),
                    );
                  }),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
          );
        }),


        const SizedBox(height: 15),
        // Reason for Leave
        Text(
          'Reason for Leave',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _leaveController.reasonController,
          decoration: InputDecoration(
            hintText: 'Enter your reason...',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // Implement Cancel logic if needed, e.g., clear form
                _leaveController.reasonController.clear();
                _leaveController.startDate.value = null;
                _leaveController.endDate.value = null;
                _leaveController.selectedLeaveType.value = 'FULL_DAY';
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 10),
            Obx(
              () => ElevatedButton(
                onPressed: _leaveController.isLoading.value
                    ? null
                    :  () {

                  print('leave mode : ${_leaveController.isEditMode.value}');
                  if (_leaveController.isEditMode.value) {
                    _leaveController.updateLeave(_leaveController.editingLeave.value!.id);
                  } else {
                    _leaveController.applyLeave();
                  }
                },
                // _leaveController.applyLeave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _leaveController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_leaveController.isEditMode.value ? 'Update Leave' : 'Apply Leave'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelectionField(
    BuildContext context, {
    required String label,
    required Rx<DateTime?> selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    selectedDate.value == null
                        ? 'MM/DD/YYYY'
                        : DateFormat('MM/dd/yyyy').format(selectedDate.value!),
                    style: TextStyle(
                      color: selectedDate.value == null
                          ? Colors.grey[600]
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveRecordsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Records',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Get.theme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (_leaveController.isFetchingRecords.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_leaveController.leaveRecords.isEmpty) {
                return const Center(child: Text('No leave records available.'));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16, // Reduced column spacing
                  dataRowMinHeight: 45, // Set minimum row height
                  dataRowMaxHeight: 60, // Set maximum row height
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) =>
                        Get.theme.primaryColor.withOpacity(0.1),
                  ),
                  columns: const [
                    DataColumn(
                        label: Text('Start Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('End Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Leave Type',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Reason',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Action',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _leaveController.leaveRecords.map((record) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                            DateFormat('MM/dd/yyyy').format(record.startDate))),
                        DataCell(Text(
                            DateFormat('MM/dd/yyyy').format(record.endDate))),
                        DataCell(Text(_formatLeaveType(record.leaveType))),
                        DataCell(
                          SizedBox(
                            width: 100, // Constrain width to prevent overflow
                            child: Text(
                              record.reason,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(_buildStatusChip(record.status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.green),
                                onPressed: () {
                                  _leaveController.startEditing(record);
                                },
                                tooltip: 'Edit Leave',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: "Delete Leave",
                                    middleText: "Are you sure you want to delete this leave?",
                                    onConfirm: () {
                                      _leaveController.deleteLeave(record.id);
                                      Get.back();
                                    },
                                    onCancel: () {},
                                  );
                                },
                                tooltip: 'Delete Leave',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'APPROVED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  String _formatLeaveType(String leaveType) {
    switch (leaveType) {
      case 'FULL_DAY':
        return 'Full Day';
      case 'FIRST_HALF':
        return 'First Half';
      case 'SECOND_HALF':
        return 'Second Half';
      default:
        return leaveType;
    }
  }

  void _showAdminBottomSheet(BuildContext context) {
    // Use Get.bottomSheet, as you are using GetX
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          // Use your app's theme color for the background
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take only as much height as needed
          children: [
            // 1. Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Select Admin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // 2. Scrollable List of Admins
            // We limit the height to 40% of the screen to prevent
            // it from covering the whole page if there are many admins.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _chatUserController.adminList.length,
                itemBuilder: (context, index) {
                  final admin = _chatUserController.adminList[index];

                  // This ListTile provides the "rich look"
                  return ListTile(
                    // leading: CircleAvatar(
                    //   // Display the first letter of the admin's name
                    //   child: Text(admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A'),
                    // ),
                    title: Text(admin.name),
                    // Optional: Add email or other info as a subtitle
                    // subtitle: Text(admin.email ?? ''),
                    onTap: () {
                      // This is your logic from the old `onChanged`
                      _leaveController.adminId.value = admin.userId;
                      _leaveController.adminName.value = admin.name;

                      // Close the bottom sheet
                      Get.back();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16), // Safe area padding at the bottom
          ],
        ),
      ),
      // This makes the background color standard
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allows the sheet to be short
    );
  }
}
