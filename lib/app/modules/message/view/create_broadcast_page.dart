import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_list_model.dart';
import '../../../global/global.dart';
import '../../../socket/socket_service.dart';
import '../../user/controller/user_list_controller.dart';

class CreateBroadcastPage extends StatefulWidget {
  final String? broadcastId;   // for edit mode
  final String? title;         // prefill
  final List<String>? preselectedRecipients;

  CreateBroadcastPage({
    this.broadcastId,
    this.title,
    this.preselectedRecipients,
  });
  @override
  _CreateBroadcastPageState createState() => _CreateBroadcastPageState();
}

class _CreateBroadcastPageState extends State<CreateBroadcastPage>
    with SingleTickerProviderStateMixin {
  final SocketService socketService = Get.put(SocketService());
  final TextEditingController titleController = TextEditingController();
  final UserListController userListController = Get.put(UserListController());

  final RxList<UserListModel> selectedUsers = <UserListModel>[].obs;

  late TabController _tabController;
  bool get isEditMode => widget.broadcastId != null;

  @override
  void initState() {
    super.initState();

    // prefill title if edit mode
    if (widget.title != null) {
      titleController.text = widget.title!;
    }

    _tabController = TabController(length: 2, vsync: this);

    userListController.fetchStaffList(); // doctors
    userListController.fetchUserList();  // patients

    // Preselect recipients in edit mode
    everAll([userListController.staffList, userListController.userList], (_) {
      if (isEditMode && widget.preselectedRecipients != null) {
        final all = [
          ...userListController.staffList,
          ...userListController.userList
        ];
        selectedUsers.assignAll(
          all.where((u) => widget.preselectedRecipients!.contains(u.id)).toList(),
        );
      }
    });

    // socket listeners
    socketService.listenForBroadcastCreated((data) {
      Get.back(result: true);
      Get.snackbar("Success", data["message"] ?? "Broadcast created");
    });

    socketService.listenForBroadcastUpdated((data) {
      Get.back(result: true);
      Get.snackbar("Success", data["message"] ?? "Broadcast updated");
    });
  }
  // void initState() {
  //   super.initState();
  //   socketService.listenForBroadcastCreated((data) {
  //     Get.back();
  //     Get.snackbar("Success", data["message"] ?? "Broadcast created");
  //   });
  //   _tabController = TabController(length: 2, vsync: this);
  //
  //   userListController.fetchStaffList(); // doctors
  //   userListController.fetchUserList();  // patients
  //   // TODO: fetch doctor list + patient list
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Broadcast" : "Create Broadcast"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Enter broadcast name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Obx(() => SizedBox(
            height: selectedUsers.isEmpty ? 0 : 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedUsers.length,
              itemBuilder: (context, index) {
                final user = selectedUsers[index];
                return Chip(
                  label: Text( "${user.firstname ?? ''} ${user.lastname ?? ''}"), // replace with user name
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => selectedUsers.removeAt(index),
                );
              },
            ),
          )),
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: "Doctors"), Tab(text: "Patients")],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildUserList("doctor"),
                buildUserList("patient"),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() => selectedUsers.isEmpty
          ? const SizedBox.shrink()
          : FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          // final socketService = Get.find<SocketService>();
          final ids = selectedUsers.map((u) => u.id!).toList();
          if (isEditMode) {
            socketService.editBroadcast(
              Global.userId!,
              widget.broadcastId!,
              titleController.text,
              ids,
            );
          }
          else {
            socketService.createBroadcast(
              Global.userId!,
              titleController.text,
              ids,
            );
          }

        },
      )),
    );
  }

  Widget buildUserList(String type) {
    // final users = type == "doctor"
    //     ? Get.find<UserListController>().staffList
    //     : Get.find<UserListController>().userList;
    final users = type == "doctor"
        ? userListController.staffList
        : userListController.userList;


    return Obx(() => ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Obx(() {
        final selected =  selectedUsers.any((u) => u.id == user.id);
        // selectedUsers.contains(user.id);

        return ListTile(
          title: Text('${user.firstname} ${user.lastname}'),
          trailing: selected
              ?  Icon(Icons.check_circle, color: Get.theme.primaryColor)
              : const Icon(Icons.radio_button_unchecked),
          onTap: () {
            if (selected) {
              // selectedUsers.remove(user.id);
              selectedUsers.removeWhere((u) => u.id == user.id);
            } else {
              // selectedUsers.add(user.id!);
              selectedUsers.add(user);
            }
          },
        );
      });
      },
    ));
  }
}
