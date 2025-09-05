import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:om_health_care_app/app/modules/message/controller/chat_contoller.dart';
import 'package:om_health_care_app/app/socket/socket_service.dart';

import '../../../global/global.dart';

class ChatPage extends StatefulWidget{
  final String? receiverId;
  final String name;

  final ChatController? chatController;

  const ChatPage({super.key, this.receiverId, required this.name, this.chatController});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
 late final ChatController chatController;
 final ScrollController _scrollController = ScrollController();

 @override
  void initState() {
    super.initState();
    chatController = Get.put(ChatController(receiverId: widget.receiverId));
    final socketService = Get.find<SocketService>();
    socketService.emitUserOnline(Global.userId??'');
  }

  @override
  void dispose() {
   final socketService = Get.find<SocketService>();
   socketService.emitUserLeftMessagePage(Global.userId??'');
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
        ],
      ),
    );
  }
}