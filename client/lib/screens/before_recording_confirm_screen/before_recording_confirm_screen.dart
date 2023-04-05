import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animations/animations.dart';
import 'package:client/screens/after_recording_screen/after_recording_screen.dart';

class BeforeRecordingConfirmScreen extends StatefulWidget {
  final String? videoCase;

  const BeforeRecordingConfirmScreen({
    super.key,
    required this.videoCase,
  });

  @override
  State<BeforeRecordingConfirmScreen> createState() =>
      _BeforeRecordingConfirmScreenState();
}

class _BeforeRecordingConfirmScreenState
    extends State<BeforeRecordingConfirmScreen> {
  bool _isLoading = false;
  bool _notPickVideo = false;
  String? videoFilePath;
  File? videoFile;

  @override
  void initState() {
    if (widget.videoCase == 'pick') {
      _pickVideo(context);
    } else {
      setState(() {
        _isLoading = false;
        _notPickVideo = true;
      });
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds: 1));
      videoFile = File(pickedFile.path);
      videoFilePath = videoFile!.path;
      print(videoFilePath);
      if (videoFilePath != null || videoFilePath != '') {
        final route = MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AfterRecordingScreen(
            filePath: videoFilePath!,
          ),
        );
        Navigator.pop(context);
        Navigator.push(context, route);
      } else {
        setState(() {
          _isLoading = false;
          _notPickVideo = true;
        });
      }
    }
  }

  Future<void> _takeVideo(BuildContext context) async {
    final pickedFile = await ImagePicker().getVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds: 1));
      videoFile = File(pickedFile.path);
      videoFilePath = videoFile!.path;
      if (videoFilePath != null || videoFilePath != '') {
        final route = MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AfterRecordingScreen(
            filePath: videoFilePath!,
          ),
        );
        Navigator.pop(context);
        Navigator.push(context, route);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor는 흰색으로 설정
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFFFF3F3F),
        ),
        // Column 정렬 이용해 화면 정가운데에 이하 요소들을 정렬
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : _notPickVideo
                ? Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // 상하 간격
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Wrap(
                                // 세로로 나열
                                direction: Axis.vertical,
                                // 나열 방향
                                crossAxisAlignment: WrapCrossAlignment.center,
                                // 정렬 방식
                                spacing: 10,
                                // 좌우 간격
                                children: [
                                  Text(
                                    '지금부터',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF453F52),
                                    ),
                                  ),
                                  Text(
                                    '녹화가 시작됩니다',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF453F52),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '주의해주세요',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF999999)
                                            .withOpacity(0.5),
                                        spreadRadius: 0.3,
                                        blurRadius: 6,
                                      )
                                    ]),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.light_mode,
                                                  size: 24,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text(
                                                  '어둠 금지',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '어두운 곳에서는',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '플래시를',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.car_crash,
                                                  size: 24,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text(
                                                  '물체 비침 주의',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '차 표면에',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '비치지 않도록',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .airline_seat_flat_angled,
                                                  size: 24,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text(
                                                  '각도 주의',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '잘 포착하도록',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '각도 조절하기',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.flash_off_outlined,
                                                  size: 24,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text(
                                                  '빠른 이동 금지',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '카메라 이동은',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '천천히',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: Size(180, 50),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  _takeVideo(context);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.videocam_outlined,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      '영상 촬영하기',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                  )
                : Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // 상하 간격
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: Wrap(
                                // 세로로 나열
                                direction: Axis.vertical,
                                // 나열 방향
                                crossAxisAlignment: WrapCrossAlignment.center,
                                // 정렬 방식
                                spacing: 10,
                                // 좌우 간격
                                children: [
                                  Text(
                                    '현재 선택된 영상이',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF453F52),
                                    ),
                                  ),
                                  Text(
                                    '없습니다',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF453F52),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Text(
                                    '하나를 선택해주세요',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        fixedSize: Size(180, 50),
                                        backgroundColor:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      onPressed: () {
                                        _pickVideo(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.video_collection_outlined,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            '앨범에서 선택',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        fixedSize: Size(180, 50),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        _takeVideo(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.videocam_outlined,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '영상 촬영하기',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
