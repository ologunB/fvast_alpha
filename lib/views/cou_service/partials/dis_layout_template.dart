import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fvastalpha/views/cou_service/commission/commission.dart';
import 'package:fvastalpha/views/cou_service/home/dis_home_view.dart';
import 'package:fvastalpha/views/cou_service/home/new_order_form.dart';
import 'package:fvastalpha/views/cou_service/settings/settings.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';
import 'package:fvastalpha/views/user/contact_us/contact_us.dart';
import 'package:fvastalpha/views/user/task_history/order_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DisLayoutTemplate extends StatefulWidget {
  @override
  _DisLayoutTemplateState createState() => _DisLayoutTemplateState();
}

final GlobalKey<ScaffoldState> disMainScaffoldKey = GlobalKey<ScaffoldState>();

class _DisLayoutTemplateState extends State<DisLayoutTemplate> {
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
    });

    _handleRemoveExternalUserId();
    removeTags();
  }

  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return DispatchHomeView();
      case 1:
        return OrdersView(from: "dis");
      case 2:
        return CommissionView();
      case 3:
        return SettingsDisView(
          from: "dis",
        );
      case 4:
        return ContactUsF(from: "dis");
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }

  Future<String> uid, name, phone, email, type, image;
  bool isActive = false;

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
      String uid =
          jsonDecode(notification.payload.rawPayload["custom"])["a"]["cus_uid"];
      String id = jsonDecode(notification.payload.rawPayload["custom"])["a"]
          ["trans_id"];

      String from =
          jsonDecode(notification.payload.rawPayload["custom"])["a"]["from"];
      String fromTime =
          jsonDecode(notification.payload.rawPayload["custom"])["a"]
              ["fromTime"];
      String to =
          jsonDecode(notification.payload.rawPayload["custom"])["a"]["to"];
      setState(() {
        if (notification.appInFocus) {
          Future.delayed(Duration(milliseconds: 100)).then((a) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => NewTaskRequest(
                        cusUid: uid,
                        transId: id,
                        from: from,
                        fromTime: fromTime,
                        to: to)));
          });
        }
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      String uid =
          jsonDecode(result.notification.payload.rawPayload["custom"])["a"]
              ["cus_uid"];
      String id =
          jsonDecode(result.notification.payload.rawPayload["custom"])["a"]
              ["trans_id"];

      String from =
          jsonDecode(result.notification.payload.rawPayload["custom"])["a"]
              ["from"];
      String fromTime =
          jsonDecode(result.notification.payload.rawPayload["custom"])["a"]
              ["fromTime"];
      String to =
          jsonDecode(result.notification.payload.rawPayload["custom"])["a"]
              ["to"];
      Future.delayed(Duration(milliseconds: 100)).then((a) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => NewTaskRequest(
                    cusUid: uid,
                    transId: id,
                    from: from,
                    fromTime: fromTime,
                    to: to)));
      });
    });

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

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared.init(oneOnlineSignalKey, iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared.consentGranted(true);
    OneSignal.shared.setLocationShared(true);
    _handleSetExternalUserId();

    // Some examples of how to use In App Messaging public methods with OneSignal SDK
    // oneSignalInAppMessagingTriggerExamples();

    // Some examples of how to use Outcome Events public methods with OneSignal SDK
    //   oneSignalOutcomeEventsExamples();
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
  void initState() {
    super.initState();

    uid = _prefs.then((prefs) {
      return (prefs.getString('uid') ?? "uid");
    });
    phone = _prefs.then((prefs) {
      return (prefs.getString('phone') ?? "uid");
    });
    email = _prefs.then((prefs) {
      return (prefs.getString('email') ?? "uid");
    });
    name = _prefs.then((prefs) {
      return (prefs.getString('name') ?? "uid");
    });
    type = _prefs.then((prefs) {
      return (prefs.getString('type') ?? "uid");
    });
    image = _prefs.then((prefs) {
      return (prefs.getString('image') ?? "uid");
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

    if (ACCEPT_T_D == "false") {
   //   acceptTermsAndCondition();
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
                    SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop');
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
  addTags() {
    OneSignal.shared.sendTag("dispatcher", "online").then((response) {
      print("Successfully sent tags with response: $response");
      showCenterToast("You are online", context);
    }).catchError((error) {
      print("Encountered an error sending tags: $error");
    });
  }

  removeTags() {
    OneSignal.shared.deleteTag("dispatcher").then((response) {
      print("Successfully deleted tag with response: $response");
    }).catchError((error) {
      print("Encountered an error sending tags: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: disMainScaffoldKey,
        drawer: Drawer(
          elevation: 4,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: isActive ? Colors.blue[300] : Colors.red[200],
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
                          Switch(
                              value: isActive,
                              onChanged: (a) {
                                if (a == true) {
                                  addTags();
                                } else {
                                  removeTags();
                                }
                                isActive = a;
                                setState(() {});
                              })
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
                          "Task History",
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
                          "Earnings",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    /*           InkWell(
                      onTap: () {
                        _onSelectItem(3);
                      },
                      child: ListTile(
                        leading: Icon(EvaIcons.activity),
                        title: Text(
                          "Subscriptions/Commission",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),*/
                    InkWell(
                      onTap: () {
                        _onSelectItem(3);
                      },
                      child: ListTile(
                        leading: Icon(Icons.settings),
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
                        leading: Icon(Icons.live_help),
                        title: Text(
                          "Support",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
