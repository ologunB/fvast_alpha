import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/notification_page.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:geocoding/geocoding.dart';
import 'choose_location.dart';
import 'order_details.dart';
import 'package:geolocator/geolocator.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeView> {
  List<double> toLats = [];
  List<double> toLongs = [];
  List<double> fromLats = [];
  List<double> fromLongs = [];

  GoogleMapController mapController;

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapCenter = LatLng(currentLocation.latitude, currentLocation.longitude);

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 10.0,
    )));
  }

  getUserLocation() async {
    currentLocation = await Geolocator.getCurrentPosition();
    List<Placemark> placeMark =
        await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);

    mapCenter = LatLng(currentLocation.latitude, currentLocation.longitude);
    _markers.add(
      Marker(
        markerId: MarkerId("Current Location"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: "Current Location", snippet: placeMark[0].name),
        icon: BitmapDescriptor.defaultMarkerWithHue(120.0),
        onTap: () {},
      ),
    );
    // setState(() {});
  }

/*
  void _onFilledMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);
    LatLng fromLatLng = LatLng(fromLats.reduce(max), fromLongs.reduce(max));
    LatLng toLatLng = LatLng(toLats.reduce(max), toLongs.reduce(max));

    LatLngBounds bound;

    if (toLatLng.latitude > fromLatLng.latitude && toLatLng.longitude > fromLatLng.longitude) {
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

    mapCenter = LatLng(currentLocation.latitude, currentLocation.longitude);
    // setState(() {});
    //   getUserLocation();

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    mapController.animateCamera(u2).then((void v) {
      check(u2, this.mapController);
    });
  }
*/

  void addMarker(LatLng mLatLng, String mTitle) {
    _markers.add(Marker(
      markerId: MarkerId((mTitle + "_" + _markers.length.toString()).toString()),
      position: mLatLng,
      infoWindow: InfoWindow(
        title: mTitle,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          mTitle == "From" ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen),
    ));
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) check(u, c);
  }

  void _onCameraMove(CameraPosition position) {
    mapCenter = position.target;
  }

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  setPolylines(double l1, double l2, List l3, List l4) async {
    List<PointLatLng> result =
        await polylinePoints?.getRouteBetweenCoordinates(kGoogleMapKey, l1, l2, l3[0], l4[0]);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    Polyline polyline = Polyline(
        polylineId: PolylineId(randomString()),
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates);
    _polylines.add(polyline);

    for (int i = 0; i < l3.length; i++) {
      if (i == l3.length - 1) {
        break;
      }
      List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
          kGoogleMapKey, l3[i], l4[i], l3[i + 1], l4[i + 1]);
      if (result.isNotEmpty) {
        result.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      Polyline polyline = Polyline(
          polylineId: PolylineId(randomString()), color: Colors.green, points: polylineCoordinates);
      _polylines.add(polyline);
    }

    //markers
    addMarker(LatLng(l1, l2), "From");

    for (int i = 0; i < l3.length; i++) {
      addMarker(LatLng(l3[i], l4[i]), "Destination ${i + 1}");
    }
    setState(() {});
  }

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
        List l3 = task.toLat;
        List l4 = task.toLong;
        fromLats.add(l1);
        fromLongs.add(l2);
        toLats.add(l3[0]);
        toLongs.add(l4[0]);

        setPolylines(l1, l2, l3, l4);
      }).toList();
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget taskItem({context, Task task, Map docTask}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => OrderDetails(task: task, dataMap: docTask)));
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
                    Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5), color: widgetColor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(userHomeNext(task.status),
                            overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${task.id.substring(0, 12)}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Stepper(
                      physics: ClampingScrollPhysics(),
                      onStepTapped: (a) {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => OrderDetails(task: task, dataMap: docTask)));
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
                            content: SizedBox()),
                        Step(
                          title: Column(
                            children: <Widget>[
                              Text(
                                task.acceptedDate ?? "--",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .70,
                                child: Text(
                                  task.to[0] + " - " + todo2(task.status),
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
                              {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
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

  Widget createdTasks(context) {
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
                              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  )
                : ListView(
                    children: snapshot.data.documents.map((document) {
                      Task task = Task.map(document);

                      return taskItem(task: task, context: context, docTask: document.data);
                    }).toList(),
                  );
        }
      },
    );
  }

  @override
  void initState() {
    getUserLocation();
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
        body: createdTasks(context),
        maxHeight: height * .6,
        minHeight: height * .25,
      ),
      body: Container(
        height: height * .65,
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
                if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on),
                        Text(
                          "Getting Location",
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ));
                  default:
                    if (snapshot.data.documents.isNotEmpty) {
                      double l1, l2, l3, l4;
                      snapshot.data.documents.map((document) {
                        Task task = Task.map(document);
                        l1 = task.fromLat;
                        l2 = task.fromLong;
                        l3 = task.toLat[0].toDouble();
                        l4 = task.toLong[0].toDouble();
                        fromLats.add(l1);
                        fromLongs.add(l2);
                        toLats.add(l3);
                        toLongs.add(l4);

                        const double PI = math.pi;
                        double degToRadian(final double deg) => deg * (PI / 180.0);
                        double radianToDeg(final double rad) => rad * (180.0 / PI);

                        num l1LatRadians = degToRadian(l1);
                        num l1LngRadians = degToRadian(l1);
                        num l2LatRadians = degToRadian(l2);
                        num lngRadiansDiff = degToRadian(l4 - l2);

                        num vectorX = math.cos(l2LatRadians) * math.cos(lngRadiansDiff);
                        num vectorY = math.cos(l2LatRadians) * math.sin(lngRadiansDiff);

                        num x = math.sqrt((math.cos(l1LatRadians) + vectorX) *
                                (math.cos(l1LatRadians) + vectorX) +
                            vectorY * vectorY);
                        num y = math.sin(l1LatRadians) + math.sin(l2LatRadians);
                        num latRadians = math.atan2(y, x);
                        num lngRadians =
                            l1LngRadians + math.atan2(vectorY, math.cos(l1LatRadians) + vectorX);

                        mapCenter = LatLng(radianToDeg(latRadians as double),
                            (radianToDeg(lngRadians as double) + 540) % 360 - 180);
                      }).toList();

                      return GoogleMap(
                        polylines: _polylines,
                        tiltGesturesEnabled: true,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(target: mapCenter, zoom: 10.0),
                        markers: _markers,
                        onCameraMove: _onCameraMove,
                      );
                    } else {
                      return GoogleMap(
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(target: mapCenter, zoom: 10.0),
                        onCameraMove: _onCameraMove,
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
                                onPressed: () {
                                  moveTo(context, NotificationPage());
                                }),
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
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) => ChooseLocation()));
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
            ),
          ],
        ),
      ),
    ));
  }
}

