import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/partials/widgets/custom_loading_button.dart';
import 'package:fvastalpha/views/partials/widgets/text_field.dart';
import 'package:fvastalpha/views/partials/widgets/toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rave_flutter/rave_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import 'nearby_courier.dart';

class ModeSelector extends StatefulWidget {
  final fromLat;
  final fromLong;
  final toLat;
  final toLong;

  const ModeSelector(
      {Key key, this.fromLat, this.fromLong, this.toLat, this.toLong})
      : super(key: key);
  @override
  _ModeSelectorState createState() => _ModeSelectorState();
}

class TypeModel {
  String type;
  IconData icon;
  String desc;
  int baseFare;
  int perKilo;
  int tax;

  TypeModel(
      {this.type, this.icon, this.desc, this.baseFare, this.perKilo, this.tax});
}

List<TypeModel> types = [
  TypeModel(
      icon: Icons.directions_bike,
      type: "Bike",
      desc: "Easy Delivery and Small Packages",
      baseFare: 20,
      perKilo: 10,
      tax: 20),
  TypeModel(
      icon: Icons.directions_car,
      type: "Mini van",
      desc: "Fast Delivery for Medium Small Packages",
      baseFare: 30,
      perKilo: 20,
      tax: 20),
  TypeModel(
      icon: Icons.airport_shuttle,
      type: "Truck",
      desc: "Fast Delivery for Heavy Packages",
      baseFare: 40,
      perKilo: 20,
      tax: 20)
];

class _ModeSelectorState extends State<ModeSelector> {
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
      icon: BitmapDescriptor.defaultMarker,
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

  int timeFactor = 50;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String packageSize, packageWeight, packageType;

  String paymentType;
  int routeType;
  TextEditingController payMode = TextEditingController();
  TextEditingController inputCouponCode = TextEditingController();
  TextEditingController validCode = TextEditingController();
  TextEditingController receiversName = TextEditingController();
  TextEditingController receiversNumber = TextEditingController();
  TextEditingController pickupInstruct = TextEditingController();
  TextEditingController deliInstruct = TextEditingController();

