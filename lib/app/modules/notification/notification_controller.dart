// // lib/controllers/notification_controller.dart
// import 'package:get/get.dart';
//
// import 'notification_service.dart';
//
//
//
// class NotificationController extends GetxController {
//   final NotificationService notificationService = Get.find();
//   final String userId;
//
//   NotificationController(this.userId);
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeSocket();
//   }
//
//   void _initializeSocket() {
//     final socketService = SocketService(userId);
//     socketService.init().then((_) {
//       socketService.listenForNotifications(_handleSocketNotification);
//     });
//   }
//
//   void _handleSocketNotification(dynamic data) {
//     if (data is Map<String, dynamic>) {
//       final title = 'New Proposal';
//       final body = data['message'] ?? 'You have a new job proposal';
//
//       notificationService.showNotification(
//         id: DateTime.now().millisecondsSinceEpoch,
//         title: title,
//         body: body,
//         payload: data['proposalId']?.toString(),
//       );
//
//       // Show a snackbar if app is in foreground
//       if (Get.isSnackbarOpen == false) {
//         Get.snackbar(title, body);
//       }
//     }
//   }
// }

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

      // Handle via ChatController
      final chatController = Get.find<ChatController>();
      chatController.handleMessageNotification(notification as MessageModel);

      // Snackbar for foreground
      if (!Get.isSnackbarOpen) {
        Get.snackbar("📩 New Message", notification.message ?? '');
      }
    } catch (e, stack) {
      print("❌ Failed to parse notification: $e");
      print(stack);
    }
  }
}
