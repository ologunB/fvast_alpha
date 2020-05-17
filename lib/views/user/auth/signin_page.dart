import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/home/home_view.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_loading_button.dart';
import 'package:fvastalpha/views/partials/widgets/show_exception_alert_dialog.dart';
import 'package:fvastalpha/views/user/auth/signup_page.dart';
import 'package:fvastalpha/views/user/home/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool rememberMe = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgetPassController = TextEditingController();
  bool isLoading = false;
  bool forgotPassIsLoading = false;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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

    setState(() {
      _autoValidate = true;
    });

    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      FirebaseUser user = value.user;

      if (value.user != null) {
        if (!value.user.isEmailVerified) {
          setState(() {
            isLoading = false;
          });
          showCupertinoDialog(
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
              });
          _firebaseAuth.signOut();
          return;
        }
        Firestore.instance
            .collection('All')
            .document(user.uid)
            .get()
            .then((document) {
          String type = document.data["Type"];
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) {
                return type == "User" ? HomeView() : DispatchHomeView();
              },
            ),
          );

          putInDB(type, document.data["Uid"], document.data["Email"],
              document.data["Name"], document.data["Phone"]);
        }).catchError((e) {
          setState(() {
            isLoading = false;
          });
          showExceptionAlertDialog(
              context: context, exception: e, title: "Error");
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

  Future putInDB(
      String type, String uid, String email, String name, phone) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setBool("isLoggedIn", true);
      prefs.setString("uid", uid);
      prefs.setString("email", email);
      prefs.setString("name", name);
      prefs.setString("type", type);
      prefs.setString("phone", phone);
    });
  }

  Future resetEmail(String email, _setState) async {
    if (forgetPassController.text.isEmpty) {
      showEmptyToast("Email", context);
      return;
    }
    _setState(() {
      forgotPassIsLoading = true;
    });
    await _firebaseAuth
        .sendPasswordResetEmail(email: forgetPassController.text)
        .then((value) {
      _setState(() {
        forgotPassIsLoading = false;
      });
      forgetPassController.clear();
      Navigator.pop(context);
      showCupertinoDialog(
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
  void initState() {
    putInDB("Login", "", "", "", "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              Column(
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
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
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
                              color: Colors.grey[500],
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
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
                                  placeholderStyle:
                                      TextStyle(fontWeight: FontWeight.w300),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                                actions: <Widget>[
                                  Center(
                                    child: StatefulBuilder(
                                      builder: (context, _setState) =>
                                          CustomLoadingButton(
                                        title: forgotPassIsLoading
                                            ? ""
                                            : "Reset Password",
                                        onPress: forgotPassIsLoading
                                            ? null
                                            : () async {
                                                resetEmail(
                                                    forgetPassController.text,
                                                    _setState);
                                              },
                                        icon: forgotPassIsLoading
                                            ? CupertinoActivityIndicator(
                                                radius: 20)
                                            : Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                              ),
                                        iconLeft: false,
                                        hasColor:
                                            forgotPassIsLoading ? true : false,
                                        bgColor: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Styles.appPrimaryColor, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(children: <Widget>[
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
                                  signIn(emailController.text,
                                      passwordController.text, context);
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
                  ]),
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
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => SignupPage()));
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
    );
  }
}
