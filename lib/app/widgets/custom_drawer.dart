import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class CustomDrawer extends StatelessWidget {
  final String firstName;
  final String lastName;

  const CustomDrawer({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
            ),
            accountName: Text(
              "$firstName $lastName",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text(""), // optional (can show email here)
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                firstName[0] + lastName[0],
                style: TextStyle(
                  fontSize: 24,
                  color: Get.theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Menu Section
          _buildMenuItem(Icons.dashboard, "Dashboard", () {
            Get.back();
          }),
          _buildMenuItem(Icons.person, "Profile", () {Get.toNamed(AppRoutes.profile);}),
          _buildMenuItem(Icons.message, "Messages", () {}),
          _buildMenuItem(Icons.local_hospital, "Add Doctor", () {}),
          _buildMenuItem(Icons.group_add, "Add User", () {}),
          _buildMenuItem(Icons.people, "Member", () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Get.theme.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
