import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'calendar_model.dart';
import 'add_task_dialog.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CalendarModel>(
          builder: (context, model, child) {
            // 현재 선택된 날짜를 '년 월' 형식으로 표시
            return Text(
              DateFormat.yMMMM('ko_KR').format(model.currentDate),
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: Color(0xFF27374D),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<CalendarModel>(
                builder: (context, model, child) {
                  return PageView.builder(
                    controller: PageController(initialPage: model.currentPageIndex),
                    onPageChanged: (pageIndex) {
                      // 페이지 변경 시 현재 날짜 업데이트
                      model.updateCurrentDateByPageIndex(pageIndex);
                    },
                    itemBuilder: (context, index) {
                      // 각 페이지에 해당하는 월의 첫 번째 날짜 계산
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
    List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    // 요일 헤더 행 추가
    calendarRows.add(
      TableRow(
        children: weekdays.map((day) {
          return Container(
            padding: const EdgeInsets.all(4.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    // 월의 첫 날과 마지막 날 계산
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    int startDayOfWeek = firstDayOfMonth.weekday % 7;

    // 날짜 채우기
    List<Widget> dayWidgets = List.generate(startDayOfWeek, (_) => Container());

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime dayDate = DateTime(date.year, date.month, day);
      bool isSelected = model.isSelectedDate(dayDate);
      bool isInDragRange = model.isInDragRange(dayDate);
      bool isToday = model.isToday(dayDate);
      bool isHoliday = model.isHoliday(dayDate);
      Color textColor = isHoliday ? Colors.red : (dayDate.weekday % 7 == 0) ? Colors.red : Colors.black;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            model.setSelectedDate(dayDate);
            _showAddTaskDialog(context, dayDate, model);
          },
          onLongPressStart: (_) => model.setDragStartDate(dayDate),
          onLongPressMoveUpdate: (details) => _handleLongPressMoveUpdate(details, context, dayWidgets, startDayOfWeek, model),
          onLongPressEnd: (_) => model.resetDragDates(),
          child: _buildDayContainer(day, isSelected, isInDragRange, isToday, model.isBlinking, textColor),
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

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details, BuildContext context, List<Widget> dayWidgets, int startDayOfWeek, CalendarModel model) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);
    int columnIndex = localPosition.dx ~/ (box.size.width / 7);
    int rowIndex = localPosition.dy ~/ (box.size.height / 6);
    int index = rowIndex * 7 + columnIndex;
    if (index >= 0 && index < dayWidgets.length) {
      DateTime endDate = DateTime(date.year, date.month, index - startDayOfWeek + 1);
      model.setDragEndDate(endDate);
    }
  }

  Widget _buildDayContainer(int day, bool isSelected, bool isInDragRange, bool isToday, bool isBlinking, Color textColor) {
    return AnimatedContainer(
      duration: Duration(milliseconds: isBlinking ? 100 : 200),
      height: 88,
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        color: isSelected || isInDragRange ? Colors.grey.withOpacity(0.5) : Colors.transparent,
      ),
      child: Stack(
        children: [
          // 현재 날짜에 파란 동그라미 추가
          if (isToday)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 8.0), // 이 값을 조정하여 원의 위치를 변경
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0), // 원의 아래에 숫자를 배치
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isToday ? Colors.white : textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, DateTime selectedDate, CalendarModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(selectedDate: selectedDate, model: model);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: TableBorder.all(color: Colors.transparent),
        children: _buildCalendar(context),
      ),
    );
  }
}
