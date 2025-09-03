import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_drawer.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
      drawer: const CustomDrawer(
        firstName: "Ishita",
        lastName: "Poshiya",
      ),
      body: const Center(
        child: Text(
          "Welcome to Dashboard!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
