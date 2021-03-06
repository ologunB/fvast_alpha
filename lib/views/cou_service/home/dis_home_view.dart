import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/cou_service/home/dis_task_detail.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/notification_page.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;

class DispatchHomeView extends StatefulWidget {
  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<DispatchHomeView> {
  GoogleMapController mapController;

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 10.0,
    )));
  }

  getUserLocation() async {
    List<Placemark> placeMark = await  placemarkFromCoordinates(
        currentLocation.latitude, currentLocation.longitude);

      _markers.add(
        Marker(
          markerId: MarkerId("Current Location"),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: InfoWindow(title: "mName", snippet: placeMark[0].name),
          icon: BitmapDescriptor.defaultMarkerWithHue(120.0),
          onTap: () {},
        ),
      );
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
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

  setPolylines(double l1, double l2, List l3, List l4) async {
    setState(() async {
      List<PointLatLng> result = await polylinePoints
          ?.getRouteBetweenCoordinates(kGoogleMapKey, l1, l2, l3[0], l4[0]);
      if (result.isNotEmpty) {
        result.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      //  setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId(randomString()),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);
      _polylines.add(polyline);
      //  });

      for (int i = 0; i < l3.length; i++) {
        if (i == l3.length - 1) {
          break;
        }
        List<PointLatLng> result =
        await polylinePoints?.getRouteBetweenCoordinates(
            kGoogleMapKey, l3[i], l4[i], l3[i + 1], l4[i + 1]);
        if (result.isNotEmpty) {
          result.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }
        //   setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId(randomString()),
            color: Colors.green,
            points: polylineCoordinates);
        _polylines.add(polyline);
        //  });
      }

      //markers
      addMarker(LatLng(l1, l2), "From");

      // setState(() {
      for (int i = 0; i < l3.length; i++) {
        addMarker(LatLng(l3[i], l4[i]), "Destination ${i + 1}");
      }
      //   });
    });
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

  @override
  void initState() {
    getUserLocation();
    getAndDraw();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<double> toLats =[];
  List<double> toLongs = [];
  List<double> fromLats = [];
  List<double> fromLongs = [];

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
                          "Task is empty",
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => DisTaskDetail(
                                task: task,
                                dataMap: document.data,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 5)
                            ], color: Colors.white),
                            child: Text(
                              "Task " + task.id,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
        }
      },
    );
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future afterLogout() async {
    final SharedPreferences prefs = await _prefs;

    setState(() {
      prefs.setBool("isLoggedIn", false);
      prefs.setString("type", "Login");
      prefs.remove("uid");
      prefs.remove("email");
      prefs.remove("name");
      prefs.remove("phone");
    });
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
            padding: const EdgeInsets.all(8.0),
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
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
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
                        l3 = task.toLat[0];
                        l4 = task.toLong[0];
                        fromLats.add(l1);
                        fromLongs.add(l2);
                        toLats.add(l3);
                        toLongs.add(l4);

                        const double PI = math.pi;
                        double degToRadian(final double deg) =>
                            deg * (PI / 180.0);
                        double radianToDeg(final double rad) =>
                            rad * (180.0 / PI);

                        num l1LatRadians = degToRadian(l1);
                        num l1LngRadians = degToRadian(l1);
                        num l2LatRadians = degToRadian(l2);
                        num lngRadiansDiff = degToRadian(l4 - l2);

                        num vectorX =
                            math.cos(l2LatRadians) * math.cos(lngRadiansDiff);
                        num vectorY =
                            math.cos(l2LatRadians) * math.sin(lngRadiansDiff);

                        num x = math.sqrt((math.cos(l1LatRadians) + vectorX) *
                                (math.cos(l1LatRadians) + vectorX) +
                            vectorY * vectorY);
                        num y = math.sin(l1LatRadians) + math.sin(l2LatRadians);
                        num latRadians = math.atan2(y, x);
                        num lngRadians = l1LngRadians +
                            math.atan2(
                                vectorY, math.cos(l1LatRadians) + vectorX);

                        mapCenter = LatLng(
                            radianToDeg(latRadians as double),
                            (radianToDeg(lngRadians as double) + 540) % 360 -
                                180);
                      }).toList();

                      return GoogleMap(
                        polylines: _polylines,
                        tiltGesturesEnabled: true,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: mapCenter,
                          zoom: 10.0,
                        ),
                        markers: _markers,
                        onCameraMove: _onCameraMove,
                      );
                    } else {
                      return GoogleMap(
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: mapCenter,
                          zoom: 10.0,
                        ),
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
                                  disMainScaffoldKey.currentState.openDrawer();
                                }),
                            IconButton(
                                icon: Icon(Icons.notifications),
                                onPressed: () {
                                  moveTo(context, NotificationPage());
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
}
