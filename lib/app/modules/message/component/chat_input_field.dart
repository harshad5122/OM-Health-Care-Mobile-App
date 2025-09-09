// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:om_health_care_app/app/modules/message/component/video_bubble.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../data/models/message_model.dart';
// import '../../../enum/message.dart';
// import '../controller/chat_contoller.dart';
// import 'audio_player.dart';
//
// class ChatInputField extends StatefulWidget {
//   final String? receiverId;
//   final String? roomId;
//
//   ChatInputField({super.key, this.receiverId, this.roomId});
//
//   @override
//   State<ChatInputField> createState() => _ChatInputFieldState();
// }
//
// class _ChatInputFieldState extends State<ChatInputField> {
//   final ChatController chatController = Get.find<ChatController>();
//   // final TextEditingController textController = TextEditingController();
//   MessageModel? message;
//
//   @override
//   void dispose() {
//     chatController.textController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: Get.theme.scaffoldBackgroundColor,
//         boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
//       ),
//       child: Column(
//         children: [
//           Obx(() {
//             final dynamic msg = chatController.replyMessage.value;
//             return (msg != null)
//                 ? Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Replying to",
//                             style:
//                             TextStyle(fontWeight: FontWeight.bold)),
//                         if (msg?.messageType == 'text')
//                           Text("${msg?.message}",
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis),
//                         if (msg?.messageType == 'image')
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: Image.network(
//                               msg?.attachmentDetails?.first.url ?? '',
//                               height: 50,
//                               width: 50,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         if (msg?.messageType == 'document')
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.file_copy_rounded,
//                                 color: Colors.grey,
//                                 size: 20,
//                               ),
//                               SizedBox(
//                                 width: 20,
//                               ),
//                               Text(msg?.attachmentDetails?.first.name ??
//                                   '')
//                             ],
//                           ),
//                         if (msg?.messageType == 'video')
//                           VideoBubble(
//                             videoUrl:
//                             msg?.attachmentDetails?.first.url ?? '',
//                             width: 50,
//                             height: 50,
//                             iconSize: 20,
//                           ),
//                         if (msg?.messageType == 'audio')
//                           SizedBox(
//                               height: 50,
//                               width: 50,
//                               child: AudioPlayerWidget(
//                                   audioUrl:
//                                   msg?.attachmentDetails?.first.url ??
//                                       '')),
//                         if (msg?.messageType == 'location')
//                           SizedBox(
//                             height: 50,
//                             width: 50,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.network(
//                                 "https://static-maps.yandex.ru/1.x/?lang=en-US&ll=${msg?.latitude},${msg?.longitude}&z=15&l=map&size=150,150",
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: () {
//                        chatController.clearReplyToMessage();
//                       }),
//                 ],
//               ),
//             )
//                 : SizedBox.shrink();
//           }),
//           Obx(() {
//             final joinUrl = chatController.messageText.value;
//             final isZoomLink = joinUrl.contains("zoom.us");
//
//             if (isZoomLink) {
//               final meetingTime = chatController.selectedMeetingTime.value;
//
//               return Container(
//                 padding: EdgeInsets.all(12),
//                 margin: EdgeInsets.only(bottom: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue),
//                 ),
//                 child: Row(
//                   children: [
//                     Image.asset(
//                       'assets/icon/zoom.png',
//                       height: 32,
//                       width: 32,
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Created a Zoom Meeting", style: TextStyle(fontWeight: FontWeight.bold)),
//                           if (meetingTime != null)
//                             Text(
//                               DateFormat('MMM d, yyyy – hh:mm a').format(meetingTime),
//                               style: TextStyle(color: Colors.grey[600]),
//                             ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: () {
//                         chatController.messageText.value = '';
//                         chatController.textController.clear();
//                         chatController.selectedMeetingTime.value = null;
//                       },
//                     )
//                   ],
//                 ),
//               );
//             }
//
//             return SizedBox.shrink();
//           }),
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.attach_file, color: Colors.grey[600]),
//                 onPressed: () => _showAttachmentOptions(context),
//               ),
//               Expanded(
//                 child: TextField(
//                   controller: chatController.textController,
//                   onChanged: (text) => chatController.messageText.value = text,
//                   decoration: InputDecoration(
//                     hintText: "Type a message...",
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.send, color: Get.theme.primaryColor),
//                 onPressed: () {
//                   if (chatController.textController.text.isNotEmpty) {
//                     if (widget.receiverId != null) {
//                       chatController.sendMessage(
//                         widget.receiverId!, MessageType.text,);
//                       chatController.fetchMessage(widget.receiverId!);
//                     }
//                     chatController.textController.clear();
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAttachmentOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Camera'),
//               onTap: () async {
//                 Get.back();
//                 File? file = await _pickImage(ImageSource.camera);
//                 if (file != null) {
//                   print('camera file ==> ${file}');
//                   if (widget.receiverId != null) {
//                     chatController.uploadAndSendFile(widget.receiverId!, file: [file]);
//                     chatController.fetchMessage(widget.receiverId!);
//                   }
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo),
//               title: const Text('Gallery'),
//               onTap: () async {
//                 Get.back();
//                 print('Opening gallery picker...');
//                 List<File> file = await _pickMultipleImages();
//                 print('Picked file ==> ${file}');
//                 if (file.isNotEmpty) {
//                   print('gallery image path ==> ${file}');
//                   if(widget.receiverId != null){
//                     chatController.uploadAndSendFile(widget.receiverId!, file: file);
//                     chatController.fetchMessage(widget.receiverId);
//                   }
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.audiotrack),
//               title: const Text('Audio'),
//               onTap: () async {
//                 Get.back();
//                 List<File> file = await _pickFile(FileType.audio);
//                 if (file.isNotEmpty) {
//                   if(widget.receiverId != null){
//                     chatController.uploadAndSendFile(widget.receiverId!,
//                         file: file);
//                     chatController.fetchMessage(widget.receiverId);
//                   }
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.videocam),
//               title: const Text('Video'),
//               onTap: () async {
//                 Get.back();
//                 List<File> file = await _pickFile(FileType.video);
//                 if (file.isNotEmpty) {
//                   if(widget.receiverId != null){
//                     chatController.uploadAndSendFile(widget.receiverId!,
//                         file: file);
//                     chatController.fetchMessage(widget.receiverId);
//                   }
//
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.insert_drive_file),
//               title: const Text('Document'),
//               onTap: () async {
//                 Get.back();
//                 List<File> file = await _pickFile(FileType.any);
//                 if (file.isNotEmpty) {
//                   if (widget.receiverId != null) {
//                     chatController.uploadAndSendFile(widget.receiverId!,
//                         file: file);
//                     chatController.fetchMessage(widget.receiverId!);
//                   }
//
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.location_on),
//               title: const Text('Location'),
//               onTap: () async {
//                 LocationPermission permission =
//                 await Geolocator.requestPermission();
//                 if (permission == LocationPermission.denied ||
//                     permission == LocationPermission.deniedForever) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Location permission denied")));
//                   return;
//                 }
//                 Position position = await Geolocator.getCurrentPosition(
//                     desiredAccuracy: LocationAccuracy.high);
//                 if(widget.receiverId != null){
//                   chatController.sendLocation(position, widget.receiverId!);
//                   chatController.fetchMessage(widget.receiverId);
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   Future<File?> _pickImage(ImageSource source) async {
//     try {
//       // Ask for permissions (especially for Android 13+)
//       final permissionStatus = await Permission.camera.request();
//       if (!permissionStatus.isGranted) {
//         print('Camera permission denied.');
//         return null;
//       }
//
//       final pickedFile = await ImagePicker().pickImage(
//         source: source,
//         maxWidth: 1080,
//         maxHeight: 1920,
//         imageQuality: 75, // Compress to avoid crash on low-end devices
//       );
//
//       if (pickedFile == null) {
//         print('No image selected (user canceled or error).');
//         return null;
//       }
//
//       final file = File(pickedFile.path);
//       print('Picked image path: ${file.path}');
//       return file;
//     } catch (e, stack) {
//       print('Exception while picking image: $e');
//       print('StackTrace: $stack');
//       return null;
//     }
//   }
//
//
//   Future<List<File>> _pickMultipleImages() async {
//     final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
//     return pickedFiles != null
//         ? pickedFiles.map((xFile) => File(xFile.path)).toList()
//         : [];
//   }
//
//   Future<List<File>> _pickFile(FileType fileType) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: fileType,
//       allowMultiple: true,
//     );
//     return result != null
//         ? result.files.map((file) => File(file.path!)).toList()
//         : [];
//   }
// }



import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/modules/message/component/video_bubble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/models/message_model.dart';
import '../../../enum/message.dart';
import '../../../global/global.dart';
import '../controller/chat_contoller.dart';
import 'audio_player.dart';

class ChatInputField extends StatefulWidget {
  final String? receiverId;
  final String? roomId;

  ChatInputField({super.key, this.receiverId, this.roomId});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final ChatController chatController = Get.find<ChatController>();
  final FocusNode _textFocusNode = FocusNode(); // Dedicated focus node for the text field

  @override
  void initState() {
    super.initState();
    // Listen for changes in editingMessage and request focus if it's set
    ever(chatController.editingMessage, (MessageModel? message) {
      if (message != null) {
        _textFocusNode.requestFocus();
      }
    });

    // Listen for changes in replyMessage and request focus if it's set
    ever(chatController.replyMessage, (MessageModel? message) {
      if (message != null) {
        _textFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    chatController.textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _sendMessageOrUpdate() {
    if (chatController.textController.text.isEmpty) return;

    if (chatController.editingMessage.value != null) {
      // If a message is being edited, update it
      chatController.updateMessage(
        chatController.editingMessage.value!.messageId,
        chatController.textController.text.trim(),
      );
      chatController.clearEditingMessage(); // Clear editing state
    } else {
      // Otherwise, send a new message
      if (widget.receiverId != null) {
        chatController.sendMessage(
          widget.receiverId!,
          MessageType.text,
        );
        chatController.fetchMessage(widget.receiverId!);
      }
    }
    chatController.textController.clear();
    chatController.clearReplyToMessage(); // Clear reply after sending/updating
    chatController.messageText.value = ""; // Clear for reactive updates
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
      ),
      child: Column(
        children: [
          // Display for editing message
          Obx(() {
            final editingMsg = chatController.editingMessage.value;
            if (editingMsg != null) {
              return Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(left: BorderSide(color: Colors.blue, width: 4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Editing message",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          Text(
                            editingMsg.message ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        chatController.clearEditingMessage();
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Display for reply message
          Obx(() {
            final replyMsg = chatController.replyMessage.value;
            if (replyMsg != null) {
              return Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(left: BorderSide(color: Colors.green, width: 4)), // WhatsApp style reply bar
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replyMsg.senderId == Global.userId ? 'You' : (replyMsg.senderDetails?.first.firstname ?? 'Unknown'),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 2),
                          if (replyMsg.messageType == 'text')
                            Text(
                              replyMsg.message ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          // Compact display for replied media types
                          if (replyMsg.messageType == 'image' && replyMsg.attachmentDetails != null && replyMsg.attachmentDetails!.isNotEmpty)
                            Text('Image: ${replyMsg.attachmentDetails!.first.name ?? ''}', style: TextStyle(color: Colors.grey[600])),
                          if (replyMsg.messageType == 'video' && replyMsg.attachmentDetails != null && replyMsg.attachmentDetails!.isNotEmpty)
                            Text('Video: ${replyMsg.attachmentDetails!.first.name ?? ''}', style: TextStyle(color: Colors.grey[600])),
                          if (replyMsg.messageType == 'audio' && replyMsg.attachmentDetails != null && replyMsg.attachmentDetails!.isNotEmpty)
                            Text('Audio: ${replyMsg.attachmentDetails!.first.name ?? ''}', style: TextStyle(color: Colors.grey[600])),
                          if (replyMsg.messageType == 'document' && replyMsg.attachmentDetails != null && replyMsg.attachmentDetails!.isNotEmpty)
                            Text('Document: ${replyMsg.attachmentDetails!.first.name ?? ''}', style: TextStyle(color: Colors.grey[600])),
                          if (replyMsg.messageType == 'location' && replyMsg.latitude != null)
                            Text('Location Shared', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        chatController.clearReplyToMessage();
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Display for Zoom link preview
          Obx(() {
            final joinUrl = chatController.messageText.value;
            final isZoomLink = joinUrl.contains("zoom.us") && chatController.editingMessage.value == null; // Only show if not editing
            if (isZoomLink) {
              final meetingTime = chatController.selectedMeetingTime.value;
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icon/zoom.png', // Ensure this asset exists
                      height: 32,
                      width: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Creating a Zoom Meeting", style: TextStyle(fontWeight: FontWeight.bold)),
                          if (meetingTime != null)
                            Text(
                              DateFormat('MMM d, yyyy – hh:mm a').format(meetingTime),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        chatController.messageText.value = '';
                        chatController.textController.clear();
                        chatController.selectedMeetingTime.value = null;
                      },
                    )
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                onPressed: () => _showAttachmentOptions(context),
              ),
              Expanded(
                child: TextField(
                  controller: chatController.textController,
                  focusNode: _textFocusNode, // Assign the focus node
                  onChanged: (text) => chatController.messageText.value = text,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                  ),
                  maxLines: 5, // Allow multiple lines for typing
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Get.theme.primaryColor),
                onPressed: _sendMessageOrUpdate, // Call the combined function
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Get.back();
                File? file = await _pickImage(ImageSource.camera);
                if (file != null) {
                  print('camera file ==> ${file}');
                  if (widget.receiverId != null) {
                    chatController.uploadAndSendFile(widget.receiverId!, file: [file]);
                    chatController.fetchMessage(widget.receiverId!);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () async {
                Get.back();
                print('Opening gallery picker...');
                List<File> file = await _pickMultipleImages();
                print('Picked file ==> ${file}');
                if (file.isNotEmpty) {
                  print('gallery image path ==> ${file}');
                  if(widget.receiverId != null){
                    chatController.uploadAndSendFile(widget.receiverId!, file: file);
                    chatController.fetchMessage(widget.receiverId);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('Audio'),
              onTap: () async {
                Get.back();
                List<File> file = await _pickFile(FileType.audio);
                if (file.isNotEmpty) {
                  if(widget.receiverId != null){
                    chatController.uploadAndSendFile(widget.receiverId!,
                        file: file);
                    chatController.fetchMessage(widget.receiverId);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () async {
                Get.back();
                List<File> file = await _pickFile(FileType.video);
                if (file.isNotEmpty) {
                  if(widget.receiverId != null){
                    chatController.uploadAndSendFile(widget.receiverId!,
                        file: file);
                    chatController.fetchMessage(widget.receiverId);
                  }

                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () async {
                Get.back();
                List<File> file = await _pickFile(FileType.any);
                if (file.isNotEmpty) {
                  if (widget.receiverId != null) {
                    chatController.uploadAndSendFile(widget.receiverId!,
                        file: file);
                    chatController.fetchMessage(widget.receiverId!);
                  }

                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location'),
              onTap: () async {
                LocationPermission permission =
                await Geolocator.requestPermission();
                if (permission == LocationPermission.denied ||
                    permission == LocationPermission.deniedForever) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Location permission denied")));
                  return;
                }
                Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high);
                if(widget.receiverId != null){
                  chatController.sendLocation(position, widget.receiverId!);
                  chatController.fetchMessage(widget.receiverId);
                }
              },
            ),
          ],
        );
      },
    );
  }


  Future<File?> _pickImage(ImageSource source) async {
    try {
      // Ask for permissions (especially for Android 13+)
      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        print('Camera permission denied.');
        return null;
      }

      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 75, // Compress to avoid crash on low-end devices
      );

      if (pickedFile == null) {
        print('No image selected (user canceled or error).');
        return null;
      }

      final file = File(pickedFile.path);
      print('Picked image path: ${file.path}');
      return file;
    } catch (e, stack) {
      print('Exception while picking image: $e');
      print('StackTrace: $stack');
      return null;
    }
  }


  Future<List<File>> _pickMultipleImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    return pickedFiles != null
        ? pickedFiles.map((xFile) => File(xFile.path)).toList()
        : [];
  }

  Future<List<File>> _pickFile(FileType fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowMultiple: true,
    );
    return result != null
        ? result.files.map((file) => File(file.path!)).toList()
        : [];
  }
}