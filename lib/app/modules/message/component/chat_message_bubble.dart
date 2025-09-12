// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:om_health_care_app/app/comms/upload_file_utils.dart';
// import 'package:om_health_care_app/app/modules/message/component/video_bubble.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:swipe_to/swipe_to.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../comms/string_utils.dart';
// import '../../../data/models/message_model.dart';
// import '../../../data/models/upload_file_model.dart';
// import '../../../global/global.dart';
// import '../controller/chat_contoller.dart';
// import '../controller/download_controller.dart';
// import 'audio_player.dart';
// import 'full_screen_image.dart';
//
// class ChatBubble extends StatefulWidget {
//   final MessageModel? message;
//   final bool isMe;
//   final bool showSenderName;
//
//   ChatBubble({this.message, required this.isMe, this.showSenderName = false});
//
//   @override
//   State<ChatBubble> createState() => _ChatBubbleState();
// }
//
// class _ChatBubbleState extends State<ChatBubble> {
//   bool _seenEmitted = false;
//
//   final ChatController controller = Get.put(ChatController());
//   final DownloadController downloadController = Get.put(DownloadController());
//   final textFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_seenEmitted && !widget.isMe) {
//
//         final String? messageId = widget.message?.messageId;
//
//         final String? status = widget.message?.messageStatus;
//
//         if (messageId != null && status != 'seen') {
//           controller.markMessageAsSeen(messageId, Global.userId ?? '');
//           _seenEmitted = true;
//         }
//       }
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final dynamic msg =  widget.message;
//     final String? text = msg.message;
//     final DateTime createdAt = msg.createdAt;
//     final localTime = createdAt.toLocal();
//     final String? messageType = msg.messageType;
//     final List<dynamic>? attachmentDetails = msg.attachmentDetails;
//     final double? latitude = msg.latitude;
//     final double? longitude = msg.longitude;
//     final String? status = widget.message?.messageStatus;
//     final String formattedTime = DateFormat('hh:mm a').format(localTime);
//     //final sender = msg.senderDetails?.first;
//     final sender = (msg.senderDetails != null && msg.senderDetails!.isNotEmpty)
//         ? msg.senderDetails!.first
//         : null;
//     final replyTo = msg.replyToDetails;
//
//     // final status = message.messageStatus;
//     return Align(
//       alignment: widget.isMe ? Alignment.centerLeft : Alignment.centerLeft,
//       child: SwipeTo(
//         onRightSwipe: (details) {
//
//             controller.setReplyToMessage(widget.message!);
//
//           FocusScope.of(context).requestFocus(textFocusNode);
//         },
//         iconOnRightSwipe: Icons.arrow_forward_ios,
//         rightSwipeWidget: SizedBox.shrink(),
//         child: GestureDetector(
//           onLongPress: () {
//             _showEditDeleteOptions(context);
//           },
//
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//
//             decoration: BoxDecoration(
//                // color: widget.isMe ? Colors.green[300] : Colors.grey[300],
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(15),
//                 topRight: const Radius.circular(15),
//                 bottomLeft: widget.isMe ? const Radius.circular(15) : Radius.zero,
//                 bottomRight: widget.isMe ? Radius.zero : const Radius.circular(15),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     widget.showSenderName ?
//                     Stack(
//                       clipBehavior: Clip.none,
//                       // Ensures the dot can overflow outside the stack
//                       children: [
//                         CircleAvatar(
//                           backgroundColor:
//                           Colors.grey.shade400,
//                           child: Text(
//                             StringUtils.getInitials("${sender?.firstname ?? ''} ${sender?.lastname ?? ''}"),
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                         ),
//                         // if(!chatUser.isRoom)
//                         Positioned(
//                           top: 1,
//                           left: 1,
//                           child: Container(
//                             width: 9, // Size of the dot
//                             height: 9,
//                             decoration: BoxDecoration(
//                               color:  Get.theme.scaffoldBackgroundColor,
//                               // Dot color
//                               shape: BoxShape
//                                   .circle, // Makes the container circular
//                             ),
//                           ),
//                         ),
//
//                         Positioned(
//                           top: 2,
//                           left: 2,
//                           child: Container(
//                             width: 6, // Size of the dot
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: widget.isMe ? Get.theme.primaryColor : Get.theme.unselectedWidgetColor,
//                               // Dot color
//                               shape: BoxShape
//                                   .circle, // Makes the container circular
//                             ),
//                           ),
//                         ),
//                       ],
//                     ) : SizedBox( width: 40 ,),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                         children: [
//                           if(widget.showSenderName)
//                             Row(
//                               children: [
//                                 Text(
//                                   "${sender?.firstname ?? ''} ${sender?.lastname ?? ''}",
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                 ),
//                                 SizedBox(width: 10,),
//                                 Text(
//                                   formattedTime,
//                                   style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
//                                 ),
//                               ],
//                             ),
//                           SizedBox(height: 5,),
//
//                           if (replyTo != null) ...[
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//
//                                       if (replyTo.message != null)
//                                         Text(
//                                           replyTo.message!,
//                                           style:  TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                           ),
//                                           softWrap: true,
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 2,
//                                         ),
//                                       if (replyTo.messageType == 'image')
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(6),
//                                           child: Image.network(
//                                             replyTo.attachmentDetails!.first.url ?? '', height: 80, width: 80, fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       if(replyTo.messageType == 'video')
//                                         VideoBubble(videoUrl: replyTo?.attachmentDetails?.first.url ?? '', width: 50, height: 50, iconSize: 20,
//                                         ),
//                                       if(replyTo.messageType == 'audio')
//                                         SizedBox(
//                                             height: 50,
//                                             width: 50,
//                                             child: AudioPlayerWidget(audioUrl: replyTo?.attachmentDetails?.first.url ?? '')),
//                                       if(replyTo.messageType == 'document')
//                                         Row(
//                                           children: [
//                                             Icon(Icons.file_copy_rounded, color: Colors.grey, size: 20,),
//                                             SizedBox(width: 20,),
//                                             Text(replyTo?.attachmentDetails?.first.name??'')
//                                           ],
//                                         ),
//                                       if(replyTo.messageType == 'location')
//                                         SizedBox(
//                                           height: 50,
//                                           width: 50,
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(10),
//                                             child: Image.network(
//                                               "https://static-maps.yandex.ru/1.x/?lang=en-US&ll=${replyTo?.latitude},${replyTo?.longitude}&z=15&l=map&size=150,150",
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5),
//                           ],
//
//                           Row(
//                             children: [
//                               replyTo != null ? Image.asset(
//                                 'assets/icon/reply_message.png',
//                                 height: 20,
//                                 width: 20,
//                               ): SizedBox.shrink(),
//                               const SizedBox(width: 6),
//                               Expanded(
//                                 child: Container(
//                                   padding: replyTo != null ? const EdgeInsets.all(8) : null,
//                                   margin: replyTo != null ? const EdgeInsets.only(bottom: 6): null,
//                                   decoration: replyTo != null ? BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ) : null,
//                                   child: Row(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       if( replyTo != null )...[
//                                         CircleAvatar(
//                                           radius: 14,
//                                           backgroundColor:
//                                           Colors.grey.shade400,
//                                           child: Text(
//                                             StringUtils.getInitials("${sender?.firstname ?? ''} ${sender?.lastname ?? ''}"),
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white),
//                                           ),
//                                         ),
//                                         SizedBox(width: 10,)
//                                       ],
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             if (messageType == "image" && attachmentDetails != null) ...[
//                                               for (var file in attachmentDetails)
//                                                 if (file.url != null)
//                                                   Stack(
//                                                     children: [
//                                                       GestureDetector(
//                                                         onTap: () {
//                                                           Get.to(() => FullScreenImage(imageUrl: file.url!));
//                                                         },
//                                                         child: ClipRRect(
//                                                           borderRadius: BorderRadius.circular(10),
//                                                           child: Image.network(
//                                                             file.url!,
//                                                             width: 200,
//                                                             height: 200,
//                                                             fit: BoxFit.cover,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       // Positioned(child: IconButton(
//                                                       //     onPressed: () {
//                                                       //       controller.downloadAndSaveFile(file.url!, 'image');
//                                                       //     },
//                                                       //     icon: const Icon(Icons.download, color: Colors.white),))
//                                                     ],
//                                                   ),
//                                               const SizedBox(height: 5),
//                                             ],
//
//                                             if (messageType == "video" && attachmentDetails != null) ...[
//                                               for (var file in attachmentDetails)
//                                                 if (file.url != null) Stack(
//                                                   children: [
//                                                     VideoBubble(videoUrl: file.url!, width: 200, height: 200, iconSize: 50,),
//                                                     Positioned(
//                                                       right: 8,
//                                                       bottom: 8,
//                                                       child: IconButton(
//                                                         icon: const Icon(Icons.download, color: Colors.white),
//                                                         onPressed: () {
//                                                           controller.downloadAndSaveFile(file.url!, 'video');
//                                                         },
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 )
//                                             ],
//
//                                             if (messageType == "audio" && attachmentDetails != null) ...[
//                                               for (var file in attachmentDetails)
//                                                 if (file.url != null) Stack(
//                                                   children: [
//                                                     AudioPlayerWidget(audioUrl: file.url!),
//                                                     IconButton(
//                                                       icon: const Icon(Icons.download),
//                                                       onPressed: () {
//                                                         controller.downloadAndSaveFile(file.url!, 'audio');
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               const SizedBox(height: 5),
//                                             ],
//
//
//                                             if (messageType == "document" && attachmentDetails != null) ...[
//                                               // for (var file in attachmentDetails)
//                                               //   if (file.name != null && file.url != null)
//                                               ...attachmentDetails.map<Widget>((dynamic file) {
//                                                 if (file is! UploadFile || file.name == null || file.url == null) return const SizedBox.shrink();
//                                                 return FutureBuilder<bool>(
//                                                     future: file.isFileDownloadedLocally(),
//                                                     builder: (context, snapshot) {
//                                                       bool downloaded = snapshot.data ?? false;
//                                                       return GestureDetector(
//                                                         onTap: () async {
//                                                           try {
//                                                             if (!downloaded) {
//                                                               final path = await ChatController().downloadFileToLocal(file);
//                                                               if (path != null) {
//                                                                 await OpenFilex.open(path);
//                                                                 // Trigger UI update by notifying controller
//                                                                 // downloadController.updateDownloadedStatus(file.name!);
//                                                               }
//                                                             } else {
//                                                               final dir = await getApplicationDocumentsDirectory();
//                                                               // final path = '${dir.path}/${file.name}';
//                                                               final path = '/storage/emulated/0/Download/${file.name}';
//                                                               await OpenFilex.open(path);
//                                                             }
//                                                           } catch (e) {
//                                                             ScaffoldMessenger.of(context).showSnackBar(
//                                                               SnackBar(content: Text("Error: ${e.toString()}")),
//                                                             );
//                                                           }
//                                                         },
//
//                                                         child: Row(
//                                                           children: [
//                                                             Stack(
//                                                               alignment: Alignment.center,
//                                                               children: [
//                                                                 Container(
//                                                                     padding: const EdgeInsets.all(8),
//                                                                     decoration: BoxDecoration(
//                                                                       color: Colors.grey.shade200,
//                                                                       shape: BoxShape.circle,
//                                                                     ),
//                                                                     child: const Icon(Icons.insert_drive_file, color: Colors.grey, size: 18,)),
//                                                                 Obx(() {
//                                                                   // final progress = downloadController.getProgress(file.name!);
//                                                                   // final isDownloading = downloadController.isDownloading(file.name!);
//                                                                   final isDownloading = downloadController.isDownloading(file.name!);
//                                                                   final progress = downloadController.getProgress(file.name!);
//                                                                   //    final isDownloaded = downloadController.isDownloaded(file.name!);
//                                                                   return isDownloading
//                                                                       ? Text(
//                                                                     '${(progress * 100).toStringAsFixed(0)}%',
//                                                                     style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//                                                                   )
//                                                                       : ((!downloaded && !widget.isMe)
//                                                                       ? const Icon(Icons.download, size: 16, color: Colors.black87)
//                                                                       : const SizedBox());
//                                                                 }),
//                                                               ],
//                                                             ),
//                                                             SizedBox(width: 5,),
//                                                             const SizedBox(width: 5),
//                                                             Column(
//                                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                                               children: [
//                                                                 Text(
//                                                                   file.name!,
//                                                                   // basename(message.attachmentId!),
//                                                                   style:  TextStyle(
//                                                                       fontSize: 14,
//                                                                       fontWeight: FontWeight.w500,
//                                                                       //color: Colors.blue,
//                                                                       overflow: TextOverflow.ellipsis),
//                                                                 ),
//                                                                 Text(StringUtils.getFileSizeString(bytes: file.size!),
//                                                                   style: TextStyle(
//                                                                       fontSize: 12,
//                                                                       color: Colors.grey
//                                                                   ),
//                                                                 )
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       );
//                                                     }
//                                                 );
//                                               }
//                                               ),
//                                               const SizedBox(height: 5),
//                                             ],
//
//                                             if (messageType == "location" && latitude != null && longitude != null) ...[
//                                               GestureDetector(
//                                                 onTap: () {
//                                                   String mapUrl =
//                                                       "https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}";
//                                                   launchUrl(Uri.parse(mapUrl),
//                                                       mode: LaunchMode.externalApplication);
//                                                   // String mapUrl = "https://www.openstreetmap.org/?mlat=${message.latitude}&mlon=${message.longitude}&zoom=15";
//                                                   // launchUrl(Uri.parse(mapUrl), mode: LaunchMode.externalApplication);
//                                                 },
//                                                 child: Container(
//                                                   height: 150,
//                                                   width: 200,
//                                                   decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                     color: Colors.blue[100],
//                                                   ),
//                                                   child: ClipRRect(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                     child: Image.network(
//                                                       // "https://maps.googleapis.com/maps/api/staticmap?center=${message.latitude},${message.longitude}&zoom=15&size=200x150&markers=color:red%7C${message.latitude},${message.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY",
//                                                       "https://static-maps.yandex.ru/1.x/?lang=en-US&ll=${longitude},${latitude}&z=15&l=map&size=200,150",
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                             // Text Message
//                                             if (text != null && text.isNotEmpty) ...[
//                                               text.contains("zoom.us") ?
//                                               GestureDetector(
//                                                 onTap: () async {
//                                                   final url = Uri.parse(text);
//                                                   if (await canLaunchUrl(url)) {
//                                                     await launchUrl(url, mode: LaunchMode.externalApplication);
//                                                   } else {
//                                                     Get.snackbar('Error', 'Could not open Zoom link');
//                                                   }
//                                                 },
//                                                 child: Container(
//                                                   padding: EdgeInsets.all(12),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.blue.shade50,
//                                                     borderRadius: BorderRadius.circular(12),
//                                                     border: Border.all(color: Colors.blue),
//                                                   ),
//                                                   child: Row(
//                                                     children: [
//                                                       Image.asset(
//                                                         'assets/icon/zoom.png',
//                                                         height: 32,
//                                                         width: 32,
//                                                       ),
//                                                       SizedBox(width: 12),
//                                                       Expanded(
//                                                         child: Column(
//                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                           children: [
//                                                             Text("Zoom Meeting", style: TextStyle(fontWeight: FontWeight.bold)),
//                                                             // You must extract datetime from message model (see step 2)
//                                                             if (localTime != null)
//                                                               Text(
//                                                                 DateFormat('MMM d, yyyy – hh:mm a').format(localTime),
//                                                                 style: TextStyle(color: Colors.grey[600]),
//                                                               ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               )
//                                                   : Text(
//                                                 text,
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: widget.message?.replyToDetails != null
//                                                       ? Colors.grey.shade700
//                                                       : Colors.black87,
//                                                 ),
//                                                 softWrap: true,
//                                               ),
//                                             ],
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showEditDeleteOptions(BuildContext context) {
//     // final controller = Get.find<ChatController>();
//     // final bool isGroup = widget.groupMessage != null;
//     final dynamic msg = widget.message;
//
//     // Calculate elapsed time in minutes
//     final createdAt = msg?.createdAt; // Ensure this is a DateTime object
//     final elapsedMinutes = DateTime.now().difference(createdAt!).inMinutes;
//
//     final canEdit = widget.isMe && elapsedMinutes <= 60;
//     final canDelete = widget.isMe && elapsedMinutes <= 180;
//
//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               if (widget.isMe && canEdit && (widget.message?.messageType == 'text' ) )// Only sender can edit
//                 ListTile(
//                   leading: Icon(Icons.edit),
//                   title: Text("Edit"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _showEditDialog(context);
//                   },
//                 ),
//               if (widget.isMe && canDelete) // Only sender can delete
//                 ListTile(
//                   leading: Icon(Icons.delete),
//                   title: Text("Delete"),
//                   onTap: () async {
//                     Navigator.pop(context); // Close the bottom sheet
//
//                     final confirm = await showDialog<bool>(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text("Delete message?"),
//                         content: Text(
//                             "Are you sure you want to delete this message?"),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context, false),
//                             child: Text("Cancel"),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.pop(context, true),
//                             child: Text("Delete",
//                                 style: TextStyle(color: Colors.red)),
//                           ),
//                         ],
//                       ),
//                     );
//
//                     if (confirm == true) {
//
//                         controller.deleteMessage(widget.message?.messageId);
//                     }
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showEditDialog(BuildContext context) {
//     //final controller = Get.find<ChatController>();
//     // final bool isGroup = widget.groupMessage != null;
//     final textController = TextEditingController(
//         text:  widget.message?.message);
//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: Text("Edit Message"),
//           content: TextField(
//             controller: textController,
//             autofocus: true,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                controller.updateMessage(
//                     widget.message?.messageId, textController.text.trim());
//                 //isGroup ? controller.fetchMessage(message?.receiverId) : controller.fetchGroupMessages(groupMessage?.roomId);
//                 Navigator.pop(context);
//
//               },
//               child: Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:om_health_care_app/app/comms/upload_file_utils.dart'; // Ensure this utility is available or remove if not used
import 'package:om_health_care_app/app/modules/message/component/video_bubble.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../comms/string_utils.dart'; // Ensure this utility is available or remove if not used
import '../../../data/models/message_model.dart';
import '../../../data/models/upload_file_model.dart';
import '../../../global/global.dart';
import '../controller/chat_contoller.dart';
import '../controller/download_controller.dart';
import 'audio_player.dart';
import 'full_screen_image.dart';

class ChatBubble extends StatefulWidget {
  final MessageModel? message;
  final bool isMe;

  ChatBubble({this.message, required this.isMe});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _seenEmitted = false;

  final ChatController controller = Get.put(ChatController());
  final DownloadController downloadController = Get.put(DownloadController());

  // No longer need textFocusNode here, it's handled in ChatInputField
  // final textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_seenEmitted && !widget.isMe) {
        final String? messageId = widget.message?.messageId;
        final String? status = widget.message?.messageStatus;

        if (messageId != null && status != 'seen') {
          controller.markMessageAsSeen(messageId, Global.userId ?? '');
          _seenEmitted = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic msg = widget.message;
    final String? text = msg.message;
    final DateTime createdAt = msg.createdAt;
    final localTime = createdAt.toLocal();
    final String? messageType = msg.messageType;
    final List<dynamic>? attachmentDetails = msg.attachmentDetails;
    final double? latitude = msg.latitude;
    final double? longitude = msg.longitude;
    final String? status = widget.message?.messageStatus;
    final String formattedTime = DateFormat('hh:mm a').format(localTime);
    final replyTo = msg.replyToDetails;
    final bool isEdited = msg.isEdited ?? false; // Get the edited status
    final replyMsg = controller.replyMessage.value;

    return Align(
      // Align messages based on sender (me = right, other = left)
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: SwipeTo(
        onRightSwipe: (details) {
          // Set reply message only if it's NOT the current user's message
          if (!widget.isMe) {
            controller.setReplyToMessage(widget.message!);
            // Request focus to the text field in ChatInputField
            // This requires a GlobalKey or similar approach if ChatInputField isn't in the same subtree
            // For simplicity, we'll assume ChatInputField handles its own focus on replyMessage change.
          }
        },
        onLeftSwipe: (details) {
          // Set reply message only if it's the current user's message
          if (widget.isMe) {
            controller.setReplyToMessage(widget.message!);
            // Request focus to the text field in ChatInputField
          }
        },
        // iconOnRightSwipe: !widget.isMe ? Icons.reply : null,
        iconOnRightSwipe: !widget.isMe ? Icons.reply : Icons.arrow_forward_ios,
        // iconOnLeftSwipe: widget.isMe ? Icons.reply : null,
        iconOnLeftSwipe: widget.isMe ? Icons.reply : Icons.arrow_back_ios,
        rightSwipeWidget: SizedBox.shrink(),
        leftSwipeWidget: SizedBox.shrink(),
        child: GestureDetector(
          onLongPress: () {
            _showEditDeleteOptions(context);
          },
          child: Align(
            alignment:
                widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width * 0.75, // Max 75% width
              ),
              child: IntrinsicWidth(
                child: Container(
                  // margin: EdgeInsets.only(
                  //   top: 5,
                  //   bottom: 5,
                  //   left: widget.isMe ? 80 : 10,
                  //   right: widget.isMe ? 10 : 80,
                  // ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.isMe ? const Color(0xFFDCF8C6) : Colors.white,
                    // WhatsApp green for sent, white for received
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: widget.isMe
                          ? const Radius.circular(12)
                          : const Radius.circular(4),
                      // Slightly different for corner
                      bottomRight: widget.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(
                              12), // Slightly different for corner
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Keep column compact
                    children: [
                      // Reply Message Bubble (WhatsApp style)
                      if (replyTo != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? const Color(0xFFD0F5B4)
                                : Colors.grey.shade200,
                            // Lighter shade for reply background
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                                left: BorderSide(
                                    color: widget.isMe
                                        ? Colors.green.shade700
                                        : Colors.blue.shade700,
                                    width: 4)), // Accent border
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   replyTo.senderId == Global.userId ? 'You' : (replyTo.senderDetails?.first.firstname ?? 'Unknown'), // Display "You" or sender name
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     color: widget.isMe ? Colors.green.shade700 : Colors.blue.shade700,
                              //   ),
                              // ),
                              // Text(
                              //   replyMsg?.senderId == Global.userId ? 'You' : (replyMsg?.senderDetails?.first.firstname ?? 'Unknown'),
                              //     style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           color: widget.isMe ? Colors.green.shade700 : Colors.blue.shade700,
                              //         ),
                              // ),
                              Text(
                                replyTo.senderId == Global.userId
                                    ? 'You'
                                    : (replyTo.senderDetails != null &&
                                            replyTo.senderDetails!.isNotEmpty
                                        ? replyTo.senderDetails!.first.firstname
                                        : 'Unknown'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.isMe
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),

                              const SizedBox(height: 2),
                              // Display replied content
                              if (replyTo.message != null &&
                                  replyTo.messageType == 'text')
                                Text(
                                  replyTo.message!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              // Handle other media types in reply preview
                              if (replyTo.messageType == 'image' &&
                                  replyTo.attachmentDetails != null &&
                                  replyTo.attachmentDetails!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.image,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        replyTo.attachmentDetails!.first.name ??
                                            'Image',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              if (replyTo.messageType == 'video' &&
                                  replyTo.attachmentDetails != null &&
                                  replyTo.attachmentDetails!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.videocam,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        replyTo.attachmentDetails!.first.name ??
                                            'Video',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              if (replyTo.messageType == 'audio' &&
                                  replyTo.attachmentDetails != null &&
                                  replyTo.attachmentDetails!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.audiotrack,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        replyTo.attachmentDetails!.first.name ??
                                            'Audio',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              if (replyTo.messageType == 'document' &&
                                  replyTo.attachmentDetails != null &&
                                  replyTo.attachmentDetails!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.insert_drive_file,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        replyTo.attachmentDetails!.first.name ??
                                            'Document',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              if (replyTo.messageType == 'location' &&
                                  replyTo.latitude != null)
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Location Shared',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                      // Main message content
                      if (messageType == "image" &&
                          attachmentDetails != null &&
                          attachmentDetails.isNotEmpty) ...[
                        for (var file in attachmentDetails)
                          if (file.url != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() =>
                                        FullScreenImage(imageUrl: file.url!));
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          file.url!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // Positioned(
                                      //   bottom: 0,
                                      //   right: 0,
                                      //   child: Row(
                                      //     children: [
                                      //       Text(formattedTime,
                                      //           style: TextStyle(fontSize: 10, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
                                      //       const SizedBox(width: 4),
                                      //       if (widget.isMe)
                                      //         Icon(
                                      //           status == 'seen' ? Icons.done_all : Icons.done,
                                      //           size: 16,
                                      //           color: status == 'seen' ? Colors.blue : Colors.white,
                                      //         ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(formattedTime,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black87)),
                                        const SizedBox(width: 4),
                                        if (widget.isMe)
                                          Icon(
                                            status == 'seen'
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 16,
                                            color: status == 'seen'
                                                ? Colors.blue
                                                : Colors.black54,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        // const SizedBox(height: 5),
                      ],

                      if (messageType == "video" &&
                          attachmentDetails != null &&
                          attachmentDetails.isNotEmpty) ...[
                        for (var file in attachmentDetails)
                          if (file.url != null)
                            Column(
                              children: [
                                // VideoBubble(videoUrl: file.url!, width: 200, height: 200, iconSize: 50),
                                VideoBubble(
                                  videoUrl: file.url!,
                                  width: 200,
                                  height: 200,
                                  isMe: widget.isMe,
                                  // formattedTime: formattedTime,
                                  // status: status!,
                                ),

                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    // decoration: BoxDecoration(
                                    //   color: Colors.grey.shade200,
                                    //   borderRadius: BorderRadius.circular(6),
                                    // ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(formattedTime,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black87)),
                                        const SizedBox(width: 4),
                                        if (widget.isMe)
                                          Icon(
                                            status == 'seen'
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 16,
                                            color: status == 'seen'
                                                ? Colors.blue
                                                : Colors.black54,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   right: 8,
                                //   bottom: 8,
                                //   child: IconButton(
                                //     icon: const Icon(Icons.download, color: Colors.white),
                                //     onPressed: () {
                                //       controller.downloadAndSaveFile(file.url!, 'video');
                                //     },
                                //   ),
                                // ),

                                // Positioned(
                                //   bottom: 8,
                                //   right: 8,
                                //   child: Row(
                                //     children: [
                                //       Text(formattedTime,
                                //           style: TextStyle(fontSize: 10, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
                                //       const SizedBox(width: 4),
                                //       if (widget.isMe)
                                //         Icon(
                                //           status == 'seen' ? Icons.done_all : Icons.done,
                                //           size: 16,
                                //           color: status == 'seen' ? Colors.blue : Colors.white,
                                //         ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            )
                      ],

                      if (messageType == "audio" &&
                          attachmentDetails != null &&
                          attachmentDetails.isNotEmpty) ...[
                        for (var file in attachmentDetails)
                          if (file.url != null)
                            Stack(
                              children: [
                                AudioPlayerWidget(audioUrl: file.url!),
                                Positioned(
                                  // Adjusted position for download button
                                  right: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.download,
                                        size: 20, color: Colors.black54),
                                    onPressed: () {
                                      controller.downloadAndSaveFile(
                                          file.url!, 'audio');
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Row(
                                    children: [
                                      Text(formattedTime,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                    color: Colors.black,
                                                    blurRadius: 2)
                                              ])),
                                      const SizedBox(width: 4),
                                      if (widget.isMe)
                                        Icon(
                                          status == 'seen'
                                              ? Icons.done_all
                                              : Icons.done,
                                          size: 16,
                                          color: status == 'seen'
                                              ? Colors.blue
                                              : Colors.white,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        const SizedBox(height: 5),
                      ],

                      if (messageType == "document" &&
                          attachmentDetails != null &&
                          attachmentDetails.isNotEmpty) ...[
                        ...attachmentDetails.map<Widget>((dynamic file) {
                          if (file is! UploadFile ||
                              file.name == null ||
                              file.url == null) return const SizedBox.shrink();
                          return FutureBuilder<bool>(
                              future: file.isFileDownloadedLocally(),
                              builder: (context, snapshot) {
                                bool downloaded = snapshot.data ?? false;
                                return GestureDetector(
                                  onTap: () async {
                                    try {
                                      if (!downloaded) {
                                        final path = await ChatController()
                                            .downloadFileToLocal(file);
                                        if (path != null) {
                                          await OpenFilex.open(path);
                                          // downloadController.updateDownloadedStatus(file.name!);
                                        }
                                      } else {
                                        final dir =
                                            await getApplicationDocumentsDirectory();
                                        final path =
                                            '/storage/emulated/0/Download/${file.name}';
                                        await OpenFilex.open(path);
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("Error: ${e.toString()}")),
                                      );
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.insert_drive_file,
                                                      color: Colors.grey,
                                                      size: 18,
                                                    )),
                                                Obx(() {
                                                  final isDownloading =
                                                      downloadController
                                                          .isDownloading(
                                                              file.name!);
                                                  final progress =
                                                      downloadController
                                                          .getProgress(
                                                              file.name!);
                                                  return isDownloading
                                                      ? Text(
                                                          '${(progress * 100).toStringAsFixed(0)}%',
                                                          style: const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      : ((!downloaded &&
                                                              !widget
                                                                  .isMe) // Show download for others, if not downloaded
                                                          ? const Icon(
                                                              Icons.download,
                                                              size: 16,
                                                              color: Colors
                                                                  .black87)
                                                          : const SizedBox());
                                                }),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    file.name!,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                  Text(
                                                    StringUtils
                                                        .getFileSizeString(
                                                            bytes: file.size!),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Row(
                                          children: [
                                            Text(
                                              formattedTime,
                                              // pass from parent: DateFormat('hh:mm a').format(message.createdAt)
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            if (widget.isMe)
                                              Icon(
                                                status == 'seen'
                                                    ? Icons.done_all
                                                    : Icons.done,
                                                size: 16,
                                                color: status == 'seen'
                                                    ? Colors.blue
                                                    : Colors.black54,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }),
                        const SizedBox(height: 5),
                      ],

                      if (messageType == "location" &&
                          latitude != null &&
                          longitude != null) ...[
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                String mapUrl =
                                    "https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}";
                                launchUrl(Uri.parse(mapUrl),
                                    mode: LaunchMode.externalApplication);
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 150,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.blue[100],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        "https://static-maps.yandex.ru/1.x/?lang=en-US&ll=${longitude},${latitude}&z=15&l=map&size=200,150",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Positioned(
                                  //   bottom: 0,
                                  //   right: 0,
                                  //   child: Row(
                                  //     children: [
                                  //       Text(
                                  //         formattedTime,
                                  //         // from parent: DateFormat('hh:mm a').format(msg.createdAt)
                                  //         style: TextStyle(
                                  //           fontSize: 10,
                                  //           color: Colors.grey[600],
                                  //           // shadows: [Shadow(color: Colors.black, blurRadius: 2)], // readable over map
                                  //         ),
                                  //       ),
                                  //       const SizedBox(width: 4),
                                  //       if (widget.isMe)
                                  //         Icon(
                                  //           status == 'seen'
                                  //               ? Icons.done_all
                                  //               : Icons.done,
                                  //           size: 16,
                                  //           color: status == 'seen'
                                  //               ? Colors.blue
                                  //               : Colors.grey[600],
                                  //         ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                // decoration: BoxDecoration(
                                //   color: Colors.grey.shade200,
                                //   borderRadius: BorderRadius.circular(6),
                                // ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.black87)),
                                    const SizedBox(width: 4),
                                    if (widget.isMe)
                                      Icon(
                                        status == 'seen' ? Icons.done_all : Icons.done,
                                        size: 16,
                                        color: status == 'seen' ? Colors.blue : Colors.black54,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 5),
                      ],

                      // Text Message
                      if (text != null && text.isNotEmpty) ...[
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 70),
                              // leave room for timestamp
                              child: text.contains("zoom.us")
                                  ? GestureDetector(
                                      onTap: () async {
                                        final url = Uri.parse(text);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          Get.snackbar('Error',
                                              'Could not open Zoom link');
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.blue),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                    'assets/icon/zoom.png',
                                                    height: 24,
                                                    width: 24),
                                                const SizedBox(width: 8),
                                                const Text("Zoom Meeting",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat(
                                                      'MMM d, yyyy – hh:mm a')
                                                  .format(localTime),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: widget.isMe
                                            ? Colors.black87
                                            : Colors.black,
                                      ),
                                    ),
                            ),

                            // WhatsApp style timestamp + status inside bubble
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isEdited)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Text(
                                        'Edited',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600]),
                                      ),
                                    ),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 4),
                                  if (widget.isMe)
                                    Icon(
                                      status == 'seen'
                                          ? Icons.done_all
                                          : Icons.done,
                                      size: 16,
                                      color: status == 'seen'
                                          ? Colors.blue
                                          : Colors.grey[600],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      // if (text != null && text.isNotEmpty) ...[
                      //   text.contains("zoom.us") ?
                      //   GestureDetector(
                      //     onTap: () async {
                      //       final url = Uri.parse(text);
                      //       if (await canLaunchUrl(url)) {
                      //         await launchUrl(url, mode: LaunchMode.externalApplication);
                      //       } else {
                      //         Get.snackbar('Error', 'Could not open Zoom link');
                      //       }
                      //     },
                      //     child: Container(
                      //       padding: const EdgeInsets.all(8),
                      //       decoration: BoxDecoration(
                      //         color: Colors.blue.shade50,
                      //         borderRadius: BorderRadius.circular(8),
                      //         border: Border.all(color: Colors.blue),
                      //       ),
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Row(
                      //             children: [
                      //               Image.asset(
                      //                 'assets/icon/zoom.png', // Ensure this asset exists
                      //                 height: 24,
                      //                 width: 24,
                      //               ),
                      //               const SizedBox(width: 8),
                      //               const Text("Zoom Meeting", style: TextStyle(fontWeight: FontWeight.bold)),
                      //             ],
                      //           ),
                      //           const SizedBox(height: 4),
                      //           Text(
                      //             DateFormat('MMM d, yyyy – hh:mm a').format(localTime),
                      //             style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   )
                      //       : Text(
                      //     text,
                      //     style: TextStyle(
                      //       fontSize: 15,
                      //       color: widget.isMe ? Colors.black87 : Colors.black, // Darker text for received for contrast
                      //     ),
                      //     softWrap: true,
                      //   ),
                      // ],
                      //
                      // const SizedBox(height: 4), // Spacing between message content and timestamp/status
                      //
                      // // Timestamp and Status (Edited label)
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end, // Align to end for both sent/received
                      //   children: [
                      //     if (isEdited)
                      //       Padding(
                      //         padding: const EdgeInsets.only(right: 4.0),
                      //         child: Text(
                      //           'Edited',
                      //           style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      //         ),
                      //       ),
                      //     Text(
                      //       formattedTime,
                      //       style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      //     ),
                      //     const SizedBox(width: 4),
                      //     if (widget.isMe) // Show read status only for messages sent by me
                      //       Icon(
                      //         status == 'seen' ? Icons.done_all : Icons.done,
                      //         size: 16,
                      //         color: status == 'seen' ? Colors.blue : Colors.grey[600],
                      //       ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDeleteOptions(BuildContext context) {
    final dynamic msg = widget.message;
    final createdAt = msg?.createdAt;
    final elapsedMinutes = DateTime.now().difference(createdAt!).inMinutes;

    final canEdit = widget.isMe && elapsedMinutes <= 60; // Editable for 1 hour
    final canDelete =
        widget.isMe && elapsedMinutes <= 180; // Deletable for 3 hours

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              if (widget.isMe &&
                  canEdit &&
                  (widget.message?.messageType == 'text'))
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit"),
                  onTap: () {
                    Navigator.pop(context);
                    controller.setEditingMessage(
                        widget.message!); // Set message for editing
                  },
                ),
              if (widget.isMe && canDelete)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete"),
                  onTap: () async {
                    Navigator.pop(context);

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete message?"),
                        content: const Text(
                            "Are you sure you want to delete this message?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      controller.deleteMessage(widget.message?.messageId);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
