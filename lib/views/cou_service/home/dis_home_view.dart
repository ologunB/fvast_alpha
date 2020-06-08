import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/cou_service/home/dis_task_detail.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_order_form.dart';

class DispatchHomeView extends StatefulWidget {
  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<DispatchHomeView> {
  GoogleMapController mapController;
  List<Marker> markers = <Marker>[];

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

/*
  @override
  void initState() {
    Future.delayed(Duration(seconds: 1)).then((a) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => NewTaskRequest()));
    });
    super.initState();
  }

*/

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
                       return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => DisTaskDetail(task: task),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(padding:EdgeInsets.all(10 ),decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)], color: Colors.white),
                              child: Text(
                                "Task " + task.id,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),);
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
                                  disMainScaffoldKey.currentState.openDrawer();
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
    ));
  }
}
