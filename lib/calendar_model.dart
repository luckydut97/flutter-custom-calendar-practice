import 'package:flutter/material.dart';

class CalendarModel with ChangeNotifier {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  DateTime? _dragStartDate;
  DateTime? _dragEndDate;
  int _currentPageIndex = 500; // 중간 페이지 인덱스

  DateTime get currentDate => _currentDate;
  DateTime get selectedDate => _selectedDate;
  DateTime? get dragStartDate => _dragStartDate;
  DateTime? get dragEndDate => _dragEndDate;
  int get currentPageIndex => _currentPageIndex;

  void setCurrentDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _dragStartDate = null;
    _dragEndDate = null;
    notifyListeners();
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
}