// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
// import '../controller/video_controller.dart';
//
// class FullScreenVideo extends StatelessWidget {
//   final String videoUrl;
//
//   const FullScreenVideo({Key? key, required this.videoUrl}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final videoController = Get.put(VideoController(videoUrl));
//
//     return WillPopScope(
//       onWillPop: () async {
//         videoController.videoPlayerController.pause();
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: GestureDetector(
//           onTap: videoController.togglePlayPause,
//           child: Center(
//             child: Obx(() => videoController.isInitialized.value
//                 ? Stack(
//               alignment: Alignment.center,
//               children: [
//                 AspectRatio(
//                   aspectRatio: videoController
//                       .videoPlayerController.value.aspectRatio,
//                   child: VideoPlayer(videoController.videoPlayerController),
//                 ),
//                 if (!videoController.isPlaying.value)
//                   const Icon(Icons.play_circle_fill,
//                       size: 80, color: Colors.white),
//               ],
//             )
//                 : const CircularProgressIndicator()),
//           ),
//         ),
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/video_controller.dart';

class FullScreenVideo extends StatelessWidget {
  final String videoUrl;
  final VideoController controller;

  FullScreenVideo({super.key, required this.videoUrl})
      : controller = Get.find<VideoController>(tag: videoUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (!controller.isInitialized.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              /// Video Player
              Center(
                child: AspectRatio(
                  aspectRatio:
                  controller.videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(controller.videoPlayerController),
                ),
              ),

              /// Controls (bottom like WhatsApp)
              Positioned(
                bottom: 20,
                left: 10,
                right: 10,
                child: Column(
                  children: [
                    /// Progress bar with scrubbing
                    VideoProgressIndicator(
                      controller.videoPlayerController,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.blue,
                        backgroundColor: Colors.white38,
                        bufferedColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),

                    /// Play/Pause + Time labels
                    Row(
                      children: [
                        IconButton(
                          icon: Obx(() => Icon(
                            controller.isPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          )),
                          onPressed: controller.togglePlayPause,
                        ),
                        Obx(() => Text(
                          controller.currentPositionText.value,
                          style: const TextStyle(color: Colors.white),
                        )),
                        const Spacer(),
                        Obx(() => Text(
                          controller.durationText.value,
                          style: const TextStyle(color: Colors.white),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
// import '../controller/video_controller.dart';
//
// class FullScreenVideo extends StatelessWidget {
//   final String videoUrl;
//   final VideoController controller;
//
//   FullScreenVideo({super.key, required this.videoUrl})
//       : controller = Get.find<VideoController>(tag: videoUrl);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Obx(() {
//           if (!controller.isInitialized.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return Stack(
//             children: [
//               Center(
//                 child: AspectRatio(
//                   aspectRatio:
//                   controller.videoPlayerController.value.aspectRatio,
//                   child: VideoPlayer(controller.videoPlayerController),
//                 ),
//               ),
//
//               /// Controls
//               Positioned(
//                 bottom: 20,
//                 left: 10,
//                 right: 10,
//                 child: Column(
//                   children: [
//                     VideoProgressIndicator(
//                       controller.videoPlayerController,
//                       allowScrubbing: true,
//                       colors: VideoProgressColors(
//                         playedColor: Colors.blue,
//                         backgroundColor: Colors.white38,
//                         bufferedColor: Colors.grey,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             controller.videoPlayerController.value.isPlaying
//                                 ? Icons.pause
//                                 : Icons.play_arrow,
//                             color: Colors.white,
//                           ),
//                           onPressed: controller.togglePlayPause,
//                         ),
//                         Text(
//                           _formatDuration(controller
//                               .videoPlayerController.value.position),
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         const Spacer(),
//                         Text(
//                           _formatDuration(controller
//                               .videoPlayerController.value.duration),
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
//
//   String _formatDuration(Duration duration) {
//     return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
//   }
// }
