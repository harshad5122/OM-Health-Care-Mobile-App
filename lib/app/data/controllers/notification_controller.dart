// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import '../../data/models/notification_model.dart';
// import '../../global/tokenStorage.dart';
// import '../../utils/api_constants.dart';
//
// class Notificationcontroller extends GetxController {
//   var notifications = <NotificationModel>[].obs;
//   var unreadCount = 0.obs;
//   var isLoading = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchNotifications();
//   }
//
//   Future<void> fetchNotifications() async {
//     isLoading.value = true;
//     try {
//       final token = await TokenStorage.getToken();
//
//       final response = await http.get(
//         Uri.parse(ApiConstants.GET_NOTIFICATION),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == 1 && data['body'] != null) {
//           List<dynamic> list = data['body'];
//           notifications.value =
//               list.map((e) => NotificationModel.fromJson(e)).toList();
//
//           unreadCount.value =
//               notifications.where((n) => n.read == false).length;
//         }
//       }
//     } catch (e) {
//       print('Error fetching notifications: $e');
//     }
//     isLoading.value = false;
//   }
//
//
//
//   Future<void> markAsRead(String id) async {
//     final index = notifications.indexWhere((n) => n.id == id);
//     if (index != -1 && notifications[index].read == false) {
//       // Optimistically update UI
//       notifications[index] = notifications[index].copyWith(read: true);
//       unreadCount.value =
//           notifications.where((n) => n.read == false).length;
//
//       try {
//         final token = await TokenStorage.getToken();
//         final response = await http.get(
//           Uri.parse('${ApiConstants.MARK_SEEN_NOTIFICATION}/$id'), // Assuming APIConstants.MARK_SEEN_NOTIFICATION is the base URL
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         );
//
//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           if (data['success'] == 1) {
//             print('Notification $id marked as seen successfully');
//             // No need to re-fetch all notifications if only marking as read.
//             // UI is already updated.
//           } else {
//             print('Failed to mark notification $id as seen: ${data['msg']}');
//             // Revert UI change if API call fails
//             notifications[index] = notifications[index].copyWith(read: false);
//             unreadCount.value =
//                 notifications.where((n) => n.read == false).length;
//           }
//         } else {
//           print('Failed to mark notification $id as seen with status ${response.statusCode}');
//           // Revert UI change if API call fails
//           notifications[index] = notifications[index].copyWith(read: false);
//           unreadCount.value =
//               notifications.where((n) => n.read == false).length;
//         }
//       } catch (e) {
//         print('Error marking notification $id as seen: $e');
//         Get.snackbar("Error", "Failed to mark notification as read: $e");
//         // Revert UI change if API call fails
//         notifications[index] = notifications[index].copyWith(read: false);
//         unreadCount.value =
//             notifications.where((n) => n.read == false).length;
//       }
//     }
//   }
//
//   /// 🔑 Call Update Appointment Status API
//   Future<void> updateAppointmentStatus({
//     required String referenceId,
//     required String senderId,
//     required String status, // CONFIRMED or CANCELLED
//     String? message,
//     String? notificationId,
//   }) async {
//     try {
//       final token = await TokenStorage.getToken();
//
//       final body = {
//         "reference_id": referenceId,
//         "sender_id": senderId,
//         "status": status,
//         "message": message ?? "",
//         "notification_id": notificationId,
//       };
//
//       final response = await http.put(
//         Uri.parse(ApiConstants.UPDATE_APPOINTMENT_STATUS),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(body),
//       );
//
//       final data = jsonDecode(response.body);
//       print('response code ::${response.statusCode}');
//       if (response.statusCode == 200) {
//         Get.back();
//         Get.snackbar("Success", "Appointment $status successfully");
//         print('response: ${response.body}');
//         // Refresh notifications after update
//         await fetchNotifications();
//         if (notificationId != null) {
//           markAsRead(notificationId); // Mark as read after action
//         }
//       } else {
//         Get.back();
//         Get.snackbar("Error", data["msg"] ?? "Failed to update appointment");
//         print('error message :: ${ data["msg"]}');
//       }
//     } catch (e) {
//       Get.back();
//       Get.snackbar("Error", "Something went wrong: $e");
//       print('catch error : ${e}');
//     }
//   }
//
//   Future<void> updateLeaveStatus({
//     required String referenceId,
//     required String senderId, // This might be staffId for leave, confirm with API
//     required String status, // APPROVED or REJECTED
//     String? message,
//     String? notificationId,
//   }) async {
//     try {
//       final token = await TokenStorage.getToken();
//
//       final body = {
//         "reference_id": referenceId,
//         "sender_id": senderId, // Assuming sender_id is applicable for leave API as well
//         "status": status,
//         "message": message ?? "",
//         "notification_id": notificationId,
//       };
//
//       print('update leave api body :: ${body}');
//
//       final response = await http.put(
//         Uri.parse(ApiConstants.UPDATE_LEAVE_STATUS),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(body),
//       );
//
//       final data = jsonDecode(response.body);
//       print('response code ::${response.statusCode}');
//       if (response.statusCode == 200) { // Changed data["success"] == true to 1
//         Get.back();
//         Get.snackbar("Success", "Leave ${status.toLowerCase()} successfully"); // Dynamic status text
//         print('response: ${response.body}');
//         await fetchNotifications(); // Refresh notifications after update
//         if (notificationId != null) {
//           markAsRead(notificationId); // Mark as read after action
//         }
//       } else {
//         Get.back();
//         Get.snackbar("Error", data["msg"] ?? "Failed to update leave request");
//         print('error message :: ${data["msg"]}');
//       }
//     } catch (e) {
//       Get.back();
//       Get.snackbar("Error", "Something went wrong: $e");
//       print('catch error : $e');
//     }
//   }
// }


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