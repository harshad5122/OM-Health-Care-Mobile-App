import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/dashboard_screen_controller.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_drawer.dart';
import 'notification_page.dart';


class DashboardPage extends StatelessWidget {

  final DashboardScreenController controller = Get.put(DashboardScreenController());
  // const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Dashboard",
        // onMenuPressed: () => Scaffold.of(context).openDrawer(),
        onMenuPressed: () {
          // Wrap context in Builder to find Scaffold ancestor
          Scaffold.of(context).openDrawer();
        },
        onNotificationPressed: () {
          Get.to(() => NotificationPage());
        },
      ),

      drawer: CustomDrawer(),
      body: const Center(
        child: Text(
          "Welcome to Dashboard!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
