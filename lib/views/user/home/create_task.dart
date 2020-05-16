import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/user/home/type_selector.dart';
import 'package:google_maps_webservice/places.dart';

class CreateTask extends StatefulWidget {
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  TextEditingController myLocationController =
      TextEditingController(text: "Current Location");
  TextEditingController theirController = TextEditingController();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey[200],
                hintColor: Styles.commonDarkBackground,
              ),
              child: TextField(
                readOnly: true,
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
                  displayPrediction(p, _scaffoldKey.currentState);
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
      bottomNavigationBar: CustomButton(
          title: "PROCEED",
          onPress: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => ModeSelector()));
          }),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onError(PlacesAutocompleteResponse response) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleMapKey);

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      scaffold.showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      );
    }
  }
}
