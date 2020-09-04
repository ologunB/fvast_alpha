import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';

class SettingView extends StatefulWidget {
  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Styles.appPrimaryColor,
          child: Container(
            color: Colors.grey[100],
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.menu,
                              size: 30,
                            ),
                            onPressed: () {
                              /*  if (!scaffoldController.isOpen()) {
                                    scaffoldController.menuController.open();
                                  }*/
                              cusMainScaffoldKey.currentState.openDrawer();
                            }),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Text(
                                "Settings",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            )),
                        IconButton(
                            icon: Icon(Icons.notifications), onPressed: () {}),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ));
  }
}
