import 'package:flutter/material.dart';

class CalendarModel with ChangeNotifier {
  DateTime _currentDate = DateTime.now(); // 현재 날짜
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜
  DateTime? _dragStartDate; // 드래그 시작 날짜
  DateTime? _dragEndDate; // 드래그 종료 날짜
  int _currentPageIndex = 500; // 페이지 인덱스 (초기값 500으로 설정)
  bool _isBlinking = false; // 선택한 날짜가 깜빡이는지 여부

  // 공휴일 리스트 (현재 연도의 공휴일들을 포함)
  final Map<DateTime, String> _holidays = {
    DateTime(DateTime.now().year, 1, 1): "새해",
    DateTime(DateTime.now().year, 3, 1): "삼일절",
    DateTime(DateTime.now().year, 5, 5): "어린이날",
    DateTime(DateTime.now().year, 6, 6): "현충일",
    DateTime(DateTime.now().year, 8, 15): "광복절",
    DateTime(DateTime.now().year, 10, 3): "개천절",
    DateTime(DateTime.now().year, 12, 25): "성탄절",
    // 필요한 공휴일을 여기에 추가
  };

  // 현재 날짜 반환
  DateTime get currentDate => _currentDate;

  // 선택된 날짜 반환
  DateTime get selectedDate => _selectedDate;

  // 드래그 시작 날짜 반환
  DateTime? get dragStartDate => _dragStartDate;

  // 드래그 종료 날짜 반환
  DateTime? get dragEndDate => _dragEndDate;

  // 현재 페이지 인덱스 반환
  int get currentPageIndex => _currentPageIndex;

  // 선택된 날짜가 깜빡이는지 여부 반환
  bool get isBlinking => _isBlinking;

  // 현재 날짜 설정
  void setCurrentDate(DateTime date) {
    _currentDate = date;
    notifyListeners(); // 상태 변경 알림
  }

  // 선택된 날짜 설정
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _isBlinking = true; // 선택된 날짜 깜빡임 활성화
    notifyListeners(); // 상태 변경 알림
    Future.delayed(Duration(milliseconds: 300), () {
      _isBlinking = false; // 깜빡임 비활성화
      notifyListeners(); // 상태 변경 알림
    });
  }

  // 페이지 인덱스 설정
  void setPageIndex(int pageIndex) {
    _currentPageIndex = pageIndex;
    notifyListeners(); // 상태 변경 알림
  }

  // 드래그 시작 날짜 설정
  void setDragStartDate(DateTime date) {
    _selectedDate = date; // 선택된 날짜도 동일하게 설정
    _dragStartDate = date;
    _dragEndDate = date;
    notifyListeners(); // 상태 변경 알림
  }

  // 드래그 종료 날짜 설정
  void setDragEndDate(DateTime date) {
    _dragEndDate = date;
    notifyListeners(); // 상태 변경 알림
  }

  // 드래그 날짜 초기화
  void resetDragDates() {
    _dragStartDate = null;
    _dragEndDate = null;
    notifyListeners(); // 상태 변경 알림
  }

  // 해당 날짜가 선택된 날짜인지 확인
  bool isSelectedDate(DateTime date) {
    return _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
  }

  // 해당 날짜가 오늘인지 확인
  bool isToday(DateTime date) {
    DateTime today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // 해당 날짜가 드래그 범위 내에 있는지 확인
  bool isInDragRange(DateTime dayDate) {
    if (_dragStartDate == null || _dragEndDate == null) {
      return false;
    }
    DateTime startDate = _dragStartDate!;
    DateTime endDate = _dragEndDate!;
    if (startDate.isBefore(endDate)) {
      return !dayDate.isBefore(startDate) && !dayDate.isAfter(endDate);
    } else {
      return !dayDate.isBefore(endDate) && !dayDate.isAfter(startDate);
    }
  }

  // 해당 날짜가 공휴일인지 확인
  bool isHoliday(DateTime date) {
    return _holidays.containsKey(DateTime(date.year, date.month, date.day));
  }

  // 페이지 인덱스를 기반으로 현재 날짜 업데이트
  void updateCurrentDateByPageIndex(int pageIndex) {
    int monthDifference = pageIndex - _currentPageIndex;
    setCurrentDate(DateTime(
      _currentDate.year,
      _currentDate.month + monthDifference,
      1,
    ));
    setPageIndex(pageIndex);
  }
}