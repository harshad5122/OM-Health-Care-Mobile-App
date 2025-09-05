import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/upload_file_model.dart';
import '../../../data/models/user_detail_model.dart';
import '../../../enum/message.dart';
import '../../../global/global.dart';
import '../../../global/tokenStorage.dart';
import '../../../socket/socket_service.dart';
import '../../../utils/api_constants.dart';
import '../../upload_file/controller/upload_file_controller.dart';
// import '../models/group_message_model.dart';
import 'package:http/http.dart' as http;
import '../../user/controller/user_list_controller.dart';
import 'download_controller.dart';

class ChatController extends GetxController {
  final String? receiverId;
  final String? roomId;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  // final RxList<GroupMessageModel> groupMessages = <GroupMessageModel>[].obs;
  final RxString messageText = ''.obs;
  final TextEditingController textController = TextEditingController();
  final selectedMeetingTime = Rxn<DateTime>();

  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  final SocketService socketService = Get.put(SocketService());
  final UploadFileController uploadController = Get.put(UploadFileController());

  Rx<MessageModel?> replyMessage = Rx<MessageModel?>(null);
  // Rx<GroupMessageModel?> replyGroupMessage = Rx<GroupMessageModel?>(null);

  final ScrollController _scrollController = ScrollController();
  // final notificationService = Get.find<NotificationService>();

  // final ChatListController chatController = Get.put(ChatListController());
  final UserListController chatController = Get.put(UserListController());

  ChatController({this.roomId, this.receiverId});

  @override
  void onInit() {
    super.onInit();
    // if(roomId != null){
    //   fetchGroupMessages(roomId);
    // }else{
      fetchMessage(receiverId);
    // }
    initSocket(userId: Global.userId??'', roomId: roomId);
    _registerSocketListeners();
  }

  @override
  void onClose() {
    if (socketService.socket != null) {
      socketService.socket!.off("chat_message");
      // socketService.socket?.off("group_message");
    }
    super.onClose();
  }

  void _registerSocketListeners() {
    socketService
      ..listenForUpdatedMessages(_onMessageUpdated)
      ..listenForDeletedMessages(_onMessageDeleted)
      // ..listenToGroupMessageUpdate(_onGroupMessageUpdated)
      // ..listenToGroupMessageDelete(_onGroupMessageDeleted)
      ..listenForSeenMessages(_onMessageSeen)
      ..listenForDeliveredMessages(_onMessageDelivered);
      // ..listenForSeenGroupMessages(_onGroupMessageSeen)
      // ..listenForDeliveredGroupMessages(_onGroupMessageDelivered);
  }


