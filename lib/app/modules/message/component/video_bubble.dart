import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/video_controller.dart';
import 'full_screen_video.dart';

class VideoBubble extends StatelessWidget {
  final String videoUrl;
  final double width;
  final double height;
  final bool isMe;
  // final String formattedTime;
  // final String status;
  final VideoController controller;

  VideoBubble({
    Key? key,
    required this.videoUrl,
    required this.width,
    required this.height,
    required this.isMe,
    // required this.formattedTime,
    // required this.status,
  })  : controller = Get.put(VideoController(videoUrl), tag: videoUrl),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => FullScreenVideo(videoUrl: videoUrl));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Thumbnail
            Obx(() => controller.thumbnailPath.isNotEmpty
                ? Image.file(
              File(controller.thumbnailPath.value),
              width: width,
              height: height,
              fit: BoxFit.cover,
            )
                : Container(
              width: width,
              height: height,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            )),

            /// Center play button
            const Icon(Icons.play_circle_fill,
                color: Colors.white, size: 50),

            /// Bottom-left video icon + duration
            Positioned(
              bottom: 6,
              left: 6,
              child: Row(
                children: [
                  const Icon(Icons.videocam,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                    controller.durationText.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 2)
                      ],
                    ),
                  )),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
