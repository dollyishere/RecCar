import 'package:flutter/material.dart';
import '../../widgets/my_page/rent_log_line.dart';
import '../../widgets/common/footer.dart';
import '../../services/my_page_api.dart';
import 'package:client/widgets/common/image_go_detail.dart';

class DamageDetail extends StatefulWidget {
  final damageImageUrl;
  final damageDate;
  final kindOfDamage;
  final damagaLocation;
  final memo;

  const DamageDetail({
    super.key,
    required this.damageImageUrl,
    required this.damageDate,
    required this.kindOfDamage,
    required this.damagaLocation,
    required this.memo,
  });

  @override
  State<DamageDetail> createState() => _DamageDetailState();
}

class _DamageDetailState extends State<DamageDetail> {
  Map<String, dynamic> detailDamageInfo = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 90,
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 300,
                      ),
                      child: ImageGoDetail(
                        imagePath: widget.damageImageUrl,
                        imageCase: 'url',
                      ),
                    ),
                  ),
                  // const Divider(
                  //   height: 40,
                  //   thickness: 1.5,
                  //   indent: 20,
                  //   endIndent: 20,
                  //   color: Color(0xFFD8D8D8),
                  // ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1,
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.7),
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          )
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      width: 1000,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "손상 정보",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          RentLogLine(
                            infoTitle: "파손 일자",
                            info: widget.damageDate.toString().substring(0, 10),
                            space: 100,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          RentLogLine(
                            infoTitle: "파손 종류",
                            info: "${widget.kindOfDamage}",
                            space: 100,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          RentLogLine(
                            infoTitle: "파손 부위",
                            info: "${widget.damagaLocation}",
                            space: 100,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if ("${widget.memo}" != "")
                            RentLogLine(
                              infoTitle: "메모",
                              info: "${widget.memo}",
                              space: 100,
                            ),
                          if ("${widget.memo}" == "")
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "메모",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontSize: 12,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const Text(
                                    "메모가 없습니다",
                                    style: TextStyle(
                                      color: Color(0xFFD9D9D9),
                                      fontSize: 13,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
