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
import '../../notification/notification_service.dart';
import '../../upload_file/controller/upload_file_controller.dart';
// import '../models/group_message_model.dart';
import 'package:http/http.dart' as http;
import '../../user/controller/user_list_controller.dart';
import 'download_controller.dart';

class ChatController extends GetxController {
  final String? receiverId;
  final bool? isBroadcast;

  final RxList<MessageModel> messages = <MessageModel>[].obs;

  final RxString messageText = ''.obs;
  final TextEditingController textController = TextEditingController();
  final selectedMeetingTime = Rxn<DateTime>();

  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  final SocketService socketService = Get.put(SocketService());
  final UploadFileController uploadController = Get.put(UploadFileController());

  Rx<MessageModel?> replyMessage = Rx<MessageModel?>(null);


  final ScrollController _scrollController = ScrollController();
  final notificationService = Get.find<NotificationService>();

  // final ChatListController chatController = Get.put(ChatListController());
  final UserListController chatController = Get.put(UserListController());

  // Add this variable to track which message is being edited
  Rx<MessageModel?> editingMessage = Rx<MessageModel?>(null);

  final unreadIndex = (-1).obs;
  final unreadMarkerShown = true.obs;

  ChatController({this.receiverId, this.isBroadcast});

  @override
  void onInit() {
    super.onInit();
    // if(roomId != null){
    //   fetchGroupMessages(roomId);
    // }else{
    if (isBroadcast == true) {
      fetchMessage(null, broadcastId: receiverId);
    } else {
      fetchMessage(receiverId);
    }
    // fetchMessage(receiverId);
    // }

    socketService.connectSocket(Global.userId??'');
    setupSocketListeners();

    initSocket(userId: Global.userId??'');
    _registerSocketListeners();
    socketService.listenForBroadcastAck((data) {
      print("📢 Broadcast ACK received: $data");
      // Get.snackbar("Broadcast", data["message"] ?? "Broadcast sent!");
    });
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
      ..listenForSeenMessages(_onMessageSeen)
      ..listenForDeliveredMessages(_onMessageDelivered);

  }

  int get unreadCount {
    return messages
        .where((msg) => msg.isRead == false && msg.receiverId == Global.userId)
        .length;
  }


  void setUnreadMarker() {
    if (!unreadMarkerShown.value) return;

    final unreadMessages = messages
        .asMap()
        .entries
        .where((entry) => entry.value.isRead == false && entry.value.receiverId == Global.userId)
        .toList();

    if (unreadMessages.isNotEmpty) {
      // Since list is reversed in UI (newest first), we need the LAST unread message in the list
      unreadIndex.value = unreadMessages.last.key;
    } else {
      unreadIndex.value = -1;
    }
  }



