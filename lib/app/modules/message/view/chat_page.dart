// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:om_health_care_app/app/modules/message/controller/chat_contoller.dart';
// import 'package:om_health_care_app/app/socket/socket_service.dart';
//
// import '../../../global/global.dart';
// import '../component/chat_input_field.dart';
// import '../component/chat_message_bubble.dart';
//
// class ChatPage extends StatefulWidget{
//   final String? receiverId;
//   final String name;
//
//   final ChatController chatController;
//
//    ChatPage({Key? key, this.receiverId, required this.name})
//       : chatController = Get.put(ChatController(receiverId: receiverId)),
//         super(key: key);
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//  late final ChatController chatController;
//  final ScrollController _scrollController = ScrollController();
//
//  @override
//   void initState() {
//     super.initState();
//     chatController = Get.put(ChatController(receiverId: widget.receiverId));
//     final socketService = Get.find<SocketService>();
//     socketService.emitUserOnline(Global.userId??'');
//   }
//
//   @override
//   void dispose() {
//    final socketService = Get.find<SocketService>();
//    socketService.emitUserLeftMessagePage(Global.userId??'');
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.name),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Obx(() {
//               return ListView.builder(
//                 controller: _scrollController,
//                 reverse: true,
//                 itemCount: widget.chatController.messages.length,
//                 itemBuilder: (context, index) {
//                   var message = widget.chatController.messages[index];
//                   bool isMe = message.senderId == Global.userId;
//
//                   DateTime messageDate = message.createdAt;
//                   String formattedDate =
//                   DateFormat('dd-MM-yyyy').format(messageDate);
//
//                   bool showDateHeader = index ==
//                       widget.chatController.messages.length - 1 ||
//                       DateFormat('dd-MM-yyyy').format(
//                           widget.chatController.messages[index + 1].createdAt) !=
//                           formattedDate;
//
//
//                   bool showSenderName = index == widget.chatController.messages.length - 1 ||
//                       widget.chatController.messages[index + 1].senderId != message.senderId ||
//                       DateFormat('dd-MM-yyyy').format(widget.chatController.messages[index + 1].createdAt) != formattedDate ||
//                       (widget.chatController.messages[index + 1].createdAt.isBefore(message.createdAt.add(Duration(minutes: -3))));                        // widget.chatController.messages[index + 1].createdAt.difference(message.createdAt).inMinutes >= 3;
//
//                   return Column(
//                     children: [
//                       if (showDateHeader)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Center(
//                             child: Text(
//                               formattedDate,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ChatBubble(message: message, isMe: isMe,showSenderName: showSenderName, ),
//                     ],
//                   );
//                 },
//               );}),
//           ),
//           ChatInputField(
//             receiverId: widget.receiverId??'',
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/modules/message/controller/chat_contoller.dart';
import 'package:om_health_care_app/app/socket/socket_service.dart';

import '../../../global/global.dart';
import '../component/chat_input_field.dart';
import '../component/chat_message_bubble.dart';

class ChatPage extends StatefulWidget{
  final String? receiverId;
  final String name;

  // No longer initialize controller in constructor, will be done in initState
  ChatPage({Key? key, this.receiverId, required this.name}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController chatController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize the controller in initState
    chatController = Get.put(ChatController(receiverId: widget.receiverId));
    final socketService = Get.find<SocketService>();
    socketService.emitUserOnline(Global.userId??'');
  }

  @override
  void dispose() {
    final socketService = Get.find<SocketService>();
    socketService.emitUserLeftMessagePage(Global.userId??'');
    chatController.dispose(); // Dispose the controller when the page is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: _scrollController,
                reverse: true, // Display latest messages at the bottom
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  var message = chatController.messages[index];
                  bool isMe = message.senderId == Global.userId;

                  DateTime messageDate = message.createdAt;
                  // String formattedDate = DateFormat('dd MMMM yyyy').format(messageDate);
                  String formattedDate = getFormattedDate(messageDate);

                  // Determine if a date header should be shown
                  bool showDateHeader = false;
                  if (index == chatController.messages.length - 1) { // First message in reversed list
                    showDateHeader = true;
                  } else {
                    DateTime previousMessageDate = chatController.messages[index + 1].createdAt;
                    // if (DateFormat('dd MMMM yyyy').format(previousMessageDate) != formattedDate) {
                    //   showDateHeader = true;
                    // }
                    if (messageDate.year != previousMessageDate.year ||
                        messageDate.month != previousMessageDate.month ||
                        messageDate.day != previousMessageDate.day) {
                      showDateHeader = true;
                    }
                  }

                  return Column(
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          // child: Chip(
                          //   label: Text(
                          //     formattedDate,
                          //     style: const TextStyle(
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          //   backgroundColor: Colors.grey.shade700,
                          // ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                        ),
                      // Pass message and isMe to ChatBubble
                      ChatBubble(message: message, isMe: isMe),
                    ],
                  );
                },
              );
            }),
          ),
          ChatInputField(
            receiverId: widget.receiverId??'',
          ),
        ],
      ),
    );
  }

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return "Today";
    } else if (msgDate == yesterday) {
      return "Yesterday";
    } else if (now.difference(msgDate).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

}




