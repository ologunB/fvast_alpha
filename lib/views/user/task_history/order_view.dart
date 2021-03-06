import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/notification_page.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';

import 'custom_order_page.dart';

class OrdersView extends StatefulWidget {
  final String from;

  OrdersView({Key key, this.from}) : super(key: key);

  @override
  _OrdersViewState createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          leading: IconButton(
              icon: Icon(
                Icons.menu,
                size: 30,
              ),
              onPressed: () {
                widget.from == "dis"
                    ? disMainScaffoldKey.currentState.openDrawer()
                    : cusMainScaffoldKey.currentState.openDrawer();
              }),
          bottom: TabBar(
              isScrollable: true,
              unselectedLabelColor: Colors.grey[500],
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Styles.appPrimaryColor),
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("En Route",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Completed",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Cancelled",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ),
                ),
              ]),
          title: Text(
            "My Orders",
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  moveTo(context, NotificationPage());
                }),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: TabBarView(children: [
            CustomOrderPage(type: "Pending", color: Styles.appPrimaryColor, theUID: MY_UID),
            CustomOrderPage(type: "Completed", color: Colors.green, theUID: MY_UID),
            CustomOrderPage(type: "Cancelled", color: Colors.red, theUID: MY_UID)
          ]),
        ),
      ),
    );
  }
}
