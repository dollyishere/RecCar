import 'package:flutter/material.dart';
import 'package:client/widgets/register/category_title.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectReturnDate extends StatefulWidget {
  final void Function(DateTime) updateDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(BuildContext, int?) showModal;

  const SelectReturnDate({
    super.key,
    required this.updateDate,
    this.minDate,
    this.maxDate,
    required this.showModal,
  });

  @override
  State<SelectReturnDate> createState() => _SelectReturnDateState();
}

class _SelectReturnDateState extends State<SelectReturnDate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Modal Bar
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFFEFEFEF),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          // 카테고리 리스트, 현재는 선택해서 이동 불가하고 시간 남으면 클릭시 모달 내용 변경하도록 설정
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CategoryTitle(
                      title: '대여 일자',
                      isSelected: false,
                      showModal: widget.showModal,
                      modalIndex: 4,
                    ),
                    CategoryTitle(
                      title: '반납 일자',
                      isSelected: true,
                      showModal: widget.showModal,
                    ),
                  ],
                )),
          ),
        ),
        // 카테고리 하단 바
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: double.infinity,
          height: 1,
          color: const Color(0xFFEFEFEF),
        ),
        // 제조사 선택 Body의 제목
        Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(
            right: 30,
            left: 30,
            bottom: 10,
            top: 0,
          ),
          child: Text(
            '대여 일자를 선택해주세요.',
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            // mainAxisSize: MainAxisSize.max, // 메인 축 크기를 최대로 설정
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SfDateRangePicker(
                    view: DateRangePickerView.month,
                    minDate: widget.minDate,
                    maxDate: widget.maxDate,
                    monthViewSettings: const DateRangePickerMonthViewSettings(
                        firstDayOfWeek: 7),
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      widget.updateDate(args.value);
                    },
                    todayHighlightColor: Theme.of(context).primaryColor,
                    selectionColor: Theme.of(context).primaryColor,
                    headerStyle: const DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      todayTextStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    selectionTextStyle:
                        const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        )
      ],
    );
  }
}