  void initSocket({required String userId, String? roomId}) {

    print('Room Id :::: ${roomId}');

    socketService.connectSocket(userId);
    if(roomId != null){
      socketService.joinRoom(userId, roomId);
    }

    socketService.on('chat_message', (data) async{
      // chatController.fetchChatList();
      chatController.fetchUserList();
      print('📩 Received message: $data');
      print("Raw socket data received: ${jsonEncode(data)}");
      // messages.add(data);
      try {
        // if(roomId != null){
        //   final message = GroupMessageModel.fromJson(data);
        //   print('Before group senderDetails ::: ${message.senderDetails}');
        //   if (message.senderDetails == null || message.senderDetails!.isEmpty) {
        //     final user = await fetchUserDetails(message.senderId??'');
        //     if (user != null){
        //       message.senderDetails = [user];
        //       print('After group senderDetails ::: ${message.senderDetails}');
        //     }else {
        //       print("⚠️ User details not found for ID: ${message.senderId}");
        //     }
        //   }
        //   //messages.add(message);
        //   groupMessages.insert(0, message);
        //   update();
        //
        // }
        // else{
          final message = MessageModel.fromJson(data);
          print('Before chat senderDetails ::: ${message.senderDetails}');
          if (message.senderDetails == null || message.senderDetails!.isEmpty) {
            final user = await fetchUserDetails(message.senderId??'');
            if (user != null){
              message.senderDetails = [user];
              print('After chat senderDetails ::: ${message.senderDetails}');
            }else {
              print("⚠️ User details not found for ID: ${message.senderId}");
            }

          }
          //messages.add(message);
          messages.insert(0, message);
          update();
        // }
      } catch (e, stack) {
        print("❌ Failed to parse message: $e");
        print(stack);
      }
    });




    socketService.on('receiveNotification', (data) {
      print('🔔 Notification: $data');
      try{
        final mapData = Map<String, dynamic>.from(data);
        print('🔍 Map Parsed Notification: $mapData');
        print('📎 Attachments: ${mapData['attachmentDetails']}');
        final notification = MessageModel.fromJson(mapData);
        // final groupNotification = GroupMessageModel.fromJson(mapData);
        // if(mapData['isGroup'] == true){
        //   handleGroupMessageNotification(groupNotification);
        // }else{
        //   handleMessageNotification(notification);
        // }
      }catch (e, stack) {
        print(" Failed to parse notification: $e");
        print(stack);
      }
      // notifications.add(Map<String, dynamic>.from(data));
    });

    // Listen for delivery confirmations
    socketService.on('message_delivered', (data) {
      print('✅ Delivered: $data');
      // if(roomId != null){
      //   _onGroupMessageDelivered(data);
      // }else{
        _onMessageDelivered(data);
      // }
    });

    // Optional
    socketService.on('joined_room', (data) {
      print('🚪 Joined room: $data');
    });
  }

  // void sendMessage(String messageText, {String? replyTo}) {
  //   final message = {
  //     'sender_id': Global.userId,
  //     'room_id': roomId,
  //     'message': messageText,
  //     if (replyTo != null) 'replyTo': replyTo,
  //   };
  //
  //   socketService.sendMessage(message);
  // }


  void setReplyToMessage(MessageModel message) {
    replyMessage.value = message;
  }

  // void setReplyToGroupMessage(GroupMessageModel groupMessage) {
  //   replyGroupMessage.value = groupMessage;
  // }

  void clearReplyToMessage() {
    replyMessage.value = null;
  }

  // void clearReplyToGroupMessage() {
  //   replyGroupMessage.value = null;
  // }

  void sendMessage(String receiverId, MessageType type) async{
    if (messageText.value.isNotEmpty && socketService.socket != null) {
      //final receiver = await fetchUserDetails(receiverId);
      final message = MessageModel(
        senderId: Global.userId!,
        receiverId: receiverId,
        message: messageText.value,
        attachmentId: [],
        messageType: type.toString().split('.').last,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageStatus: 'sent',
        replyTo: replyMessage.value,
        senderDetails: [UserDetails(
          id: Global.userId!,
          firstname: Global.userFirstname!,
          lastname: Global.userLastname!,
          email: Global.email!,
          // other fields if needed
        )],
        // receiverDetails: [receiver!],
        dateTime: selectedMeetingTime.value,
        replyToDetails: replyMessage.value,
      );

      print('Sending Zoom link at: ${selectedMeetingTime.value}');
      print('Saved in message model: ${message.dateTime}');

      messages.insert(0, message); // insert at top since ListView is reversed
      _scrollToBottom();
      update(); // notify GetX

      socketService.sendMessage(message);

      selectedMeetingTime.value = null;
      // chatController.fetchChatList();
      chatController.fetchAdminList();
      messageText.value = "";
      clearReplyToMessage();

    }
  }

