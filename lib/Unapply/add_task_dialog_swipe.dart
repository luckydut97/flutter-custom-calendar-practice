/* Swipe 삭제 버전입니다. 할일 체크 표시 기능은 없습니다.
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

  void _addTask(String task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _editTask(int index, String newTask) {
    setState(() {
      _tasks[index] = newTask;
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateFormat('M월 d일 (E)', 'ko_KR').format(widget.selectedDate), // 년도 없이 표시
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_tasks[index]),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      bool confirm = false;
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("삭제 확인"),
                            content: Text("정말로 이 할 일을 삭제하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  confirm = false;
                                },
                                child: Text("취소"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  confirm = true;
                                },
                                child: Text("삭제"),
                              ),
                            ],
                          );
                        },
                      );
                      return confirm;
                    },
                    onDismissed: (direction) {
                      _removeTask(index);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () => _showTaskInputDialog(index: index),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_tasks[index]),
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
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300], // 버튼 배경색
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
}*/
