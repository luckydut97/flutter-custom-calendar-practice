import 'package:flutter/material.dart'; //Flutter의 기본 디자인 라이브러리
import 'package:intl/intl.dart'; //국제화 및 날짜 형식을 처리하기 위한 패키지
import 'package:provider/provider.dart'; //상태 관리를 위한 패키지
import 'calendar_model.dart';
import 'add_task_dialog.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 현재 선택된 날짜를 '년 월' 형식으로 표시
        title: Consumer<CalendarModel>(
          builder: (context, model, child) {
            return Text(
              DateFormat.yMMMM('ko_KR').format(model.currentDate),
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: Color(0xFF27374D), //앱 바의 배경색
      ),
      body: SafeArea( // 화면의 안전 영역 내에서 내용 표시
        child: Column( // 세로로 위젯을 배치하는 열 레이아웃 사용
          children: [
            Expanded(
              // 캘린더 모델을 사용하여 페이지 뷰 빌드
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
  final DateTime date; //해당 월의 첫 번째 날짜

  CalendarMonth({required this.date}); //date 매개변수를 필수로 받아옴

  // 캘린더 테이블 생성
  List<TableRow> _buildCalendar(BuildContext context) {
    final model = Provider.of<CalendarModel>(context); //model은 CalendarModel의 인스턴스를 가져옴
    List<TableRow> calendarRows = []; //calendarRows는 테이블의 행을 저장할 리스트
    List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토']; //weekdays는 요일 헤더

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
    int startDayOfWeek = firstDayOfMonth.weekday % 7; //월의 첫 번째 날짜의 요일을 계산합니다.

    // 날짜 채우기
    List<Widget> dayWidgets = List.generate(startDayOfWeek, (_) => Container());

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime dayDate = DateTime(date.year, date.month, day);
      bool isSelected = model.isSelectedDate(dayDate);
      bool isInDragRange = model.isInDragRange(dayDate);
      bool isToday = model.isToday(dayDate); //오늘인지
      bool isHoliday = model.isHoliday(dayDate); //공휴일인지
      Color textColor = isHoliday ? Colors.red : (dayDate.weekday % 7 == 0) ? Colors.red : Colors.black;

      //날짜 위젯 추가
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            model.setSelectedDate(dayDate);
            _showAddTaskDialog(context, dayDate, model); //날짜를 선택하고 할 일 추가 다이얼로그 표시
          },
          onLongPressStart: (_) => model.setDragStartDate(dayDate), //드래그 시작 날짜 설정
          onLongPressMoveUpdate: (details) => _handleLongPressMoveUpdate(details, context, dayWidgets, startDayOfWeek, model), //드래그 이동 업데이트
          onLongPressEnd: (_) => model.resetDragDates(), //드래그 날짜 초기화
          child: _buildDayContainer(day, isSelected, isInDragRange, isToday, model.isBlinking, textColor), //날짜 컨테이너를 생성
        ),
      );
    }

    // 6행 7열로 나누기 (날짜 위젯을 6행 7열로 나누어 TableRow로 추가)
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

  // 롱 프레스 이동 업데이트 처리
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

  // 하루 컨테이너 빌드
  Widget _buildDayContainer(int day, bool isSelected, bool isInDragRange, bool isToday, bool isBlinking, Color textColor) {
    return AnimatedContainer(
      duration: Duration(milliseconds: isBlinking ? 100 : 200),
      height: 88,
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        color: isSelected || isInDragRange ? Colors.blue.withOpacity(0.2) : Colors.transparent,
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

  // 할 일 추가 다이얼로그 표시
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
        children: _buildCalendar(context), //메서드를 호출하여 테이블 행을 생성
      ),
    );
  }
}