import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../data/models/message_model.dart';

class SocketService extends GetxService {
  IO.Socket? socket;

  final RxBool isConnected = false.obs;

  Future<void> connectSocket(String userId) async {
    socket = IO.io('https://12dbde6422fe.ngrok-free.app', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.onConnect((_) {
      isConnected.value = true;
      print('✅ Socket connected');
      socket?.emit('connect_user', {'user_id': userId});
    });

    socket?.onDisconnect((_) {
      isConnected.value = false;
      print('❌ Socket disconnected');
    });

    socket?.onConnectError((data) {
      print('❗ Socket Connect Error: $data');
    });

    socket?.onError((data) {
      print('❗ Socket Error: $data');
    });
  }


  // =========================
  //  User Presence
  // =========================

  void emitUserOnline(String userId) {
    socket?.emit('user_online', userId);
    print("Emitted user_online: $userId");
  }

  void emitUserLeftMessagePage(String userId) {
    socket?.emit('user_left_message_page', userId);
    print("Emitted user_left_message_page: $userId");
  }

  // =========================
  //  User Room Management
  // =========================

  void joinRoom(String userId, String roomId) {
    socket!.emit('join_room', {
      'user_id': userId,
      'room_id': roomId,
    });
  }

  void leaveRoom(String roomId, String userId) {
    socket!.emit('leave_room', {
      'room_id': roomId,
      'user_id': userId,
    });
  }

  // =========================
  //  Message Emitters
  // =========================

  void sendMessage(MessageModel messageData) {
    socket?.emit('chat_message', messageData);
  }

  // void sendGroupMessage(GroupMessageModel messageData) {
  //   socket?.emit('chat_message', messageData);
  // }

  void emitSendMessage(Map<String, dynamic> data) {
    if (socket == null) return;
    socket?.emit('chat_message', data);
    print("Emitted 'chat_message': $data");
  }

  void emitMessageSeen(String messageId, String userId) {
    socket?.emit('message_seen', {
      'messageId': messageId,
      'user_id': userId,
    });
  }

  void updateMessage(String messageId, String updatedText) {
    socket?.emit('update_message', {
      'messageId': messageId,
      'message': updatedText,
    });
  }

  void updateGroupMessage(String messageId, String roomId, String updatedText) {
    socket!.emit('update_group_message', {
      'messageId': messageId,
      'room_id': roomId,
      'message': updatedText,
    });
  }

  void deleteMessage(String messageId){
    socket?.emit('delete_message', {
      'messageId': messageId
    });
  }

  void deleteGroupMessage(String messageId){
    socket?.emit('delete_group_message', {
      'messageId': messageId
    });
  }

  void createBroadcast(String adminId, String title, List<String> recipients) {
    final data = {
      "admin_id": adminId,
      "title": title,
      "recipients": recipients,
    };

    print("Emitting create_broadcast: $data");
    socket?.emit("create_broadcast", data);
  }

  void editBroadcast(
      String adminId, String broadcastId, String title, List<String> recipients) {
    final data = {
      "admin_id": adminId,
      "broadcast_id": broadcastId,
      "title": title,
      "recipients": recipients,
    };
    print("Emitting edit_broadcast: $data");
    socket?.emit("edit_broadcast", data);
  }

  // Send message to a broadcast
  void sendBroadcastMessage(String adminId, String broadcastId, String message) {
    final data = {
      "sender_id": adminId,
      "broadcast_id": broadcastId,
      "message": message,
      "attachments": []
    };
    print("📤 Emitting broadcast_message: $data");
    socket?.emit("broadcast_message", data);
  }
  // void sendBroadcastMessage(String adminId, String broadcastId, String message) {
  //   socket?.emit("broadcast_message", {
  //     "sender_id": adminId,
  //     "broadcast_id": broadcastId,
  //     "message": message,
  //     "attachments": []
  //   });
  // }


  //=========================
  // Event Listeners
  // =========================

  void clearMessageListeners() {
    socket?.off('message_ack');
    socket?.off('chat_message');
    socket?.off('message_updated');
    socket?.off('message_deleted');
    socket?.off('message_seen');
    print("--- All message listeners cleared. ---");
  }

  void listenForMessageAck(Function(Map<String, dynamic> data) onAck) {
    socket?.on('message_ack', (data) {
      if (data is Map<String, dynamic>) {
        print("✅ Message ACK received: $data");
        onAck(data);
      } else {
        print("❗ Invalid Message ACK received: $data");
      }
    });
  }

  void listenForNewMessage(Function(dynamic data) onMessage) {
    socket?.on('chat_message', (data) {
      print("✅ New message received: $data");
      onMessage(data);
    });
  }


  void listenForBroadcastCreated(Function(Map<String, dynamic>) onCreated) {
    socket?.on("broadcast_created", (data) {
      print("📢 Broadcast created: $data");
      if (data is Map) {
        onCreated(Map<String, dynamic>.from(data));
      }
    });

    socket?.on("error", (err) {
      print("❌ Broadcast error: $err");
    });
  }

  void listenForBroadcastUpdated(Function(Map<String, dynamic>) onUpdated) {
    socket?.on("broadcast_updated", (data) {
      print("✅ Broadcast updated: $data");
      if (data is Map) onUpdated(Map<String, dynamic>.from(data));
    });

    socket?.on("error", (err) {
      print("❌ Broadcast update error: $err");
    });
  }

  void listenForBroadcastAck(Function(Map<String, dynamic>) onAck) {
    socket?.on("broadcast_ack", (data) {
      print("✅ Broadcast ack: $data");
      if (data is Map) {
        onAck(Map<String, dynamic>.from(data));
      }
    });
  }


  void listenForUpdatedMessages(Function(Map data) onUpdated) {
    socket?.on('message_updated', (data) {
      onUpdated(data);
    });
  }

  void listenForDeletedMessages(Function(Map data) onDeleted) {
    socket?.on('message_deleted', (data) {
      onDeleted(data);
    });
  }

  void listenForSeenMessages(Function(Map data) onSeen) {
    socket?.on('message_seen', (data) {
      onSeen(data);
    });
  }

  void listenForSeenGroupMessages(Function(Map data) onSeen) {
    socket?.on('message_seen', (data) {
      onSeen(data);
    });
  }

  void listenForDeliveredMessages(Function(Map<String, dynamic> data) onDelivered){
    socket?.on('message_delivered', (data) {
      print("📨 message_delivered event received: $data");
      if (data is Map<String, dynamic>) {
        onDelivered(data);
      } else if (data is Map) {
        onDelivered(Map<String, dynamic>.from(data));}
      else {
        print("⚠️ Invalid data type for message_delivered: $data");
      }
    });
  }

  void listenForDeliveredGroupMessages(Function(Map data) onDelivered){
    socket?.on('message_delivered', (data) {
      onDelivered(data);
    });
  }

  void listenToReceivedMessages(Function(Map<String, dynamic>) onReceived){
    socket?.on('chat_message', (data) {
      print('📨 Received direct message: $data');
      if (data is Map<String, dynamic>) {
        onReceived(data);
      }
    });
  }

  void listenToNewMessages(Function(Map<String, dynamic>) onData) {
    socket?.on('new_message', (data) {
      print('🆕 New message: $data');
      onData(Map<String, dynamic>.from(data));
    });
  }

  // Listen for Broadcast Acknowledgment
  // void listenForBroadcastAck(Function(Map<String, dynamic> data) onAck) {
  //   socket?.on('broadcast_ack', (data) {
  //     print('📢 Broadcast Acknowledged: $data');
  //     if (data is Map<String, dynamic>) {
  //       onAck(data);
  //     } else if (data is Map) {
  //       onAck(Map<String, dynamic>.from(data));
  //     } else {
  //       print("⚠️ Invalid data type for broadcast_ack: $data");
  //     }
  //   });
  // }



  void listenToGroupMessages(Function(Map<String, dynamic>) onMessageReceived) {
    socket?.on('chat_message', (data) {
      print('📨 Received direct group message: $data');
      if (data is Map<String, dynamic>) {
        onMessageReceived(data);
      }
    });
  }

  void listenToGroupMessageUpdate(Function(Map data) onUpdated) {
    socket?.on('group_message_updated', (data){
      onUpdated(data);
    });
  }

  void listenToGroupMessageDelete(Function(Map data) onDeleted) {
    socket?.on('group_message_deleted', (data) {
      onDeleted(data);
    });
  }

  void listenForLeftRoom(Function(dynamic) onLeftRoom) {
    socket?.on('left_room', onLeftRoom);
  }

  void listenForPresenceUpdates(Function(String userId, bool isOnline) onChange) {
    socket?.on('presence_update', (data) {
      final userId = data['userId'];
      final isOnline = data['isOnline'];
      if (userId != null && isOnline != null) {
        onChange(userId, isOnline);
      }
    });
  }

  // =========================
  // NOTIFICATION LISTENER
  // =========================

  void onReceiveNotification(Function(dynamic data) callback) {
    socket?.on('receiveNotification', (data){
      print("Notification received: $data");
      callback(data);
    });
  }


  void setupMessageListeners({
    //required Function(dynamic data) onNewMessage,
    required Function(dynamic data) onNotification,
    // Function(Map<String, dynamic> data)? onBroadcastAck,
  }) {
    //socket?.on('new_message', onNewMessage);
    socket?.on('receiveNotification', onNotification);
    // if (onBroadcastAck != null) {
    //   socket?.on('broadcast_ack', onBroadcastAck);
    // }
  }



  void on(String event, Function(dynamic) callback) {
    socket?.on(event, callback);
  }

  void off(String event) {
    socket?.off(event);
  }
}
