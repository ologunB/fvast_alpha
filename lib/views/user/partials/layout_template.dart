import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fvastalpha/views/cou_service/settings/settings.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/user/auth/convertwebview.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';
import 'package:fvastalpha/views/user/contact_us/contact_us.dart';
import 'package:fvastalpha/views/user/home/home_view.dart';
import 'package:fvastalpha/views/user/home/order_done.dart';
import 'package:fvastalpha/views/user/task_history/order_view.dart';
import 'package:fvastalpha/views/user/wallet/wallet_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LayoutTemplate extends StatefulWidget {
  @override
  _LayoutTemplateState createState() => _LayoutTemplateState();
}

final GlobalKey<ScaffoldState> cusMainScaffoldKey = GlobalKey<ScaffoldState>();

class _LayoutTemplateState extends State<LayoutTemplate> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future afterLogout() async {
    final SharedPreferences prefs = await _prefs;

    setState(() {
      prefs.setBool("isLoggedIn", false);
      prefs.setString("type", "Login");
      prefs.remove("uid");
      prefs.remove("email");
      prefs.remove("name");
      prefs.remove("phone");
      prefs.remove("image");
      prefs.remove("accept_td");
    });
  }

  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return HomeView();
      case 1:
        return OrdersView(from: "cus");
      case 2:
        return WalletView();
      case 3:
        return SettingsDisView(from: "cus");
      case 4:
        return ContactUsF();
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }

  Future<String> uid, name, phone, email, type, image, accept_td;

  @override
  void initState() {
    super.initState();

    uid = _prefs.then((prefs) {
      return (prefs.getString('uid') ?? "uid");
    });
    phone = _prefs.then((prefs) {
      return (prefs.getString('phone') ?? "phone");
    });
    email = _prefs.then((prefs) {
      return (prefs.getString('email') ?? "email");
    });
    name = _prefs.then((prefs) {
      return (prefs.getString('name') ?? "name");
    });
    type = _prefs.then((prefs) {
      return (prefs.getString('type') ?? "type");
    });
    image = _prefs.then((prefs) {
      return (prefs.getString('image') ?? "image");
    });
    accept_td = _prefs.then((prefs) {
      return (prefs.getString('accept_td') ?? "false");
    });
    assign();
    initPlatformState();
  }

  void assign() async {
    MY_UID = await uid;
    MY_EMAIL = await email;
    MY_TYPE = await type;
    MY_NUMBER = await phone;
    MY_NAME = await name;
    MY_IMAGE = await image;
    ACCEPT_T_D = await accept_td;

    if (ACCEPT_T_D == "false") {
    //  acceptTermsAndCondition();
    }
    setState(() {});
  }

  acceptTermsAndCondition() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Image.asset(
              "assets/images/logo.png",
              height: 70,
            ),
            content: SingleChildScrollView(
              child: Text(
                '''TERMS AND CONDITIONS\n
Welcome to fvast.com, this site is owned and managed by FVAST ENTERPRISE , a business duly registered with the corporate affairs commission in Nigeria, with registration number BN: 2956782
FVAST ENTERPRISE registered address is at No.9a Mogadishu Street Wuse zone 4, Abuja.
FVAST is a web based app for ordering logistics; it communicates logistics service requests to the logistics service providers who have been registered as users of the FVAST app.
FVAST makes it easy for customers who require logistics services in any part of Nigeria and beyond to be linked up to riders who are willing to render such services provided both parties are signed on to the FVAST app.
FVAST APP, grants both riders and customers a non-exclusive, revocable license to access the app and its associated services. The eligibility to qualify for the numerous benefits embedded therein is dependent on riders and customers agreement to its terms and conditions which is geared towards protecting its valued users. FVAST may only terminate use of the website and services if in breach of its terms and conditions and this won’t be without giving proper notifications, several warnings and fair hearing to the affected users.''',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () async {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text("NO")),
              FlatButton(
                  onPressed: () async {
                    Future<SharedPreferences> _prefs =
                        SharedPreferences.getInstance();

                    final SharedPreferences prefs = await _prefs;

                    prefs.setString("accept_td", "True");
                    Navigator.pop(context);
                  },
                  child: Text("YES")),
            ],
          );
        });
  }

  String _debugLabelString = "";

  bool _requireConsent = true;

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      setState(() {
        if (notification.appInFocus) {
          int routeType =
              jsonDecode(notification.payload.rawPayload["custom"])["a"]
                  ["routeType"];
          String type =
              jsonDecode(notification.payload.rawPayload["custom"])["a"]
                  ["type"];
          String paymentType =
              jsonDecode(notification.payload.rawPayload["custom"])["a"]
                  ["paymentType"];
          String reName =
              jsonDecode(notification.payload.rawPayload["custom"])["a"]
                  ["reName"];
          String reNum =
              jsonDecode(notification.payload.rawPayload["custom"])["a"]
                  ["reNum"];
          String status =
              jsonDecode(notification.payload.rawPayload["custom"])["a"]
                  ["status"];

          showCenterToast(status, context);
          double amount =
              jsonDecode(notification.payload.rawPayload["custom"])["a"]
                  ["amount"];

          if (status == "Mark Completed") {
            Navigator.push(
              context,
              CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) => OrderCompletedPage(
                    payment: paymentType,
                    type: type,
                    route: routeType,
                    receiversName: reName,
                    receiversNumber: reNum,
                    amount: amount,
                    from: "Customer"),
              ),
            );
          }
        } else {}
        _debugLabelString =
            "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
      setState(() {});
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {});

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
            "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {
      print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    await OneSignal.shared.init(oneOnlineSignalKey, iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared.consentGranted(true);
    OneSignal.shared.setLocationShared(true);
    _handleSetExternalUserId();
  }

  void _handleSetExternalUserId() {
    print("Setting external user ID");
    String _externalUserId = MY_UID;
    OneSignal.shared.setExternalUserId(_externalUserId).then((results) {
      if (results == null) return;

      this.setState(() {
        _debugLabelString = "External user id set: $results";
      });
    });
  }

  void _handleRemoveExternalUserId() {
    OneSignal.shared.removeExternalUserId().then((results) {
      if (results == null) return;

      this.setState(() {
        _debugLabelString = "External user id removed: $results";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: cusMainScaffoldKey,
        drawer: Drawer(
          elevation: 4,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: <Widget>[
                          FutureBuilder(
                              future: image,
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.done) {
                                  return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        child: CachedNetworkImage(
                                          imageUrl: snap.data ?? "ere",
                                          height: 60,
                                          width: 60,
                                          placeholder: (context, url) => Image(
                                              image: AssetImage(
                                                  "assets/images/person.png"),
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.contain),
                                          errorWidget: (context, url, error) =>
                                              Image(
                                                  image: AssetImage(
                                                      "assets/images/person.png"),
                                                  height: 60,
                                                  width: 60,
                                                  fit: BoxFit.contain),
                                        ),
                                      ));
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.asset(
                                          "assets/images/person.png",
                                          height: 50,
                                          width: 50)),
                                );
                              }),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FutureBuilder(
                                      future: name,
                                      builder: (context, snap) {
                                        if (snap.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snap.data,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          );
                                        }
                                        return Text(
                                          "Name",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        );
                                      }),
                                  FutureBuilder(
                                      future: phone,
                                      builder: (context, snap) {
                                        if (snap.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snap.data,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          );
                                        }
                                        return Text(
                                          "Phone",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _onSelectItem(0);
                      },
                      child: ListTile(
                        leading: Icon(EvaIcons.home),
                        title: Text(
                          "Home",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _onSelectItem(1);
                      },
                      child: ListTile(
                        leading: Icon(EvaIcons.briefcase),
                        title: Text(
                          "Tasks History",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _onSelectItem(2);
                      },
                      child: ListTile(
                        leading: Icon(EvaIcons.creditCard),
                        title: Text(
                          "Payment and Wallet",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _onSelectItem(3);
                      },
                      child: ListTile(
                        leading: Icon(EvaIcons.settings),
                        title: Text(
                          "Settings",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _onSelectItem(4);
                      },
                      child: ListTile(
                        leading: Icon(Icons.help),
                        title: Text(
                          "Help and Support",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                  title: "SignUp to Drive",
                  onPress: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                ConvertWebView() // ConvertFromUser()

                            ));
                  }),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.arrow_back, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => CustomDialog(
                      title: "Are you sure you want to log out?",
                      onClicked: () async {
                        FirebaseAuth.instance.signOut().then((a) {
                          afterLogout();
                          _handleRemoveExternalUserId();
                          Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => SigninPage()),
                              (Route<dynamic> route) => false);
                        });
                      },
                      includeHeader: true,
                    ),
                  );
                },
              )
            ],
          ),
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      ),
    );
  }
}
