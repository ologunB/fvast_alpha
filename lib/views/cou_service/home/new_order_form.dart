import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/cou_service/home/dis_task_detail.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:http/http.dart' as http;

class NewTaskRequest extends StatefulWidget {
  final String cusUid;
  final String through;
  final  String transId;
  final String from;
  final String fromTime;
  final List to;

  NewTaskRequest({this.cusUid, this.transId, this.from, this.through, this.fromTime, this.to});

  @override
  _NewTaskRequestState createState() => _NewTaskRequestState();
}

class _NewTaskRequestState extends State<NewTaskRequest> {
  acceptOrder(context) async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await Firestore.instance
        .collection("Orders")
        .document("Pending")
        .collection(widget.cusUid)
        .document(widget.transId)
        .get();

    bool assigned = doc.data["assigned"];

    if (assigned) {
      setState(() {
        isLoading = false;
      });
      showCenterToast("Job has been assigned", context);
      Navigator.pop(context);
    } else {
      Map toDispatchData = doc.data;
      toDispatchData.update("Dis Uid", (a) => MY_UID, ifAbsent: () => MY_UID);
      toDispatchData.update("Dis Name", (a) => MY_NAME, ifAbsent: () => MY_NAME);
      toDispatchData.update("Dis Number", (a) => MY_NUMBER, ifAbsent: () => MY_NUMBER);
      toDispatchData.update("status", (a) => "Accepted", ifAbsent: () => "Accepted");
      toDispatchData.update("Accepted Date", (a) => presentDateTime(),
          ifAbsent: () => presentDateTime());
      toDispatchData.update("assigned", (a) => true, ifAbsent: () => true);

      Firestore _firestore = Firestore.instance;

      WriteBatch writeBatch = _firestore.batch();
      writeBatch.setData(
          _firestore
              .collection("Orders")
              .document("Pending") //create for dispatcher
              .collection(MY_UID)
              .document(widget.transId),
          toDispatchData);

      writeBatch.setData(
          _firestore
              .collection("Orders")
              .document("Pending") //create for dispatcher
              .collection(widget.cusUid)
              .document(widget.transId),
          toDispatchData);

      writeBatch.delete(_firestore
          .collection("Utils")
          .document("Tasks")
          .collection("uid")
          .document(widget.transId));

      writeBatch.commit().then((value) {
        _handleSendNotification();
        Navigator.pop(context);
        Task task = Task.map(toDispatchData);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DisTaskDetail(task: task, dataMap: toDispatchData),
          ),
        );
      });
      /*     Firestore.instance
          .collection("Orders")
          .document("Pending") //create for dispatcher
          .collection(MY_UID)
          .document(widget.transId)
          .setData(toDispatchData)
          .then((value) {
        Firestore.instance
            .collection("Orders")
            .document("Pending") //update the customer
            .collection(widget.cusUid)
            .document(widget.transId)
            .setData(toDispatchData)
            .then((value) {
          Firestore.instance
              .collection("Utils")
              .document("Tasks")
              .collection("uid")
              .document(widget.transId)
              .delete();

          _handleSendNotification();
          Navigator.pop(context);
          Task task = Task.map(toDispatchData);
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => DisTaskDetail(task: task, dataMap: toDispatchData),
            ),
          );
        });
      });*/
    }
    setState(() {
      isLoading = false;
    });
  }

  bool isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 60)).then((a) {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
          (Route<dynamic> route) => false);
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _tabStep() => Container(
        margin: EdgeInsets.only(top: 10),
        child: Stepper(
          key: Key(Random.secure().nextDouble().toString()),
          physics: ClampingScrollPhysics(),
          currentStep: 1,
          steps: steppers(),
          controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
              Container(),
        ),
      );

  List<Step> steppers() {
    List<Step> bb = [];

    bb.add(Step(
      title: Column(
        children: <Widget>[
          Text(
            widget.fromTime,
            style: TextStyle(color: Colors.grey),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .70,
            child: Text(
              widget.from,
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

    for (String i in widget.to) {
      bb.add(Step(
        title: Column(
          children: <Widget>[
            Text(
              "--",
              style: TextStyle(color: Colors.grey),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .70,
              child: Text(
                i,
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

  double ratingNum = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (_) {
              return CustomDialog(
                title: "Do you want to exit the request?",
                includeHeader: true,
                onClicked: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
                      (Route<dynamic> route) => false);
                },
              );
            });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text("New Task Request"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  if (widget.through == "pool") {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
                        (Route<dynamic> route) => false);
                  }
                })
          ],
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        key: _scaffoldKey,
        body: Center(
          child: ListView(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                child: SvgPicture.asset(
                  "assets/images/location.svg",
                  semanticsLabel: 'Acme Logo',
                  height: 150,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _tabStep(),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          if (widget.through == "pool") {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
                                (Route<dynamic> route) => false);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "DECLINE",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900, color: Colors.red),
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Styles.appPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          acceptOrder(disMainScaffoldKey.currentContext);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            !isLoading
                                ? Text(
                                    "ACCEPT",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  )
                                : CupertinoActivityIndicator()
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _handleSendNotification() async {
    String url = "https://onesignal.com/api/v1/notifications";
    var imgUrlString =
        "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8";

    var client = http.Client();

    var headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $oneSignalApiKey"
    };

    var body = {
      "app_id": oneSignalAppID,
      "include_external_user_ids": [widget.cusUid],
      "headings": {"en": "En route"},
      "contents": {"en": "Your task has been accepted and we will reach you as soon as possible."},
      "data": {
        "routeType": "em",
        "type": "em",
        "paymentType": "em",
        "reName": "em",
        "reNum": "em",
        "amount": "em",
        "status": "Accepted",
      },
      "android_background_layout": {
        "image": imgUrlString,
        "headings_color": "ff000000",
        "contents_color": "ff0000FF"
      }
    };
    await client.post(url, headers: headers, body: jsonEncode(body)).catchError((a) {
      print(a.toString());
      showCenterToast("Error: " + a.toString(), context);
    });
  }
}
