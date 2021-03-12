import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/cou_service/home/new_order_form.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/notification_page.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/home/home_view.dart';

class TaskPoolPage extends StatefulWidget {
  @override
  _TaskPoolPageState createState() => _TaskPoolPageState();
}

class _TaskPoolPageState extends State<TaskPoolPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.menu,
              size: 30,
            ),
            onPressed: () {
              disMainScaffoldKey.currentState.openDrawer();
            }),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                moveTo(context, NotificationPage());
              }),
        ],
        title: Text(
          "Task Pool",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Available Tasks",
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("Utils")
            .document("Tasks")
            .collection("uid")
            .orderBy("Timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 30),
                    Text(
                      "Getting Data",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
                height: 300,
                width: 300,
              );
            default:
              //  updateDetails(snapshot.data.documents.length);
              return snapshot.data.documents.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Text(
                              "No Available Tasks!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    )
                  : ListView(
                      children: snapshot.data.documents.map((document) {
                        Task task = Task.map(document);
                        return GestureDetector(
                          onTap: () {
                            moveTo(
                                context,
                                NewTaskRequest(
                                    cusUid: task.userUid,
                                    transId: task.id,
                                    from: task.from,
                                    to: task.to,
                                    fromTime: task.startDate));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3, top: 3, right: 3),
                            child: _tabStep(task),
                          ),
                        );
                      }).toList(),
                    );
          }
        },
      ),
    );
  }

  Widget _tabStep(Task task) => Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all()),
      margin: EdgeInsets.only(top: 10),
      child: Stepper(
        key: Key(Random.secure().nextDouble().toString()),
        onStepTapped: (a) {
          moveTo(
              context,
              NewTaskRequest(
                  through: "pool",
                  cusUid: task.userUid,
                  transId: task.id,
                  from: task.from,
                  to: task.to,
                  fromTime: task.startDate));
        },
        physics: ClampingScrollPhysics(),
        currentStep: 1,
        steps: steppers(task),
        controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
            Container(),
      ));

  List<Step> steppers(Task task) {
    List<Step> bb = [];

    bb.add(Step(
      title: Column(
        children: <Widget>[
          Text(
            task.startDate,
            style: TextStyle(color: Colors.grey),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .70,
            child: Text(
              task.from + " - " + todo1(task.status),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      content: Container(),
    ));

    for (String i in task.to) {
      bb.add(Step(
        title: Column(
          children: <Widget>[
            Text(
              task.acceptedDate ?? "--",
              style: TextStyle(color: Colors.grey),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .70,
              child: Text(
                i + " - " + todo2(task.status),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        content: SizedBox(),
      ));
    }
    return bb;
  }
}
