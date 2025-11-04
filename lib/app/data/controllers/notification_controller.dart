import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/models/notification_model.dart';
import '../../global/tokenStorage.dart';
import '../../utils/api_constants.dart';

class Notificationcontroller extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse(ApiConstants.GET_NOTIFICATION),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == 1 && data['body'] != null) {
          List<dynamic> list = data['body'];
          final allNotifications = list.map((e) => NotificationModel.fromJson(e)).toList();

          // Filter to only show unread notifications
          notifications.value = allNotifications.where((n) => !n.read).toList();

          // Update unread count for the drawer badge
          unreadCount.value = notifications.length;
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
    isLoading.value = false;
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      // Optimistically remove the notification from the UI
      final removedNotification = notifications.removeAt(index);
      unreadCount.value = notifications.length;

      try {
        final token = await TokenStorage.getToken();
        final response = await http.get(
          Uri.parse('${ApiConstants.MARK_SEEN_NOTIFICATION}/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        final data = jsonDecode(response.body);
        if (response.statusCode != 200 || data['success'] != 1) {
          // If the API call fails, add the notification back to the list
          notifications.insert(index, removedNotification);
          unreadCount.value = notifications.length;
          Get.snackbar("Error", "Failed to mark notification as read.");
        }
      } catch (e) {
        // If an error occurs, revert the change
        notifications.insert(index, removedNotification);
        unreadCount.value = notifications.length;
        Get.snackbar("Error", "Failed to mark notification as read: $e");
      }
    }
  }

  /// 🔑 Call Update Appointment Status API
  Future<void> updateAppointmentStatus({
    required String referenceId,
    required String senderId,
    required String status,
    String? message,
    String? notificationId,
  }) async {
    try {
      final token = await TokenStorage.getToken();

      final body = {
        "reference_id": referenceId,
        "sender_id": senderId,
        "status": status,
        "message": message ?? "",
        "notification_id": notificationId,
      };

      final response = await http.put(
        Uri.parse(ApiConstants.UPDATE_APPOINTMENT_STATUS),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar("Success", "Appointment $status successfully");
        // Refresh notifications; this will now only fetch and display unread ones.
        await fetchNotifications();
      } else {
        Get.back();
        Get.snackbar("Error", data["msg"] ?? "Failed to update appointment");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  Future<void> updateLeaveStatus({
    required String referenceId,
    required String senderId,
    required String status,
    String? message,
    String? notificationId,
  }) async {
    try {
      final token = await TokenStorage.getToken();

      final body = {
        "reference_id": referenceId,
        "sender_id": senderId,
        "status": status,
        "message": message ?? "",
        "notification_id": notificationId,
      };

      final response = await http.put(
        Uri.parse(ApiConstants.UPDATE_LEAVE_STATUS),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar("Success", "Leave ${status.toLowerCase()} successfully");
        // Refresh notifications after update
        await fetchNotifications();
      } else {
        Get.back();
        Get.snackbar("Error", data["msg"] ?? "Failed to update leave request");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
}