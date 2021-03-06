import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/partials/widgets/custom_loading_button.dart';
import 'package:fvastalpha/views/partials/widgets/text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rave_flutter/rave_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import 'nearby_courier.dart';
import 'package:http/http.dart' as http;

class ModeSelector extends StatefulWidget {
  final double fromLat;
  final double fromLong;
  final List<double> toLat;
  final List<double> toLong;
  final String from;
  final List<String> to;

  const ModeSelector(
      {Key key, this.fromLat, this.fromLong, this.to, this.toLat, this.toLong, this.from})
      : super(key: key);

  @override
  _ModeSelectorState createState() => _ModeSelectorState();
}

double balance = 0;

class _ModeSelectorState extends State<ModeSelector> {
  void getBalance() async {
    DocumentSnapshot doc = await Firestore.instance.collection('All').document(MY_UID).get();

    balance = doc.data["Balance"];
  }

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  final Set<Marker> _markers = {};

  static int calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))).toInt();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

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

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String packageSize, packageWeight, packageType;

  String paymentType;
  int routeType;
  TextEditingController payMode = TextEditingController();
  TextEditingController inputCouponCode = TextEditingController();
  TextEditingController btcWalletController =
      TextEditingController(text: "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy");
  TextEditingController validCode = TextEditingController();
  TextEditingController receiversName = TextEditingController();
  TextEditingController receiversNumber = TextEditingController();
  TextEditingController pickupInstruct = TextEditingController();
  TextEditingController deliInstruct = TextEditingController();

  bool isCouponLoading = false;

  int distanceBtwn;

