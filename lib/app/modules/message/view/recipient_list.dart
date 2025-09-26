import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../comms/string_utils.dart';
import '../controller/recipient_controller.dart';
import 'create_broadcast_page.dart';

class RecipientsListPage extends StatelessWidget {
  final String broadcastId;
  final String broadcastTitle;

  RecipientsListPage({
    required this.broadcastId,
    required this.broadcastTitle,
  });

  final RecipientController controller = Get.put(RecipientController());

  @override
  Widget build(BuildContext context) {
    // Fetch recipients when page is first built
    controller.fetchRecipients(broadcastId);

    return Scaffold(
      appBar: AppBar(title: Text(broadcastTitle)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Get.theme.primaryColor),
              title: const Text("Edit Broadcast"),
              onTap: () async{
                // Get.to(() => CreateBroadcastPage(
                //   broadcastId: broadcastId,
                //   title: broadcastTitle,
                //   preselectedRecipients: controller.recipients
                //       .map((r) => r.id)
                //       .toList(),
                // ));
                final updated = await Get.to(() => CreateBroadcastPage(
                  broadcastId: broadcastId,
                  title: broadcastTitle,
                  preselectedRecipients:
                  controller.recipients.map((r) => r.id).toList(),
                ));
                if (updated == true) {
                  controller.fetchRecipients(broadcastId);
                }
              },
            ),
            const Divider(color: Colors.grey),
            ...controller.recipients.map((r) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade400,
                child: Text(
                  StringUtils.getInitials(r.name),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text(r.name),
              subtitle: Text("${r.email}"),
              isThreeLine: true,
            )),
          ],
        );
      }),
    );
  }
}
