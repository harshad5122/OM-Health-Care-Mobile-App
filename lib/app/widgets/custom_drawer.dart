import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global/global.dart';
import '../routes/app_routes.dart';

class CustomDrawer extends StatelessWidget {

  const CustomDrawer({super.key,});

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
              "${Global.userFirstname} ${Global.userLastname}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text(""), // optional (can show email here)
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "${Global.userFirstname?[0]}${Global.userLastname?[0]}",
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
          _buildMenuItem(Icons.local_hospital, "Add Doctor", () {Get.toNamed(AppRoutes.addDoctor);}),
          _buildMenuItem(Icons.group_add, "Add User", () {Get.toNamed(AppRoutes.addUser);}),
          _buildMenuItem(Icons.people, "Member", () {}),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildMenuItem(
              Icons.logout,
              "Logout",
                  () {
                // Add your logout logic here
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ),
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
