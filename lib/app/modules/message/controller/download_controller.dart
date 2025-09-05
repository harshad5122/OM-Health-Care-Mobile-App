
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadController extends GetxController {
  var downloadProgress = <String, double>{}.obs; // Map<fileName, progress>

  var isdownloading = false.obs;
  var downloadprogress = 0.0.obs;
  var isDownloaded = false.obs;

  void setProgress(String fileName, double progress) {
    downloadProgress[fileName] = progress;
  }

  double getProgress(String fileName) {
    return downloadProgress[fileName] ?? 0.0;
  }

  bool isDownloading(String fileName) {
    final progress = downloadProgress[fileName];
    return progress != null && progress < 1.0;
  }


  Future<void> downloadFile(String url, String fileType) async {
    isdownloading.value = true;
    downloadprogress.value = 0.0;
    print(':::: Enter this permission check ::::');
    final permissionStatus = await Permission.storage.request();
    if (!permissionStatus.isGranted) {
      isdownloading.value = false;
      return;
    }

    try {
      print(':::: Enter this try block ::::');
      final fileName = url.split('/').last;
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      final totalBytes = response.contentLength ?? 0;
      int received = 0;

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';
      final file = File(tempPath);
      final sink = file.openWrite();

      await response.stream.listen(
            (chunk) {
          received += chunk.length;
          sink.add(chunk);
          downloadprogress.value = received / totalBytes;
        },
        onDone: () async {
          await sink.close();

          final externalDir = await getExternalStorageDirectory();
          if (externalDir == null) return;

          final targetDir = '${externalDir.path}/$fileType';
          final saveDir = Directory(targetDir);
          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }

          final finalPath = '$targetDir/$fileName';
          await file.copy(finalPath);

          isDownloaded.value = true;
          isdownloading.value = false;
        },
        onError: (e) {
          print('Download failed: $e');
          isdownloading.value = false;
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Error: $e');
      isdownloading.value = false;
    }
  }
}
