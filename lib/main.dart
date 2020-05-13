import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/partials/cus_main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Geometria',
        primaryColor: Styles.appPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: CusMainPage(),
    );
  }
}
