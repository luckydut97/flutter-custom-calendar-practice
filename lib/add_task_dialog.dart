import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_model.dart';

class AddTaskDialog extends StatefulWidget {
  final DateTime selectedDate;
  final CalendarModel model;

  AddTaskDialog({required this.selectedDate, required this.model});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  List<String> _tasks = [];
  List<bool> _selectedTasks = [];
  List<bool> _completedTasks = [];

  void _addTask(String task) {
    setState(() {
      _tasks.add(task);
      _selectedTasks.add(false);
      _completedTasks.add(false);
    });
  }

  void _editTask(int index, String newTask) {
    setState(() {
      _tasks[index] = newTask;
    });
  }

  void _removeSelectedTasks() {
    setState(() {
      for (int i = _tasks.length - 1; i >= 0; i--) {
        if (_selectedTasks[i]) {
          _tasks.removeAt(i);
          _selectedTasks.removeAt(i);
          _completedTasks.removeAt(i);
        }
      }
    });
  }

  void _completeSelectedTasks() {
    setState(() {
      for (int i = 0; i < _tasks.length; i++) {
        if (_selectedTasks[i]) {
          _completedTasks[i] = !_completedTasks[i];
          _selectedTasks[i] = false; // 완료 후 선택 해제
        }
      }
    });
  }

  Future<void> _showTaskInputDialog({int? index}) async {
    String initialText = index != null ? _tasks[index] : '';
    TextEditingController controller = TextEditingController(text: initialText);

    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '할일 입력',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      if (index != null) {
        _editTask(index, result);
      } else {
        _addTask(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0), // Dialog (Container)의 모서리를 둥글게 설정
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('M월 d일 (E)', 'ko_KR').format(widget.selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.check_circle),
                      onPressed: _completeSelectedTasks,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: _removeSelectedTasks,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showTaskInputDialog(index: index),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _tasks[index],
                                style: TextStyle(
                                  decoration: _completedTasks[index]
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreenAccent.withOpacity(0.2),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                            ),
                          ),
                        ),
                        Checkbox(
                          value: _selectedTasks[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedTasks[index] = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              onPressed: () => _showTaskInputDialog(),
              child: Text(
                '+ 할일 추가',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
