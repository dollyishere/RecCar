import 'package:flutter/material.dart';
import 'package:client/widgets/common/header.dart';
import 'package:client/widgets/common/footer.dart';
import 'package:client/widgets/register/register_line.dart';
import 'package:client/widgets/register/register_title.dart';
import 'package:client/widgets/register/register_list.dart';
import 'package:client/screens/register/select_maker.dart';
import 'package:client/screens/register/select_car.dart';
import 'package:client/widgets/common/modal_navigator.dart';

class CarRegister extends StatefulWidget {
  const CarRegister({Key? key}) : super(key: key);

  @override
  State<CarRegister> createState() => _CarRegisterState();
}

class _CarRegisterState extends State<CarRegister> {

  Map<String, dynamic> selectedMaker = {
    'id' : null,
    'title' : null,
  };

  void updateSelectedMaker(makerId, makerTitle) {
    setState(() {
      if (selectedMaker['id'] == makerId) {
        selectedMaker = {
          'id' : null,
          'title': null,
        };
      } else {
        selectedMaker = {
          'id' : makerId,
          'title' : makerTitle,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const Header(
                title: '차량 등록'
            ),
            Expanded(child:
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 14,
              ),
              child: Column(
                children: [
                  const RegisterTitle(
                      title: '차량 정보'
                  ),
                  RegisterList(
                    lineList: [
                      ModalNavigator(
                        showedWidget: SelectMaker(
                            updateSelectedMaker: updateSelectedMaker,
                        ),
                        child: registerLine(
                          category: '제조사',
                          content: selectedMaker['title'],
                          isLastLine: false,
                        ),
                      ),
                      const ModalNavigator(
                        showedWidget: SelectCar(),
                        child: registerLine(
                          category: '차종',
                          content: 'SM5',
                          isLastLine: false,
                        ),
                      ),
                      const registerLine(
                        category: '연료 종류',
                        content: '가솔린',
                        isLastLine: true,
                      ),
                    ],
                  ),
                  const RegisterTitle(
                      title: '대여 정보'
                  ),
                  const RegisterList(
                    lineList: [
                      registerLine(
                        category: '대여 일자',
                        content: '2023년 10월 25일',
                        isLastLine: false,
                      ),
                      registerLine(
                        category: '반납 일자',
                        content: '2023년 10월 25일',
                        isLastLine: false,
                      ),
                      registerLine(
                        category: '렌트카 업체',
                        content: 'SSAFY',
                        isLastLine: false,
                      ),
                      registerLine(
                        category: '차량 번호',
                        content: '00허 2102',
                        isLastLine: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
            const Footer()
          ],
        )
    );
  }
}
