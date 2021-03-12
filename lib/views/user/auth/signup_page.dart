import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/settings/privacy_policy.dart';
import 'package:fvastalpha/views/cou_service/settings/terms_conditions.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/show_exception_alert_dialog.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';
import 'package:loading_overlay/loading_overlay.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String selectedType;
  bool isDispatcher = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController streetController = TextEditingController(text: "");
  TextEditingController cityController = TextEditingController(text: "");
  TextEditingController plateNumberController = TextEditingController(text: "");

  bool isLoading = false;

  Future signUp() async {
    offKeyboard(context);

    if (selectedType == null) {
      showCenterToast("Choose a Type", context);
      return;
    }
    _formKey.currentState.save();
    _formKey.currentState.validate();
    if (!_formKey.currentState.validate()) {
      return;
    }
    String email = emailController.text;
    String password = passController.text;
    String name = nameController.text;
    String phone = phoneController.text;
    String street = streetController.text;
    String city = cityController.text;
    String plateNumber = plateNumberController.text;
    setState(() {
      isLoading = true;
    });
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      FirebaseUser user = value.user;

      if (value.user != null) {
        user.sendEmailVerification().then((v) {
          Map<String, Object> mData = Map();
          mData.putIfAbsent("Name", () => name);
          mData.putIfAbsent("Email", () => email);
          mData.putIfAbsent("Phone", () => phone);
          mData.putIfAbsent("Street", () => street);
          mData.putIfAbsent("City", () => city);
          mData.putIfAbsent("Plate Number", () => plateNumber);
          mData.putIfAbsent("Type", () => selectedType);
          mData.putIfAbsent("Uid", () => user.uid);
          mData.putIfAbsent("Avatar", () => "mm");
          mData.putIfAbsent("online", () => false);
          mData.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);

          Firestore.instance.collection("All").document(user.uid).setData(mData).then((val) {
            showCupertinoDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    content: Text(
                      "User created, Check email for verification. Thanks for using FVast",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50), color: Colors.red),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    CupertinoPageRoute(builder: (context) => SigninPage()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Text(
                                "  OK  ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                });

            setState(() {
              isLoading = false;
            });
          }).catchError((e) {
            showExceptionAlertDialog(context: context, exception: e, title: "Error");
            setState(() {
              isLoading = false;
            });
          });
        }).catchError((e) {
          showExceptionAlertDialog(context: context, exception: e, title: "Error");
          setState(() {
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }).catchError((e) {
      showExceptionAlertDialog(context: context, exception: e, title: "Error");
      setState(() {
        isLoading = false;
      });
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    //   SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Flexible(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70))),
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
                                  icon: Icon(Icons.arrow_back_ios, color: Styles.appPrimaryColor),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(builder: (context) => SigninPage()),
                                        (Route<dynamic> route) => false);
                                  }),
                              Expanded(
                                child: Text(
                                  "Sign up on FVAST",
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
                                  return 'Please enter your Name!';
                                }
                                return null;
                              },
                              controller: nameController,
                              decoration: InputDecoration(
                                  fillColor: Styles.commonDarkBackground,
                                  filled: true,
                                  suffixIcon: Icon(Icons.person),
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Name',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  )),
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
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
                              keyboardType: TextInputType.emailAddress,
                              validator: validateEmail,
                              controller: emailController,
                              decoration: InputDecoration(
                                fillColor: Styles.commonDarkBackground,
                                filled: true,
                                suffixIcon: Icon(Icons.email),
                                contentPadding: EdgeInsets.all(10),
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter your Number!';
                                }
                                return null;
                              },
                              controller: phoneController,
                              maxLength: 11,
                              decoration: InputDecoration(
                                fillColor: Styles.commonDarkBackground,
                                filled: true,
                                suffixIcon: Icon(Icons.contact_phone),
                                contentPadding: EdgeInsets.all(10),
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
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
                              obscureText: true,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your password!';
                                } else if (value.length < 6) {
                                  return 'Password must be greater than 6 characters!';
                                }
                                return null;
                              },
                              controller: passController,
                              decoration: InputDecoration(
                                fillColor: Styles.commonDarkBackground,
                                filled: true,
                                suffixIcon: Icon(Icons.lock),
                                contentPadding: EdgeInsets.all(10),
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isDispatcher,
                          child: AnimatedContainer(
                            duration: Duration(seconds: 4),
                            child: Column(
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
                                      maxLength: 10,
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
                                /*    Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Theme(
                                    data: ThemeData(
                                        primaryColor:
                                            Styles.commonDarkBackground,
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
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text("Sign up as "),
                          ),
                          value: selectedType,
                          underline: SizedBox(),
                          items: ["User", "Dispatcher"].map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                "Sign up as $value",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          isExpanded: true,
                          onChanged: (value) {
                            selectedType = value;
                            if (selectedType == "User") {
                              isDispatcher = false;
                            } else {
                              isDispatcher = true;
                            }
                            setState(() {});
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                signUp();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
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
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  //  alignment: Alignment.bottomLeft,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          CupertinoPageRoute(builder: (context) => SigninPage()),
                                          (Route<dynamic> route) => false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Own an Account? Login",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ]),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            //  mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: "By signing up you agree to our ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Terms of service',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Styles.appPrimaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              moveTo(context, TandCs());
                                            }),
                                      TextSpan(
                                        text: ' and ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey),
                                      ),
                                      TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Styles.appPrimaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              moveTo(context, PrivacyPo());
                                            }),
                                    ]),
                              )
                            ],
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
      ),
    );
  }
}
