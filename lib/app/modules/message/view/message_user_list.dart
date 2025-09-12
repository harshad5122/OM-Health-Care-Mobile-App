// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:om_health_care_app/app/modules/user/controller/user_list_controller.dart';
// import '../../../comms/date_utils.dart';
// import '../../../comms/string_utils.dart';
// import '../../../global/global.dart';
// import '../../../routes/app_routes.dart';
// import '../../../widgets/custom_shimmer.dart';
// import '../../../widgets/custom_tab.dart';
//
// class MessageUserList extends StatefulWidget{
//   @override
//   State<MessageUserList> createState() => _MessageUserListState();
// }
//
// class _MessageUserListState extends State<MessageUserList> with SingleTickerProviderStateMixin {
//   final UserListController controller = Get.put(UserListController());
//
//   TabController? _tabController;
//
// @override
//   void initState() {
//     super.initState();
//     // controller.fetchUserList();
//     if (Global.role == 1) {
//       controller.fetchAdminList();
//     } else if (Global.role == 2) {
//       controller.fetchAdminList();
//       controller.fetchStaffList();
//       controller.fetchUserList();
//       _tabController = TabController(length: 3, vsync: this);
//     } else if (Global.role == 3) {
//       controller.fetchAdminList();
//     }
//   }
//
//
//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();
//   //   controller.fetchUserList();
//   // }
//
//   Widget buildList(List<dynamic> users) {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return ListView.builder(
//           itemCount: 6,
//           itemBuilder: (_, __) => Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             child: CustomShimmer(
//               width: MediaQuery.of(context).size.width * 0.9,
//               height: 40,
//             ),
//           ),
//         );
//       }
//
//       if (users.isEmpty) {
//         return const Center(child: Text("No users found"));
//       }
//
//       return ListView.builder(
//         itemCount: users.length,
//         itemBuilder: (context, index) {
//           final chatUser = users[index];
//           return GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () {
//               Get.toNamed(AppRoutes.chat, arguments: {
//                 'receiverId': chatUser.id,
//                 'name': chatUser.firstname,
//               })?.then((_) {
//                 // reload correct list
//                 if (Global.role == 1 || Global.role == 3) {
//                   controller.fetchAdminList();
//                 } else {
//                   controller.fetchAdminList();
//                   controller.fetchStaffList();
//                   controller.fetchUserList();
//                 }
//               });
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Row(
//                             children: [
//                               Stack(
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   CircleAvatar(
//                                     backgroundColor: Colors.grey.shade400,
//                                     child: Text(
//                                       StringUtils.getInitials(
//                                           '${chatUser.firstname} ${chatUser.lastname}'),
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 1,
//                                     left: 1,
//                                     child: Container(
//                                       width: 9,
//                                       height: 9,
//                                       decoration: BoxDecoration(
//                                         color: Get.theme.scaffoldBackgroundColor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 2,
//                                     left: 2,
//                                     child: Container(
//                                       width: 6,
//                                       height: 6,
//                                       decoration: BoxDecoration(
//                                         color: chatUser.isOnline == true
//                                             ? Colors.green
//                                             : Get.theme.unselectedWidgetColor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '${chatUser.firstname} ${chatUser.lastname}',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     Text(
//                                       chatUser.email ?? '',
//                                       style: TextStyle(
//                                           color: Colors.grey.shade500),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           DateUtilsHelper.formatDate("${chatUser.createdAt}"),
//                           style: TextStyle(
//                               color: Get.theme.dividerColor,
//                               fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(thickness: 0.2,)
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text("Message"),
//       ),
//       body: Column(
//         children: [
//         Wrap(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: SizedBox(
//                           height: 40,
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: "Search",
//                               prefixIcon: const Icon(Icons.search),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               contentPadding: EdgeInsets.symmetric(
//                                   vertical: 0, horizontal: 12),
//                             ),
//                             onChanged: (value) {
//                               controller.searchText.value = value;
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           if (Global.role == 2 && _tabController != null) ...[
//             // Tab menu (Admin, Doctor, Patient)
//             CustomTab(
//               controller: _tabController!,
//               tabs: const ["Admin", "Doctor", "Patient"],
//             ),
//           ],
//           Expanded(child: Obx(() {
//             if (controller.isLoading.value) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if(Global.role == 2){
//               return TabBarView(
//                 controller: _tabController,
//                 children: [
//                   buildList(controller.filteredAdminList),
//                   buildList(controller.filteredStaffList),
//                   buildList(controller.filteredUserList),
//                 ],
//               );
//             }else if (Global.role == 1 || Global.role == 3) {
//               return buildList(controller.filteredAdminList);
//             } else {
//               return const Center(child: Text("No data available"));
//             }
//           }
//           )
//           )
//         ],
//       )
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../comms/date_utils.dart';
import '../../../comms/string_utils.dart';
import '../../../global/global.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_shimmer.dart';
import '../../../widgets/custom_tab.dart';
import '../controller/chat_user_controller.dart';

class MessageUserList extends StatefulWidget {
  @override
  State<MessageUserList> createState() => _MessageUserListState();
}

class _MessageUserListState extends State<MessageUserList>
    with SingleTickerProviderStateMixin {
  final ChatUserController controller = Get.put(ChatUserController());

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    controller.fetchChatUsers();

    if (Global.role == 2) {
      _tabController = TabController(length: 3, vsync: this);
    }
  }

  Widget buildList(List<dynamic> users) {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: CustomShimmer(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 40,
            ),
          ),
        );
      }

      if (users.isEmpty) {
        return const Center(child: Text("No users found"));
      }

      users.sort((a, b) {
        final aDate = a.lastMessage?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.lastMessage?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate); // descending order
      });

      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final chatUser = users[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Get.toNamed(AppRoutes.chat, arguments: {
                'receiverId': chatUser.userId,
                'name': chatUser.name,
              })?.then((_) {
                controller.fetchChatUsers();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade400,
                                child: Text(
                                  StringUtils.getInitials(chatUser.name),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatUser.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Text(
                                    //   chatUser.messagePreview,
                                    //   style: TextStyle(
                                    //       color: Colors.grey.shade500),
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    Text(
                                      (chatUser.messagePreview != null && chatUser.messagePreview.trim().isNotEmpty)
                                          ? chatUser.messagePreview
                                          : "No message yet - start your first chat!",
                                      style: TextStyle(color: Colors.grey.shade500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (chatUser.lastMessage?.createdAt != null)
                              Text(
                                DateUtilsHelper.formatDate(
                                    chatUser.lastMessage!.createdAt.toString()),
                                style: TextStyle(
                                    color: Get.theme.dividerColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            if (chatUser.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  chatUser.unreadCount.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 0.2),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Message")),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                onChanged: (value) {
                  controller.searchText.value = value;
                },
              ),
            ),
          ),

          if (Global.role == 2 && _tabController != null) ...[
            CustomTab(
              controller: _tabController!,
              tabs: const ["Admin", "Doctor", "Patient"],
            ),
          ],

          Expanded(child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (Global.role == 2 && _tabController != null) {
              return TabBarView(
                controller: _tabController,
                children: [
                  buildList(controller.adminList),
                  buildList(controller.staffList),
                  buildList(controller.patientList),
                ],
              );
            } else if (Global.role == 1) {
              return buildList(controller.adminList);
            }  else if (Global.role == 3) {
              return buildList(controller.adminList);
            } else {
              return const Center(child: Text("No data available"));
            }
          })),
        ],
      ),
    );
  }
}
