import 'dart:async';
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

class HomeView extends StatefulWidget {
  HomeView({@required Key key}) : super(key: key);
  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeView> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  final Set<Marker> _markers = {};
  static int calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))).toInt();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    //offerLatLng and currentLatLng are custom
    LatLng fromLatLng = LatLng(widget.fromLat, widget.fromLong);
    LatLng toLatLng = LatLng(widget.toLat, widget.toLong);
    setState(() {
      _markers.clear();
      addMarker(fromLatLng, "From");
      addMarker(toLatLng, "To");
    });
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

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        kGoogleMapKey,
        widget.fromLat,
        widget.fromLong,
        widget.toLat,
        widget.toLong);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
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
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.blue[200],
                      ),
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
                  /*        SizedBox(height: 30),
           Text(
                    "Getting Data",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  SizedBox(height: 30),*/
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

  @override
  Widget build(BuildContext context) {
    /* for (var i = 0; i < 2; i++) {
      markers.add(
        Marker(
          markerId: MarkerId("Location1"),
          position: _center,
          infoWindow: InfoWindow(title: "My Location", snippet: "Street name"),
          onTap: () {},
        ),
      );
    }*/
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
            Container(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                initialCameraPosition:
                    CameraPosition(zoom: 10.0, target: _center),
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
}
