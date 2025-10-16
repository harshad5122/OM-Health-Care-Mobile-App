import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../message/controller/chat_user_controller.dart';
import '../controller/leave_controller.dart';
import 'package:get/get.dart';

class LeaveRecordPage extends StatelessWidget{
  final LeaveController _leaveController = Get.put(LeaveController());
  LeaveRecordPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Record'),
        backgroundColor:
        Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildLeaveRecordsSection(),
      ),
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
}