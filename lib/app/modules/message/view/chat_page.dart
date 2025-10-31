import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/modules/message/controller/chat_contoller.dart';
import 'package:om_health_care_app/app/modules/message/view/recipient_list.dart';
import 'package:om_health_care_app/app/socket/socket_service.dart';

import '../../../global/global.dart';
import '../component/chat_input_field.dart';
import '../component/chat_message_bubble.dart';

class ChatPage extends StatefulWidget{
  final String? receiverId;
  final String name;
  final bool? isBroadcast;

  // No longer initialize controller in constructor, will be done in initState
  ChatPage({Key? key, this.receiverId, required this.name, this.isBroadcast}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController chatController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatController = Get.put(ChatController(receiverId: widget.receiverId,  isBroadcast: widget.isBroadcast));
    final socketService = Get.find<SocketService>();
    // socketService.emitUserOnline(Global.userId??'');
    final currentUserId = Global.userId;
    // Once messages are loaded, calculate unread position

    if (currentUserId != null) {
      socketService.emitUserOnline(currentUserId);
    }
    // ever(chatController.messages, (_) {
    //   chatController.setUnreadMarker();
    // });
  }


  @override
  void dispose() {
    final socketService = Get.find<SocketService>();
    socketService.emitUserLeftMessagePage(Global.userId??'');

    chatController.markAllAsRead();

    chatController.dispose(); // Dispose the controller when the page is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          if (widget.isBroadcast == true)
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {
                // open RecipientsListPage
                Get.to(() => RecipientsListPage(
                  broadcastId: widget.receiverId ?? "",
                  broadcastTitle: widget.name,
                ));
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
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

                        if (chatController.unreadIndex.value == index && chatController.unreadMarkerShown.value)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${chatController.unreadCount} unread messages",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
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
              // receiverId: widget.receiverId??'',
              receiverId: widget.isBroadcast == true ? null : widget.receiverId, // only for normal chat
              broadcastId: widget.isBroadcast == true ? widget.receiverId : null, // pass receiverId as broadcastId in broadcast mode
            ),
          ],
        ),
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