var widgetColor = Colors.blue[200];

String userHomeNext(status) {
  String todo = "";

  if (status == "Pending") {
    widgetColor = Colors.redAccent[200];
    todo = "Awaiting";
  } else if (status == "Accepted") {
    todo = "Task Accepted";
    widgetColor = Colors.lightBlueAccent[200];
  } else if (status == "Start Task 1") {
    todo = "Task 1 Started";
    widgetColor = Colors.greenAccent[200];
  } else if (status == "End Task 1") {
    todo = "Task 1 Ended";
    widgetColor = Colors.lightBlueAccent[200];
  } else if (status == "End Task 2") {
    todo = "Task 2 Ended";
    widgetColor = Colors.lightBlueAccent[200];
  } else if (status == "Start Task 2") {
    todo = "Task 2 Started";
    widgetColor = Colors.greenAccent[200];
  } else if (status == "Start Task 3") {
    todo = "Task 3 Started";
    widgetColor = Colors.greenAccent[200];
  } else if (status == "End Task 3") {
    todo = "Task 3 Ended";
    widgetColor = Colors.lightBlueAccent[200];
  } else if (status == "Start Task 4") {
    todo = "Task 4 Started";
    widgetColor = Colors.greenAccent[200];
  } else if (status == "End Task 4") {
    todo = "Task 4 Ended";
    widgetColor = Colors.lightBlueAccent[200];
  } else if (status == "Completed") {
    widgetColor = Colors.greenAccent[200];
    todo = "Completed";
  }

  return todo;
}

String todo1(status) {
  String fromStatus = "Pending";

  if (status == "Start Arrival") {
    fromStatus = "Completed";
  }
  return fromStatus;
}

String todo2(status) {
  String toStatus = "Pending";

  if (status == "Start Arrival") {
    toStatus = "Completed";
  }
  return toStatus;
}
