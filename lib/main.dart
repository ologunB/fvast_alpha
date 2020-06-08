import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:fvastalpha/views/user/walkthrough/walkthrough_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Raleway',
        primaryColor: Styles.appPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: MyWrapper(),
    );
  }
}

class MyWrapper extends StatefulWidget {
  @override
  _MyWrapperState createState() => _MyWrapperState();
}

class _MyWrapperState extends State<MyWrapper> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> type, uid;

  @override
  void initState() {
    super.initState();
    type = _prefs.then((prefs) {
      return (prefs.getString('type'));
    });
    uid = _prefs.then((prefs) {
      return (prefs.getString('uid') ?? "uid");
    });
    assign();
  }

  void assign() async {
    MY_UID = await uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: type,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String _type = snapshot.data;
          if (_type == "Dispatcher") {
            return DisLayoutTemplate();
          } else if (_type == "User") {
            return LayoutTemplate();
          } else if (_type == "Login") {
            return SigninPage();
          } else {
            return WalkthroughPage();
          }
        }
        return Scaffold(
          body: Container(),
        );
      },
    );
  }
}

