import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar_model.dart';
import 'main_screen.dart';

void main() {
  // 지역화 데이터 초기화 후 앱 실행
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