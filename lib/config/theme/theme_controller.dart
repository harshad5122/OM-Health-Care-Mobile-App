import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  ThemeData get theme =>
      isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(theme);
  }
}
