import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import 'nearby_courier.dart';

class ModeSelector extends StatefulWidget {
  @override
  _ModeSelectorState createState() => _ModeSelectorState();
}

class TypeModel {
  String type;
  IconData value;
  String desc;

  TypeModel({this.type, this.value, this.desc});
}

List<TypeModel> types = [
  TypeModel(
      value: Icons.directions_bike,
      type: "Bike",
      desc: "Easy Delivery and Small Packages"),
  TypeModel(
      value: Icons.directions_car,
      type: "Mini van",
      desc: "Fast Delivery for Medium Small Packages"),
  TypeModel(
      value: Icons.airport_shuttle,
      type: "Mini Truck",
      desc: "Fast Delivery and Heavy Packages")
];

String packageSize, packageWeight, packageType;

class _ModeSelectorState extends State<ModeSelector> {
  bool isBottomNav = true;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    LatLng latLng_1 = LatLng(40.416775, -3.70379);
    LatLng latLng_2 = LatLng(41.385064, 2.173403);
    LatLngBounds bound = LatLngBounds(southwest: latLng_1, northeast: latLng_2);

    setState(() {
      _markers.clear();
      addMarker(latLng_1, "From");
      addMarker(latLng_2, "To");
    });

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    this.mapController.animateCamera(u2).then((void v) {
      check(u2, this.mapController);
    });
  }

  void addMarker(LatLng mLatLng, String mTitle) {
    _markers.add(Marker(
      // This marker id can be anything that uniquely identifies each marker.
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
  LatLng _lastMapPosition = const LatLng(7.3034138, 5.143012800000008);

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  TextEditingController payMode = TextEditingController();
  TextEditingController couponMode = TextEditingController();
  TextEditingController inputCouponCode = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String paymentType;
  int routeType = -1;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: GoogleMap(
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
                                              Container(
                                                height: 70,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius:
                                                      BorderRadius.circular(35),
                                                ),
                                                child: Icon(
                                                  types[index].value,
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
                                                      fontWeight:
                                                          FontWeight.w500),
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
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Styles
                                                          .appPrimaryColor),
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
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text(" ₦ 678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text("Minimun Fare: ",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text(" ₦ 678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text("Per minute: ",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text(" ₦678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text("Per Kilometer: ",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text(" ₦ 678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
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
                                      ));
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
                                        types[index].value,
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
                                controller: couponMode,
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
                                          CustomButton(
                                              title: "APPLY",
                                              onPress: () {
                                                setState(() {});
                                                Navigator.pop(context);
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListView(
                                    children: <Widget>[
                                      Text("Deliver To:",
                                          style: TextStyle(fontSize: 18)),
                                      Theme(
                                        data: ThemeData(
                                            primaryColor:
                                                Styles.commonDarkBackground,
                                            hintColor:
                                                Styles.commonDarkBackground),
                                        child: TextField(
                                          onTap: () {},
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Styles.commonDarkBackground,
                                              filled: true,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Reciever's Name",
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
                                      SizedBox(height: 8),
                                      Theme(
                                        data: ThemeData(
                                            primaryColor:
                                                Styles.commonDarkBackground,
                                            hintColor:
                                                Styles.commonDarkBackground),
                                        child: TextField(
                                          onTap: () {},
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Styles.commonDarkBackground,
                                              filled: true,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Receiver's Mobile",
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
                                      SizedBox(height: 8),
                                      Text("Instructions",
                                          style: TextStyle(fontSize: 18)),
                                      Theme(
                                        data: ThemeData(
                                            primaryColor:
                                                Styles.commonDarkBackground,
                                            hintColor:
                                                Styles.commonDarkBackground),
                                        child: TextField(
                                          onTap: () {},
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Styles.commonDarkBackground,
                                              filled: true,
                                              hintText: "Pickup Instructions",
                                              contentPadding:
                                                  EdgeInsets.all(10),
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
                                      SizedBox(height: 8),
                                      Theme(
                                        data: ThemeData(
                                            primaryColor:
                                                Styles.commonDarkBackground,
                                            hintColor:
                                                Styles.commonDarkBackground),
                                        child: TextField(
                                          onTap: () {},
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Styles.commonDarkBackground,
                                              filled: true,
                                              hintText: "Delivery Instructions",
                                              contentPadding:
                                                  EdgeInsets.all(10),
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
                                            child: Text("Choose Size"),
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
                                            child: Text("Choose Type"),
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
                                            child: Text("Choose Size"),
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
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  // finding nearby courier
                                                  return CustomDialog(
                                                    title:
                                                        "Do you want to proceed with this?",
                                                    includeHeader: true,
                                                    onClicked: () {
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                            builder: (context) =>
                                                                NearbyCourier()),
                                                      );
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
}
