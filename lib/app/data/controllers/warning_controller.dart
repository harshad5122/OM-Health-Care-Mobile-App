import 'package:get/get.dart';

class WarningController extends GetxController {
  var showWarning = true.obs;

  void dismissWarningText() {
    showWarning.value = false;
  }
}