// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../data/controllers/notification_controller.dart';
//
//
//
// class NotificationPage extends StatelessWidget {
//   final Notificationcontroller controller = Get.find<Notificationcontroller>();
//
//   NotificationPage({Key? key}) : super(key: key);
//
//   Widget _buildButtonsForType(String type, String? referenceId, String? senderId, String? notificationId ) {
//     if (type == "APPOINTMENT_REQUEST") {//|| type == "LEAVE_REQUEST"
//       return Row(
//         children: [
//           TextButton(
//             onPressed: () {
//               // // TODO: implement Decline logic
//               // Get.snackbar("Declined", "Declined the $type");
//               if (referenceId != null && senderId != null) {
//                 controller.updateAppointmentStatus(
//                   referenceId: referenceId,
//                   senderId: senderId,
//                   status: "CANCELLED",
//                   message: "Doctor declined the appointment",
//                   notificationId: notificationId,
//                 );
//               }
//             },
//             child: Text("Decline"),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//           ),
//           SizedBox(width: 8),
//           ElevatedButton(
//             onPressed: () {
//               if (referenceId != null && senderId != null) {
//                 controller.updateAppointmentStatus(
//                   referenceId: referenceId,
//                   senderId: senderId,
//                   status: "CONFIRMED",
//                   message: "Doctor accepted the appointment",
//                   notificationId: notificationId,
//                 );
//               }
//               // // TODO: implement Accept logic
//               // Get.snackbar("Accepted", "Accepted the $type");
//             },
//             child: Text("Accept"),
//           ),
//         ],
//       );
//     }
//     // No buttons for other types
//     return SizedBox.shrink();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notifications"),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (controller.notifications.isEmpty) {
//           return Center(child: Text("No notifications"));
//         }
//         return ListView.separated(
//           separatorBuilder: (_, __) => Divider(),
//           itemCount: controller.notifications.length,
//           itemBuilder: (context, index) {
//             final notif = controller.notifications[index];
//             return InkWell(
//               onTap: () {
//                 controller.markAsRead(notif.id!);
//                 // TODO: Navigate to details if needed
//               },
//               child: Container(
//                 color: notif.read ? Colors.white : Colors.grey[200],
//                 padding: EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Notification type with badge for unread
//                     Row(
//                       children: [
//                         Text(
//                           notif.type ?? 'Unknown',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: notif.read ? Colors.black54 : Colors.black,
//                           ),
//                         ),
//                         // if (!notif.read)
//                         //   Padding(
//                         //     padding: const EdgeInsets.only(left: 6),
//                         //     child: Container(
//                         //       width: 8,
//                         //       height: 8,
//                         //       decoration: BoxDecoration(
//                         //         color: Colors.red,
//                         //         shape: BoxShape.circle,
//                         //       ),
//                         //     ),
//                         //   ),
//                       ],
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       notif.message ?? '',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: notif.read ? Colors.black54 : Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     _buildButtonsForType(notif.type ?? "",
//                       notif.referenceId,
//                       notif.senderId,
//                       notif.id,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/notification_controller.dart';
import '../data/models/notification_model.dart';

class NotificationPage extends StatelessWidget {
  final Notificationcontroller controller = Get.find<Notificationcontroller>();

  NotificationPage({Key? key}) : super(key: key);

  Widget _buildActionButtons(NotificationModel notif) {
    // 🔑 Only show for APPOINTMENT_REQUEST
    if (notif.type == "APPOINTMENT_REQUEST") {
      return Row(
        children: [
          TextButton(
            onPressed: () {
              if (notif.referenceId != null && notif.senderId != null) {
                controller.updateAppointmentStatus(
                  referenceId: notif.referenceId!,
                  senderId: notif.senderId!,
                  status: "CANCELLED", // ❌ Decline
                  message: "Doctor declined the appointment",
                  notificationId: notif.id,
                );
              }
            },
            child: const Text("Decline"),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (notif.referenceId != null && notif.senderId != null) {
                controller.updateAppointmentStatus(
                  referenceId: notif.referenceId!,
                  senderId: notif.senderId!,
                  status: "CONFIRMED", // ✅ Accept
                  message: "Doctor accepted the appointment",
                  notificationId: notif.id,
                );
              }
            },
            child: const Text("Accept"),
          ),
        ],
      );
    }
    // For other notifications → no buttons
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return const Center(child: Text("No notifications"));
        }
        return ListView.separated(
          separatorBuilder: (_, __) => const Divider(),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            return InkWell(
              onTap: () {
                controller.markAsRead(notif.id!);
                // optional: navigate to appointment details page
              },
              child: Container(
                color: notif.read ? Colors.white : Colors.grey[200],
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type
                    Text(
                      notif.type ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: notif.read ? Colors.black54 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Message
                    Text(
                      notif.message ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: notif.read ? Colors.black54 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ✅ Action buttons (only for APPOINTMENT_REQUEST)
                    _buildActionButtons(notif),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
