//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../data/controllers/notification_controller.dart';
// import '../data/models/notification_model.dart';
//
// class NotificationPage extends StatelessWidget {
//   final Notificationcontroller controller = Get.find<Notificationcontroller>();
//
//   NotificationPage({Key? key}) : super(key: key);
//
//
//
//   void _showAcceptConfirmationDialog(BuildContext context, NotificationModel notif) {
//     Get.defaultDialog(
//       title: "Accept Appointment?",
//       titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       content: const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
//         child: Text(
//           "Are you sure you want to accept this appointment?",
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 15),
//         ),
//       ),
//       barrierDismissible: false,
//       actions: [
//         OutlinedButton(
//           onPressed: () => Get.back(),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: Colors.grey[700],
//             side: BorderSide(color: Colors.grey.shade400),
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           child: const Text("No"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Get.back();
//             if (notif.referenceId != null && notif.senderId != null) {
//               controller.updateAppointmentStatus(
//                 referenceId: notif.referenceId!,
//                 senderId: notif.senderId!,
//                 status: "CONFIRMED",
//                 message: "Doctor accepted the appointment",
//                 notificationId: notif.id,
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Get.theme.primaryColor,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             elevation: 2,
//           ),
//           child: const Text("Yes"),
//         ),
//       ],
//     );
//   }
//
//
//   void _showDeclineConfirmationDialog(BuildContext context, NotificationModel notif) {
//     final TextEditingController reasonController = TextEditingController();
//     final RxBool isReasonEmpty = true.obs;
//
//     reasonController.addListener(() {
//       isReasonEmpty.value = reasonController.text.trim().isEmpty;
//     });
//
//     Get.defaultDialog(
//       title: "Cancel Appointment?",
//       titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       content: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Are you sure you want to cancel this appointment?",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 15),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: reasonController,
//               decoration: InputDecoration(
//                 labelText: "Reason for cancellation",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.all(12),
//               ),
//               // maxLines: 3,
//             ),
//           ],
//         ),
//       ),
//       barrierDismissible: false,
//       actions: [
//         OutlinedButton(
//           onPressed: () {
//             Get.back();
//             reasonController.dispose();
//           },
//           style: OutlinedButton.styleFrom(
//             foregroundColor: Colors.grey[700],
//             side: BorderSide(color: Colors.grey.shade400),
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           child: const Text("No"),
//         ),
//         Obx(() => ElevatedButton(
//           onPressed: isReasonEmpty.value
//               ? null
//               : () {
//             Get.back();
//             if (notif.referenceId != null && notif.senderId != null) {
//               controller.updateAppointmentStatus(
//                 referenceId: notif.referenceId!,
//                 senderId: notif.senderId!,
//                 status: "CANCELLED",
//                 message: reasonController.text.trim().isNotEmpty
//                     ? reasonController.text.trim()
//                     : "Doctor declined the appointment",
//                 notificationId: notif.id,
//               );
//             }
//             reasonController.dispose();
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Get.theme.primaryColor,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             elevation: 2,
//           ),
//           child: const Text("Yes"),
//         )),
//       ],
//     );
//   }
//
//
//   Widget _buildActionButtons(NotificationModel notif) {
//     // 🔑 Only show for APPOINTMENT_REQUEST
//     if (notif.type == "APPOINTMENT_REQUEST" || notif.type == "LEAVE_REQUEST" ) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           ElevatedButton(
//             onPressed: () => _showDeclineConfirmationDialog(Get.context!, notif),
//             child: const Text("Decline"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.redAccent, // button color
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton(
//             onPressed: () => _showAcceptConfirmationDialog(Get.context!, notif),
//             child: const Text("Accept"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Get.theme.primaryColor, // button color
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//     // For other notifications → no buttons
//     return const SizedBox.shrink();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Notifications")),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (controller.notifications.isEmpty) {
//           return const Center(child: Text("No notifications"));
//         }
//         return ListView.separated(
//           separatorBuilder: (_, __) => const Divider(),
//           itemCount: controller.notifications.length,
//           itemBuilder: (context, index) {
//             final notif = controller.notifications[index];
//             return InkWell(
//               onTap: () {
//                 controller.markAsRead(notif.id!);
//                 // optional: navigate to appointment details page
//               },
//               child: Container(
//                 color: notif.read ? Colors.white : Colors.white,
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Type
//                     Text(
//                       notif.type ?? 'Unknown',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: notif.read ? Colors.black54 : Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     // Message
//                     Text(
//                       notif.message ?? '',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: notif.read ? Colors.black54 : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // ✅ Action buttons (only for APPOINTMENT_REQUEST)
//                     _buildActionButtons(notif),
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

  void _showAcceptConfirmationDialog(BuildContext context, NotificationModel notif) {
    String title = notif.type == "APPOINTMENT_REQUEST" ? "Accept Appointment?" : "Accept Leave?";
    String contentText = notif.type == "APPOINTMENT_REQUEST"
        ? "Are you sure you want to accept this appointment?"
        : "Are you sure you want to accept this leave request?";
    String successMessage = notif.type == "APPOINTMENT_REQUEST"
        ? "Doctor accepted the appointment"
        : "Admin accepted the leave request";
    String successStatus = notif.type == "APPOINTMENT_REQUEST" ? "CONFIRMED" : "APPROVED";


    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Text(
          contentText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
      ),
      barrierDismissible: false,
      actions: [
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey.shade400),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("No"),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            if (notif.referenceId != null && notif.senderId != null) {
              if (notif.type == "APPOINTMENT_REQUEST") {
                controller.updateAppointmentStatus(
                  referenceId: notif.referenceId!,
                  senderId: notif.senderId!,
                  status: successStatus,
                  message: successMessage,
                  notificationId: notif.id,
                );
              } else if (notif.type == "LEAVE_REQUEST") {
                controller.updateLeaveStatus(
                  referenceId: notif.referenceId!,
                  senderId: notif.senderId!, // Assuming senderId is used for leave as well
                  status: successStatus,
                  message: successMessage,
                  notificationId: notif.id,
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
          child: const Text("Yes"),
        ),
      ],
    );
  }

  void _showDeclineConfirmationDialog(BuildContext context, NotificationModel notif) {
    String title = notif.type == "APPOINTMENT_REQUEST" ? "Cancel Appointment?" : "Reject Leave?";
    String contentText = notif.type == "APPOINTMENT_REQUEST"
        ? "Are you sure you want to cancel this appointment?"
        : "Are you sure you want to reject this leave request?";
    String defaultMessage = notif.type == "APPOINTMENT_REQUEST"
        ? "Doctor declined the appointment"
        : "Admin rejected the leave request";
    String declineStatus = notif.type == "APPOINTMENT_REQUEST" ? "CANCELLED" : "REJECTED";


    final TextEditingController reasonController = TextEditingController();
    final RxBool isReasonEmpty = true.obs;

    reasonController.addListener(() {
      isReasonEmpty.value = reasonController.text.trim().isEmpty;
    });

    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contentText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: "Reason for ${notif.type == "APPOINTMENT_REQUEST" ? "cancellation" : "rejection"}",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      actions: [
        OutlinedButton(
          onPressed: () {
            Get.back();
            reasonController.dispose();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey.shade400),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("No"),
        ),
        Obx(() => ElevatedButton(
          onPressed: isReasonEmpty.value
              ? null
              : () {
            Get.back();
            if (notif.referenceId != null && notif.senderId != null) {
              String finalMessage = reasonController.text.trim().isNotEmpty
                  ? reasonController.text.trim()
                  : defaultMessage;

              if (notif.type == "APPOINTMENT_REQUEST") {
                controller.updateAppointmentStatus(
                  referenceId: notif.referenceId!,
                  senderId: notif.senderId!,
                  status: declineStatus,
                  message: finalMessage,
                  notificationId: notif.id,
                );
              } else if (notif.type == "LEAVE_REQUEST") {
                controller.updateLeaveStatus(
                  referenceId: notif.referenceId!,
                  senderId: notif.senderId!,
                  status: declineStatus,
                  message: finalMessage,
                  notificationId: notif.id,
                );
              }
            }
            reasonController.dispose();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
          child: const Text("Yes"),
        )),
      ],
    );
  }

  Widget _buildActionButtons(NotificationModel notif) {
    if (notif.type == "APPOINTMENT_REQUEST" || notif.type == "LEAVE_REQUEST") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => _showDeclineConfirmationDialog(Get.context!, notif),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(notif.type == "APPOINTMENT_REQUEST" ? "Decline" : "Reject"),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showAcceptConfirmationDialog(Get.context!, notif),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(notif.type == "APPOINTMENT_REQUEST" ? "Accept" : "Approve"),
          ),
        ],
      );
    }
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
                // Mark as read only if it hasn't been read yet and no action is taken
                if (!notif.read && notif.type != "APPOINTMENT_REQUEST" && notif.type != "LEAVE_REQUEST") {
                  controller.markAsRead(notif.id!);
                }
                // You might want to navigate to a detail page here based on notif.type
              },
              child: Container(
                color: notif.read ? Colors.white : Colors.white, // Subtle highlight for unread
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.type ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: notif.read ? Colors.black54 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: notif.read ? Colors.black54 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
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