import 'package:attendance/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'colorcheme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calander.dart';

//void main() => runApp(MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: MyHomePage.id,
      routes: {
        LoginPage.id: (context) => LoginPage(),
        CalendarPage.id: (context) => CalendarPage(),
        MyHomePage.id: (context) => MyHomePage(),
      },
    );
  }
}