import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/recipient_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';


class RecipientController extends GetxController {
  final recipients = <Recipient>[].obs;
  final isLoading = false.obs;

  /// Fetch recipients for a broadcast
  Future<void> fetchRecipients(String broadcastId) async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();
      final url = "${ApiConstants.BASE_URL}/broadcasts/recipients/$broadcastId";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> body = data["body"];
        recipients.assignAll(body.map((e) => Recipient.fromJson(e)).toList());
      } else {
        Get.snackbar("Error", "Failed to load recipients");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
