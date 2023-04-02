import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'package:client/screens/check_car_damage_screen/check_car_damage_detail_modal.dart';
import 'package:client/widgets/common/image_go_detail.dart';

class CheckCarDamagePart extends StatefulWidget {
  final String imageUrl;
  final VideoPlayerController videoPlayerController;
  final Map<String, dynamic> carDamage;
  final void Function(int, String, int, int, int, int, String)
      changeDamageValue;

  const CheckCarDamagePart({
    required this.imageUrl,
    required this.videoPlayerController,
    required this.carDamage,
    required this.changeDamageValue,
  });

  @override
  State<CheckCarDamagePart> createState() => _CheckCarDamagePartState();
}

class _CheckCarDamagePartState extends State<CheckCarDamagePart> {
  List<String> damagedParts = []; // damagedParts 리스트 초기화
  String damageView = '미정';

  // timer 시, 분, 초 단위로 표시 전환해줌
  String _durationToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    // carDamageList의 인덱스 2, 3, 4, 5의 값을 검사하여 damagedParts 리스트에 추가
    if (widget.carDamage["Scratch"] > 0) {
      damagedParts.add("스크래치");
    }
    if (widget.carDamage["Crushed"] > 0) {
      damagedParts.add("찌그러짐");
    }
    if (widget.carDamage["Breakage"] > 0) {
      damagedParts.add("파손");
    }
    if (widget.carDamage["Separated"] > 0) {
      damagedParts.add("이격");
    }

    if (damagedParts.length > 1) {
      setState(() {
        damageView = '${damagedParts[0]} 외 ${damagedParts.length - 1}건';
      });
    } else if (damagedParts.length > 0) {
      setState(() {
        damageView = damagedParts[0];
      });
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF999999).withOpacity(0.5),
            spreadRadius: 0.3,
            blurRadius: 6,
          )
        ],
        borderRadius: BorderRadius.circular(20),
        // color: Colors.black,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300,
                maxHeight: 200,
              ),
              child: FadeInImage(
                placeholder:
                    AssetImage('lib/assets/images/loading_img/loading_gif.gif'),
                image: NetworkImage(widget.imageUrl),
              ),
              // 사진 존재 여부에 따라 사진 표시될 지 아닐지 여부 결정됨
              // child: imageUrl != ''
              //     ? ImageGoDetail(
              //         imagePath: imageUrl,
              //         imageCase: 'url',
              //       )
              //     : Container(
              //         width: 300,
              //         height: 200,
              //         decoration: BoxDecoration(
              //           color: Theme.of(context).disabledColor,
              //         ),
              //         child: Center(
              //           child: Text('사진이 없습니다'),
              //         ),
              //       ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                        ),
                        Text(
                          ' 타임 스탬프',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    InkWell(
                      onTap: () async {
                        await widget.videoPlayerController.pause();
                        await widget.videoPlayerController.seekTo(
                          Duration(seconds: widget.carDamage["timeStamp"]),
                        );
                        await widget.videoPlayerController.play();
                      },
                      child: Text(
                        "${_durationToString(Duration(seconds: widget.carDamage["timeStamp"]))}",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 16,
                        ),
                        Text(
                          ' 손상 종류',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      damageView,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.car_crash,
                          size: 16,
                        ),
                        Text(
                          ' 차량 부위',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.carDamage["part"] != ""
                          ? widget.carDamage["part"]
                          : '미정',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider(
          //   thickness: 1.5,
          // ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25.0),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 6,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        child: CheckCarDamageDetailModal(
                          carDamage: widget.carDamage,
                          changeDamageValue: widget.changeDamageValue,
                          imageUrl: widget.imageUrl,
                        ),
                      ),
                    );
                  },
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Color(0xFFFBD5DC),
                  ),
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFBD5DC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "리스트 추가",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
