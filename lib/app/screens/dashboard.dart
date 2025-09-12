import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/dashboard_screen_controller.dart';
import '../widgets/custom_drawer.dart';


class DashboardPage extends StatelessWidget {

  final DashboardScreenController controller = Get.put(DashboardScreenController());
  // const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text(
          "Welcome to Dashboard!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
