

import 'package:get/get.dart';
import 'package:om_health_care_app/app/data/models/message_model.dart';
import '../../data/models/notification_model.dart';
import '../../socket/notification_socket.dart';
import '../message/controller/chat_contoller.dart';
import 'notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService notificationService = Get.find();
  final String userId;

  NotificationController(this.userId);

  @override
  void onInit() {
    super.onInit();
    _initializeSocket();
  }

  void _initializeSocket() {
    final socketService = SocketService(userId);
    socketService.init().then((_) {
      socketService.listenForNotifications(_handleSocketNotification);
    });
  }

  void _handleSocketNotification(dynamic data) {
    try {
      final notification = NotificationModel.fromJson(Map<String, dynamic>.from(data));

      if (notification.type == "APPOINTMENT_REQUEST") {
        // Show a local notification for appointment
        final notifService = Get.find<NotificationService>();
        notifService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "New Appointment Request",
          body: notification.message ?? "You have a new appointment request.",
          payload: notification.referenceId, // Pass appointmentId for tap actions if needed
        );
        // Optionally display snackbar as a fallback
        if (!Get.isSnackbarOpen) {
          Get.snackbar("🩺 Appointment", notification.message ?? '');
        }
      }else {
        // Existing chat handling
        final chatController = Get.find<ChatController>();
        chatController.handleMessageNotification(notification as MessageModel);

        if (!Get.isSnackbarOpen) {
          Get.snackbar("📩 New Message", notification.message ?? '');
        }
      }

      // Handle via ChatController
      // final chatController = Get.find<ChatController>();
      // chatController.handleMessageNotification(notification as MessageModel);
      //
      // // Snackbar for foreground
      // if (!Get.isSnackbarOpen) {
      //   Get.snackbar("📩 New Message", notification.message ?? '');
      // }
    } catch (e, stack) {
      print("❌ Failed to parse notification: $e");
      print(stack);
    }
  }
}
