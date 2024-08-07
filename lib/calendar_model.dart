import 'package:flutter/material.dart';

class CalendarModel with ChangeNotifier {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  DateTime? _dragStartDate;
  DateTime? _dragEndDate;
  int _currentPageIndex = 500;
  bool _isBlinking = false; // 선택한 날짜가 깜빡이는지 여부

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

  DateTime get currentDate => _currentDate;
  DateTime get selectedDate => _selectedDate;
  DateTime? get dragStartDate => _dragStartDate;
  DateTime? get dragEndDate => _dragEndDate;
  int get currentPageIndex => _currentPageIndex;
  bool get isBlinking => _isBlinking;

  void setCurrentDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _isBlinking = true;
    notifyListeners();
    Future.delayed(Duration(milliseconds: 300), () {
      _isBlinking = false;
      notifyListeners();
    });
  }

  void setPageIndex(int pageIndex) {
    _currentPageIndex = pageIndex;
    notifyListeners();
  }

  void setDragStartDate(DateTime date) {
    _selectedDate = date;
    _dragStartDate = date;
    _dragEndDate = date;
    notifyListeners();
  }

  void setDragEndDate(DateTime date) {
    _dragEndDate = date;
    notifyListeners();
  }

  void resetDragDates() {
    _dragStartDate = null;
    _dragEndDate = null;
    notifyListeners();
  }

  bool isSelectedDate(DateTime date) {
    return _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
  }

  bool isToday(DateTime date) {
    DateTime today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

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

  bool isHoliday(DateTime date) {
    return _holidays.containsKey(DateTime(date.year, date.month, date.day));
  }

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