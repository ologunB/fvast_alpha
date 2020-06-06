import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import 'choose_location.dart';
import 'order_details.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatefulWidget {
  HomeView({@required Key key}) : super(key: key);

  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeView> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onFilledMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    //offerLatLng and currentLatLng are custom
    LatLng fromLatLng = LatLng(fromLats.reduce(max), fromLongs.reduce(max));
    LatLng toLatLng = LatLng(toLats.reduce(max), toLongs.reduce(max));

    LatLngBounds bound;
    if (toLatLng.latitude > fromLatLng.latitude &&
        toLatLng.longitude > fromLatLng.longitude) {
      bound = LatLngBounds(southwest: fromLatLng, northeast: toLatLng);
    } else if (toLatLng.longitude > fromLatLng.longitude) {
      bound = LatLngBounds(
          southwest: LatLng(toLatLng.latitude, fromLatLng.longitude),
          northeast: LatLng(fromLatLng.latitude, toLatLng.longitude));
    } else if (toLatLng.latitude > fromLatLng.latitude) {
      bound = LatLngBounds(
          southwest: LatLng(fromLatLng.latitude, toLatLng.longitude),
          northeast: LatLng(toLatLng.latitude, fromLatLng.longitude));
    } else {
      bound = LatLngBounds(southwest: toLatLng, northeast: fromLatLng);
    }

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    this.mapController.animateCamera(u2).then((void v) {
      check(u2, this.mapController);
    });
  }

  void addMarker(LatLng mLatLng, String mTitle) {
    _markers.add(Marker(
      markerId:
          MarkerId((mTitle + "_" + _markers.length.toString()).toString()),
      position: mLatLng,
      infoWindow: InfoWindow(
        title: mTitle,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(mTitle == "From"
          ? BitmapDescriptor.hueRed
          : BitmapDescriptor.hueGreen),
    ));
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  setPolylines(l1, l2, l3, l4) async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        kGoogleMapKey, l1, l2, l3, l4);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    addMarker(LatLng(l1, l2), "From");
    addMarker(LatLng(l3, l4), "To");
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('Poly'),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget taskItem({context, Task task}) {
    var color = Colors.blue[200];
    if (task.status == "Accepted") {
      color = Colors.green[200];
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => OrderDetails()));
      },
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.location_searching),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${task.id}  ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5), color: color),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "  Task ${task.status}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Stepper(
                      physics: ClampingScrollPhysics(),
                      onStepTapped: (a) {
                        /*     Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => OrderCompletedPage()));*/
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    OrderDetails(task: task)));
                      },
                      currentStep: 1,
                      steps: [
                        Step(
                            title: Column(
                              children: <Widget>[
                                Text(
                                  task.startDate,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .70,
                                  child: Text(
                                    task.from,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                            content: SizedBox()),
                        Step(
                          title: Column(
                            children: <Widget>[
                              Text(
                                task.endDate,
                                style: TextStyle(color: Colors.grey),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .70,
                                child: Text(
                                  task.to,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          content: SizedBox(),
                        ),
                      ],
                      controlsBuilder: (BuildContext context,
                              {VoidCallback onStepContinue,
                              VoidCallback onStepCancel}) =>
                          SizedBox()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Divider(),
          )
        ],
      ),
    );
  }

  Widget createTasks(context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("Orders")
          .document("Pending")
          .collection(MY_UID)
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
                children: <Widget>[
                  CupertinoActivityIndicator(),
                ],
              ),
              height: 300,
              width: 300,
            );
          default:
            return snapshot.data.documents.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.hourglass_empty,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          "Task is empty, Create a Task!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  )
                : ListView(
                    children: snapshot.data.documents.map((document) {
                      Task task = Task.map(document);
                      return taskItem(task: task, context: context);
                    }).toList(),
                  );
        }
      },
    );
  }

  List<double> toLats = List();
  List<double> toLongs = List();
  List<double> fromLats = List();
  List<double> fromLongs = List();

  getAndDraw() async {
    Firestore.instance
        .collection("Orders")
        .document("Pending")
        .collection(MY_UID)
        .getDocuments()
        .then((doc) {
      doc.documents.map((document) {
        Task task = Task.map(document);
        double l1 = task.fromLat;
        double l2 = task.fromLong;
        double l3 = task.toLat;
        double l4 = task.toLong;
        fromLats.add(l1);
        fromLongs.add(l2);
        toLats.add(l3);
        toLongs.add(l4);

        setPolylines(l1, l2, l3, l4);
      }).toList();
    });
  }

  @override
  void initState() {
    getAndDraw();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      bottomSheet: SolidBottomSheet(
        headerBar: Container(
          decoration: BoxDecoration(
            color: Styles.appPrimaryColor,
          ),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Good ${greeting()}, $MY_NAME",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        autoSwiped: false,
        draggableBody: true,
        body: createTasks(context),
        maxHeight: height * .6,
        minHeight: height * .25,
      ),
      body: Container(
        child: Stack(
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
                    return GoogleMap(
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      initialCameraPosition:
                          CameraPosition(zoom: 10.0, target: _center),
                    );
                  default:
                    if (snapshot.data.documents.isNotEmpty) {
                      snapshot.data.documents.map((document) {
                        Task task = Task.map(document);
                        double l1 = task.fromLat;
                        double l2 = task.fromLong;
                        double l3 = task.toLat;
                        double l4 = task.toLong;
                        fromLats.add(l1);
                        fromLongs.add(l2);
                        toLats.add(l3);
                        toLongs.add(l4);

                        //setPolylines(l1, l2, l3, l4);
                      }).toList();
                      return GoogleMap(
                        polylines: _polylines,
                        tiltGesturesEnabled: true,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onMapCreated: _onFilledMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 10.0,
                        ),
                        markers: _markers,
                        onCameraMove: _onCameraMove,
                      );
                    } else {
                      return GoogleMap(
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        initialCameraPosition:
                            CameraPosition(zoom: 10.0, target: _center),
                      );
                    }
                }
              },
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
                                  Icons.menu,
                                  size: 30,
                                ),
                                onPressed: () {
                                  cusMainScaffoldKey.currentState.openDrawer();
                                }),
                            IconButton(
                                icon: Icon(Icons.notifications),
                                onPressed: () {}),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Styles.appPrimaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                     Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            ChooseLocation()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Create Task",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  void _handleSendNotification(String id) async {
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
      "filters": [
        {
          "field": "tag",
          "key": "status",
          "relation": "=",
          "value": "online"
        } /*,
        {"operator": "OR"},
        {"field": "amount_spent", "relation": ">", "value": "0"}*/
      ],
      "headings": {"en": "Searching Dispatchers around"},
      "contents": {"en": "You just booked for a task"},
      "data": {
        "cus_uid": MY_UID,
        "trans_id": id,
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
    client.close();

/*   header = {"Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic NGEwMGZmMjItY2NkNy0xMWUzLTk5ZDUtMDAwYzI5NDBlNjJj"}

    payload = {"app_id": "5eb5a37e-b458-11e3-ac11-000c2940e62c",
      "filters": [
        {"field": "tag", "key": "level", "relation": "=", "value": "10"},
        {"operator": "OR"}, {"field": "amount_spent", "relation": ">", "value": "0"}
      ],
      "contents": {"en": "English Message"}}


    var status = await OneSignal.shared.getPermissionSubscriptionState();

    var playerId = status.subscriptionStatus.userId;
    //var playerId = MY_UID;

    var imgUrlString =
        "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8";

    var id = "76652917-a8df-494d-a334-109ef0e686ea";
    var notification = OSCreateNotification(
        playerIds: [id],
        content: "You just booked for an order, Searching Dispatchers around",
        heading: "Searching Dispatchers",
        iosAttachments: {"id1": imgUrlString},
        bigPicture: imgUrlString,
        buttons: [
          OSActionButton(text: "OK", id: "id1"),
          // OSActionButton(text: "test2", id: "id2")
        ]);

    await OneSignal.shared.postNotification(notification);

    this.setState(() {
      //  _debugLabelString = "Sent notification with response: $response";
    });*/
  }
}



var data = {
  "payload": {
    "google.delivered_priority": "normal",
    "google.sent_time": 1591454068581,
    "google.ttl": 259200,
    "google.original_priority": "normal",
    "bg_img": {
      "bc": "ff0000FF",
      "img":
          "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8",
      "tc": "ff000000"
    },
    "custom": {
      "a": {"cus_uid": "Yzx0RnhWBMWhQiibh3I0cS8G43f2", "trans_id": "bsshhs"},
      "i": "34f777d3-17fc-4d3a-97ae-7de82a683f8a"
    },
    "from": "691882460257",
    "alert": "You just booked for a task",
    "title": "Searching Dispatchers around",
    "google.message_id": "0:1591454068584321%4acd3053f9fd7ecd",
    "google.c.sender.id": "691882460257",
    "notificationId": 2136058561
  },
  "displayType": 2,
  "shown": true,
  "appInFocus": true,
  "silent": null
};
