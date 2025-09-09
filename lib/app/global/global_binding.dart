import 'package:get/get.dart';
import '../data/controllers/warning_controller.dart';

class GlobalBindings extends Bindings {
   @override
  void dependencies() {
     Get.put(WarningController(), permanent: true);
  }
}