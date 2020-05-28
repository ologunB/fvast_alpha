import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyCourier extends StatefulWidget {
  final fromLat;
  final fromLong;
  final toLat;
  final toLong;

  const NearbyCourier(
      {Key key, this.fromLat, this.fromLong, this.toLat, this.toLong})
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

    LatLng fromLatLng = LatLng(widget.fromLat, widget.fromLong);
    LatLng toLatLng = LatLng(widget.toLat, widget.toLong);
    LatLngBounds bound =
        LatLngBounds(southwest: fromLatLng, northeast: toLatLng);

    setState(() {
      _markers.clear();
      addMarker(fromLatLng, "From");
      addMarker(toLatLng, "To");
    });

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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SpinKitFadingCube(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? Colors.blue
                                  : Styles.appPrimaryColor,
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
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "21, Koforidua Street, Wuse 2, Abuja",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          )
        ],
      ),
    );
  }
}

/**/
