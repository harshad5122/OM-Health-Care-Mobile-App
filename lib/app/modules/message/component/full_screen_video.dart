import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/video_controller.dart';

class FullScreenVideo extends StatelessWidget {
  final String videoUrl;

  const FullScreenVideo({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final videoController = Get.put(VideoController(videoUrl));

    return WillPopScope(
      onWillPop: () async {
        videoController.videoPlayerController.pause();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: videoController.togglePlayPause,
          child: Center(
            child: Obx(() => videoController.isInitialized.value
                ? Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: videoController
                      .videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(videoController.videoPlayerController),
                ),
                if (!videoController.isPlaying.value)
                  const Icon(Icons.play_circle_fill,
                      size: 80, color: Colors.white),
              ],
            )
                : const CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

