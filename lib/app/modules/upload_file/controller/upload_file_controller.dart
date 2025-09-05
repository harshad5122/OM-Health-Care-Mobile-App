import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/models/upload_file_model.dart';
import '../../../global/tokenStorage.dart';
import '../../../utils/api_constants.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class UploadFileController extends GetxController {
  var isLoading = false.obs;
  var uploadedFile = Rxn<UploadFile>();

  Future<UploadFile?> uploadFile(File file) async {
    try {
      isLoading.value = true;
      String? token = await TokenStorage.getToken();

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.UPLOAD_FILE));
      request.headers['Authorization'] = '$token';
      request.headers['Content-Type'] = 'multipart/form-data';

      var fileMimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      print("Uploading file with MIME type: $fileMimeType");
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        file.path,
        contentType: MediaType.parse(fileMimeType),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print('status code : ${response.statusCode}');
      print('response ::::: ${response.body}');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        uploadedFile.value = UploadFile.fromJson(jsonResponse);
        Get.snackbar("Success", "File uploaded successfully!");
        return uploadedFile.value;  // Return uploaded file
      } else {
        Get.snackbar("Error", "File upload failed!");
        return null;  //Return null on failure
      }
    }on http.ClientException catch (e) {
      print('Client Exception: $e');
    } on SocketException catch (e) {
      print('Network Error: $e');
    } on FormatException catch (e) {
      print('Response format error: $e');
    } catch (e) {
      print('Exception: $e');
      Get.snackbar("Error", "Exception: $e");
      return null;  // Return null in case of an exception
    } finally {
      isLoading.value = false;
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (e) {
          print("Failed to delete temp file: $e");
        }
      }
    }
  }
}
