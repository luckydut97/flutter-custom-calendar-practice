import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // 지역화 데이터 초기화용
import 'calendar_model.dart';
import 'main_screen.dart';

void main() {
  initializeDateFormatting().then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => CalendarModel(),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Calendar',
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}