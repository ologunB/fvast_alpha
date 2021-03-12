import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/show_exception_alert_dialog.dart';
import 'package:fvastalpha/views/user/auth/signup_page.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_overlay/loading_overlay.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController forgetPassController = TextEditingController();
  bool isLoading = false;
  TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;


  // bool forgotPassIsLoading = false;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    putInDB("Login", "", "", "", "", "", false);
    super.initState();
  }

  Future signIn(String email, String password, context) async {
    if (emailController.text.toString().isEmpty) {
      showEmptyToast("Email", context);
      return;
    } else if (passwordController.text.toString().isEmpty) {
      showEmptyToast("Password", context);
      return;
    }

    _formKey.currentState.save();
    _formKey.currentState.validate();

    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((value) {
      FirebaseUser user = value.user;

      if (value.user != null) {
        if (!value.user.isEmailVerified) {
          setState(() {
            isLoading = false;
          });
          showDialog(
              context: context,
              builder: (_) {
                return CupertinoAlertDialog(
                  title: Text(
                    "Email not verified!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  actions: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Styles.appPrimaryColor),
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
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
              });
          _firebaseAuth.signOut();
          return;
        }
        Firestore.instance.collection('All').document(user.uid).get().then((document) {
          MY_TYPE = document.data["Type"];

          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                  builder: (context) => MY_TYPE == "User" ? LayoutTemplate() : DisLayoutTemplate()),
              (Route<dynamic> route) => false);

          MY_UID = document.data["Uid"];
          MY_EMAIL = document.data["Email"];
          MY_NAME = document.data["Name"];
          MY_NUMBER = document.data["Phone"];
          MY_IMAGE = document.data["Avatar"];
          IS_ONLINE = document.data["online"];
          print(MY_NAME + MY_NUMBER);

          putInDB(
            MY_TYPE,
            MY_UID,
            MY_EMAIL,
            MY_NAME,
            MY_NUMBER,
            MY_IMAGE,
            IS_ONLINE ?? false,
          );
        }).catchError((e) {
          setState(() {
            isLoading = false;
          });
          showExceptionAlertDialog(context: context, exception: e, title: "Error");
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _firebaseAuth.signOut();
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

  Future putInDB(type, uid, email, name, phone, image, online) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setBool("isLoggedIn", true);
      prefs.setString("uid", uid);
      prefs.setString("email", email);
      prefs.setString("name", name);
      prefs.setString("type", type);
      prefs.setString("phone", phone);
      prefs.setString("image", image);
      prefs.setBool("online", online);
    });
  }

  Future resetEmail(String email) async {
    if (forgetPassController.text.isEmpty) {
      showCenterToast("Enter Email!", context);
      return;
    }
    Navigator.pop(context);
    setState(() {
      isLoading = true;
    });
    await _firebaseAuth.sendPasswordResetEmail(email: forgetPassController.text).then((value) {
      setState(() {
        isLoading = false;
      });
      forgetPassController.clear();
      showDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text(
                "Reset email sent!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            );
          });
    }).catchError((e) {
      showExceptionAlertDialog(context: context, title: "Error", exception: e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Form(
          key: _formKey,autovalidateMode: AutovalidateMode.always,
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: Image.asset(
                        "assets/images/loginimage.png",
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Welcome to FVAST!",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Styles.appPrimaryColor),
                          ),
                        ],
                        mainAxisSize: MainAxisSize.max,
                      ),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Theme(
                        data: ThemeData(
                            primaryColor: Styles.commonDarkBackground,
                            hintColor: Styles.commonDarkBackground),
                        child: TextFormField(
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
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                          style: TextStyle(
                              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                          controller: passwordController,
                          decoration: InputDecoration(
                            fillColor: Styles.commonDarkBackground,
                            filled: true,
                            suffixIcon: Icon(Icons.lock),
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          style: TextStyle(
                              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTap: () {
                              offKeyboard(context);

                              showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (_) => CupertinoAlertDialog(
                                  title: Column(
                                    children: <Widget>[
                                      Text("Enter Email"),
                                    ],
                                  ),
                                  content: CupertinoTextField(
                                    controller: forgetPassController,
                                    placeholder: "Email",
                                    padding: EdgeInsets.all(10),
                                    keyboardType: TextInputType.emailAddress,
                                    placeholderStyle: TextStyle(fontWeight: FontWeight.w300),
                                    style: TextStyle(fontSize: 20, color: Colors.black),
                                  ),
                                  actions: <Widget>[
                                    Center(
                                        child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: FlatButton(
                                          onPressed: () {
                                            resetEmail(forgetPassController.text);
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                  "Reset Password",
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
                                    )),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Styles.appPrimaryColor, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FlatButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  offKeyboard(context);
                                  signIn(emailController.text, passwordController.text, context);
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
                                        "SIGN IN",
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
                                  Navigator.push(context,
                                      CupertinoPageRoute(builder: (context) => SignupPage()));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "   Create an account   ",
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
                        ])
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
