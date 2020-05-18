import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class TaskDetail extends StatefulWidget {
  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  GoogleMapController mapController;

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      bottomSheet: SolidBottomSheet(
        headerBar: Container(
          padding: EdgeInsets.all(10),
          child: Text(
            "Task Info",
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 20, color: Colors.blue),
          ),
        ),
        draggableBody: true,
        body: Container(
          padding: EdgeInsets.all(8),
          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text("1:30 - Pickup",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Text("ACCEPTED",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(EvaIcons.person),
                title: Text("Ariyo Daniel",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                trailing: IconButton(
                    icon: Icon(EvaIcons.phoneCall), onPressed: () {}),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text("21, Koforidua Street, Wuse, Abuja",
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                trailing: IconButton(
                    icon: Icon(EvaIcons.globeOutline), onPressed: () {}),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    "Task Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Route: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("Bike ", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Payment Type: ",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("Cash", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Coupon: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(" -- ", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Receiver's Name: ",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("Richard Ray", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Receiver's  Mobile",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("08173893833", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Package Size/Weight",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("Medium/<2kg", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Package Type ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text(" Loads ", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text("Notes",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.add)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "No Notes yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text("Images",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.add)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "No Images yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Text("Signature",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.add)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "No Signatures yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    "Payment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Commission: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("#234 ", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Payment Mode: ",
                              style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("Cash", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("Status: ", style: TextStyle(fontSize: 16)),
                          Expanded(child: Divider(thickness: 2)),
                          Text("Pending", style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(title: "START TASK", onPress: () {})
            ],
          ),
        ),
        maxHeight: height * .8,
        minHeight: height * .4,
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
                                  Icons.arrow_back_ios,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
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