  @override
  void initState() {
    setPolylines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    int distanceBtwn = calculateDistance(
        widget.toLat, widget.toLong, widget.fromLat, widget.fromLong);
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
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            timeConvert(distanceBtwn / timeFactor),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 20),
                          ),
                          Text(
                            distanceBtwn.toString() + " KM",
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          )
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
                      child: ListView.builder(
                        itemCount: 3,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
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
                                                color: Styles.appPrimaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          child: Icon(
                                            types[index].icon,
                                            color: Styles.appPrimaryColor,
                                          ),
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            types[index].type,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            types[index].desc,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Styles.appPrimaryColor),
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Base Fare: ",
                                              style: TextStyle(fontSize: 16)),
                                          Expanded(
                                              child: Divider(thickness: 2)),
                                          Text(
                                              " ₦ " +
                                                  types[index]
                                                      .baseFare
                                                      .toString(),
                                              style: TextStyle(fontSize: 16))
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Per Kilometer: ",
                                              style: TextStyle(fontSize: 16)),
                                          Expanded(
                                              child: Divider(thickness: 2)),
                                          Expanded(
                                              child: Divider(thickness: 2)),
                                          Text(
                                              " ₦ " +
                                                  types[index]
                                                      .perKilo
                                                      .toString(),
                                              style: TextStyle(fontSize: 16))
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Tax: ",
                                              style: TextStyle(fontSize: 16)),
                                          Expanded(
                                              child: Divider(thickness: 2)),
                                          Expanded(
                                              child: Divider(thickness: 2)),
                                          Text(
                                              " ₦ " +
                                                  types[index].tax.toString(),
                                              style: TextStyle(fontSize: 16))
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 50),
                                    CustomButton(
                                        title: "Use ${types[index].type}",
                                        onPress: () {
                                          Navigator.pop(context);
                                          routeType = index;
                                          setState(() {});
                                        }),
                                    SizedBox(height: 10)
                                  ],
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          color: routeType == index
                                              ? Colors.blue[100]
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Icon(
                                        types[index].icon,
                                        color: routeType == index
                                            ? Styles.appPrimaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          types[index].type,
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: routeType == index
                                                  ? Styles.appPrimaryColor
                                                  : Colors.grey),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
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
                                      builder: (context) => StatefulBuilder(
                                              builder: (context, _setState) {
                                            return ListView(
                                              shrinkWrap: true,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        height: 8,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            color: Styles
                                                                .appPrimaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                      )
                                                    ],
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Text(
                                                        "Payment Mode",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Styles
                                                                .appPrimaryColor),
                                                      ),
                                                    )
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                ),
                                                RadioListTile(
                                                  value: "Cash Payment",
                                                  groupValue: paymentType,
                                                  activeColor:
                                                      Styles.appPrimaryColor,
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .trailing,
                                                  onChanged: (value) {
                                                    _setState(() {
                                                      paymentType = value;
                                                    });
                                                  },
                                                  title: Text("Cash Payment",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ),
                                                RadioListTile(
                                                  value: "Card Payment",
                                                  groupValue: paymentType,
                                                  activeColor:
                                                      Styles.appPrimaryColor,
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .trailing,
                                                  onChanged: (value) {
                                                    _setState(() {
                                                      paymentType = value;
                                                    });
                                                  },
                                                  title: Text("Card Payment",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ),
                                                SizedBox(height: 50),
                                                CustomButton(
                                                    title: "Choose",
                                                    onPress: () {
                                                      payMode.text =
                                                          paymentType;
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
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
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
                                onTap: () {
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
                                                      color: Styles
                                                          .appPrimaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                )
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            ),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  "Apply Coupon",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Styles
                                                          .appPrimaryColor),
                                                ),
                                              )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: Styles
                                                      .commonDarkBackground,
                                                  hintColor: Styles
                                                      .commonDarkBackground),
                                              child: TextField(
                                                autofocus: true,
                                                controller: inputCouponCode,
                                                decoration: InputDecoration(
                                                    fillColor: Styles
                                                        .commonDarkBackground,
                                                    filled: true,
                                                    hintText: "Coupon code",
                                                    contentPadding:
                                                        EdgeInsets.all(10),
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    )),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 50),
                                          CustomLoadingButton(
                                              title: "APPLY",
                                              onPress: () {
                                                if (inputCouponCode
                                                    .text.isEmpty) {
                                                  showCenterToast(
                                                      "Code cannot be empty",
                                                      context);
                                                  return;
                                                }
                                                Future.delayed(
                                                        Duration(seconds: 3))
                                                    .then((a) {
                                                  validCode.text = "-₦ " + "20";
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                });
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
                                    hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    )),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
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
                          }
                          if (routeType == null) {
                            showCenterToast("Choose the Route Type", context);
                            return;
                          }
                          scaffoldKey.currentState.showBottomSheet(
                            (context) => StatefulBuilder(
                              builder: (context, _setState) => SolidBottomSheet(
                                headerBar: Container(
                                  decoration: BoxDecoration(
                                    color: Styles.appPrimaryColor,
                                  ),
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
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
                                      Text("Deliver To:",
                                          style: TextStyle(fontSize: 18)),
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
                                      Text("Instructions",
                                          style: TextStyle(fontSize: 18)),
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
                                      Text("Package Details",
                                          style: TextStyle(fontSize: 18)),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Styles.commonDarkBackground,
                                        ),
                                        child: DropdownButton<String>(
                                          hint: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Text("Choose Size*"),
                                          ),
                                          value: packageSize,
                                          underline: SizedBox(),
                                          items: ["Small", "Medium", "Large"]
                                              .map((value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  "$value",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            packageSize = value;

                                            setState(() {});
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Styles.commonDarkBackground,
                                        ),
                                        child: DropdownButton<String>(
                                          hint: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Text("Choose Type*"),
                                          ),
                                          value: packageType,
                                          underline: SizedBox(),
                                          items: [
                                            "Glass Packing",
                                            "Box Packing"
                                          ].map((value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  "$value",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            packageType = value;

                                            setState(() {});
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Styles.commonDarkBackground,
                                        ),
                                        child: DropdownButton<String>(
                                          hint: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
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
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  "$value",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            packageWeight = value;

                                            setState(() {});
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
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
                                              showCenterToast(
                                                  "Fill important fields",
                                                  context);
                                              return;
                                            }

                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return CustomDialog(
                                                    title:
                                                        "Do you want to proceed with this?",
                                                    includeHeader: true,
                                                    onClicked: () {
                                                      if (paymentType ==
                                                          "Cash Payment") {
                                                        compileTransaction(
                                                            context);
                                                      } else {
                                                        processCardTransaction(
                                                            context);
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

  double amount = 200;
  processCardTransaction(context) async {
    var initializer = RavePayInitializer(
        amount: amount, publicKey: ravePublicKey, encryptionKey: raveEncryptKey)
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
      ..staging = true
      ..isPreAuth = true
      ..displayFee = true;

    RavePayManager()
        .prompt(context: context, initializer: initializer)
        .then((result) {
      Toast.show("err", context,
          gravity: Toast.TOP, duration: Toast.LENGTH_LONG);

      if (result.status == RaveStatus.success) {
        doAfterSuccess(result.message);
      } else if (result.status == RaveStatus.cancelled) {
        if (mounted) {
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                "Closed!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: Styles.appPrimaryColor,
              duration: Duration(seconds: 3),
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

  compileTransaction(context) {
    String orderID = "ORD" + DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, Object> mData = Map();
    mData.putIfAbsent("Name", () => MY_NAME);
    mData.putIfAbsent("Date", () => presentDate());
    mData.putIfAbsent("Amount", () => amount);
    mData.putIfAbsent("userUid", () => MY_UID);
    mData.putIfAbsent("fromLat", () => widget.fromLat);
    mData.putIfAbsent("fromLong", () => widget.fromLong);
    mData.putIfAbsent("toLat", () => widget.toLat);
    mData.putIfAbsent("toLong", () => widget.toLong);
    mData.putIfAbsent("Payment Type", () => paymentType);
    mData.putIfAbsent("coupon", () => validCode.text);
    mData.putIfAbsent("Receiver Name", () => receiversName.text);
    mData.putIfAbsent("Receiver Number", () => receiversNumber.text);
    mData.putIfAbsent("Pickup Instru", () => pickupInstruct.text);
    mData.putIfAbsent("Delivery Instru", () => deliInstruct.text);
    mData.putIfAbsent("Size", () => packageSize);
    mData.putIfAbsent("Weight", () => packageWeight);
    mData.putIfAbsent("type", () => packageType);
    mData.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);
    mData.putIfAbsent("id", () => orderID);

    showCupertinoDialog(
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

    Firestore.instance
        .collection("Orders")
        .document("Pending")
        .collection(MY_UID)
        .document(orderID)
        .setData(mData)
        .then((a) {
      setState(() {
        isLoading = true;
      });

      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) {
            return NearbyCourier();
          },
        ),
      );
    });
  }

  bool isLoading = false;
  void doAfterSuccess(String serverData) async {
    setState(() {
      isLoading = true;
    });

    final Map<String, Object> data = Map();
    data.putIfAbsent("Amount", () => amount);
    data.putIfAbsent("uid", () => MY_UID);
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
        .collection("Wallet")
        .document(MY_UID)
        .setData(data)
        .then((a) {
      compileTransaction(context);
    });
  }
}