  Future<void> uploadAndSendFile(String receiverId, {List<File>? file}) async {
    if (file == null || file.isEmpty) return;
    for (var files in file) {
      UploadFile? uploadedFile = await uploadController.uploadFile(files);
      if (uploadedFile != null && socketService.socket != null) {
        final message = MessageModel(
            senderId: Global.userId!,
            receiverId: receiverId,
            attachmentId: uploadedFile.id != null ? [uploadedFile.id!] : null,
            messageType: uploadedFile.fileType,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            messageStatus: 'sent',
            replyTo: replyMessage.value,
            senderDetails: [UserDetails(
              id: Global.userId!,
              firstname: Global.userFirstname!,
              lastname: Global.userLastname!,
              email: Global.email!,
            )],
            replyToDetails: replyMessage.value,
            attachmentDetails: [
              UploadFile(
                id: uploadedFile.id,
                size: uploadedFile.size,
                name: uploadedFile.name,
                url: uploadedFile.url,
                fileType: uploadedFile.fileType,
              )
            ]
        );

        messages.insert(0, message);
        _scrollToBottom();
        update();

        socketService.sendMessage(message);
        clearReplyToMessage();

        //  Map<String, dynamic> messageData = {
        //    "senderId": message.senderId,
        //    "receiverId": message.receiverId,
        //    "message": message.message,
        //    "attachmentId": message.attachmentId ?? "",
        //    "messageType": message.messageType,
        //    "attachmentDetails": message.attachmentDetails?.map((e) => e.toJson()).toList()
        //  };
        //
        // print("Sending message to socket: $messageData");
        //
        //  socketService.socket!.emit("chat_message", message.toJson());
        //  socketService.socket?.emit("new_message", message.toJson());
        //  messages.add(message);
      }
    }
  }

  void sendLocation(Position position, String receiverId,) {
    final message = MessageModel(
      senderId: Global.userId!,
      receiverId: receiverId,
      messageType: "location",
      latitude: position.latitude,
      longitude: position.longitude,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messageStatus: 'sent',
      replyTo: replyMessage.value,
      senderDetails: [UserDetails(
        id: Global.userId!,
        firstname: Global.userFirstname!,
        lastname: Global.userLastname!,
        email: Global.email!,
      )],
      replyToDetails: replyMessage.value,
    );

    messages.insert(0, message);
    _scrollToBottom();
    update();

    socketService.sendMessage(message);
    clearReplyToMessage();

    //!.ocketService.socket!.emit("chat_message", message.toJson());
    // socketService.socket?.emit("new_message", message.toJson());
    // messages.add(message);
  }

  void receiveMessage(Map<String, dynamic> data) async{
    final newMessage = MessageModel.fromJson(data);
    print('Before new messsage sender details ===> ${newMessage.senderDetails}');
    if(newMessage.senderDetails == null || newMessage.senderDetails!.isEmpty){
      final user = await fetchUserDetails(newMessage.senderId??'');
      newMessage.senderDetails = [user!];
      print('After new messsage sender details ===> ${newMessage.senderDetails}');
    }
    //  messages.add(MessageModel.fromJson(data));
    messages.insert(0, newMessage); // Show instantly at top (because reverse: true)
    _scrollToBottom();
    update();
  }

  // void newMessage(Map<String, dynamic> data) {
  //   final msg = GroupMessageModel.fromJson(data);
  //   groupMessages.insert(0, msg);
  //   update();
  // }




