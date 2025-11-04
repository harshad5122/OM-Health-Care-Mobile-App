
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:om_health_care_app/app/modules/auth/controllers/auth_controller.dart';
// 1. Import the Notificationcontroller
import '../data/controllers/notification_controller.dart';
import '../data/models/staff_list_model.dart';
import '../global/global.dart';
import '../modules/appointment/controller/appointment_controller.dart';
import '../modules/appointment/views/booking_calendar_view.dart';
import '../routes/app_routes.dart';

class CustomDrawer extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());
  // 2. Initialize the Notificationcontroller
  final Notificationcontroller notificationController =
  Get.put(Notificationcontroller());

  CustomDrawer({
    super.key,
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
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
              ),
              accountName: Text(
                "${Global.userFirstname} ${Global.userLastname}",
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

            // Logout Button with Confirmation Dialog
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildMenuItem(
                // 5. Update call to _buildMenuItem
                Icon(Icons.logout, color: Get.theme.primaryColor),
                "Logout",
                    () {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Are you sure you want to logout?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black87),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      controller.logoutUser();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Get.theme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuForRole(int? role) {
    switch (role) {
      case 1: // User
        return [
          _buildMenuItem(
            Icon(Icons.person, color: Get.theme.primaryColor), // Updated
            "Profile",
                () {
              Get.toNamed(AppRoutes.profile);
            },
          ),
          _buildMenuItem(
            Icon(Icons.message, color: Get.theme.primaryColor), // Updated
            "Messages",
                () {
              Get.toNamed(AppRoutes.messageUserList);
            },
          ),
          _buildMenuItem(
            Icon(Icons.event, color: Get.theme.primaryColor), // Updated
            "Book Appointment",
                () {
              Get.toNamed(AppRoutes.appointment);
            },
          ),
        ];

      case 2: // Admin
        return [
          _buildMenuItem(
            Icon(Icons.person, color: Get.theme.primaryColor), // Updated
            "Profile",
                () {
              Get.back();
            },
          ),
          _buildMenuItem(
            _buildNotificationIcon(), // <-- Use the new badge widget
            "Notification",
                () {
              Get.toNamed(AppRoutes.notification);
            },
          ),
          _buildMenuItem(
            Icon(Icons.message, color: Get.theme.primaryColor), // Updated
            "Messages",
                () {
              Get.toNamed(AppRoutes.messageUserList);
            },
          ),
          _buildMenuItem(
            Icon(Icons.local_hospital, color: Get.theme.primaryColor), // Updated
            "Add Doctor",
                () {
              Get.toNamed(AppRoutes.addDoctor);
            },
          ),
          _buildMenuItem(
            Icon(Icons.group_add, color: Get.theme.primaryColor), // Updated
            "Add User",
                () {
              Get.toNamed(AppRoutes.addUser);
            },
          ),
          _buildMenuItem(
            Icon(Icons.people, color: Get.theme.primaryColor), // Updated
            "Member",
                () {
              Get.toNamed(AppRoutes.member);
            },
          ),
          _buildMenuItem(
            Icon(Icons.event, color: Get.theme.primaryColor), // Updated
            "Book Appointment",
                () {
              Get.toNamed(AppRoutes.appointment);
            },
          ),
          _buildMenuItem(
            Icon(Icons.calendar_month_sharp,
                color: Get.theme.primaryColor), // Updated
            "Appointments",
                () {
              Get.toNamed(AppRoutes.appointment_page);
            },
          ),
          _buildMenuItem(
            Icon(Icons.outbond_outlined,
                color: Get.theme.primaryColor), // Updated
            "Leave",
                () {
              Get.toNamed(AppRoutes.leave_page);
            },
          ),
        ];

      case 3: // Staff
        return [
          _buildMenuItem(
            Icon(Icons.person, color: Get.theme.primaryColor), // Updated
            "Profile",
                () {
              Get.back();
            },
          ),
          _buildMenuItem(
            _buildNotificationIcon(), // <-- Use the new badge widget
            "Notification",
                () {
              Get.toNamed(AppRoutes.notification);
            },
          ),
          _buildMenuItem(
            Icon(Icons.message, color: Get.theme.primaryColor), // Updated
            "Messages",
                () {
              Get.toNamed(AppRoutes.messageUserList);
            },
          ),
          _buildMenuItem(
            Icon(Icons.outbond_outlined,
                color: Get.theme.primaryColor), // Updated
            "Apply Leave",
                () {
              Get.toNamed(AppRoutes.leave_management);
            },
          ),
          _buildMenuItem(
            Icon(Icons.outbond_outlined,
                color: Get.theme.primaryColor), // Updated
            "Leave Record",
                () {
              Get.toNamed(AppRoutes.leave_page);
            },
          ),
          _buildMenuItem(
            Icon(Icons.event, color: Get.theme.primaryColor), // Updated
            "Book Appointment",
                () {
              Get.toNamed(AppRoutes.booking_appointment,
                  arguments: {"doctor": StaffListModel(id: Global.staffId)});
            },
          ),
          _buildMenuItem(
            Icon(Icons.calendar_today, color: Get.theme.primaryColor), // Updated
            "Appointments",
                () {
              Get.toNamed(AppRoutes.patient_appointment);
            },
          ),
          _buildMenuItem(
            Icon(Icons.perm_contact_cal_sharp,
                color: Get.theme.primaryColor), // Updated
            "Patients",
                () {
              Get.toNamed(AppRoutes.patients_page);
            },
          ),
        ];

      default:
        return [
          const ListTile(
            title: Text("No menu available"),
          ),
        ];
    }
  }

  // 3. Create the new widget for the notification icon
  Widget _buildNotificationIcon() {
    return Obx(() {
      int count = notificationController.unreadCount.value;

      return Stack(
        clipBehavior: Clip.none, // Allow badge to show outside the stack
        children: [
          Icon(Icons.notifications, color: Get.theme.primaryColor),
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(), // Show '9+' if count > 9
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

  // 4. Modify _buildMenuItem to accept a Widget
  Widget _buildMenuItem(Widget leadingIcon, String title, VoidCallback onTap) {
    return ListTile(
      leading: leadingIcon, // Use the provided widget
      title: Text(title),
      onTap: onTap,
    );
  }
}