import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/controllers/notification_controller.dart';



class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;

  CustomAppBar({
    Key? key,
    required this.title,
    this.onMenuPressed,
    this.onNotificationPressed,
  }) : super(key: key);

  final Notificationcontroller notificationController = Get.put(Notificationcontroller());

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading:
      Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      // IconButton(
      //   icon: Icon(Icons.menu),
      //   onPressed: onMenuPressed,
      // ),
      actions: [
        Obx(() {
          int unreadCount = notificationController.unreadCount.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: onNotificationPressed,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                )
            ],
          );
        }),
      ],    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
