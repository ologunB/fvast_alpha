import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConvertFromUser extends StatefulWidget {
  @override
  _ConvertFromUserState createState() => _ConvertFromUserState();
}

class _ConvertFromUserState extends State<ConvertFromUser> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController streetController = TextEditingController(text: "");
  TextEditingController cityController = TextEditingController(text: "");
  TextEditingController plateNumberController = TextEditingController(text: "");

  bool isLoading = false;

  Future convert() async {
    _formKey.currentState.save();
    _formKey.currentState.validate();

    if (!_formKey.currentState.validate()) {
      return;
    }

    String street = streetController.text;
    String city = cityController.text;
    String plateNumber = plateNumberController.text;
    setState(() {
      isLoading = true;
    });

    var ts = DateTime.now().millisecondsSinceEpoch;

    Map<String, Object> mData = Map();
    mData.putIfAbsent("Name", () => MY_NAME);
    mData.putIfAbsent("Email", () => MY_EMAIL);
    mData.putIfAbsent("Phone", () => MY_NUMBER);
    mData.putIfAbsent("Street", () => street);
    mData.putIfAbsent("City", () => city);
    mData.putIfAbsent("Plate Number", () => plateNumber);
    mData.putIfAbsent("Type", () => "Dispatcher");
    mData.putIfAbsent("Uid", () => MY_UID);
    mData.putIfAbsent("Avatar", () => "mm");
    mData.putIfAbsent("Timestamp", () => ts);

    Firestore.instance
        .collection("All")
        .document(MY_UID)
        .updateData(mData)
        .then((val) async {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Text(
                "User converted. Proceed to accept orders",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.red),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => DisLayoutTemplate()),
                              (Route<dynamic> route) => false);
                        },
                        child: Text(
                          "  OK  ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          });

      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      await prefs.setString("type", "Dispatcher");
      MY_TYPE = "Dispatcher";

      setState(() {
        isLoading = false;
      });
    }).catchError((a) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,autovalidateMode: AutovalidateMode.always,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Flexible(
                  child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(70))),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                    color: Styles.appPrimaryColor),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            Expanded(
                              child: Text(
                                "Sign up as Dispatcher",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.appPrimaryColor),
                              ),
                            ),
                          ],
                          mainAxisSize: MainAxisSize.max,
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Theme(
                              data: ThemeData(
                                  primaryColor: Styles.commonDarkBackground,
                                  hintColor: Styles.commonDarkBackground),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter your Street Address!';
                                  }
                                  return null;
                                },
                                controller: streetController,
                                decoration: InputDecoration(
                                  fillColor: Styles.commonDarkBackground,
                                  filled: true,
                                  suffixIcon: Icon(Icons.center_focus_strong),
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Street Address',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Theme(
                              data: ThemeData(
                                  primaryColor: Styles.commonDarkBackground,
                                  hintColor: Styles.commonDarkBackground),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter your City!';
                                  }
                                  return null;
                                },
                                controller: cityController,
                                decoration: InputDecoration(
                                  fillColor: Styles.commonDarkBackground,
                                  filled: true,
                                  suffixIcon: Icon(Icons.center_focus_strong),
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'City',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Theme(
                              data: ThemeData(
                                  primaryColor: Styles.commonDarkBackground,
                                  hintColor: Styles.commonDarkBackground),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter your Plate number!';
                                  }
                                  return null;
                                },
                                controller: plateNumberController,
                                decoration: InputDecoration(
                                  fillColor: Styles.commonDarkBackground,
                                  filled: true,
                                  suffixIcon: Icon(Icons.confirmation_number),
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Plate Number',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Theme(
                              data: ThemeData(
                                  primaryColor: Styles.commonDarkBackground,
                                  hintColor: Styles.commonDarkBackground),
                              child: TextField(
                                decoration: InputDecoration(
                                  fillColor: Styles.commonDarkBackground,
                                  filled: true,
                                  suffixIcon: Icon(Icons.description),
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Anything Else',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Styles.appPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FlatButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    convert();
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: isLoading
                                      ? CupertinoActivityIndicator()
                                      : Text(
                                          "SIGN UP",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
