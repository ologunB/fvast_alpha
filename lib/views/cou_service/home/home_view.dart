import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class DispatchHomeView extends StatefulWidget {
  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<DispatchHomeView> {
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> aa = [];
  Widget tasksListWidget(context) {
    return aa.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.hourglass_empty,
                color: Colors.blue,
              ),
              Text("Task is empty, Create a Task!")
            ],
          )
        : ListView.builder(
            itemCount: aa.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                  child: Column(
                children: <Widget>[],
              ));
            });
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

  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < 2; i++) {
      markers.add(
        Marker(
          markerId: MarkerId("Location1"),
          position: _center,
          infoWindow: InfoWindow(title: "My Location", snippet: "Street name"),
          onTap: () {},
        ),
      );
    }
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
                  "Good Evening, Daniel",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        autoSwiped: false,
        draggableBody: true,
        body: tasksListWidget(context),
        maxHeight: height * .6,
        minHeight: height * .25,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 10.0,
                ),
                markers: Set<Marker>.of(markers),
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
                                  _scaffoldKey.currentState.openDrawer();
                                }),
                            IconButton(
                                icon: Icon(Icons.notifications),
                                onPressed: () {}),
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
      drawer: Drawer(
        elevation: 4,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset("assets/images/person.png",
                                      height: 50, width: 50)),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Audu Daniel",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text("0817890978"),
                                  ],
                                ),
                              ),
                            ),
                            Switch(
                                value: isActive,
                                onChanged: (a) {
                                  isActive = a;
                                  setState(() {});
                                })
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.home),
                      title: Text(
                        "Home",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text(
                        "Task History",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.card_travel),
                      title: Text(
                        "Earnings",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.card_travel),
                      title: Text(
                        "Subscriptions/Commission",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text(
                        "Settings",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text(
                        "Support",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.arrow_back, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Logout",
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    )
                  ],
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => CustomDialog(
                    title: "Are you sure you want to log out?",
                    onClicked: () async {
                      FirebaseAuth.instance.signOut().then((a) {
                        afterLogout();
                        Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => SigninPage()),
                            (Route<dynamic> route) => false);
                      });
                    },
                    includeHeader: true,
                  ),
                );
              },
            )
          ],
        ),
      ),
    ));
  }
}
