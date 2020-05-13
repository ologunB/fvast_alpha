import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String selectedType;
  bool isDispatcher = false;
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.transparent, Styles.appPrimaryColor],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.darken,
                child: Image(
                  image: AssetImage("assets/images/mapbg.png"),
                  fit: BoxFit.fitHeight,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 60),
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    Flexible(
                        child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(70))),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Sign up on FVAST",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Styles.appPrimaryColor),
                                  ),
                                ],
                                mainAxisSize: MainAxisSize.max,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: Styles.commonDarkBackground,
                                    hintColor: Styles.commonDarkBackground),
                                child: TextField(
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
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      )),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: Styles.commonDarkBackground,
                                    hintColor: Styles.commonDarkBackground),
                                child: TextField(
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
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: Styles.commonDarkBackground,
                                    hintColor: Styles.commonDarkBackground),
                                child: TextField(
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
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: Styles.commonDarkBackground,
                                    hintColor: Styles.commonDarkBackground),
                                child: TextField(
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
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Theme(
                                        data: ThemeData(
                                            primaryColor:
                                                Styles.commonDarkBackground,
                                            hintColor:
                                                Styles.commonDarkBackground),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            fillColor:
                                                Styles.commonDarkBackground,
                                            filled: true,
                                            suffixIcon:
                                                Icon(Icons.center_focus_strong),
                                            contentPadding: EdgeInsets.all(10),
                                            hintText: 'Street Address',
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Theme(
                                        data: ThemeData(
                                            primaryColor:
                                                Styles.commonDarkBackground,
                                            hintColor:
                                                Styles.commonDarkBackground),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            fillColor:
                                                Styles.commonDarkBackground,
                                            filled: true,
                                            suffixIcon: Icon(Icons.location_on),
                                            contentPadding: EdgeInsets.all(10),
                                            hintText: 'City',
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Theme(
                                        data: ThemeData(
                                            primaryColor:
                                                Styles.commonDarkBackground,
                                            hintColor:
                                                Styles.commonDarkBackground),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            fillColor:
                                                Styles.commonDarkBackground,
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              hint: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text("Sign up as "),
                              ),
                              value: selectedType,
                              underline: SizedBox(),
                              items: ["User", "Dispatcher"].map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    "Sign up as $value",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: FlatButton(
                                  onPressed: () {},
                                  child: Text(
                                    "   SIGN UP   ",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
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
                                      CupertinoPageRoute(
                                          builder: (context) => SigninPage()),
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
                        ])
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 30),
                child: Container(
                  height: 50,
                  width: 55,
                  color: Colors.white,
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Styles.appPrimaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
