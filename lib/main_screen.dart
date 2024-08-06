import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'calendar_model.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '메인 페이지',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF27374D),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단에 년과 월 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<CalendarModel>(
                builder: (context, model, child) {
                  return Text(
                    DateFormat.yMMMM('ko_KR').format(model.currentDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<CalendarModel>(
                builder: (context, model, child) {
                  return PageView.builder(
                    controller: PageController(initialPage: model.currentPageIndex),
                    onPageChanged: (pageIndex) {
                      int monthDifference = pageIndex - model.currentPageIndex;
                      model.setCurrentDate(DateTime(
                        model.currentDate.year,
                        model.currentDate.month + monthDifference,
                        1,
                      ));
                      model.setPageIndex(pageIndex);
                    },
                    itemBuilder: (context, index) {
                      DateTime date = DateTime(
                        model.currentDate.year,
                        model.currentDate.month + (index - model.currentPageIndex),
                        1,
                      );
                      return CalendarMonth(date: date);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarMonth extends StatelessWidget {
  final DateTime date;

  CalendarMonth({required this.date});

  List<TableRow> _buildCalendar(BuildContext context) {
    final model = Provider.of<CalendarModel>(context);
    List<TableRow> calendarRows = [];

    // 첫 번째 행: 요일
    List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    calendarRows.add(
      TableRow(
        children: List.generate(7, (index) {
          return Container(
            padding: const EdgeInsets.all(4.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                weekdays[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey, // 요일 색상은 회색으로 설정
                ),
              ),
            ),
          );
        }),
      ),
    );

    // 월의 첫 날과 마지막 날 계산
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    int startDayOfWeek = (firstDayOfMonth.weekday % 7); // 일요일 시작 기준

    // 날짜 채우기
    List<Widget> dayWidgets = [];
    for (int i = 0; i < startDayOfWeek; i++) {
      dayWidgets.add(Container()); // 빈 셀 추가
    }
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime dayDate = DateTime(date.year, date.month, day);
      bool isSelected = model.selectedDate.year == dayDate.year &&
          model.selectedDate.month == dayDate.month &&
          model.selectedDate.day == dayDate.day;
      bool isInDragRange = model.isInDragRange(dayDate);
      Color textColor = (dayDate.weekday % 7 == 0) ? Colors.red : Colors.black; // 일요일은 빨간색, 나머지는 검정색

      dayWidgets.add(
        GestureDetector(
          onTap: () => model.setSelectedDate(dayDate),
          onLongPressStart: (_) => model.setDragStartDate(dayDate),
          onLongPressMoveUpdate: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPosition = box.globalToLocal(details.globalPosition);
            int columnIndex = localPosition.dx ~/ (box.size.width / 7);
            int rowIndex = localPosition.dy ~/ (box.size.height / 6);
            int index = rowIndex * 7 + columnIndex;
            if (index >= 0 && index < dayWidgets.length) {
              DateTime endDate = DateTime(date.year, date.month, index - startDayOfWeek + 1);
              model.setDragEndDate(endDate);
            }
          },
          onLongPressEnd: (_) => model.resetDragDates(),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: 88, // 날짜 셀의 상하 간격을 넓게 설정
            margin: EdgeInsets.all(1), // 날짜 셀 간의 간격을 최소화
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
              color: isSelected || isInDragRange ? Colors.grey.withOpacity(0.5) : Colors.transparent,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 6행 7열로 나누기
    for (int i = 0; i < dayWidgets.length; i += 7) {
      calendarRows.add(
        TableRow(
          children: List.generate(7, (index) {
            return i + index < dayWidgets.length ? dayWidgets[i + index] : Container();
          }),
        ),
      );
    }

    return calendarRows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: TableBorder.all(color: Colors.transparent), // 경계선 제거
        children: _buildCalendar(context),
      ),
    );
  }
}