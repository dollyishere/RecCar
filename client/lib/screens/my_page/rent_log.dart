import 'package:flutter/material.dart';
import '../../widgets/common/footer.dart';
import '../../widgets/my_page/rent_log_card.dart';
import './rent_log_detail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RentLog extends StatefulWidget {
  const RentLog({Key? key}) : super(key: key);

  @override
  State<RentLog> createState() => _RentLogState();
}

class _RentLogState extends State<RentLog> {
  static final storage = FlutterSecureStorage();
  dynamic userId = '';
  dynamic userName = '';
  dynamic userEmail = '';
  dynamic userProfileImg = '';
  late dynamic damage;

  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserState();
    });
  }

  checkUserState() async {
    var id = await storage.read(key: 'id');
    var name = await storage.read(key: 'name');
    var email = await storage.read(key: 'email');
    var img = await storage.read(key: 'profileImg');
    setState(() {
      userId = id;
      userName = name;
      userEmail = email;
      userProfileImg = img;
    });
    if (userId == null) {
      Navigator.pushNamed(context, '/login'); // 로그인 페이지로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    // late var rentCnt;
    Future<void> getRentLog() async {
      final url = Uri.parse(
        'https://api/v1/car/history/{userId}',
      );
      final response = await http.get(url);
      print(response.statusCode);
      setState(() {
        damage = response.body;
      });
      // 여기에 api로 get하고
      // setState로 rentCnt를 변경해주자!
      // 날짜, 회사, 파손 개수 데이터도 여기서 setState로 받자!
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            height: 80,
            padding: EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 렌트 내역 개수 출력
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '총 ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '6',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: '건의 렌트 내역',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 간격
          SizedBox(
            height: 20,
          ),
          Expanded(
            // 렌트 내역은 스크롤이 가능하게
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 추후 rentCnt만큼 돌림
                  // 렌트 내역을 리스트로 출력
                  for (int i = 0; i < 6; i++)
                    // RentLogCard라는 widget에 데이터를 넘겨줌
                    RentLogCard(
                      startDate: "2021.11.26",
                      endDate: "2021.11.27",
                      company: "그린카",
                      damage: 3,
                      id: i,
                    ),
                ],
              ),
            ),
          ),
          Footer(),
        ],
      ),
    );
  }
}
