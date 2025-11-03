
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoController extends GetxController {
  late final VideoPlayerController videoPlayerController;
  final RxBool isPlaying = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString thumbnailPath = ''.obs;
  final RxString durationText = ''.obs;
  final RxString currentPositionText = '0:00'.obs;

  VideoController(String videoUrl) {
    videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        isInitialized.value = true;

        // Save duration in mm:ss format
        final duration = videoPlayerController.value.duration;
        durationText.value =
        "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";

        // Generate thumbnail
        _generateThumbnail(videoUrl);
        update();
      });

    videoPlayerController.addListener(() {
      // update play/pause state
      isPlaying.value = videoPlayerController.value.isPlaying;

      // update current position
      final position = videoPlayerController.value.position;
      currentPositionText.value =
      "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}";
    });
  }

  Future<void> _generateThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );

      if (path != null) {
        thumbnailPath.value = path;
        update();
      }
    } catch (e) {
      print("Error generating thumbnail: $e");
    }
  }

  void togglePlayPause() {
    if (videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
    } else {
      videoPlayerController.play();
    }
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }
}




// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
//
// class VideoController extends GetxController {
//   late final VideoPlayerController videoPlayerController;
//   final RxBool isPlaying = true.obs;
//   final RxBool isInitialized = false.obs;
//   final RxString thumbnailPath = ''.obs;
//   final RxString durationText = ''.obs;
//
//   VideoController(String videoUrl) {
//     videoPlayerController = VideoPlayerController.network(videoUrl)
//       ..initialize().then((_) {
//         isInitialized.value = true;
//
//         // Save duration in mm:ss format
//         final duration = videoPlayerController.value.duration;
//         durationText.value =
//         "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
//
//         // Generate thumbnail
//         _generateThumbnail(videoUrl);
//         update();
//       });
//
//     videoPlayerController.addListener(() {
//       isPlaying.value = videoPlayerController.value.isPlaying;
//     });
//   }
//
//   Future<void> _generateThumbnail(String videoUrl) async {
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final path = await VideoThumbnail.thumbnailFile(
//         video: videoUrl,
//         thumbnailPath: tempDir.path,
//         imageFormat: ImageFormat.JPEG,
//         maxHeight: 200,
//         quality: 75,
//       );
//
//       if (path != null) {
//         thumbnailPath.value = path;
//         update();
//       }
//     } catch (e) {
//       print("Error generating thumbnail: $e");
//     }
//   }
//
//   void togglePlayPause() {
//     if (videoPlayerController.value.isPlaying) {
//       videoPlayerController.pause();
//     } else {
//       videoPlayerController.play();
//     }
//   }
//
//   @override
//   void onClose() {
//     videoPlayerController.dispose();
//     super.onClose();
//   }
// }
