import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ModeSelector extends StatefulWidget {
  @override
  _ModeSelectorState createState() => _ModeSelectorState();
}

class TypeModel {
  String type;
  IconData value;

  TypeModel({this.type, this.value});
}

List<TypeModel> types = [
  TypeModel(value: Icons.directions_bike, type: "Bike"),
  TypeModel(value: Icons.directions_car, type: "Car"),
  TypeModel(value: Icons.airport_shuttle, type: "Lorry")
];

class _ModeSelectorState extends State<ModeSelector> {
  GoogleMapController mapController;
  List<Marker> markers = <Marker>[];
  Position currentLocation;

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  TextEditingController payMode = TextEditingController();
  TextEditingController couponMode = TextEditingController();
  TextEditingController inputCouponCode = TextEditingController();
  getUserLocation() async {
    List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(
        currentLocation.latitude, currentLocation.longitude);

    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId("Current Location"),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: InfoWindow(title: "", snippet: placeMark[0].name),
          icon: BitmapDescriptor.defaultMarkerWithHue(120.0),
          onTap: () {},
        ),
      );
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    });
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String paymentType;
  int routeType = -1;
  @override
  Widget build(BuildContext context) {
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
                  markers: Set<Marker>.of(markers),
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
                                                height: 60,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius:
                                                      BorderRadius.circular(30),
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
                                                Text("Charge: ",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text("\$ 678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text("Tax: ",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text("\$ 678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text("Sub-total: ",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text("\$ 678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text("Total: ",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Expanded(
                                                    child:
                                                        Divider(thickness: 2)),
                                                Text("\$ 678 ",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 50),
                                          CustomButton(
                                              title: "Use Bike",
                                              onPress: () {
                                                /* Navigator.push(context,
              CupertinoPageRoute(builder: (context) => ModeSelector()));
      */
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
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Icon(
                                        types[index].value,
                                        color: Styles.appPrimaryColor,
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
                                              color: Styles.appPrimaryColor),
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
                          child: GestureDetector(
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
                                              Text("Payment Mode")
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
                                                enabled: false,
                                                // controller: payMode,
                                                decoration: InputDecoration(
                                                    fillColor: Styles
                                                        .commonDarkBackground,
                                                    filled: true,
                                                    hintText: "Choose Payment",
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
                                              title: "Choose",
                                              onPress: () {
                                                payMode.text = paymentType;
                                                setState(() {});
                                                Navigator.pop(context);
                                              }),
                                          SizedBox(height: 20)
                                        ],
                                      ));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: Styles.commonDarkBackground,
                                    hintColor: Styles.commonDarkBackground),
                                child: TextField(
                                  enabled: false,
                                  // controller: payMode,
                                  decoration: InputDecoration(
                                      fillColor: Styles.commonDarkBackground,
                                      filled: true,
                                      hintText: "Choose Payment",
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
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
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
                                              Text("Apply Coupon")
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
                                                enabled: false,
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
                                                payMode.text = paymentType;
                                                setState(() {});
                                                Navigator.pop(context);
                                              }),
                                          SizedBox(height: 20)
                                        ],
                                      ));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: Styles.commonDarkBackground,
                                    hintColor: Styles.commonDarkBackground),
                                child: TextField(
                                  enabled: false,
                                  controller: couponMode,
                                  decoration: InputDecoration(
                                      fillColor: Styles.commonDarkBackground,
                                      filled: true,
                                      hintText: "Input Coupon",
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
                          ),
                        ),
                      ],
                    )
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
      bottomNavigationBar: CustomButton(
          title: "PROCEED",
          onPress: () {
            /* Navigator.push(context,
              CupertinoPageRoute(builder: (context) => ModeSelector()));
      */
          }),
    );
  }
}

class TypeItem extends StatelessWidget {
  final IconData icon;
  final String type;
  TypeItem({this.icon, this.type});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(30)),
              child: Icon(
                icon,
                color: Styles.appPrimaryColor,
              )),
        ),
        Row(
          children: <Widget>[
            Center(
              child: Text(
                type,
                style: TextStyle(fontSize: 17, color: Styles.appPrimaryColor),
              ),
            )
          ],
        )
      ],
    );
  }
}
