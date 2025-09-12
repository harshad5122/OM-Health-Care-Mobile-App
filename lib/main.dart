import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/global/global.dart';
import 'app/global/global_binding.dart';
import 'app/modules/notification/notification_controller.dart';
import 'app/modules/notification/notification_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'config/theme/theme_controller.dart';

void main() async {
  Get.put(ThemeController());
  GlobalBindings().dependencies();
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => NotificationService().init());
  Get.put(NotificationController(Global.userId ?? ''));

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

