import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/video_controller.dart';
import 'full_screen_video.dart';


class VideoBubble extends StatelessWidget {
  final String videoUrl;
  final double width;
  final double height;
  final double iconSize;
  final VideoController controller;

  VideoBubble({Key? key, required this.videoUrl, required this.width, required this.height, required this.iconSize})
      : controller = Get.put(VideoController(videoUrl), tag: videoUrl),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => FullScreenVideo(videoUrl: videoUrl));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Obx(() => controller.thumbnailPath.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(controller.thumbnailPath.value),
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          )
              : Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black12,
            ),
            child: Center(child: CircularProgressIndicator()), // Loading
          )),
          Icon(Icons.play_circle_fill, color: Colors.white, size: iconSize),
        ],
      ),
    );
  }
}
