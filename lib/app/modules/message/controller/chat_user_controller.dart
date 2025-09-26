import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/broadcast_model.dart';
import '../../../data/models/chat_user_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';

class ChatUserController extends GetxController {
  /// Observables
  var isLoading = false.obs;

  /// All users from API
  var allUsers = <ChatUser>[].obs;

  /// Filtered lists by role
  var adminList = <ChatUser>[].obs;
  var staffList = <ChatUser>[].obs;
  var patientList = <ChatUser>[].obs;

  /// Search text
  final searchText = ''.obs;
  final RxList<BroadcastModel> broadcastList = <BroadcastModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(searchText, (_) => filterUsers());
  }

  /// Fetch chat users (single API)
  Future<void> fetchChatUsers() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse(ApiConstants.GET_ALL_CHAT_USER),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];

        allUsers.value = body.map((e) => ChatUser.fromJson(e)).toList();

        _splitUsersByRole();
        filterUsers();
      } else {
        Get.snackbar("Error", "Failed to load chat users");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch broadcasts
  Future<void> fetchBroadcasts() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse(ApiConstants.GET_BROADCASTS), // <- define this in ApiConstants
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];

        broadcastList.value =
            body.map((e) => BroadcastModel.fromJson(e)).toList();
        broadcastList.sort((a, b) =>
            b.createdAt.compareTo(a.createdAt));
      } else {
        Get.snackbar("Error", "Failed to load broadcasts");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  /// Split into admin, staff, patient lists by role
  void _splitUsersByRole() {
    patientList.assignAll(allUsers.where((u) => u.role == 1));
    adminList.assignAll(allUsers.where((u) => u.role == 2));
    staffList.assignAll(allUsers.where((u) => u.role == 3));
  }

  /// Search filter
  void filterUsers() {
    final query = searchText.value.toLowerCase();

    if (query.isEmpty) {
      _splitUsersByRole();
    } else {
      patientList.assignAll(
        allUsers.where((u) =>
        u.role == 1 &&
            (u.name.toLowerCase().contains(query) ||
                u.email.toLowerCase().contains(query))),
      );
      adminList.assignAll(
        allUsers.where((u) =>
        u.role == 2 &&
            (u.name.toLowerCase().contains(query) ||
                u.email.toLowerCase().contains(query))),
      );
      staffList.assignAll(
        allUsers.where((u) =>
        u.role == 3 &&
            (u.name.toLowerCase().contains(query) ||
                u.email.toLowerCase().contains(query))),
      );
    }
  }
}
