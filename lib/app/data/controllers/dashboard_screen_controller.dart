import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreenController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request camera, gallery, and notification permissions
    await _requestCameraPermission();
    await _requestStoragePermission();
    await _requestGalleryPermission();
    await _requestNotificationPermission();
  }

  Future<void> _requestCameraPermission() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _requestStoragePermission() async {
    final storageStatus = await Permission.storage.status;
    if(!storageStatus.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _requestGalleryPermission() async {
    final galleryStatus = await Permission.photos.status;
    if (!galleryStatus.isGranted) {
      await Permission.photos.request();
    }
  }

  Future<void> _requestNotificationPermission() async {
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }
  }


}
