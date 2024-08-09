import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar_model.dart';
import 'main_screen.dart';

void main() {
  //  날짜 및 시간 형식을 초기화
  initializeDateFormatting().then((_) {
    runApp( // Flutter 애플리케이션을 실행하는 함수
      ChangeNotifierProvider( // provider 패키지를 사용하여 CalendarModel을 애플리케이션의 상태로 제공하는 역할
        create: (context) => CalendarModel(), //CalendarModel 인스턴스 생성하고
        child: MyApp(), // 이를 child 위젯인 MyApp에 제공
      ),
    );
  });
}

class MyApp extends StatelessWidget { // 클래스는 Flutter 애플리케이션의 루트 위젯
  @override
  Widget build(BuildContext context) { //Flutter의 위젯 트리를 구성하는 메서드
    return MaterialApp(
      title: 'Custom Calendar',
      debugShowCheckedModeBanner: false,
      home: MainScreen(), //애플리케이션이 시작될 때 표시할 메인 화면을 설정
    );
  }
}