  void initSocket({required String userId}) {

    // print('Room Id :::: ${roomId}');

    socketService.connectSocket(userId);
    setUnreadMarker();
    // if(roomId != null){
    //   socketService.joinRoom(userId, roomId);
    // }

    socketService.on('chat_message', (data) async{
      // chatController.fetchChatList();
      chatController.fetchUserList();
      print('📩 Received message: $data');
      print("Raw socket data received: ${jsonEncode(data)}");
      // messages.add(data);
      try {

        final message = MessageModel.fromJson(data);
        print('Before chat senderDetails ::: ${message.senderDetails}');
        if (message.senderDetails == null || message.senderDetails!.isEmpty) {
          final user = await fetchUserDetails(message.senderId??'');
          if (user != null){
            message.senderDetails = [user];
            print('After chat senderDetails ::: ${message.senderDetails}');
          }else {
            print("⚠️User details not found for ID: ${message.senderId}");
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

        handleMessageNotification(notification);

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


  // New methods for editing messages
  void setEditingMessage(MessageModel message) {
    editingMessage.value = message;
    textController.text = message.message ?? ''; // Populate text field with message content
  }

  void clearEditingMessage() {
    editingMessage.value = null;
    textController.clear();
  }


  void setReplyToMessage(MessageModel message) {
    replyMessage.value = message;
  }



  void clearReplyToMessage() {
    replyMessage.value = null;
  }


  void sendMessage(String receiverId, MessageType type , {String? broadcastId}) async{
    final String messageContent = messageText.value.trim();
    // if (messageText.value.isNotEmpty && socketService.socket != null) {
    if (messageContent.isEmpty) return;
      // final String messageContent = messageText.value;

      final currentUserId = Global.userId;
    if (currentUserId == null) return;
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();

      //final receiver = await fetchUserDetails(receiverId);
      final MessageModel message = MessageModel(
        tempId: tempId,
        messageId: tempId,
        senderId: currentUserId,
        receiverId: receiverId,
        message: messageContent,
        attachmentId: [],
        messageType: type.toString().split('.').last,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageStatus: 'sent',

        isDeleted: false,
        isEdited: false,
        isRead: false,

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


      print('Saved in message model: ${message.dateTime}');

      messages.insert(0, message);
      messageText.value = '';
      textController.clear();
      // clearReplyToMessage();
      // selectedMeetingTime.value = null;
      _scrollToBottom();
      update(); // notify GetX

      // socketService.sendMessage(message);

      final Map<String, dynamic> messageData = {
        'tempId': tempId, // <-- CRUCIAL: Send tempId to the backend
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        // 'broadcast_id': broadcastId,
        'message': messageContent,
        'message_type': type.toString().split('.').last,
        'reply_to': replyMessage.value?.messageId,
        'reply_to_details': replyMessage.value,
        'sender_details': [UserDetails(
          id: Global.userId!,
          firstname: Global.userFirstname!,
          lastname: Global.userLastname!,
          email: Global.email!,
          // other fields if needed
        )],
        'attechment_id': [], // Handle attachments separately if needed
        // Add other fields like 'latitude', 'longitude' if they exist
      };

      // 4. Emit the event
      // (This assumes you have attachments, location, etc., handled elsewhere)
      // For now, this just sends a text message.
      socketService.emitSendMessage(messageData);

      // selectedMeetingTime.value = null;
      chatController.fetchAdminList();
    clearReplyToMessage();
    selectedMeetingTime.value = null;
      // messageText.value = "";
      // clearReplyToMessage();

    // }
  }

  Future<void> uploadAndSendFile(String receiverId, {List<File>? file, String? broadcastId}) async {
    if (file == null || file.isEmpty) return;
    for (var files in file) {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();

      final currentUserId = Global.userId;

      UploadFile? uploadedFile = await uploadController.uploadFile(files);
      if (uploadedFile != null && socketService.socket != null) {
        final MessageModel message = MessageModel(
            tempId: tempId,
            messageId: tempId, // Placeholder
            senderId: currentUserId,
            receiverId: receiverId,
            broadcastId: broadcastId,
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

        final Map<String, dynamic> messageData = {
          'tempId': tempId,
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'broadcast_id': broadcastId,
          'message': '', // Or a caption if you have one
          'message_type': uploadedFile.fileType,
          'reply_to': replyMessage.value?.messageId,
          'attechment_id': [uploadedFile.id!], // The ID from the upload
        };

        socketService.emitSendMessage(messageData);
        // socketService.sendMessage(message);
        clearReplyToMessage();


      }
    }
  }

  void sendLocation(Position position, String receiverId, {String? broadcastId}) {

    final currentUserId = Global.userId;
    if (currentUserId == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final message = MessageModel(
      tempId: tempId,
      messageId: tempId,
      senderId: currentUserId,
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

    final Map<String, dynamic> messageData = {
      'tempId': tempId,
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'broadcast_id': broadcastId,
      'message': 'Location',
      'message_type': "location",
      'latitude': position.latitude,
      'longitude': position.longitude,
      'reply_to': replyMessage.value?.messageId,
      'attechment_id': [],
    };

    socketService.emitSendMessage(messageData);

    // socketService.sendMessage(message);
    clearReplyToMessage();


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


  void sendBroadcast(String broadcastId, MessageType type) {
    if (messageText.value.isNotEmpty && socketService.socket != null) {
      final message = MessageModel(
        senderId: Global.userId!,
        broadcastId: broadcastId,
        message: messageText.value,
        attachmentId: [],
        messageType: type.toString().split('.').last,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageStatus: 'sent',
        replyTo: replyMessage.value,
        senderDetails: [
          UserDetails(
            id: Global.userId!,
            firstname: Global.userFirstname!,
            lastname: Global.userLastname!,
            email: Global.email!,
          )
        ],
        dateTime: selectedMeetingTime.value,
        replyToDetails: replyMessage.value,
      );

      messages.insert(0, message); // local UI update
      _scrollToBottom();
      update();

      socketService.sendBroadcastMessage(Global.userId!, broadcastId, messageText.value);

      selectedMeetingTime.value = null;
      chatController.fetchAdminList();
      messageText.value = "";
      clearReplyToMessage();
    }
  }



  Future<UserDetails?> fetchUserDetails(String receiverId) async {
    String? token = await TokenStorage.getToken();
    // final url = '${ApiConstants.GET_USER_DETAILS}/$receiverId';
    final url = '${ApiConstants.GET_USER_BY_ID}/$receiverId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
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


  Future<void> fetchMessage(String? receiverId, {String? broadcastId}) async {

    String? token = await TokenStorage.getToken();
    // final url = '${ApiConstants.GET_MESSAGE_LIST}?user_id=$receiverId';
    String url;
    if (broadcastId != null && broadcastId.isNotEmpty) {
      url = '${ApiConstants.GET_MESSAGE_LIST}?broadcast_id=$broadcastId';
    } else if (receiverId != null && receiverId.isNotEmpty) {
      url = '${ApiConstants.GET_MESSAGE_LIST}?user_id=$receiverId';
    } else {
      print("❌ No receiverId or broadcastId provided");
      return;
    }
    print('fetch message url : ${url}');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
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
        print('message value ==> ${messages}');
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
      // Update the message content and set isEdited to true
      messages[index] = messages[index].copyWith(
        message: data['message'],
        isEdited: true, // Mark as edited
        updatedAt: DateTime.now(), // Update timestamp
      );
      messages.refresh();
    }
  }

  void _onMessageDeleted(Map data) {
    messages.removeWhere((m) => m.messageId == data['messageId']);
  }



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


  void updateMessage(String? messageId, String newText) {
    if (messageId != null) {
      socketService.updateMessage(messageId, newText);
      // fetchMessage(receiverId);
      if (isBroadcast == true) {
        // In broadcast mode, 'receiverId' (from the controller) is the broadcastId
        fetchMessage(null, broadcastId: receiverId);
      } else {
        // This is for normal one-to-one chats
        fetchMessage(receiverId);
      }
    }
  }

  void deleteMessage(String? messageId) {
    if (messageId != null) socketService.deleteMessage(messageId);
  }

  void markMessageAsSeen(String messageId, String userId) {
    socketService.emitMessageSeen(messageId, userId);
  }

  void handleMessageNotification(MessageModel notification){
    messages.add(notification);

    print('notification message type ===> ${notification.messageType}');
    print('attachmentDetails ===> ${notification.attachmentDetails}');

    final attachments = notification.attachmentDetails;

    if(notification.messageType == 'image'){
      if (attachments != null && attachments.isNotEmpty) {
        notificationService.showNotification(
          id: DateTime
              .now()
              .millisecondsSinceEpoch ~/ 1000,
          title: 'New Image Message',
          body: notification.message ?? 'You received an image!',
          imageUrl: attachments?.first.url, // Pass the URL of the image
        );
      }else {
        print('⚠️ Image message received but attachments are empty or null.');
      }
    }
    else if(notification.messageType == 'document'){
      notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'New Document',
        body: 'You received a document: ${notification.attachmentDetails?.first.name}',
      );
    }
    else if (notification.messageType == 'video') {
      notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'New Video',
        body: 'Video',
      );
    }
    else if (notification.messageType == 'audio') {
      notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'New Audio',
        body: 'Video',
      );
    }
    else if (notification.messageType == 'location') {
      notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'New Location',
        body: 'Location',
      );
    }else {
      notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'New Message',
        body: notification.message ?? '',
      );
    }

  }

  void markAllAsRead() {
    for (var i = 0; i < messages.length; i++) {
      if (!messages[i].isRead && messages[i].receiverId == Global.userId) {
        messages[i] = messages[i].copyWith(isRead: true, messageStatus: 'seen');
        // Also notify backend if required
        if (messages[i].messageId != null) {
          markMessageAsSeen(messages[i].messageId!, Global.userId!);
        }
      }
    }
    messages.refresh();
  }


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




  void emitMessageSeen(String? messageId) {
    if (messageId == null) return;

    final currentUserId = Global.userId;
    socketService.emitMessageSeen(
       messageId,
      currentUserId??'',
    );
    print("Emitted 'message_seen' for $messageId");
  }

  void setupSocketListeners() {
    // --- 1. CLEAR all previous listeners ---
    // This prevents duplicate events which break real-time updates
    socketService.clearMessageListeners();

    // --- 2. Listen for SENDER'S acknowledgment ---
    // This updates the sender's message from "tempId" to the real messageId
    // and updates the status from 'sending'/'sent' to 'delivered'.
    socketService.listenForMessageAck((data) async {
      final MessageModel serverMessage = MessageModel.fromJson(data);

      // Fetch sender details for the acked message if missing
      if (serverMessage.senderDetails == null || serverMessage.senderDetails!.isEmpty) {
        final user = await fetchUserDetails(serverMessage.senderId ?? '');
        if (user != null) {
          serverMessage.senderDetails = [user];
        }
      }

      final tempId = data['tempId']; // The backend sends this back

      if (tempId == null) return;

      // Find the optimistic message in our list by its tempId
      final index = messages.indexWhere((m) => m.tempId == tempId);

      if (index != -1) {
        // Replace the temporary message with the real one from the server
        messages[index] = serverMessage;
        messages.refresh();
        print("ACK: Message with tempId $tempId updated to real ID ${serverMessage.messageId}");
      }
    });

    // --- 3. Listen for a NEW message (as a RECEIVER) ---
    socketService.listenForNewMessage((data) async{
      final MessageModel newMessage = MessageModel.fromJson(data);

      // If the new message doesn't have sender details, fetch them.
      if (newMessage.senderDetails == null || newMessage.senderDetails!.isEmpty) {
        final user = await fetchUserDetails(newMessage.senderId??'');
        if (user != null) {
          newMessage.senderDetails = [user];
        }
      }

      // Prevent adding a duplicate
      if (!messages.any((m) => m.messageId == newMessage.messageId)) {
        messages.insert(0, newMessage);
      }

      // --- CRITICAL: Automatically emit 'seen' ---
      // If we receive a message while on this screen, we have "seen" it.
      // Tell the server, so the sender gets a blue tick.
      final currentUserId = Global.userId;
      if (newMessage.receiverId == currentUserId) {
        emitMessageSeen(newMessage.messageId);
      }
      chatController.fetchUserList();
    });

    // --- 4. Listen for message EDITS ---
    socketService.listenForUpdatedMessages((data) {
      final String? messageId = data['_id'] ?? data['messageId'];
      if (messageId == null) return;

      final index = messages.indexWhere((m) => m.messageId == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          message: data['message'],
          isEdited: data['edited'],
        );
        messages.refresh();
      }
    });

    // --- 5. Listen for message DELETES ---
    socketService.listenForDeletedMessages((data) {
      final String? messageId = data['messageId'];
      if (messageId == null) return;

      final index = messages.indexWhere((m) => m.messageId == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          isDeleted: data['is_deleted'],
        );
        messages.refresh();
      }
    });

    // --- 6. Listen for 'SEEN' status (as a SENDER) ---
    // This is when the OTHER user sees our message.
    socketService.listenForSeenMessages((data) {
      final String? messageId = data['messageId'];
      if (messageId == null) return;

      final index = messages.indexWhere((m) => m.messageId == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          messageStatus: data['message_status'], // Should be 'seen'
        );
        messages.refresh();
      }
    });
  }

}
