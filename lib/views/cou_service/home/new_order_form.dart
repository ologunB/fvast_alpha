import 'dart:convert';

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
  final String cusUid, transId, from, fromTime, to;

  const NewTaskRequest(
      {Key key, this.cusUid, this.transId, this.from, this.fromTime, this.to})
      : super(key: key);

  @override
  _NewTaskRequestState createState() => _NewTaskRequestState();
}

class _NewTaskRequestState extends State<NewTaskRequest> {

  getOrder(context) async {
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
      toDispatchData.putIfAbsent("Dis Uid", () => MY_UID);
      toDispatchData.putIfAbsent("Dis Name", () => MY_NAME);
      toDispatchData.putIfAbsent("Dis Number", () => MY_NUMBER);
      toDispatchData.update("status", (a) => "Accepted");
      toDispatchData.putIfAbsent("Accepted Date", () => presentDateTime());
      toDispatchData.putIfAbsent("assigned", () => true);

      Firestore.instance
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
          _handleSendNotification();
          Navigator.pop(context);
          Task task = Task.map(toDispatchData);
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => DisTaskDetail(task: task),
            ),
          );
        });
      });
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
          physics: ClampingScrollPhysics(),
          onStepTapped: (a) {},
          currentStep: 1,
          steps: [
            Step(
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
            ),
            Step(
              title: Column(
                children: <Widget>[
                  Text(
                    "---",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: Text(
                      widget.to,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              content: Text(" "),
            ),
          ],
          controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
              Container(),
        ),
      );

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
                      CupertinoPageRoute(
                          builder: (context) => DisLayoutTemplate()),
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
                    Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => DisLayoutTemplate()),
                        (Route<dynamic> route) => false);
                  })
            ],
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          key: _scaffoldKey,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            Navigator.pushAndRemoveUntil(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => DisLayoutTemplate()),
                                (Route<dynamic> route) => false);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "DECLINE",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red),
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
                            getOrder(context);
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
          ),),
    );
  }

    void _handleSendNotification() async {
      String url = "https://onesignal.com/api/v1/notifications";
      var imgUrlString =
          "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8";

    var client = http.Client();

    var headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic NDA4Mjc0MGUtMTMxYS00YjFlLTgwZTktMmRiYmVmYjRjZWFj"
    };

    var body = {
      "app_id": oneOnlineSignalKey,
      "include_external_user_ids": [widget.cusUid],
      "headings": {"en": "En route"},
      "contents": {
        "en":
            "Your task has been accepted and we will reach you as soon as possible."
      },
      "data": {
        "routeType": "em",
        "type": "em",
        "paymentType": "em",
        "reName": "em",
        "reNum": "em",
        "amount": "em",
      },
      "android_background_layout": {
        "image": imgUrlString,
        "headings_color": "ff000000",
        "contents_color": "ff0000FF"
      }
    };
    await client
        .post(url, headers: headers, body: jsonEncode(body))
        .catchError((a) {
      print(a.toString());
      showCenterToast("Error: " + a.toString(), context);
    });
  }
}
