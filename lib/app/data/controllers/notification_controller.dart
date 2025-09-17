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
          notifications.value =
              list.map((e) => NotificationModel.fromJson(e)).toList();

          unreadCount.value =
              notifications.where((n) => n.read == false).length;
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
    isLoading.value = false;
  }

  /// Mark notification as read by id
  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && notifications[index].read == false) {
      notifications[index] = notifications[index].copyWith(read: true);
      unreadCount.value =
          notifications.where((n) => n.read == false).length;

      // TODO: Call backend API to mark notification as read if exists
    }
  }

  /// 🔑 Call Update Appointment Status API
  Future<void> updateAppointmentStatus({
    required String referenceId,
    required String senderId,
    required String status, // CONFIRMED or CANCELLED
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
      if (response.statusCode == 200 && data["success"] == true) {
        Get.snackbar("Success", "Appointment $status successfully");
        // Refresh notifications after update
        await fetchNotifications();
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to update appointment");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
}
