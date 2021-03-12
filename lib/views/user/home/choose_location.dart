import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/user/home/type_selector.dart';
import 'package:geolocator/geolocator.dart';
import "package:google_maps_webservice/geocoding.dart";
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChooseLocation extends StatefulWidget {
  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  TextEditingController fromLocController = TextEditingController(text: "Current Location");

  var theAddress = "---";
  List<bool> locations;
  List<TextEditingController> toLocControllers;

  @override
  void initState() {
    locations = [true];
    toLocControllers = [TextEditingController()];

    super.initState();
    getUserLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Position currentLocation;

  getUserLocation() async {
    try {
      currentLocation = await locateUser();

      fromLat = currentLocation.latitude;
      fromLong = currentLocation.longitude;
      List<Placemark> placeMark = await placemarkFromCoordinates(fromLat, fromLong);

      setState(() {
        theAddress = placeMark[0].name + ", " + placeMark[0].locality;
        fromLocController.text = theAddress;
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
              children: <Widget>[Text("App might not function well"), Icon(Icons.error)],
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
                            fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
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
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Text(
              "From",
              style: TextStyle(color: Colors.blue),
            ),
          ),
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

                  if (p == null) {
                    return;
                  }

                  await _places.getDetailsByPlaceId(p.placeId).then((detail) {
                    fromLat = detail.result.geometry.location.lat;
                    fromLong = detail.result.geometry.location.lng;
                    fromLocController.text = p.description;
                  });
                },
                controller: fromLocController,
                decoration: InputDecoration(
                    fillColor: Styles.commonDarkBackground,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.location_searching,
                      color: Colors.blue,
                    ),
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: TextStyle(
                        color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.w400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          ListView.builder(
              itemCount: locations.length,
              shrinkWrap: true,
              //reverse: true,
              itemBuilder: (context, index) {
                return eachTaskWidget(index);
              }),
          locations.length > 1
              ? Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: Text(
                      "Arrange the Stops in Order of Nearness",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
            title: "PROCEED",
            onPress: () {
              print(locations);
              // return;
              if (fromLong == null) {
                Fluttertoast.showToast(
                    msg: "Present Location is null",
                    gravity: ToastGravity.CENTER,
                    toastLength: Toast.LENGTH_LONG);

                return;
              }
              if (toLats.isEmpty) {
                Fluttertoast.showToast(
                    msg: "Select Destination",
                    gravity: ToastGravity.CENTER,
                    toastLength: Toast.LENGTH_LONG);
                return;
              }
              if (toLats.length != toLocControllers.length) {
                Fluttertoast.showToast(
                    msg: "Some coordinates not gotten, wait!",
                    gravity: ToastGravity.CENTER,
                    toastLength: Toast.LENGTH_LONG);
                return;
              }
              List<String> texts = [];
              for (var i in toLocControllers) {
                texts.add(i.text);
              }

              print(toLongs);
              //  return;
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ModeSelector(
                    fromLat: fromLat,
                    fromLong: fromLong,
                    toLat: toLats,
                    toLong: toLongs,
                    from: fromLocController.text,
                    to: texts,
                  ),
                ),
              );
            }),
      ),
    );
  }

  void onError(PlacesAutocompleteResponse response) {
    Fluttertoast.showToast(
        msg: response.errorMessage, gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);
  }

  double fromLat, fromLong;
  List<double> toLats = [];
  List<double> toLongs = [];

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleMapKey);

  Widget eachTaskWidget(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: Text(
            locations.length == 1 ? "To" : "Stop ${index + 1}",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 10),
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

                      if (p == null) {
                        return;
                      }
                      await _places.getDetailsByPlaceId(p.placeId).then((detail) {
                        double lat = detail.result.geometry.location.lat;
                        double long = detail.result.geometry.location.lng;
                        toLats.insert(index, lat);
                        toLongs.insert(index, long);
                        toLocControllers[index].text = p.description;
                        // showCenterToast(toLats.toString(), context);
                        setState(() {});
                      });
                    },
                    controller: toLocControllers[index],
                    decoration: InputDecoration(
                        fillColor: Styles.commonDarkBackground,
                        filled: true,
                        hintText: index > 0 ? "Choose Stop" : "Choose a stop",
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                        contentPadding: EdgeInsets.all(10),
                        hintStyle: TextStyle(
                            color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    style:
                        TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
              )),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: GestureDetector(
                    onTap: () {
                      if (locations[index]) {
                        if (locations.length == 4) {
                          showCenterToast("You cannot choose more than 4 stops", context);
                          return;
                        }
                        if (toLocControllers[index].text.isEmpty) {
                          showCenterToast("Destination is empty", context);
                          return;
                        }
                        locations[index] = false;
                        print("index is " + locations[index].toString());
                        index = index + 1;
                        locations.insert(index, true);
                        toLocControllers.insert(index, TextEditingController());

                        print(locations.toString());
                      } else {
                        print(toLocControllers[index]);
                        if (locations.length == 1) {
                          showCenterToast("You must choose a stop", context);
                          return;
                        }
                        if (locations.length == 1) {
                          locations[0] = true;
                        }
                        print(locations.toString());

                        toLocControllers.removeAt(index);
                        locations.removeAt(index);
                        // noOfTasks = noOfTasks - 1;
                      }

                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        locations[index] ? Icons.add : Icons.clear,
                        color: Colors.white,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: locations[index] ? Colors.blue : Colors.red,
                      ),
                    )),
              )
            ],
          ),
        )
      ],
    );
  }
}

class Destination {
  bool isLast = true;
}