//  int timeFactor = 50;
  bool makeCouponClick = true;

  applyCoupon(_setState) {
    if (inputCouponCode.text.isEmpty) {
      showCenterToast("Code cannot be empty", context);
      return;
    }
    _setState(() {
      isCouponLoading = true;
    });
    Future.delayed(Duration(seconds: 3)).then((a) {
      validCode.text = "20";
      int coupounAmount = 20;
      isCouponLoading = false;
      totalAmount = totalAmount - coupounAmount;

      makeCouponClick = false;
      setState(() {});
      _setState(() {});
      Navigator.pop(context);
    });
  }

  routeSelected(index) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Container(
                  height: 8,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Styles.appPrimaryColor, borderRadius: BorderRadius.circular(5)),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Icon(
                  routeTypes[index].icon,
                  color: Styles.appPrimaryColor,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  routeTypes[index].type,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  routeTypes[index].desc,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400, color: Styles.appPrimaryColor),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text("Base Fare: ", style: TextStyle(fontSize: 16)),
                Expanded(child: Divider(thickness: 2)),
                Text(" ₦ " + routeTypes[index].baseFare.toString(), style: TextStyle(fontSize: 16))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text("Per Kilometer: ", style: TextStyle(fontSize: 16)),
                Expanded(child: Divider(thickness: 2)),
                Expanded(child: Divider(thickness: 2)),
                Text(
                  " ₦ " + routeTypes[index].perKilo.toString(),
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text("Tax: ", style: TextStyle(fontSize: 16)),
                Expanded(child: Divider(thickness: 2)),
                Expanded(child: Divider(thickness: 2)),
                Text(" 7.5% VAT ", style: TextStyle(fontSize: 16))
              ],
            ),
          ),
          CustomButton(
              title: "Use ${routeTypes[index].type}",
              onPress: () {
                routeSelector(context, index);
              }),
          SizedBox(height: 10)
        ],
      ),
    );
  }

  Widget eachRoute(int index) {
    return GestureDetector(
      onTap: () {
        routeSelected(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: routeType == index ? Colors.blue[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  routeTypes[index].icon,
                  color: routeType == index ? Styles.appPrimaryColor : Colors.grey,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Center(
                  child: Text(
                    routeTypes[index].type,
                    style: TextStyle(
                        fontSize: 17,
                        color: routeType == index ? Styles.appPrimaryColor : Colors.grey),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget otherRoute() {
    return GestureDetector(
      onTap: () {
        showDialog(
            useRootNavigator: true,
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text("All Routes"),
                  content: Container(
                    height: 200,
                    child: Center(
                      child: ListView.builder(
                          itemCount: routeTypes.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  routeSelected(index);
                                },
                                child: Material(
                                  child: ListTile(
                                    leading: Icon(routeTypes[index].icon),
                                    title: Text(
                                      routeTypes[index].type,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ));
                          }),
                    ),
                  ));
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: (routeType ?? 0) > 1 ? Colors.blue[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  routeTypes[(routeType ?? 2)].icon ?? Icons.format_list_bulleted,
                  color: (routeType ?? 0) > 1 ? Styles.appPrimaryColor : Colors.grey,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Center(
                  child: Text(
                    "Others",
                    style: TextStyle(
                        fontSize: 17,
                        color: (routeType ?? 0) > 1 ? Styles.appPrimaryColor : Colors.grey),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void routeSelector(BuildContext context, int index) {
    Navigator.pop(context);
    routeType = index;
    //  timeFactor = routeTypes[index].perKilo;
    int baseFare = routeTypes[index].baseFare;
    double distanceAmount = routeTypes[index].perKilo * distanceBtwn / 1;

    int tax = (0.075 * (baseFare + distanceAmount)).floor();
    totalAmount = baseFare + tax + distanceAmount;
    setState(() {});
  }

  @override
  void initState() {
    setPolylines();
    getBalance();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    distanceBtwn = 0;

    distanceBtwn =
        calculateDistance(widget.toLat[0], widget.toLong[0], widget.fromLat, widget.fromLong);

    if (widget.toLat.length == 2) {
      distanceBtwn = distanceBtwn +
          calculateDistance(widget.toLat[0], widget.toLong[0], widget.toLat[1], widget.toLong[1]);
    }

    if (widget.toLat.length == 3) {
      distanceBtwn = distanceBtwn +
          calculateDistance(widget.toLat[0], widget.toLong[0], widget.toLat[1], widget.toLong[1]) +
          calculateDistance(widget.toLat[1], widget.toLong[1], widget.toLat[2], widget.toLong[2]);
    }
    if (widget.toLat.length == 4) {
      distanceBtwn = distanceBtwn +
          calculateDistance(widget.toLat[0], widget.toLong[0], widget.toLat[1], widget.toLong[1]) +
          calculateDistance(widget.toLat[1], widget.toLong[1], widget.toLat[2], widget.toLong[2]) +
          calculateDistance(widget.toLat[2], widget.toLong[2], widget.toLat[3], widget.toLong[3]);
    }
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
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
                    Positioned.fill(
                      child: Align(
                          child: Column(
                        children: <Widget>[
                          SizedBox(height: 40),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(spreadRadius: 2, blurRadius: 11, color: Colors.black26)
                                ],
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  distanceBtwn.toString() + " KM",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                                Text(
                                  "₦ " + commaFormat.format(toTens(totalAmount)),
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                                /*    Text(
                                  timeConvert(distanceBtwn / timeFactor),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),*/
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ),
                        ],
                      )),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[eachRoute(0), eachRoute(1), otherRoute()],
                        shrinkWrap: true,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Theme(
                              data: ThemeData(
                                  primaryColor: Styles.commonDarkBackground,
                                  hintColor: Styles.commonDarkBackground),
                              child: TextField(
                                readOnly: true,
                                onTap: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        ),
                                      ),
                                      context: context,
                                      builder: (context) =>
                                          StatefulBuilder(builder: (context, _setState) {
                                            return ListView(
                                              shrinkWrap: true,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        height: 8,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            color: Styles.appPrimaryColor,
                                                            borderRadius: BorderRadius.circular(5)),
                                                      )
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: Text(
                                                        "Payment Mode",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Styles.appPrimaryColor),
                                                      ),
                                                    )
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                ),
                                                RadioListTile(
                                                  value: "Cash Payment",
                                                  groupValue: paymentType,
                                                  activeColor: Styles.appPrimaryColor,
                                                  controlAffinity: ListTileControlAffinity.trailing,
                                                  onChanged: (value) {
                                                    _setState(() {
                                                      paymentType = value;
                                                    });
                                                  },
                                                  title: Text("Cash Payment",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w400)),
                                                ),
                                                RadioListTile(
                                                  value: "Card Payment",
                                                  groupValue: paymentType,
                                                  activeColor: Styles.appPrimaryColor,
                                                  controlAffinity: ListTileControlAffinity.trailing,
                                                  onChanged: (value) {
                                                    _setState(() {
                                                      paymentType = value;
                                                    });
                                                  },
                                                  title: Text("Card Payment",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w400)),
                                                ),
                                                RadioListTile(
                                                  value: "Bitcoin Payment",
                                                  toggleable: true,
                                                  groupValue: paymentType,
                                                  activeColor: Styles.appPrimaryColor,
                                                  controlAffinity: ListTileControlAffinity.trailing,
                                                  onChanged: (value) {
                                                    // to enable uncomment
                                                    _setState(() {
                                                      paymentType = value;
                                                    });
                                                  },
                                                  title: Text("Bitcoin Payment",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w400)),
                                                ),
                                                SizedBox(height: 5),
                                                CustomButton(
                                                    title: "Choose",
                                                    onPress: () {
                                                      payMode.text = paymentType;
                                                      _setState(() {});
                                                      Navigator.pop(context);
                                                    }),
                                                SizedBox(height: 20)
                                              ],
                                            );
                                          }));
                                },
                                controller: payMode,
                                decoration: InputDecoration(
                                    fillColor: Styles.commonDarkBackground,
                                    filled: true,
                                    hintText: "Payment Mode",
                                    contentPadding: EdgeInsets.all(10),
                                    hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    )),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Theme(
                              data: ThemeData(
                                  primaryColor: Styles.commonDarkBackground,
                                  hintColor: Styles.commonDarkBackground),
                              child: TextField(
                                readOnly: true,
                                controller: validCode,
                                onTap: !makeCouponClick
                                    ? null
                                    : () {
                                        scaffoldKey.currentState.showBottomSheet(
                                          (context) => StatefulBuilder(
                                            builder: (context, _setState) => ListView(
                                              shrinkWrap: true,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        height: 8,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            color: Styles.appPrimaryColor,
                                                            borderRadius: BorderRadius.circular(5)),
                                                      )
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: Text(
                                                        "Apply Coupon",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Styles.appPrimaryColor),
                                                      ),
                                                    )
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 10),
                                                  child: Theme(
                                                    data: ThemeData(
                                                        primaryColor: Styles.commonDarkBackground,
                                                        hintColor: Styles.commonDarkBackground),
                                                    child: TextField(
                                                      autofocus: true,
                                                      controller: inputCouponCode,
                                                      decoration: InputDecoration(
                                                          fillColor: Styles.commonDarkBackground,
                                                          filled: true,
                                                          hintText: "Coupon code",
                                                          contentPadding: EdgeInsets.all(10),
                                                          hintStyle: TextStyle(
                                                              color: Colors.grey[500],
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w400),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(5.0),
                                                          )),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w400),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 50),
                                                StatefulBuilder(builder: (context, _setState) {
                                                  return Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: CustomLoadingButton(
                                                        title: "APPLY",
                                                        context: context,
                                                        isLoading: isCouponLoading,
                                                        onPress: isCouponLoading
                                                            ? null
                                                            : () {
                                                                applyCoupon(_setState);
                                                              }),
                                                  );
                                                }),
                                                SizedBox(height: 20)
                                              ],
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30),
                                            ),
                                          ),
                                        );
                                      },
                                decoration: InputDecoration(
                                    fillColor: Styles.commonDarkBackground,
                                    filled: true,
                                    hintText: "Promo Code",
                                    contentPadding: EdgeInsets.all(10),
                                    prefixText: "- ₦ ",
                                    hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    )),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    CustomButton(
                        title: "PROCEED",
                        onPress: () {
                          if (paymentType == null) {
                            showCenterToast("Choose a payment type", context);
                            return;
                          } else if (routeType == null) {
                            showCenterToast("Choose the Route Type", context);
                            return;
                          }
                          amountBefore = totalAmount;
                          scaffoldKey.currentState.showBottomSheet(
                            (context) => StatefulBuilder(
                              builder: (context, _setState) => SingleChildScrollView(
                                child: SolidBottomSheet(
                                  headerBar: Container(
                                    decoration: BoxDecoration(
                                      color: Styles.appPrimaryColor,
                                    ),
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                            child: IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                }),
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            "Courier Details",
                                            style: TextStyle(color: Colors.white, fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  draggableBody: true,
                                  body: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: ListView(
                                      children: <Widget>[
                                        Text("Package Details*", style: TextStyle(fontSize: 18)),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            color: Styles.commonDarkBackground,
                                          ),
                                          child: DropdownButton<String>(
                                            hint: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Text("Choose Size*"),
                                            ),
                                            value: packageSize,
                                            underline: SizedBox(),
                                            items: ["Small", "Medium", "Large"].map((value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    "$value",
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              packageSize = value;
                                              totalAmount = amountBefore;
                                              if (value == "Medium") {
                                                sizeCharge = 5;
                                              } else if (value == "Large") {
                                                sizeCharge = 10;
                                              } else if (value == "Small") {
                                                sizeCharge = 0;
                                              }
                                              totalAmount = totalAmount +
                                                  sizeCharge +
                                                  weightCharge +
                                                  packageCharge;

                                              setState(() {});
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            color: Styles.commonDarkBackground,
                                          ),
                                          child: DropdownButton<String>(
                                            hint: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Text("Choose Type*"),
                                            ),
                                            value: packageType,
                                            underline: SizedBox(),
                                            items: ["Glass Packing", "Box Packing"].map((value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    "$value",
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              packageType = value;

                                              totalAmount = amountBefore;
                                              if (value == "Glass Packing") {
                                                packageCharge = 10;
                                              } else {
                                                packageCharge = 0;
                                              }

                                              totalAmount = totalAmount +
                                                  sizeCharge +
                                                  weightCharge +
                                                  packageCharge;

                                              setState(() {});
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            color: Styles.commonDarkBackground,
                                          ),
                                          child: DropdownButton<String>(
                                            hint: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Text("Choose Weight*"),
                                            ),
                                            value: packageWeight,
                                            underline: SizedBox(),
                                            items: [
                                              "Less than 1kg",
                                              "1 - 3kg",
                                              "3 - 8kg",
                                              "Greater than 8kg"
                                            ].map((value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    "$value",
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              packageWeight = value;

                                              totalAmount = amountBefore;
                                              if (value == "1 - 3kg") {
                                                weightCharge = 5;
                                              } else if (value == "3 - 8kg") {
                                                weightCharge = 10;
                                              } else if (value == "Greater than 8kg") {
                                                weightCharge = 15;
                                              } else {
                                                weightCharge = 1;
                                              }
                                              totalAmount = totalAmount +
                                                  sizeCharge +
                                                  weightCharge +
                                                  packageCharge;
                                              setState(() {});
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text("Deliver To*", style: TextStyle(fontSize: 18)),
                                        CustomTextField(
                                          controller: receiversName,
                                          inputType: TextInputType.text,
                                          text: "Receiver's Name*",
                                        ),
                                        SizedBox(height: 8),
                                        CustomTextField(
                                          controller: receiversNumber,
                                          inputType: TextInputType.number,
                                          text: "Receiver's Number*",
                                        ),
                                        SizedBox(height: 8),
                                        Text("Instructions", style: TextStyle(fontSize: 18)),
                                        CustomTextField(
                                          controller: pickupInstruct,
                                          inputType: TextInputType.text,
                                          text: "Pickup Instructions",
                                        ),
                                        SizedBox(height: 8),
                                        CustomTextField(
                                          controller: deliInstruct,
                                          inputType: TextInputType.text,
                                          text: "Delivery Instructions",
                                        ),
                                        SizedBox(height: 8),
                                        CustomButton(
                                            title: "CONFIRM",
                                            onPress: () {
                                              if (receiversName.text.isEmpty ||
                                                  receiversNumber.text.isEmpty ||
                                                  packageWeight.isEmpty ||
                                                  packageType.isEmpty ||
                                                  packageSize.isEmpty ||
                                                  receiversName.text.isEmpty) {
                                                showCenterToast("Fill important fields", context);
                                                return;
                                              }

                                              showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return CustomDialog(
                                                      title: "Do you want to proceed with this?",
                                                      includeHeader: true,
                                                      onClicked: () {
                                                        if (paymentType == "Cash Payment") {
                                                          compileTransaction(context);
                                                        } else if (paymentType == "Card Payment") {
                                                          processCardTransaction(context);
                                                        } else if (paymentType ==
                                                            "Bitcoin Payment") {
                                                          useBitcoinPayment(context);
                                                        }
                                                      },
                                                    );
                                                  });
                                            })
                                      ],
                                    ),
                                  ),
                                  maxHeight: height * .6,
                                  minHeight: height * .5,
                                ),
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                          );
                        })
                  ],
                ),
              )
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

  double totalAmount = 0;
  double amountBefore = 0;
  double sizeCharge = 0;
  double weightCharge = 0;
  double packageCharge = 0;

  processCardTransaction(context) async {
    var initializer = RavePayInitializer(
        amount: toTens(totalAmount).toDouble(),
        publicKey: ravePublicKey,
        encryptionKey: raveEncryptKey)
      ..country = "NG"
      ..currency = "NGN"
      ..email = MY_EMAIL
      ..fName = MY_NAME
      ..lName = "lName"
      ..narration = "FVAST"
      ..txRef = "SCH${DateTime.now().millisecondsSinceEpoch}"
      ..acceptAccountPayments = false
      ..acceptCardPayments = true
      ..acceptAchPayments = false
      ..acceptGHMobileMoneyPayments = false
      ..acceptUgMobileMoneyPayments = false
      ..staging = false
      ..isPreAuth = true
      ..companyName = Text(
        "FVast Payment",
        style: TextStyle(fontSize: 14),
      )
      ..companyLogo = Image.asset("assets/images/logo.png")
      ..displayFee = true;

    RavePayManager().prompt(context: context, initializer: initializer).then((result) {
      if (result.status == RaveStatus.success) {
        doAfterSuccess(result.message);
      } else if (result.status == RaveStatus.cancelled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Closed!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: Styles.appPrimaryColor,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else if (result.status == RaveStatus.error) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                  "Error",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
                content: Text(
                  "An error has occured ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
      }

      print(result);
    });
  }

  void useBitcoinPayment(context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Send ₦" + toTens(totalAmount).toString() + " to this Bitcoin Wallet Address",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Theme(
                data: ThemeData(
                    primaryColor: Styles.commonDarkBackground,
                    hintColor: Styles.commonDarkBackground),
                child: TextField(
                  autofocus: true,
                  readOnly: true,
                  controller: btcWalletController,
                  decoration: InputDecoration(
                      fillColor: Styles.commonDarkBackground,
                      filled: true,
                      suffix: InkWell(
                        child: Icon(Icons.content_copy),
                        onTap: () {
                          Clipboard.setData(new ClipboardData(text: btcWalletController.text));
                          if (mounted) {
                            showCenterToast("Address Copied!", context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Address Copied!",
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                backgroundColor: Styles.appPrimaryColor,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                      contentPadding: EdgeInsets.all(10),
                      hintStyle: TextStyle(
                          color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Styles.appPrimaryColor,
                    ),
                    child: FlatButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Image.asset(
                                  "assets/images/logo.png",
                                  height: 70,
                                ),
                                content: SingleChildScrollView(
                                  child: Text(
                                    "Are you sure you have sent money to the wallet?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                      child: Text("NO")),
                                  FlatButton(
                                      onPressed: () async {
                                        compileTransaction(context);
                                      },
                                      child: Text("YES")),
                                ],
                              );
                            });
                      },
                      child: Text(
                        "Proceed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  String orderID;

  compileTransaction(context) async {
    orderID = "ORD" + DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, Object> mData = Map();
    mData.putIfAbsent("Name", () => MY_NAME);
    mData.putIfAbsent("startDate", () => presentDateTime());
    mData.putIfAbsent("endDate", () => "--");
    mData.putIfAbsent("Amount", () => toTens(totalAmount));
    mData.putIfAbsent("userUid", () => MY_UID);
    mData.putIfAbsent("userPhone", () => MY_NUMBER);
    mData.putIfAbsent("fromLat", () => widget.fromLat);
    mData.putIfAbsent("fromLong", () => widget.fromLong);
    mData.putIfAbsent("toLat", () => widget.toLat);
    mData.putIfAbsent("toLong", () => widget.toLong);
    mData.putIfAbsent("Payment Type", () => paymentType);
    mData.putIfAbsent("Route Type", () => routeType);
    mData.putIfAbsent("coupon", () => validCode.text);
    mData.putIfAbsent("Receiver Name", () => receiversName.text);
    mData.putIfAbsent("Receiver Number", () => receiversNumber.text);
    mData.putIfAbsent("Pickup Instru", () => pickupInstruct.text);
    mData.putIfAbsent("Delivery Instru", () => deliInstruct.text);
    mData.putIfAbsent("Size", () => packageSize);
    mData.putIfAbsent("fromAdd", () => widget.from);
    mData.putIfAbsent("toAdd", () => widget.to);
    mData.putIfAbsent("Weight", () => packageWeight);
    mData.putIfAbsent("type", () => packageType);
    mData.putIfAbsent("assigned", () => false);
    mData.putIfAbsent("distance", () => distanceBtwn);
    mData.putIfAbsent("status", () => "Pending");
    mData.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);
    mData.putIfAbsent("id", () => orderID);

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Almost Done",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: CupertinoActivityIndicator(radius: 20),
          );
        });

    DocumentReference docRef = Firestore.instance
        .collection("Orders")
        .document("Pending")
        .collection(MY_UID)
        .document(orderID);

    docRef.setData(mData).then((value) {
      setState(() {
        isLoading = true;
      });

      Firestore.instance
          .collection("Utils")
          .document("Tasks")
          .collection("uid")
          .document(orderID)
          .setData(mData);

      _handleSendNotification(docRef.documentID).then((value) => Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => NearbyCourier(
              fromLong: widget.fromLong,
              id: orderID,
              fromLat: widget.fromLat,
              toLat: widget.toLat,
              toLong: widget.toLong,
              currentAdd: widget.from,
            ),
          ),
          (Route<dynamic> route) => false));
    });
  }

  bool isLoading = false;

  void doAfterSuccess(String serverData) async {
    String orderID = "WAL" + DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      isLoading = true;
    });

    final Map<String, Object> data = Map();
    data.putIfAbsent("Amount", () => toTens(totalAmount));
    data.putIfAbsent("uid", () => MY_UID);
    data.putIfAbsent("date", () => presentDateTime());
    data.putIfAbsent("id", () => orderID);
    data.putIfAbsent("type", () => "Deposit");
    data.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Finishing processing",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: CupertinoActivityIndicator(radius: 20),
          );
        });

    Firestore.instance
        .collection("Utils")
        .document("Wallet")
        .collection(MY_UID)
        .document(orderID)
        .setData(data)
        .then((a) {
      compileTransaction(context);
    });
  }

  Future _handleSendNotification(String id) async {
    String message = "You created a New task at ${widget.from}";
    final Map<String, Object> data = Map();
    data.putIfAbsent("Message", () => message);
    data.putIfAbsent("Date", () => presentDateTime());
    data.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    Firestore.instance
        .collection("Utils")
        .document("Notification")
        .collection(MY_UID)
        .document(randomString())
        .setData(data);

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
      "filters": [
        {"field": "tag", "key": "dispatcher", "relation": "=", "value": "online"}
      ],
      "headings": {"en": "New task available at"},
      "contents": {"en": widget.from},
      "data": {
        "cus_uid": MY_UID,
        "trans_id": id,
        "from": widget.from,
        "fromTime": presentDateTime(),
        "to": widget.to,
        "toTime": "---",
      },
      "android_background_layout": {
        "image": imgUrlString,
        "headings_color": "ff000000",
        "contents_color": "ff0000FF"
      }
    };
    await client
        .post(url, headers: headers, body: jsonEncode(body))
        .then((value) => (res) {})
        .catchError((a) {
      print(a.toString());
      showCenterToast("Error: " + a.toString(), context);
    });
  }
}
