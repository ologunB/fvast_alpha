import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_loading_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
class DisTaskDetail extends StatefulWidget {
  final Task task;

  const DisTaskDetail({Key key, this.task}) : super(key: key);

  @override
  _DisTaskDetailState createState() => _DisTaskDetailState();
}

class _DisTaskDetailState extends State<DisTaskDetail> {
  GoogleMapController mapController;

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String status;

  @override
  Widget build(BuildContext context) {
    Task task = widget.task;
    int routeType = task.routeType;

    int baseFare = routeTypes[routeType].baseFare;
    int distance = task.distance;
    int tax = routeTypes[routeType].tax;
    int perKiloCharge = (routeTypes[routeType].perKilo * distance / 10).round();
    int total = baseFare + perKiloCharge + tax;
    var height = MediaQuery.of(context).size.height;

    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      bottomSheet: SolidBottomSheet(
        headerBar: Container(
          padding: EdgeInsets.all(10),
          child: Text(
            "Task Info",
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 20, color: Colors.blue),
          ),
        ),
        draggableBody: true,
        body: Container(
          padding: EdgeInsets.all(8),
          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("Orders")
                    .document("Pending")
                    .collection(MY_UID)
                    .orderBy("Timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return CustomButton(
                          title: "Getting Data", onPress: () {});
                    default:
                      if (snapshot.data.documents.isNotEmpty)
                        snapshot.data.documents.map((document) {
                          Task task = Task.map(document);
                          if (task.id == widget.task.id) {
                            status = task.status;
                          }
                        }).toList();
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => DisTaskDetail(task: task),
                              ),
                            );
                          },
                          child: CustomLoadingButton(
                              title: todoNext(status) ,
                              onPress: () {
                                processTask(context, todoNext(status));
                              },
                              isLoading: isLoading,
                              context: context));
                  }
                },
              )
,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text(task.acceptedDate + " PICKUP",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Text(status ?? task.status,                    overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(EvaIcons.person),
                title: Text(task.name,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                trailing: IconButton(
                    icon: Icon(EvaIcons.phoneCall),
                    onPressed: () {
                      showCenterToast(task.userPhone, context);
                    }),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text(task.from,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                trailing: IconButton(
                    icon: Icon(EvaIcons.globeOutline),
                    onPressed: () {
                      showCenterToast("Go to map", context);
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    "Task Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Route: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(routeTypes[routeType].type,
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Payment Type: ",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(task.paymentType, style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Coupon: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(task.coupon, style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Receiver's Name: ",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(task.reName, style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Receiver's  Mobile",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(task.reNum, style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Package Size/Weight",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(task.size, style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Package Type ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(task.type, style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text("Notes",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.add)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "No Notes yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text("Images",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.add)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "No Images yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text("Signature",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.add)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "No Signatures yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    "Payment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Base Fare: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(" \₦ " + commaFormat.format((baseFare)),
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Distance charge: ",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(" \₦ " + commaFormat.format(perKiloCharge),
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Tax: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(" \₦ " + commaFormat.format(tax),
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Others: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(
                              " \₦ " +
                                  commaFormat
                                      .format(widget.task.amount - total),
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Total: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(" \₦ " + commaFormat.format(widget.task.amount),
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        maxHeight: height * .8,
        minHeight: height * .4,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 10.0,
                ),
              ),
              height: MediaQuery.of(context).size.height * .75,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }

  bool isLoading = false;

  processTask(context, next) async {
   setState(() {
      isLoading = true;
    });
    Map<String, String> toDispatchData = Map();
    toDispatchData.putIfAbsent("status", () => next);

    Firestore.instance
        .collection("Orders")
        .document("Pending") //update for dispatcher
        .collection(MY_UID)
        .document(widget.task.id)
        .updateData(toDispatchData)
        .then((value) {
      Firestore.instance
          .collection("Orders")
          .document("Pending") //update the customer
          .collection(widget.task.userUid)
          .document(widget.task.id)
          .updateData(toDispatchData)
          .then((value) {
        _handleSendNotification(status);
        showCenterToast(status, context);

        setState(() {
          isLoading = false;
        });
      });
    });

    setState(() {
      isLoading = false;
    });
  }

  String todoNext(status) {
    String todo = "Start Task";
    if (status == "Accepted") {
      todo = "Start Arrival";
    } else if (status == "Start Arrival") {
      todo = "Arrived";
    } else if (status == "Arrived") {
      todo = "Start Delivery";
    } else if (status == "Start Delivery") {
      todo = "Complete Delivery Task";
    }else if (status == "Complete Delivery Task") {
      todo = "Completed";
    }
    return todo;
  }

  void _handleSendNotification(status) async {
    String url = "https://onesignal.com/api/v1/notifications";
    var imgUrlString =
        "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8";

    var client = http.Client();

    var headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic YTZlNmY2MWItMmEzMi00ZWI0LTk4MjQtYzc4NjUxMGE5OWQ5"
    };

    var body = {
      "app_id": "28154149-7e50-4f2c-b6e8-299293dffb33",
      "include_external_user_ids": [widget.task.userUid],
      "headings": {"en": "Searching Dispatchers around"},
      "contents": {"en": "You just booked for a task"},
      "data": {
         "type": "customer"
      },
      "android_background_layout": {
        "image": imgUrlString,
        "headings_color": "ff000000",
        "contents_color": "ff0000FF"
      }
    };
    await client
        .post(url, headers: headers, body: jsonEncode(body))
        .then((value) => (res) {
      String body = res.body;
      //  print(body);
      int code = jsonDecode(body)["statusCode"];
      //print(code);
    })
        .catchError((a) {
      print(a.toString());
      showCenterToast("Error: " + a.toString(), context);
    });

  }

}
