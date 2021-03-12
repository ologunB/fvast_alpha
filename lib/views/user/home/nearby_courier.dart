import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_view.dart';
import 'order_details.dart';

class NearbyCourier extends StatefulWidget {
  final double fromLat;
  final String id;
  final double fromLong;
  final List<double> toLat;
  final List<double> toLong;
  final String currentAdd;

  const NearbyCourier(
      {Key key, this.fromLat, this.fromLong, this.toLat, this.toLong, this.currentAdd, this.id})
      : super(key: key);

  @override
  _NearbyCourierState createState() => _NearbyCourierState();
}

class _NearbyCourierState extends State<NearbyCourier> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    //offerLatLng and currentLatLng are custom
    LatLng fromLatLng = LatLng(widget.fromLat, widget.fromLong);
    LatLng toLatLng = LatLng(widget.toLat[0], widget.toLong[0]);
    setState(() {
      _markers.clear();
      addMarker(fromLatLng, "From");
      for (int i = 0; i < widget.toLat.length; i++) {
        addMarker(LatLng(widget.toLat[i], widget.toLong[i]), "Destination ${i + 1}");
      }
    });
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

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    this.mapController.animateCamera(u2).then((void v) {
      check(u2, this.mapController);
    });
  }

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

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        kGoogleMapKey, widget.fromLat, widget.fromLong, widget.toLat[0], widget.toLong[0]);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId(randomString()),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }

  @override
  void initState() {
    setPolylines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: GoogleMap(
                  polylines: _polylines,
                  tiltGesturesEnabled: true,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 10.0,
                  ),
                  markers: _markers,
                  onCameraMove: _onCameraMove,
                ),
              ),
              createdTask(context),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => LayoutTemplate()),
                  (Route<dynamic> route) => false);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                children: <Widget>[
                  IconButton(
                      icon: Icon(EvaIcons.home, size: 28, color: Colors.blue), onPressed: () {}),
                  Text(
                    "Go Home",
                    style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w700),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget createdTask(context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("Orders")
          .document("Pending")
          .collection(MY_UID)
          .document(widget.id)
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
            return !snapshot.data.exists
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
                          "Task has been deleted\nGo to home and Create a new Task!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  )
                : snapshot.data.data["assigned"]
                    ? taskItem(
                        task: Task.map(snapshot.data.data),
                        context: context,
                        docTask: snapshot.data.data)
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SpinKitFadingCube(
                                itemBuilder: (BuildContext context, int index) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: index.isEven ? Colors.blue : Styles.appPrimaryColor,
                                    ),
                                  );
                                },
                                size: 30,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Finding Nearby Courier",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      widget.currentAdd,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
        }
      },
    );
  }

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
}
