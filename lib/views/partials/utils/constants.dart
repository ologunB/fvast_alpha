import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: non_constant_identifier_names
String MY_NAME, MY_UID, MY_TYPE, MY_NUMBER, MY_EMAIL, MY_IMAGE, ACCEPT_T_D;
// ignore: non_constant_identifier_names
bool IS_ONLINE = false;
Position currentLocation = Position(longitude: 7.3034138, latitude: 5.143012);
LatLng mapCenter = const LatLng(7.3034138, 5.143012);

showEmptyToast(String aa, BuildContext context) {
  Fluttertoast.showToast(
      msg: "$aa cannot be empty", gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);
  return;
}

showCenterToast(String a, BuildContext context) {
  Fluttertoast.showToast(msg: a, gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);
  return;
}

String validateEmail(value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Enter Valid Email';
  } else if (value.isEmpty) {
    return 'Please enter your email!';
  } else
    return null;
}

String kGoogleMapKey = "AIzaSyD4XcMQdkcBpG-nrLPwUK7kzywq-DtepzI";
String ravePublicKey = "FLWPUBK-873c5e9f20041fe3b9e5d3a3d49fb109-X";
String raveEncryptKey = "feb6bb192b8b5957f96823ee";
String oneSignalAppID = "e08b2257-9db2-4bd0-a9d7-b5674094ddda";
const String oneSignalApiKey = "YjJiYTkwYTctMzk0My00NjI4LTkwNTYtY2U5YTc5YzA1NzIy";

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

String timeAgo(DateTime d) {
  Duration diff = DateTime.now().difference(d);
  if (diff.inDays > 365)
    return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
  if (diff.inDays > 30)
    return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
  if (diff.inDays > 7)
    return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  if (diff.inDays > 0) return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
  if (diff.inHours > 0) return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  if (diff.inMinutes > 0)
    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  return "just now";
}

timeConvert(double d) {
  if (d < 1) return "1 hour";
  if (d > 120) return ">5 days";
  if (d > 96) return "4 days";
  if (d > 72) return ">3 days";
  if (d > 48) return ">2 days";
  if (d > 24) return ">1 day";
  if (d < 24) return "${d.ceil()} hours";
}

int toTens(num) {
  return (num / 10.0).round() * 10;
}

const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

String randomString() {
  Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < 12; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}

String presentDate() {
  return DateFormat("EEE MMM d").format(DateTime.now());
}

String presentDateTime() {
  return DateFormat("EEE MMM d, HH:mm").format(DateTime.now());
}

//  return DateFormat("EEE MMM d, yyyy HH:mm a").format(DateTime.now());

final commaFormat = new NumberFormat("#,##0", "en_US");

Future<String> uploadImage(File file) async {
  String url = "";
  if (file != null) {
    StorageReference reference = FirebaseStorage.instance.ref().child("images/${randomString()}");

    StorageUploadTask uploadTask = reference.putFile(file);
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    url = (await downloadUrl.ref.getDownloadURL());
  }
  return url;
}

class RouteModel {
  String type;
  IconData icon;
  String desc;
  int baseFare;
  int perKilo;

  RouteModel({
    this.type,
    this.icon,
    this.desc,
    this.baseFare,
    this.perKilo,
  });
}

List<RouteModel> routeTypes = [
  RouteModel(
    icon: Icons.directions_bike,
    type: "Bike",
    desc: "Easy Delivery and Small Packages",
    baseFare: 400,
    perKilo: 50,
  ),
  RouteModel(
    icon: Icons.directions_car,
    type: "Car",
    desc: "Fast Delivery for Medium Small Packages",
    baseFare: 700,
    perKilo: 50,
  ),
  RouteModel(
    icon: Icons.airport_shuttle,
    type: "Truck",
    desc: "Fast Delivery for Heavy Packages",
    baseFare: 9000,
    perKilo: 100,
  ),
/*  RouteModel(
    icon: Icons.motorcycle,
    type: "Tricycle",
    desc: "Fast Delivery for Heavy Packages",
    baseFare: 700,
    perKilo: 50,
  ),
  RouteModel(
    icon: Icons.airplanemode_active,
    type: "Jet",
    desc: "Fast Delivery for Heavy Packages",
    baseFare: 9000,
    perKilo: 200,
  ),*/
];

offKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
    return;
  }
  currentFocus.unfocus();
}
