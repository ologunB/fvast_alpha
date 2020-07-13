import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/widgets/toast.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
String MY_NAME, MY_UID, MY_TYPE, MY_NUMBER, MY_EMAIL, MY_IMAGE;
Position currentLocation;

showEmptyToast(String aa, BuildContext context) {
  Toast.show("$aa cannot be empty", context,
      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  return;
}

showCenterToast(String a, BuildContext context) {
  Toast.show(a, context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
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
String ravePublicKey = "FLWPUBK_TEST-4775239fc89f256ef2f24cddcebc17e1-X";
String raveEncryptKey = "FLWSECK_TEST079f656d190b";
String oneOnlineSignalKey = "c25d99bb-1ab2-462f-a7b3-827ac97c7563";

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
  if (diff.inDays > 0)
    return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
  if (diff.inHours > 0)
    return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  if (diff.inMinutes > 0)
    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  return "just now";
}

String timeConvert(double d) {
  if (d < 1) return "1 hour";
  if (d > 120) return ">5 days";
  if (d > 96) return "4 days";
  if (d > 72) return ">3 days";
  if (d > 48) return ">2 days";
  if (d > 24) return ">1 day";
  if (d < 24) return "${d.ceil()} hours";
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
    StorageReference reference =
        FirebaseStorage.instance.ref().child("images/${randomString()}");

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
    perKilo: 20,
  ),
  RouteModel(
    icon: Icons.directions_car,
    type: "Car",
    desc: "Fast Delivery for Medium Small Packages",
    baseFare: 400,
    perKilo: 20,
  ),
  RouteModel(
    icon: Icons.airport_shuttle,
    type: "Truck",
    desc: "Fast Delivery for Heavy Packages",
    baseFare: 400,
    perKilo: 20,
  ),
  RouteModel(
    icon: Icons.motorcycle,
    type: "Tricycle",
    desc: "Fast Delivery for Heavy Packages",
    baseFare: 400,
    perKilo: 20,
  ),
  RouteModel(
    icon: Icons.airplanemode_active,
    type: "Jet",
    desc: "Fast Delivery for Heavy Packages",
    baseFare: 400,
    perKilo: 20,
  ),
];
