import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'config/theme/theme_controller.dart';

void main() {
  runApp(const OmHealthCareApp());
}

class OmHealthCareApp extends StatelessWidget {
  const OmHealthCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    return Obx(() {
        return GetMaterialApp(
          title: 'Om Health Care',
          debugShowCheckedModeBanner: false,
          // theme: ThemeData(
          //   primarySwatch: Colors.teal,
          // ),
          theme: themeController.theme,
          initialRoute: AppRoutes.login,
          getPages: AppPages.pages,
        );
      }
    );
  }
}

