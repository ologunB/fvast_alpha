
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_loading_button.dart';
import 'package:fvastalpha/views/partials/widgets/show_exception_alert_dialog.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _PaymentMethodState createState() => _PaymentMethodState();
}

Widget text(String t) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        t,
        style: TextStyle(fontSize: 16, color: Styles.appPrimaryColor),
      ),
    );

class _PaymentMethodState extends State<ChangePasswordPage> {
  bool isLoading = false;
  TextEditingController oldPass = TextEditingController();
  TextEditingController new1Pass = TextEditingController();
  TextEditingController new2Pass = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool _autoValidate = false;

  Future _changePassword(String former, String password) async {
    setState(() {
      isLoading = true;
    });

    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    await _firebaseAuth
        .signInWithEmailAndPassword(email: MY_EMAIL, password: former)
        .then((user) {
      user.user.updatePassword(password).then((_) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                content: Text(
                  "Password successfully changed. Don't forget your password!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
        oldPass.clear();
        new1Pass.clear();
        new2Pass.clear();
        setState(() {
          isLoading = false;
          _autoValidate = false;
        });
        return true;
      }).catchError((e) {
        showExceptionAlertDialog(
            context: context, exception: e, title: "Error");
        setState(() {
          isLoading = false;
        });
        return true;
      });
    }).catchError((e) {
      showExceptionAlertDialog(context: context, exception: e, title: "Error");
      setState(() {
        isLoading = false;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Change Password",
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(children: [
          Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Container(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text("Old Password"),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter here"),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your password!';
                                } else if (value.length < 6) {
                                  return 'Password must be greater than 6 characters!';
                                }
                                return null;
                              },
                              controller: oldPass,
                            ),
                          ),
                          Divider(),
                          text("New Password"),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter here"),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your password!';
                                } else if (value.length < 6) {
                                  return 'Password must be greater than 6 characters!';
                                }
                                return null;
                              },
                              controller: new1Pass,
                            ),
                          ),
                          Divider(),
                          text("Confirm Password"),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter here"),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your password!';
                                } else if (value.length < 6) {
                                  return 'Password must be greater than 6 characters!';
                                }
                                return null;
                              },
                              controller: new2Pass,
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(blurRadius: 22, color: Colors.grey[300])
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CustomLoadingButton(
            title: isLoading ? "" : "Update",
            onPress: isLoading
                ? null
                : () async {
                    _formKey.currentState.save();
                    _formKey.currentState.validate();

                    setState(() {
                      _autoValidate = true;
                    });

                    if (_formKey.currentState.validate()) {
                      _changePassword(oldPass.text, new2Pass.text);
                    }
                  },
            isLoading: isLoading
               ,context: context,
           ),
        ),
      ),
    );
  }
}
