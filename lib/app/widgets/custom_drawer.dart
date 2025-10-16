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

          // Role-based menu
          ..._buildMenuForRole(Global.role),

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

  List<Widget> _buildMenuForRole(int? role) {
    switch (role) {
      case 1: // User
        return [
          _buildMenuItem(Icons.person, "Profile", () {
            Get.toNamed(AppRoutes.profile);
          }),
          _buildMenuItem(Icons.message, "Messages", () {
            Get.toNamed(AppRoutes.messageUserList);
          }),
          _buildMenuItem(Icons.event, "Book Appointment", () {
            Get.toNamed(AppRoutes.appointment);
          }),
        ];

      case 2: // Admin
        return [
          _buildMenuItem(Icons.dashboard, "Dashboard", () {
            Get.back();
          }),
          _buildMenuItem(Icons.person, "Profile", () {
            Get.toNamed(AppRoutes.profile);
          }),
          _buildMenuItem(Icons.message, "Messages", () {
            Get.toNamed(AppRoutes.messageUserList);
          }),
          _buildMenuItem(Icons.local_hospital, "Add Doctor", () {
            Get.toNamed(AppRoutes.addDoctor);
          }),
          _buildMenuItem(Icons.group_add, "Add User", () {
            Get.toNamed(AppRoutes.addUser);
          }),
          _buildMenuItem(Icons.people, "Member", () {
            Get.toNamed(AppRoutes.member);
          }),
          _buildMenuItem(Icons.event, "Book Appointment", () {
            Get.toNamed(AppRoutes.appointment);
          }),
          _buildMenuItem(Icons.calendar_month_sharp, "Appointments", () {
            Get.toNamed(AppRoutes.appointment_page);
          }),
          _buildMenuItem(Icons.outbond_outlined, "Leave", () {
            Get.toNamed(AppRoutes.leave_page);
          }),
        ];

      case 3: // Staff
        return [
          _buildMenuItem(Icons.person, "Profile", () {
            Get.toNamed(AppRoutes.profile);
          }),
          _buildMenuItem(Icons.message, "Messages", () {
            Get.toNamed(AppRoutes.messageUserList);
          }),
          _buildMenuItem(Icons.outbond_outlined, "Apply Leave", () {
            Get.toNamed(AppRoutes.leave_management);
          }),
          _buildMenuItem(Icons.outbond_outlined, "Leave Record", () {
            Get.toNamed(AppRoutes.leave_page);
          }),
          _buildMenuItem(Icons.calendar_today, "Appointments", () {
            Get.toNamed(AppRoutes.patient_appointment);
          }),
          _buildMenuItem(Icons.perm_contact_cal_sharp, "Patients", () {
            Get.toNamed(AppRoutes.patients_page);
          }),
        ];

      default:
        return [
          const ListTile(
            title: Text("No menu available"),
          ),
        ];
    }
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Get.theme.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
