import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/screens/check_video_screen/check_video_screen.dart';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:gallery_saver/gallery_saver.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  VideoPlayerController? videoController;

  File? _videoFile;

  // Initial values
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;

  bool _isRearCameraSelected = true;

  // bool _isVideoCameraSelected = true;

  bool _isRecordingInProgress = false;

  // 최소, 최대 줌 레벨 설정
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // 최소, 최대 화면 크기(해상도?) 레벨 설정
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;

  // Current values
  // 현재 줌 레벨
  double _currentZoomLevel = 1.0;

  // 현재 화면 크기 레벨
  double _currentExposureOffset = 0.0;

  // 플래쉬 켰는지, 키지 않았는지 여부 확인
  FlashMode? _currentFlashMode;

  // 타이머
  Timer? stopwatch;
  int _counter = 0;
  bool _isPaused = true;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  // 카메라/녹음 기능 접근 허가
  getPermissionStatus() async {
    // 카메라&녹음 허가 받았는지 확인하여 돌아온 값을 status에 저장
    await Permission.camera.request();
    var status = await Permission.camera.status;

    // 만약 허가 받은 상태라면, _isCameraPermissionGranted 값을 true로 전환
    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    print(allFileList);
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
      } else {
        _videoFile = null;
      }
      setState(() {});
    }
  }

  // 현재 사용할 수 있는 카메라 목록 가져옴
  Future<void> getCameras() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print('Error in fecting the cameras: $e');
    }
  }

  Future<XFile?> capture() async {
    try {
      // 카메라 프리뷰의 이미지를 캡쳐합니다.
      final image = await controller!.takePicture();
      return image;
    } catch (e) {
      // 캡쳐에 실패한 경우 에러를 출력합니다.
      print(e);
      return null;
    }
  }

  Future<void> saveImageToGallery(XFile imageFile, String folderName) async {
    try {
      final appDir = await getExternalStorageDirectory(); // 앱의 로컬 디렉토리 가져오기
      final folderPath = '${appDir!.path}/$folderName'; // 앱의 이름으로 만든 폴더 경로 설정
      await Directory(folderPath).create(recursive: true); // 해당 경로에 폴더 생성
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg'; // 이미지 파일 이름 설정
      final filePath = '$folderPath/$fileName'; // 파일 경로 설정
      final imageBytes = await imageFile.readAsBytes(); // 이미지 파일 바이트 가져오기
      await File(filePath).writeAsBytes(imageBytes); // 파일에 이미지 바이트 저장하기
      await GallerySaver.saveImage(filePath); // 갤러리에 파일 저장하기
    } catch (e) {
      print(e);
    }
  }

  // Future<void> _startVideoPlayer() async {
  //   if (_videoFile != null) {
  //     videoController = VideoPlayerController.file(_videoFile!);
  //     await videoController!.initialize().then((_) {
  //       // Ensure the first frame is shown after the video is initialized,
  //       // even before the play button has been pressed.
  //       setState(() {});
  //     });
  //     await videoController!.setLooping(true);
  //     await videoController!.play();
  //   }
  // }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      // 현재 카메라 기능 모두 가져옴
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  // 만약 사용자가 화면의 한 부분을 탭한다면, 그 부분의 좌표를 가져와 finder 효과를 줌
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _startTimer() {
    stopwatch = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  void _stopTimer() {
    if (stopwatch != null) {
      setState(() {
        _isPaused = true;
        stopwatch!.cancel();
        stopwatch = null;
        _counter = 0;
      });
    }
  }

  void _pauseTimer() {
    if (stopwatch != null) {
      setState(() {
        _isPaused = true;
        stopwatch!.cancel();
        stopwatch = null;
      });
    }
  }

  void _resumeTimer() {
    if (stopwatch == null) {
      setState(() {
        _isPaused = false;
        stopwatch = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _counter++;
          });
        });
      });
    }
  }

  // timer 시, 분, 초 단위로 표시 전환해줌
  String _durationToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // double _getCameraAngle(Orientation orientation) {
  //   double angle = 0;
  //   switch (orientation) {
  //     case Orientation.landscape:
  //       angle = -90;
  //       break;
  //     // case DeviceOrientation.landscapeRight:
  //     //   angle = 90 * 3.1415926535897932 / 180;
  //     //   break;
  //     case Orientation.portrait:
  //       angle = 0;
  //       break;
  //   }
  //   return angle;
  // }

  @override
  void initState() {
    // Hide the status bar in Android
    // 하단바만 보이게 조절
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
      ],
    );
    // 카메라 정보 가져오기
    getCameras();
    // 카메라, 마이크 장치 허락 받기
    getPermissionStatus();
    controller?.initialize();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: (controller!.value.aspectRatio),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CameraPreview(
                                  controller!,
                                  child: LayoutBuilder(builder:
                                      (BuildContext context,
                                          BoxConstraints constraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (details) =>
                                          onViewFinderTap(details, constraints),
                                    );
                                  }),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: (orientation == Orientation.portrait)
                                    ? MediaQuery.of(context).size.width / 2 - 90
                                    : MediaQuery.of(context).size.height / 2 +
                                        45,
                                child: Container(
                                  height: 32,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${_durationToString(Duration(seconds: _counter))}",
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (_currentFlashMode !=
                                              FlashMode.torch) {
                                            setState(() {
                                              _currentFlashMode =
                                                  FlashMode.torch;
                                            });
                                            await controller!.setFlashMode(
                                              FlashMode.torch,
                                            );
                                          } else {
                                            setState(() {
                                              _currentFlashMode = FlashMode.off;
                                            });
                                            await controller!.setFlashMode(
                                              FlashMode.off,
                                            );
                                          }
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: Colors.black38,
                                              size: 60,
                                            ),
                                            Icon(
                                              Icons.highlight,
                                              color: _currentFlashMode ==
                                                      FlashMode.torch
                                                  ? Colors.amber
                                                  : Colors.white,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                      _isRecordingInProgress
                                          ? Container(
                                              height: 80,
                                              width: 160,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      if (controller!.value
                                                          .isRecordingPaused) {
                                                        await resumeVideoRecording();
                                                        _resumeTimer();
                                                      } else {
                                                        await pauseVideoRecording();
                                                        _pauseTimer();
                                                      }
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        controller!.value
                                                                .isRecordingPaused
                                                            ? const Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 42,
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .circle,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 30,
                                                                  ),
                                                                ],
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .pause_rounded,
                                                                color: Colors
                                                                    .black,
                                                                size: 42,
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      _stopTimer();
                                                      _isCameraInitialized =
                                                          false;

                                                      XFile? rawVideo =
                                                          await stopVideoRecording();
                                                      print(
                                                          'my_file is here!!!');
                                                      print(rawVideo!.path);
                                                      File videoFile =
                                                          File(rawVideo!.path);

                                                      int fileSizeInBytes =
                                                          await videoFile
                                                              .length();
                                                      double fileSizeInMB =
                                                          fileSizeInBytes /
                                                              (1024 * 1024);
                                                      print(
                                                          'Video file size: $fileSizeInMB MB');
                                                      int currentUnix = DateTime
                                                              .now()
                                                          .millisecondsSinceEpoch;

                                                      final directory =
                                                          await getApplicationDocumentsDirectory();

                                                      String fileFormat =
                                                          videoFile.path
                                                              .split('.')
                                                              .last;

                                                      _videoFile =
                                                          await videoFile.copy(
                                                        '${directory.path}/$currentUnix.$fileFormat',
                                                      );
                                                      allFileList
                                                          .add(videoFile);

                                                      final route =
                                                          MaterialPageRoute(
                                                        fullscreenDialog: true,
                                                        builder: (_) =>
                                                            CheckVideoPage(
                                                                filePath:
                                                                    videoFile
                                                                        .path),
                                                      );
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                          context, route);
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.square_rounded,
                                                          color: Colors.black,
                                                          size: 30,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          // 동영상 촬영 시작 시
                                          : InkWell(
                                              onTap: () async {
                                                await startVideoRecording();
                                                _startTimer();
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: Colors.white,
                                                    size: 80,
                                                  ),
                                                  Icon(
                                                    Icons.circle,
                                                    color: Colors.red,
                                                    size: 30,
                                                  ),
                                                ],
                                              ),
                                            ),
                                      _isRecordingInProgress
                                          ? InkWell(
                                              onTap: () async {
                                                // XFile? rawImage =
                                                //     await capture();
                                                //
                                                // if (rawImage != null) {
                                                //   saveImageToGallery(
                                                //       rawImage, 'capture');
                                                // }
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: Colors.black38,
                                                    size: 60,
                                                  ),
                                                  // Icon(
                                                  //   Icons.circle,
                                                  //   color: Colors.white,
                                                  //   size: 40,
                                                  // ),
                                                  Icon(
                                                    Icons.camera,
                                                    color: Colors.white,
                                                    size: 30,
                                                  )
                                                ],
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _isCameraInitialized = false;
                                                });
                                                onNewCameraSelected(cameras[
                                                    _isRearCameraSelected
                                                        ? 1
                                                        : 0]);
                                                setState(() {
                                                  _isRearCameraSelected =
                                                      !_isRearCameraSelected;
                                                });
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: Colors.black38,
                                                    size: 60,
                                                  ),
                                                  Icon(
                                                    _isRearCameraSelected
                                                        ? Icons.camera_front
                                                        : Icons.camera_rear,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   color: Colors.black.withOpacity(0.5),
                      //   child: Padding(
                      //     padding:
                      //         const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         InkWell(
                      //           onTap: () async {
                      //             setState(() {
                      //               _currentFlashMode = FlashMode.off;
                      //             });
                      //             await controller!.setFlashMode(
                      //               FlashMode.off,
                      //             );
                      //           },
                      //           child: Icon(
                      //             Icons.flash_off,
                      //             color: _currentFlashMode == FlashMode.off
                      //                 ? Colors.amber
                      //                 : Colors.white,
                      //           ),
                      //         ),
                      //         InkWell(
                      //           onTap: () async {
                      //             setState(() {
                      //               _currentFlashMode = FlashMode.auto;
                      //             });
                      //             await controller!.setFlashMode(
                      //               FlashMode.auto,
                      //             );
                      //           },
                      //           child: Icon(
                      //             Icons.flash_auto,
                      //             color: _currentFlashMode == FlashMode.auto
                      //                 ? Colors.amber
                      //                 : Colors.white,
                      //           ),
                      //         ),
                      //         InkWell(
                      //           onTap: () async {
                      //             setState(() {
                      //               _currentFlashMode = FlashMode.always;
                      //             });
                      //             await controller!.setFlashMode(
                      //               FlashMode.always,
                      //             );
                      //           },
                      //           child: Icon(
                      //             Icons.flash_on,
                      //             color: _currentFlashMode == FlashMode.always
                      //                 ? Colors.amber
                      //                 : Colors.white,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE0426F),
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(),
                  Text(
                    '권한이 거부되었습니다.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color(0xFFE0426F),
                    ),
                    onPressed: () {
                      getPermissionStatus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '카메라 권한 허가',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
