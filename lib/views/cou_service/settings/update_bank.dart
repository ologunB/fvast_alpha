import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBankView extends StatefulWidget {
  @override
  _UpdateBankViewState createState() => _UpdateBankViewState();
}

class _UpdateBankViewState extends State<UpdateBankView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController bankName, accName, accNumber;
  bool isLoading = true;

  void getDetails() async {
    DocumentSnapshot doc =
        await Firestore.instance.collection('All').document(MY_UID).get();

    bankName = TextEditingController(text: doc.data["Bank Name"]);
    accName = TextEditingController(text: doc.data["Account Number"]);
    accNumber = TextEditingController(text: doc.data["Account Name"]);
    isLoading = false;

    setState(() {});
  }

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LoadingOverlay(
        isLoading: isLoading,
        child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                "Update Bank Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  Text(
                    "Bank Name",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Styles.appPrimaryColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Styles.commonDarkBackground,
                          hintColor: Styles.commonDarkBackground),
                      child: TextFormField(
                        controller: bankName,
                        decoration: InputDecoration(
                            fillColor: Styles.commonDarkBackground,
                            filled: true,
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Bank Name',
                            hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  Text(
                    "Account Number",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Styles.appPrimaryColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Styles.commonDarkBackground,
                          hintColor: Styles.commonDarkBackground),
                      child: TextFormField(
                        controller: accNumber,
                        decoration: InputDecoration(
                            fillColor: Styles.commonDarkBackground,
                            filled: true,
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Account Number',
                            hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  Text(
                    "Account Name",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Styles.appPrimaryColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Styles.commonDarkBackground,
                          hintColor: Styles.commonDarkBackground),
                      child: TextFormField(
                        controller: accName,
                        decoration: InputDecoration(
                            fillColor: Styles.commonDarkBackground,
                            filled: true,
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Account Name',
                            hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  CustomButton(
                    title: "Update",
                    onPress: () {
                      if (accName.text.trim().isEmpty ||
                          accNumber.text.trim().isEmpty ||
                          bankName.text.trim().isEmpty) {
                        showCenterToast("Fill all the empty Fields", context);
                        return;
                      }
                      isLoading = true;
                      setState(() {});
                      Map<String, Object> mData = Map();
                      mData.putIfAbsent("Account Name", () => accName.text);
                      mData.putIfAbsent("Account Number", () => accNumber.text);
                      mData.putIfAbsent("Bank Name", () => bankName.text);

                      Firestore.instance
                          .collection("All")
                          .document(MY_UID)
                          .updateData(mData)
                          .then((value) {
                        isLoading = false;
                        setState(() {});

                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                content: Text(
                                  "Bank Details Updated",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                ),
                                actions: <Widget>[
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.red),
                                        child: FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context);
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
                      });
                    },
                  )
                ],
              ),
            )),
      ),
    );
  }
}
