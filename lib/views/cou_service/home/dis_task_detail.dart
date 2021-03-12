import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:signature/signature.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/partials/widgets/custom_loading_button.dart';
import 'package:fvastalpha/views/user/home/home_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dis_order_done.dart';

class DisTaskDetail extends StatefulWidget {
  final Task task;
  final Map dataMap;

  const DisTaskDetail({Key key, this.task, this.dataMap}) : super(key: key);

  @override
  _DisTaskDetailState createState() => _DisTaskDetailState();
}

class _DisTaskDetailState extends State<DisTaskDetail> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  final Set<Marker> _markers = {};

  _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    //offerLatLng and currentLatLng are custom
    LatLng fromLatLng = LatLng(widget.task.fromLat, widget.task.fromLong);
    LatLng toLatLng = LatLng(widget.task.toLat[0], widget.task.toLong[0]);
    setState(() {
      _markers.clear();
      addMarker(fromLatLng, "From");
      for (int i; i < widget.task.toLat.length; i++) {
        addMarker(LatLng(widget.task.toLat[i], widget.task.toLong[i]), "Destination ${i + 1}");
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

  addMarker(LatLng mLatLng, String mTitle) {
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

  check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) check(u, c);
  }

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(kGoogleMapKey,
        widget.task.fromLat, widget.task.fromLong, widget.task.toLat[0], widget.task.toLong[0]);
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

  List<String> allStatus = [];

  @override
  void initState() {
    allStatus.add("Accepted");
    for (int i = 0; i < widget.task.to.length +1; i++) {
      allStatus.add("Start Task ${i + 1}");
      allStatus.add("End Task ${i + 1}");
    }

    print(allStatus);
    setPolylines();
    noteController = TextEditingController(text: widget.task.disNotes);
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController noteController;
  String status;

  @override
  Widget build(BuildContext context) {
    Task task = widget.task;
    int routeType = task.routeType;

    int baseFare = routeTypes[routeType].baseFare;
    int distance = task.distance;
    int perKiloCharge = (routeTypes[routeType].perKilo * distance).round();
    int tax = (0.075 * (baseFare + perKiloCharge)).floor();

    int total = baseFare + perKiloCharge + tax;

    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
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
          ),
          DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              builder: (context, builder) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: ListView(
                    controller: builder,
                    shrinkWrap: true,
                    //  physics: ClampingScrollPhysics(),
                    children: <Widget>[
                      Text(
                        "Task Info",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20, color: Colors.blue),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance
                            .collection("Orders")
                            .document("Pending")
                            .collection(MY_UID)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return CustomButton(title: "Getting Data", onPress: () {});
                            default:
                              if (snapshot.data.documents.isNotEmpty)
                                snapshot.data.documents.map((document) {
                                  Task task = Task.map(document);
                                  if (task.id == widget.task.id) {
                                    status = task.status;
                                  }
                                }).toList();
                              return GestureDetector(
                                  onTap: status == "Cancelled"
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => DisTaskDetail(task: task),
                                            ),
                                          );
                                        },
                                  child: status == allStatus[allStatus.length - 1]
                                      ? CustomLoadingButton(
                                          title: "Mark as Complete",
                                          onPress: () {
                                            processTask(
                                                _scaffoldKey.currentContext, "Mark Completed");
                                          },
                                          isLoading: isLoading,
                                          context: context)
                                      : CustomLoadingButton(
                                          title: status == "Cancelled" || status == null
                                              ? "Task Cancelled"
                                              : todoNext(status),
                                          onPress: () {
                                            processTask(
                                                _scaffoldKey.currentContext, todoNext(status));
                                          },
                                          isLoading: isLoading,
                                          context: context));
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: <Widget>[
                              Text(task.acceptedDate,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              Text(userHomeNext(status) ?? userHomeNext(task.status),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue))
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(EvaIcons.person),
                        title: Text(task.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                        trailing: IconButton(
                            icon: Icon(EvaIcons.phoneCall),
                            onPressed: () {
                              try {
                                launch(
                                  "tel://${task.userPhone}",
                                );
                              } catch (e) {
                                print(e);
                              }
                            }),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text(task.from,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                        trailing: IconButton(
                            icon: Icon(EvaIcons.globeOutline),
                            onPressed: () async {
                              String googleUrl =
                                  'https://www.google.com/maps/search/?api=1&query=${task.fromLat},${task.fromLong}';
                              if (await canLaunch(googleUrl)) {
                                await launch(googleUrl);
                              } else {
                                throw 'Could not open the map.';
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "Task Summary",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Route: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(routeTypes[routeType].type, style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Payment Type: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(task.paymentType, style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Coupon: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(task.coupon, style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Receiver's Name: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(task.reName, style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Receiver's  Mobile", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(task.reNum, style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Package Size/Weight", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(task.size, style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Package Type ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(task.type, style: TextStyle(fontSize: 16))
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
                              color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: <Widget>[
                              Text("Notes",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              GestureDetector(
                                child: Icon(Icons.add),
                                onTap: () {
                                  onAddNotes(context);
                                },
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            noteController.text.trim() == ""
                                ? "No Notes yet!"
                                : noteController.text,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: <Widget>[
                              Text("Images",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              GestureDetector(
                                child: Icon(Icons.add),
                                onTap: () {
                                  onAddImage(context);
                                },
                              )
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
                              color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: <Widget>[
                              Text("Signature",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              GestureDetector(
                                child: Icon(Icons.add),
                                onTap: () {
                                  onAddSignature(context);
                                },
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                      ),
                      signImage == null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: CachedNetworkImage(
                                      imageUrl: widget.task.disSign,
                                      height: 40,
                                      width: 40,
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => Text(
                                            "No Signatures yet!",
                                            style: TextStyle(fontSize: 16),
                                          ))),
                            )
                          : Image.memory(
                              signImage,
                              height: 40,
                              width: 40,
                            ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "Payment",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Base Fare: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(" \₦ " + commaFormat.format((baseFare)),
                                      style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Distance charge: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(" \₦ " + commaFormat.format(perKiloCharge),
                                      style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Tax: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(" \₦ " + commaFormat.format(tax),
                                      style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Others: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(" \₦ " + commaFormat.format(widget.task.amount - total),
                                      style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Total: ", style: TextStyle(fontSize: 16)),
                                  Expanded(child: Divider(thickness: 2)),
                                  Text(" \₦ " + commaFormat.format(widget.task.amount),
                                      style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      status == "Start Delivery" || status == "Mark Completed"
                          ? SizedBox()
                          : GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CustomDialog(
                                    title: "Do you want to cancel the order?",
                                    onClicked: () {
                                      cancelOrder();
                                    },
                                    includeHeader: true,
                                  ),
                                );
                              },
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    //    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.red,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      //    mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Cancel Order",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              }),
        ],
      ),
    ));
  }

  bool isLoading = false;

  File pop;

  Future getImageGallery() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pop = img;
    });
  }

  Future getImageCamera() async {
    var img = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      pop = img;
    });
  }

  onAddImage(context) {
    // String initialText = noteController.text;
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    getImageGallery();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Choose Image from Gallery"),
                  ),
                ),
                InkWell(
                  onTap: () {
                    getImageCamera();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Take Image from Camera"),
                  ),
                ),
              ],
            ),
          );
        });
  }

  onAddNotes(context) {
    String initialText = noteController.text;
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Add Note",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 23),
            ),
            content: Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: CupertinoTextField(
                  placeholder: "Type note here...",
                  placeholderStyle: TextStyle(fontWeight: FontWeight.w300, color: Colors.black38),
                  padding: EdgeInsets.all(10),
                  maxLines: 10,
                  onSubmitted: (e) {
                    Map<String, Object> data = Map();
                    data.putIfAbsent("Dis Notes", () => noteController.text);
                    Firestore.instance
                        .collection("Orders")
                        .document("Pending") //create for dispatcher
                        .collection(MY_UID)
                        .document(widget.task.id)
                        .updateData(data);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  controller: noteController,
                ),
              ),
            ),
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.red),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        noteController.text = initialText;
                        setState(() {});
                      },
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Styles.appPrimaryColor,
                    ),
                    child: FlatButton(
                      onPressed: () {
                        if (noteController.text.isEmpty) {
                          showCenterToast("Enter note", context);
                          return;
                        }
                        Map<String, Object> data = Map();
                        data.putIfAbsent("Dis Notes", () => noteController.text);
                        Firestore.instance
                            .collection("Orders")
                            .document("Pending") //create for dispatcher
                            .collection(MY_UID)
                            .document(widget.task.id)
                            .updateData(data);
                        setState(() {});
                        Navigator.pop(context);
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

  Uint8List signImage;

  onAddSignature(context) {
    final SignatureController signController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.black12,
    );

    ///  final _signKey = GlobalKey<SignatureState>();
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Add Signature",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 23),
            ),
            content: Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Signature(
                    controller: signController,
                    width: 300,
                    height: 300,
                    backgroundColor: Colors
                        .black12, // key that allow you to provide a GlobalKey that'll let you retrieve the image once user has signed
                  )),
            ),
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.red),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Styles.appPrimaryColor,
                    ),
                    child: FlatButton(
                      onPressed: () async {
                        if (signController.isEmpty) {
                          showCenterToast(signImage.toString(), context);
                          return;
                        }
                        var image = await signController.toPngBytes();

                        signImage = image;
                        setState(() {});
                        Navigator.pop(context);

                        var _storageRef = FirebaseStorage.instance.ref();
                        StorageReference storeRef = _storageRef.child("images/${randomString()}");
                        StorageUploadTask uploadTask = storeRef.putData(image);
                        StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
                        String url = (await downloadUrl.ref.getDownloadURL());

                        Map<String, Object> map = Map();
                        map.putIfAbsent("Dis Signature", () => url);
                        Firestore.instance
                            .collection("Orders")
                            .document("Pending") //create for dispatcher
                            .collection(MY_UID)
                            .document(widget.task.id)
                            .updateData(map);
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

  String todoNext(status) {
    String todo = "";
    if (status == "Accepted") {
      todo = allStatus[1];
    } else if (status == "Start Task 1") {
      todo = allStatus[2];
    } else if (status == allStatus[2]) {
      todo = allStatus[3];
    } else if (status == allStatus[3]) {
      todo = allStatus[4];
    } else if (status == allStatus[4]) {
      todo = allStatus[5];
    } else if (status == allStatus[5]) {
      todo = allStatus[6];
    } else if (status == allStatus[6]) {
      todo = allStatus[7];
    } else if (status == allStatus[7]) {
      todo = allStatus[8];
    } else if (status == allStatus[8]) {
      todo = allStatus[9];
    } else if (status == allStatus[9]) {
      todo = allStatus[10];
    } else {
      todo = "Mark Completed";
    }
    return todo;
  }

  processTask(context, next) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> toDispatchData = Map();
    toDispatchData.putIfAbsent("status", () => next);

    if (next == "Mark Completed") {
      showDialog(
        context: context,
        builder: (_) => CustomDialog(
          title: "Are you sure you have completed the task?",
          isLoading: isLoading,
          onClicked: () async {
            Navigator.pop(context);
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
            DocumentSnapshot doc = await Firestore.instance
                .collection("Orders")
                .document("Pending")
                .collection(widget.task.userUid)
                .document(widget.task.id)
                .get();

            Map data = doc.data;
            data.update("status", (a) => next, ifAbsent: () => next);

            Firestore _firestore = Firestore.instance;

            WriteBatch writeBatch = _firestore.batch();
            writeBatch.setData(
                _firestore
                    .collection("Orders")
                    .document("Completed") //create for dispatcher
                    .collection(MY_UID)
                    .document(widget.task.id),
                data);

            writeBatch.setData(
                _firestore
                    .collection("Orders")
                    .document("Completed") //create the customer
                    .collection(widget.task.userUid)
                    .document(widget.task.id),
                data);

            writeBatch.delete(_firestore
                .collection("Orders")
                .document("Pending") //delete the customer
                .collection(widget.task.userUid)
                .document(widget.task.id));

            writeBatch.delete(_firestore
                .collection("Orders")
                .document("Pending") //delete for dispatcher
                .collection(MY_UID)
                .document(widget.task.id));

            writeBatch.commit().then((value) {
              _handleSendNotification(next, context);
            });
          },
          includeHeader: true,
        ),
      );
    } else {
      Firestore _firestore = Firestore.instance;

      WriteBatch writeBatch = _firestore.batch();
      writeBatch.updateData(
          _firestore
              .collection("Orders")
              .document("Pending") //update for dispatcher
              .collection(MY_UID)
              .document(widget.task.id),
          toDispatchData);

      writeBatch.updateData(
          _firestore
              .collection("Orders")
              .document("Pending") //update for dispatcher
              .collection(widget.task.userUid)
              .document(widget.task.id),
          toDispatchData);
      writeBatch.commit().then((value) {
        _handleSendNotification(next, context);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _handleSendNotification(mStatus, context) async {
    const url = "https://onesignal.com/api/v1/notifications";
    const imgUrlString =
        "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8";
    var client = http.Client();

    const headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $oneSignalApiKey"
    };

    String desc = "";
    if (mStatus == "Start Task 1") {
      desc = "Dispatcher will arrive soon at your task point";
    } else if (mStatus == "End Task 1") {
      desc = "Dispatcher has ended Task 1";
    }
    if (mStatus == "Start Task 2") {
      desc = "Dispatcher will arrive soon at your task point";
    } else if (mStatus == "End Task 2") {
      desc = "Dispatcher has ended Task 2";
    }
    if (mStatus == "Start Task 3") {
      desc = "Dispatcher will arrive soon at your task point";
    } else if (mStatus == "End Task 3") {
      desc = "Dispatcher has ended Task 3";
    }
    if (mStatus == "Start Task 4") {
      desc = "Dispatcher will arrive soon at your task point";
    } else if (mStatus == "End Task 4") {
      desc = "Dispatcher has ended Task 4";
    } else if (mStatus == "Mark Completed") {
      desc = "Delivery Completed";
    }

    String message = "$desc by ${widget.task.disName ?? "no-name"}";
    final Map<String, Object> nData = Map();
    nData.putIfAbsent("Message", () => message);
    nData.putIfAbsent("Date", () => presentDateTime());
    nData.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    Firestore.instance
        .collection("Utils")
        .document("Notification")
        .collection(widget.task.userUid)
        .document(randomString())
        .setData(nData);

    var body = {};
    if (mStatus == "Mark Completed") {
      body = {
        "app_id": oneSignalAppID,
        "include_external_user_ids": [widget.task.userUid],
        "headings": {"en": "Completed"},
        "contents": {"en": "Task Completed"},
        "data": {
          "routeType": widget.task.routeType,
          "type": widget.task.type,
          "paymentType": widget.task.paymentType,
          "reName": widget.task.reName,
          "reNum": widget.task.reNum,
          "amount": widget.task.amount,
          "status": "Mark Completed",
        },
        "android_background_layout": {
          "image": imgUrlString,
          "headings_color": "ff000000",
          "contents_color": "ff0000FF"
        }
      };
    } else {
      body = {
        "app_id": oneSignalAppID,
        "include_external_user_ids": [widget.task.userUid],
        "headings": {"en": userHomeNext(mStatus)},
        "contents": {"en": desc},
        "data": {
          "routeType": "em",
          "type": "em",
          "paymentType": "em",
          "reName": "em",
          "reNum": "em",
          "amount": "em",
          "status": mStatus,
        },
        "android_background_layout": {
          "image": imgUrlString,
          "headings_color": "ff000000",
          "contents_color": "ff0000FF"
        }
      };
    }
    await client.post(url, headers: headers, body: jsonEncode(body)).then((http.Response value) {
      showCenterToast(mStatus, _scaffoldKey.currentContext);
      setState(() {
        isLoading = false;
      });

      if (mStatus == "Mark Completed") {
        Navigator.pop(_scaffoldKey.currentContext);
        Navigator.pop(context);
        Navigator.push(
          _scaffoldKey.currentContext,
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => DisOrderCompletedPage(
              task: widget.task,
            ),
          ),
        );
      }
    }).catchError((a) {
      print(a.toString());
      showCenterToast("Error: " + a.toString(), _scaffoldKey.currentContext);
    });
  }

  void cancelOrder() {
    Task task = widget.task;
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

    Firestore _firestore = Firestore.instance;

    WriteBatch writeBatch = _firestore.batch();
    writeBatch.delete(_firestore
        .collection("Orders")
        .document("Pending") //delete for dispatcher
        .collection(task.disUid)
        .document(task.id));

    writeBatch.setData(
        _firestore
            .collection("Orders")
            .document("Cancelled") //set cancelled for dispatcher
            .collection(task.disUid)
            .document(task.id),
        widget.dataMap);

    writeBatch.updateData(
        _firestore
            .collection("Orders")
            .document("Pending") //   update customer
            .collection(task.userUid)
            .document(task.id),
        {
          "Dis Uid": null,
          "Dis Name": null,
          "Dis Number": null,
          "status": "Pending",
          "Accepted Date": "--",
          "assigned": false
        });

    writeBatch.setData(
        _firestore
            .collection("Utils")
            .document("Tasks") // create in pool again
            .collection("uid")
            .document(widget.task.id),
        {
          "Name": task.name,
          "startDate": task.startDate,
          "endDate": "--",
          "Amount": task.amount,
          "userUid": task.userUid,
          "userPhone": task.userPhone,
          "fromLat": task.fromLat,
          "fromLong": task.fromLong,
          "toLat": task.toLat,
          "toLong": task.toLong,
          "Payment Type": task.paymentType,
          "Timestamp": DateTime.now().millisecondsSinceEpoch,
          "Route Type": task.routeType,
          "Receiver Name": task.reName,
          "id": task.id,
          "Receiver Number": task.reNum,
          "status": "Pending",
          "Pickup Instru": task.pickInstr,
          "distance": task.distance,
          "Delivery Instru": task.deliInstru,
          "Weight": task.weight,
          "type": task.type,
          "Size": task.size,
          "fromAdd": task.from,
          "toAdd": task.to,
          "assigned": false
        });

    writeBatch.commit().then((value) {
      _sendCancelNotification();

      showCenterToast("Order Cancelled", context);

      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
          (Route<dynamic> route) => false);
    });
  }

  void _sendCancelNotification() async {
    String message =
        "Dispatcher cancelled  the task at ${widget.task.from} by ${widget.task.name ?? "no-name"}";
    final Map<String, Object> nData = Map();
    nData.putIfAbsent("Message", () => message);
    nData.putIfAbsent("Date", () => presentDateTime());
    nData.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    Firestore _firestore = Firestore.instance;

    WriteBatch writeBatch = _firestore.batch();
    writeBatch.setData(
        _firestore
            .collection("Utils")
            .document("Notification")
            .collection(MY_UID)
            .document(randomString()),
        nData);

    writeBatch.setData(
        _firestore
            .collection("Utils")
            .document("Notification")
            .collection(widget.task.userUid)
            .document(randomString()),
        nData);
    writeBatch.commit();

    const url = "https://onesignal.com/api/v1/notifications";
    const imgUrlString =
        "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8";
    var client = http.Client();

    const headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $oneSignalApiKey"
    };

    var body = {
      "app_id": oneSignalAppID,
      "include_external_user_ids": [widget.task.userUid],
      "headings": {"en": "Cancelled"},
      "contents": {"en": "Dispatcher has cancelled the order"},
      "data": {
        "routeType": "em",
        "type": "em",
        "paymentType": "em",
        "reName": "em",
        "reNum": "em",
        "amount": "em",
        "status": "Cancelled",
      },
      "android_background_layout": {
        "image": imgUrlString,
        "headings_color": "ff000000",
        "contents_color": "ff0000FF"
      }
    };
    await client
        .post(url, headers: headers, body: jsonEncode(body))
        .then((http.Response value) {})
        .catchError((a) {
      print(a.toString());
    });
  }
}
