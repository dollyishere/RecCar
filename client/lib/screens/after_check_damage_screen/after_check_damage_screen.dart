import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:client/screens/after_recording_screen/damage_count_info_block.dart';
import 'package:client/services/check_car_api.dart';

// 만약 애니메이션 효과 추가 시, 수정 필요
class AfterCheckDamageScreen extends StatefulWidget {
  final String filePath;
  final List<Map<String, dynamic>> carDamagesAllList;

  const AfterCheckDamageScreen({
    Key? key,
    required this.filePath,
    required this.carDamagesAllList,
  }) : super(key: key);

  @override
  State<AfterCheckDamageScreen> createState() => _AfterCheckDamageScreen();
}

class _AfterCheckDamageScreen extends State<AfterCheckDamageScreen> {
  bool load_data = false;
  bool loading_api = false;
  List<Map<String, dynamic>> damageInfoList = [];

  static final storage = FlutterSecureStorage();
  int? currentCarId;
  int? currentCarVideo;
  late DateTime nowDateTime;
  bool? formerState;

  // 각 유형 별 파손 개수 변수로 지정
  num scratch_count = 0;
  num crushed_count = 0;
  num breakage_count = 0;
  num separated_count = 0;

  // 각 부위 별 파손 개수 변수로 지정
  int front_count = 0;
  int back_count = 0;
  int side_count = 0;
  int wheel_count = 0;

  Future<void> setCurrentCarId() async {
    final carId = await storage.read(key: 'carId');
    setState(() {
      currentCarId = int.parse(carId!);
    });
    print(currentCarId);
  }

  Future<void> setCurrentCarVideo() async {
    final carVideoState = await storage.read(key: 'carVideoState');
    setState(() {
      if (carVideoState == '0') {
        setState(() {
          currentCarVideo = 0;
          formerState = true;
        });
      } else if (carVideoState == '1') {
        setState(() {
          currentCarVideo = 1;
          formerState = false;
        });
      } else {
        setState(() {
          currentCarVideo = 2;
          formerState = false;
        });
      }
    });
    print(currentCarVideo);
    print(formerState);
  }

  String checkDamagePart(Map<String, dynamic> damage) {
    if (damage["part"] == "앞범퍼/앞펜더/전조등") {
      setState(() {
        front_count += 1;
      });
      return 'front';
    } else if (damage["part"] == "뒷범퍼/뒷펜더/후미등") {
      setState(() {
        back_count += 1;
      });
      return 'back';
    } else if (damage["part"] == "옆면/사이드/스텝") {
      setState(() {
        side_count += 1;
      });
      return 'side';
    } else if (damage["part"] == "타이어/휠") {
      setState(() {
        wheel_count += 1;
      });
      return 'wheel';
    }
    return 'none';
  }

  Future<void> fetchData() async {
    await Future.delayed(Duration(milliseconds: 10));
    dataChange();
  }

