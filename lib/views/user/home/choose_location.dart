import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/toast.dart';
import 'package:fvastalpha/views/user/home/type_selector.dart';
import 'package:geolocator/geolocator.dart';
import "package:google_maps_webservice/geocoding.dart";
import 'package:google_maps_webservice/places.dart';

class ChooseLocation extends StatefulWidget {
  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  TextEditingController myLocationController =
      TextEditingController(text: "Current Location");
  TextEditingController theirController = TextEditingController();

  var theAddress = "---";

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Position currentLocation;
  getUserLocation() async {
    try {
      currentLocation = await locateUser();

      fromLat = currentLocation.latitude;
      fromLong = currentLocation.longitude;
      List<Placemark> placeMark =
          await Geolocator().placemarkFromCoordinates(fromLat, fromLong);

      setState(() {
        theAddress = placeMark[0].name + ", " + placeMark[0].locality;
        myLocationController.text = theAddress;
      });
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(
              "Error getting Location",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("App might not function well"),
                Icon(Icons.error)
              ],
            ),
            actions: <Widget>[
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
                        Navigator.pop(context);
                      },
                      child: Text(
                        "OK",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey[200],
                hintColor: Styles.commonDarkBackground,
              ),
              child: TextField(
                onTap: () async {
                  Prediction p = await PlacesAutocomplete.show(
                      context: context,
                      language: "en",
                      onError: onError,
                      mode: Mode.overlay,
                      apiKey: kGoogleMapKey,
                      components: [Component(Component.country, "NG")]);

                  await _places.getDetailsByPlaceId(p.placeId).then((detail) {
                    fromLat = detail.result.geometry.location.lat;
                    fromLong = detail.result.geometry.location.lng;
                  }).then((a) {
                    myLocationController.text = p.description;
                  });
                },
                controller: myLocationController,
                decoration: InputDecoration(
                    fillColor: Styles.commonDarkBackground,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.location_searching,
                      color: Colors.blue,
                    ),
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 18,
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
          Container(
              height: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: VerticalDivider(
                  thickness: 5,
                  color: Styles.commonDarkBackground,
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey[200],
                hintColor: Styles.commonDarkBackground,
              ),
              child: TextField(
                readOnly: true,
                onTap: () async {
                  Prediction p = await PlacesAutocomplete.show(
                      context: context,
                      language: "en",
                      onError: onError,
                      mode: Mode.overlay,
                      apiKey: kGoogleMapKey,
                      components: [Component(Component.country, "NG")]);
                  await _places.getDetailsByPlaceId(p.placeId).then((detail) {
                    toLat = detail.result.geometry.location.lat;
                    toLong = detail.result.geometry.location.lng;
                  }).then((a) {
                    theirController.text = p.description;
                  });
                },
                controller: theirController,
                decoration: InputDecoration(
                    fillColor: Styles.commonDarkBackground,
                    filled: true,
                    hintText: "Choose Destination",
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 18,
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
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
            title: "PROCEED",
            onPress: () {
              if (fromLong == null) {
                Toast.show("Present Location is null", context,
                    gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                return;
              }
              if (toLat == null) {
                Toast.show("Select Destination", context,
                    gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                return;
              }
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ModeSelector(
                    fromLat: fromLat,
                    fromLong: fromLong,
                    toLat: toLat,
                    toLong: toLong,
                  ),
                ),
              );
            }),
      ),
    );
  }

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
    Toast.show(response.errorMessage, context,
        gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
  }

  double fromLat, fromLong, toLat, toLong;

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleMapKey);
}