  Future<UserDetails?> fetchUserDetails(String receiverId) async {
    String? token = await TokenStorage.getToken();
    // final url = '${ApiConstants.GET_USER_DETAILS}/$receiverId';
    final url = '${ApiConstants.GET_USER_PROFILE}/$receiverId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserDetails.fromJson(jsonData['body']);
      } else {
        print('Failed to fetch user details: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    return null;
  }


  Future<void> fetchMessage(String? receiverId) async {
    String? token = await TokenStorage.getToken();
    final url = '${ApiConstants.GET_MESSAGE_LIST}?user_id=$receiverId';
    print('fetch message url : ${url}');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['body'] is List) {
          messages.value = (jsonData['body'] as List)
              .map((msg) => MessageModel.fromJson(msg))
              .toList();
        } else {
          List<dynamic> messageList = jsonData['body'];
          messages.value =
              messageList.map((msg) => MessageModel.fromJson(msg)).toList();
        }
        print('message value ==> ${messages.value}');
      } else {
        print("Failed to load messages: ${response.body}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  void _onMessageUpdated(Map data) {
    //  final jsonData = Map<String, dynamic>.from(data);
    final index = messages.indexWhere((m) => m.messageId == data['messageId']);
    if (index != -1) {
      //messages[index] = MessageModel.fromJson(jsonData);
      messages[index] = messages[index].copyWith(message: data['message'],);
      messages.refresh();
    }
  }

  // void _onGroupMessageUpdated(Map data) {
  //   // final jsonData = Map<String, dynamic>.from(data);
  //   final index = groupMessages.indexWhere((m) => m.id == data['messageId']);
  //   if (index != -1) {
  //     // groupMessages[index] = GroupMessageModel.fromJson(jsonData);
  //     groupMessages[index] = groupMessages[index].copyWith(message: data['message'],);
  //     groupMessages.refresh();
  //   }
  // }

  // void _onMessageDeleted(Map data) {
  //   final index = messages.indexWhere((m) => m.messageId == data['messageId']);
  //   if (index != -1) {
  //     messages.removeAt(index);
  //   }
  // }
  void _onMessageDeleted(Map data) {
    messages.removeWhere((m) => m.messageId == data['messageId']);
  }

  // void _onGroupMessageDeleted(Map data) {
  //   // final index = groupMessages.indexWhere((m) => m.id == data['messageId']);
  //   // if (index != -1) {
  //   //   // final updated = groupMessages[index].copyWith(isDeleted: true);
  //   //   // groupMessages[index] = updated;
  //   //   groupMessages.removeAt(index);
  //   // }
  //   groupMessages.removeWhere((m) => m.id == data['messageId']);
  // }

  void _onMessageSeen(Map data) {
    final index = messages.indexWhere((msg) => msg.messageId == data['_id']);
    if (index != -1) {
      messages[index].messageStatus = data['message_status'];
      messages.refresh();
    }
  }

  void _onMessageDelivered(Map<String, dynamic> data) {
    final messageId = data['_id'];
    if (messageId == null) {
      print('⚠️ Warning: Received null messageId in delivered event');
      return;
    }
    final index = messages.indexWhere((msg) => msg.messageId == messageId);
    if (index != -1) {
      messages[index].messageStatus = data['message_status'] ?? messages[index].messageStatus;
      messages.refresh();
    }
  }

  // void _onGroupMessageSeen(Map data) {
  //   final index = groupMessages.indexWhere((msg) => msg.id == data['_id']);
  //   if (index != -1) {
  //     groupMessages[index].messageStatus = data['message_status'];
  //     groupMessages.refresh();
  //   }
  // }

  // void _onGroupMessageDelivered(Map data) {
  //   final messageId = data['_id'];
  //   if (messageId == null) {
  //     print('⚠️ Warning: Received null messageId in delivered event');
  //     return;
  //   }
  //   final index = groupMessages.indexWhere((msg) => msg.id == messageId);
  //   if (index != -1) {
  //     groupMessages[index].messageStatus = data['message_status'];
  //     groupMessages.refresh();
  //   }
  // }

  //
  // void _onGroupMessageDeleted(Map data) {
  //   final index = groupMessages.indexWhere((m) => m.id == data['messageId']);
  //   if (index != -1) {
  //     groupMessages.removeAt(index);
  //   }
  // }

  void updateMessage(String? messageId, String newText) {
    if (messageId != null) {
      socketService.updateMessage(messageId, newText);
      fetchMessage(receiverId);
    }
  }

  void deleteMessage(String? messageId) {
    if (messageId != null) socketService.deleteMessage(messageId);
  }

  void markMessageAsSeen(String messageId, String userId, bool isGroup) {
    socketService.emitMessageSeen(messageId, userId, isGroup);
  }

  // void _onMessageSeen(Map data) {
  //   String messageId = data['_id'];
  //   String status = data['message_status'];
  //
  //   int index = messages.indexWhere((msg) => msg.messageId == messageId);
  //   if (index != -1) {
  //     messages[index].messageStatus = status;
  //     update(); // or setState if using StatefulWidget
  //   }
  // }



  // Group Methods

  // void sendGroupMessage(String roomId, MessageType type) {
  //   if (messageText.value.isNotEmpty && socketService.socket != null) {
  //     final groupMessage = GroupMessageModel(
  //       senderId: Global.userId!,
  //       roomId: roomId,
  //       message: messageText.value,
  //       attachmentId: [],
  //       messageType: type.toString().split('.').last,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //       messageStatus: 'sent',
  //       isDeleted: false,
  //       status: 1,
  //       replyTo: replyGroupMessage.value,
  //       senderDetails: [UserDetails(
  //         id: Global.userId!,
  //         firstname: Global.userFirstname!,
  //         lastname: Global.userLastname!,
  //         email: Global.email!,
  //         // other fields if needed
  //       )],
  //       dateTime: selectedMeetingTime.value,
  //       replyToDetails: replyGroupMessage.value,
  //     );
  //
  //     groupMessages.insert(0, groupMessage);
  //     _scrollToBottom();
  //     update();
  //
  //     socketService.sendGroupMessage(groupMessage);
  //
  //     // socketService.socket!.emit("chat_message", groupMessage.toJson());
  //     // socketService.socket?.emit("new_message", groupMessage.toJson());
  //     //  groupMessages.add(groupMessage);
  //
  //     // 🔔 Emit Notification to Receiver
  //     // socketService.socket?.emit('receiveNotification', {
  //     //   'receiver_ids': receiverId,
  //     //   'sender_id': Global.userId,
  //     //   'message': messageText.value,
  //     //   'message_type': type.toString().split('.').last,
  //     //   //'type': roomId != null ? 'group-message' : 'message',
  //     // });
  //     chatController.fetchChatList();
  //
  //     messageText.value = "";
  //     clearReplyToGroupMessage();
  //   }
  // }

  // Future<void> uploadAndSendGroupFile(String roomId, {List<File>? files}) async {
  //   if (files == null || files.isEmpty) return;
  //   for (var file in files) {
  //     UploadFile? uploadedFile = await uploadController.uploadFile(file);
  //     if (uploadedFile != null && socketService.socket != null) {
  //       final groupMessage = GroupMessageModel(
  //           senderId: Global.userId!,
  //           roomId: roomId,
  //           message: "",
  //           attachmentId: uploadedFile.id != null ? [uploadedFile.id!] : null,
  //           messageType: uploadedFile.fileType,
  //           createdAt: DateTime.now(),
  //           updatedAt: DateTime.now(),
  //           messageStatus: 'sent',
  //           isDeleted: false,
  //           status: 1,
  //           replyTo: replyGroupMessage.value,
  //           senderDetails: [UserDetails(
  //             id: Global.userId!,
  //             firstname: Global.userFirstname!,
  //             lastname: Global.userLastname!,
  //             email: Global.email!,
  //             // other fields if needed
  //           )],
  //           replyToDetails: replyGroupMessage.value,
  //           attachmentDetails: [
  //             UploadFile(
  //               id: uploadedFile.id,
  //               size: uploadedFile.size,
  //               name: uploadedFile.name,
  //               url: uploadedFile.url,
  //               fileType: uploadedFile.fileType,
  //             )
  //           ]
  //       );
  //       groupMessages.insert(0, groupMessage);
  //       _scrollToBottom();
  //       update();
  //
  //       socketService.sendGroupMessage(groupMessage);
  //       clearReplyToGroupMessage();
  //       // socketService.socket!.emit("chat_message", groupMessage.toJson());
  //       // socketService.socket?.emit("new_message", groupMessage.toJson());
  //       // groupMessages.add(groupMessage);
  //     }
  //   }
  // }

  // void receiveGroupMessage(Map<String, dynamic> data) {
  //   // groupMessages.add(GroupMessageModel.fromJson(data));
  //   final newMessage = GroupMessageModel.fromJson(data);
  //   groupMessages.insert(0, newMessage); // Show instantly at top (because reverse: true)
  //   _scrollToBottom();
  //   update();
  // }

  // void sendGroupLocation(Position position, String roomId,) {
  //   final groupMessage = GroupMessageModel(
  //     senderId: Global.userId!,
  //     roomId: roomId,
  //     messageType: "location",
  //     latitude: position.latitude,
  //     longitude: position.longitude,
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //     messageStatus: 'sent',
  //     replyTo: replyGroupMessage.value,
  //     senderDetails: [UserDetails(
  //       id: Global.userId!,
  //       firstname: Global.userFirstname!,
  //       lastname: Global.userLastname!,
  //       email: Global.email!,
  //       // other fields if needed
  //     )],
  //     replyToDetails: replyGroupMessage.value,
  //   );
  //
  //   groupMessages.insert(0, groupMessage);
  //   _scrollToBottom();
  //   update();
  //
  //   socketService.sendGroupMessage(groupMessage);
  //   clearReplyToGroupMessage();
  //   // socketService.socket!.emit("chat_message", message.toJson());
  //   // socketService.socket?.emit("new_message", message.toJson());
  //   // groupMessages.add(message);
  // }

  // Future<void> fetchGroupMessages(String? roomId) async {
  //   String? token = await TokenStorage.getToken();
  //   final url = '${ApiConstants.GET_GROUP_MESSAGE_LIST}?room_id=$roomId';
  //   print('fetch group message url ==> ${url}');
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': '$token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var jsonData = json.decode(response.body);
  //       if (jsonData['body'] is List) {
  //         groupMessages.value =
  //             GroupMessageModel.fromJsonList(jsonData['body']);
  //       }
  //     }
  //     // if (response.statusCode == 200) {
  //     //   final List<dynamic> jsonData = json.decode(response.body)['body'];
  //     //   groupMessages.assignAll(
  //     //       jsonData.map((e) => GroupMessageModel.fromJson(e)).toList());
  //     // }
  //     else {
  //       print("Failed to load group messages: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error fetching group messages: $e");
  //   }
  // }

  // void updateGroupMessage(String? messageId, String newText) {
  //   socketService.updateGroupMessage(messageId!, roomId ?? '', newText);
  //   fetchGroupMessages(roomId);
  // }
  //
  // void deleteGroupMessage(String? messageId) {
  //   socketService.deleteGroupMessage(messageId!);
  // }
  //
  // void joinGroup(String userId, String roomId) {
  //   socketService.joinRoom(userId, roomId);
  // }
  //
  // void leaveGroup(String userId, String roomId) {
  //   socketService.leaveRoom(userId, roomId);
  // }


  Future<void> _scrollToBottom() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // because reverse: true
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  // void handleMessageNotification(MessageModel notification){
  //   messages.add(notification);
  //
  //   print('notification message type ===> ${notification.messageType}');
  //   print('attachmentDetails ===> ${notification.attachmentDetails}');
  //
  //   final attachments = notification.attachmentDetails;
  //
  //   if(notification.messageType == 'image'){
  //     if (attachments != null && attachments.isNotEmpty) {
  //       notificationService.showNotification(
  //         id: DateTime
  //             .now()
  //             .millisecondsSinceEpoch ~/ 1000,
  //         title: 'New Image Message',
  //         body: notification.message ?? 'You received an image!',
  //         imageUrl: attachments?.first.url, // Pass the URL of the image
  //       );
  //     }else {
  //       print('⚠️ Image message received but attachments are empty or null.');
  //     }
  //   }
  //   else if(notification.messageType == 'document'){
  //     notificationService.showNotification(
  //       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //       title: 'New Document',
  //       body: 'You received a document: ${notification.attachmentDetails?.first.name}',
  //     );
  //   }
  //   else if (notification.messageType == 'video') {
  //     notificationService.showNotification(
  //       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //       title: 'New Video',
  //       body: 'Video',
  //     );
  //   }
  //   else if (notification.messageType == 'audio') {
  //     notificationService.showNotification(
  //       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //       title: 'New Audio',
  //       body: 'Video',
  //     );
  //   }
  //   else if (notification.messageType == 'location') {
  //     notificationService.showNotification(
  //       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //       title: 'New Location',
  //       body: 'Location',
  //     );
  //   }else {
  //     notificationService.showNotification(
  //       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //       title: 'New Message',
  //       body: notification.message ?? '',
  //     );
  //   }
  //
  // }
  //
  // void handleGroupMessageNotification(GroupMessageModel notification){
  //   groupMessages.add(notification);
  //   notificationService.showNotification(
  //     id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //     title: '📢 Group Message',
  //     body: notification.message ?? '',
  //   );
  //   // Get.snackbar(
  //   //   '📢 Group Message',
  //   //   '${notification.message}',
  //   //   snackPosition: SnackPosition.TOP,
  //   //   duration: const Duration(seconds: 3),
  //   //   backgroundColor: Colors.black.withOpacity(0.8),
  //   //   colorText: Colors.white,
  //   // );
  // }

  // Future<String?> createZoomMeetingAPI(DateTime selectedDateTime) async {
  //   final String date = selectedDateTime.toLocal().toIso8601String().split('T')[0]; // "YYYY-MM-DD"
  //   final String time = selectedDateTime.toLocal().toIso8601String().split('T')[1].substring(0, 5); // "HH:MM"
  //   String? token = await TokenStorage.getToken();
  //   final response = await http.post(
  //     Uri.parse(ApiConstants.CREATE_ZOOM_MEETING),
  //     headers: {
  //       'Authorization': '$token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       "topic": "Static Zoom Meeting",
  //       "date": date,
  //       "time": time,
  //       //"start_time": startTime,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final body = jsonDecode(response.body);
  //     selectedMeetingTime.value = DateTime.parse(body['data']['start_time']);
  //     if (body['success'] == true && body['data']?['join_url'] != null) {
  //       messageText.value = body['data']['join_url'];
  //       return body['data']['join_url'];
  //     }
  //   }
  //   return null;
  // }

  // Future<String?> downloadFileToLocal(UploadFile file) async {
  //   try {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final filePath = '${dir.path}/${file.name}';
  //
  //
  //     final existingFile = File(filePath);
  //     if (await existingFile.exists()) {
  //       print("File already exists locally.");
  //       return filePath;
  //     }
  //
  //     final response = await http.get(Uri.parse(file.url!));
  //     if (response.statusCode == 200) {
  //       final localFile = File(filePath);
  //       await localFile.writeAsBytes(response.bodyBytes);
  //       print("Downloaded to: $filePath");
  //       return filePath;
  //     } else {
  //       Get.snackbar("Download failed", "Server error: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Download error: $e");
  //     Get.snackbar("Download failed", "Error: $e");
  //   }
  //   return null;
  // }
  Future<String?> downloadFileToLocal(UploadFile file) async {
    try {
      //final dir = await getApplicationDocumentsDirectory();
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final filePath = '${dir.path}/${file.name}';
      final httpClient = HttpClient();

      final request = await httpClient.getUrl(Uri.parse(file.url!));
      final response = await request.close();

      final bytes = <int>[];
      final total = response.contentLength;
      int received = 0;

      await for (var chunk in response) {
        bytes.addAll(chunk);
        received += chunk.length;

        final progress = received / total;
        Get.find<DownloadController>().setProgress(file.name!, progress);
      }

      final f = File(filePath);
      await f.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  Future<void> downloadAndSaveFile(String url, String fileType) async {
    // Request storage permission
    // final status = await Permission.storage.request();
    // if (!status.isGranted) return;

    // Download the file
    final fileName = url.split('/').last;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Write to a temp file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(response.bodyBytes);

      // Get external storage directory for saving
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return;

      // Save to appropriate subfolder
      final savePath = '${externalDir.path}/$fileType';
      final saveDir = Directory(savePath);
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final finalPath = '$savePath/$fileName';
      await tempFile.copy(finalPath);

      print('$fileType saved to: $finalPath');
    } else {
      print('Failed to download file: ${response.statusCode}');
    }
  }

}
