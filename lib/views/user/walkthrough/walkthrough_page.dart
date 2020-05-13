
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/walkthrough/walk1.dart';
import 'package:fvastalpha/views/user/walkthrough/walk2.dart';
import 'package:fvastalpha/views/user/walkthrough/walk3.dart';

class WalkthroughPage extends StatefulWidget {
  @override
  _WalkthroughPageState createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<WalkthroughPage> {
  PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        PageView(
          controller: controller,
          children: <Widget>[Walk1(controller), Walk2(controller), Walk3()],
          onPageChanged: (index) {
            isOnActive = index;
            setState(() {});
          },
        ),
        Center(
            child: Container(
          height: 10,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: index ==isOnActive ? 10 : 8,
                  width:index == isOnActive ? 25 : 10,
                  decoration: BoxDecoration(
                      color: index == isOnActive
                          ? Styles.appPrimaryColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(5)),
                ),
              );
            },
            itemCount: 3,
            shrinkWrap: true,
          ),
        ))
      ],
    ));
  }
}

int isOnActive = 0;