  void dataChange() {
    widget.carDamagesAllList
        .where((damage) => damage['selected'] == true)
        .forEach((damage) {
      Map<String, dynamic> carDamageInfo = {
        // "carId": int.parse(currentCarId!),
        "carId": currentCarId == null ? 0 : currentCarId,
        "former": formerState == null ? false : formerState,
        "pictureUrl": damage["Damage_Image_URL"],
        "part": checkDamagePart(damage),
        "memo": damage["memo"],
        "damageDate": nowDateTime.toIso8601String(),
        "scratch": damage["Scratch"],
        "breakage": damage["Breakage"],
        "crushed": damage["Crushed"],
        "separated": damage["Separated"],
      };
      print(carDamageInfo);
      setState(() {
        damageInfoList.add(carDamageInfo);
        scratch_count += damage["Scratch"];
        breakage_count += damage["Breakage"];
        crushed_count += damage["Crushed"];
        separated_count += damage["Separated"];
      });
    });
    setState(() {
      load_data = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setCurrentCarId();
    setCurrentCarVideo();
    nowDateTime = DateTime.now();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      // backgroundColor는 흰색으로 설정
      backgroundColor: Colors.white,
          // appBar: (load_data || loading_api ) ? AppBar(
          //   elevation: 0,
          //   backgroundColor: Colors.white,
          //   foregroundColor: Color(0xFFFF3F3F),
          // ) : null,
      // Column 정렬 이용해 화면 정가운데에 이하 요소들을 정렬
      body: load_data
          ? Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: loading_api
                      ? Center(
                          // 상하 간격
                          child: Wrap(
                            // 세로로 나열
                            direction: Axis.vertical,
                            // 나열 방향
                            crossAxisAlignment: WrapCrossAlignment.center,
                            // 정렬 방식
                            spacing: 20,
                            // 좌우 간격
                            runSpacing: 10,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '등록이',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF453F52),
                                    ),
                                  ),
                                  Text(
                                    '완료되었습니다!',
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
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '총 ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                    TextSpan(
                                      text: damageInfoList.length.toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFF3F3F),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '건의 손상이 등록되었습니다',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        DamageCountInfoBlock(
                                          damageName: "앞범퍼/앞펜더/전조등",
                                          damageCnt: front_count,
                                        ),
                                        DamageCountInfoBlock(
                                          damageName: "뒷범퍼/뒷펜더/후미등",
                                          damageCnt: back_count,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        DamageCountInfoBlock(
                                          damageName: "옆면/사이드/스텝",
                                          damageCnt: side_count,
                                        ),
                                        DamageCountInfoBlock(
                                          damageName: "타이어/휠",
                                          damageCnt: wheel_count,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: Size(180, 50),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/detail');
                                },
                                child: Text(
                                  "차량 상세 확인",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: Size(180, 50),
                                  backgroundColor:
                                      Theme.of(context).primaryColorLight,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/home');
                                },
                                child: Text(
                                  "메인 화면으로",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          // 상하 간격
                          child: Wrap(
                            // 세로로 나열
                            direction: Axis.vertical,
                            // 나열 방향
                            crossAxisAlignment: WrapCrossAlignment.center,
                            // 정렬 방식
                            spacing: 20,
                            // 좌우 간격
                            runSpacing: 10,
                            children: [
                              Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '총 ',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF453F52),
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              damageInfoList.length.toString(),
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '건의 손상을',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF453F52),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '등록할 예정입니다',
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
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10,),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        DamageCountInfoBlock(
                                          damageName: "앞범퍼/앞펜더/전조등",
                                          damageCnt: front_count,
                                        ),
                                        DamageCountInfoBlock(
                                          damageName: "뒷범퍼/뒷펜더/후미등",
                                          damageCnt: back_count,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        DamageCountInfoBlock(
                                          damageName: "옆면/사이드/스텝",
                                          damageCnt: side_count,
                                        ),
                                        DamageCountInfoBlock(
                                          damageName: "타이어/휠",
                                          damageCnt: wheel_count,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '정말 등록하시겠습니까?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                                softWrap: true,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size(180, 50),
                                  backgroundColor: Color(0xFFE0426F),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    load_data = false;
                                  });
                                  postCarDamageInfo(
                                    success: (dynamic response) {
                                      setState(() {
                                        loading_api = true;
                                      });
                                    },
                                    fail: (error) {
                                      print('차량 손상 분석 오류: $error');
                                      setState(
                                        () {
                                          loading_api = true;
                                        },
                                      );
                                    },
                                    bodyList: damageInfoList,
                                  );
                                  await storage.write(
                                      key: "carVideoState",
                                      value: currentCarVideo == 0 ? '1' : '2');
                                  setState(() {
                                    load_data = true;
                                    loading_api = true;
                                  });
                                },
                                child: Text(
                                  "등록하기",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: Size(180, 50),
                                  backgroundColor:
                                  Theme.of(context).primaryColorLight,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "돌아가기",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
    ));
  }
}
