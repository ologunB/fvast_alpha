import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/taskpool/taskpool.dart';
import 'package:fvastalpha/views/cou_service/commission/commission.dart';
import 'package:fvastalpha/views/cou_service/home/dis_home_view.dart';
import 'package:fvastalpha/views/cou_service/home/new_order_form.dart';
import 'package:fvastalpha/views/cou_service/settings/settings.dart';
import 'package:fvastalpha/views/cou_service/settings/update_profile.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';
import 'package:fvastalpha/views/user/contact_us/contact_us.dart';
import 'package:fvastalpha/views/user/task_history/order_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisLayoutTemplate extends StatefulWidget {
  @override
  _DisLayoutTemplateState createState() => _DisLayoutTemplateState();
}

final GlobalKey<ScaffoldState> disMainScaffoldKey = GlobalKey<ScaffoldState>();

class _DisLayoutTemplateState extends State<DisLayoutTemplate> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future afterLogout() async {
    final SharedPreferences prefs = await _prefs;

    Firestore.instance.collection("All").document(MY_UID).updateData({"online": false});
    setState(() {
      prefs.setBool("isLoggedIn", false);
      prefs.setString("type", "Login");
      prefs.remove("uid");
      prefs.remove("email");
      prefs.remove("name");
      prefs.remove("phone");
      prefs.remove("image");
      prefs.remove("online");
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

      case 5:
        return TaskPoolPage();
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }

  Future uid, name, phone, email, type, image, online;

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.consentGranted(true);
    OneSignal.shared.requiresUserPrivacyConsent();
    OneSignal.shared.setRequiresUserPrivacyConsent(false);

    var settings = {OSiOSSettings.autoPrompt: true, OSiOSSettings.promptBeforeOpeningPushUrl: true};

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      String uid = notification.payload.additionalData["cus_uid"];

      String id = notification.payload.additionalData["trans_id"];

      String from = notification.payload.additionalData["from"];

      String fromTime = notification.payload.additionalData["fromTime"];

      List to = notification.payload.additionalData["to"];

      if (notification.appInFocus) {
        Future.delayed(Duration(milliseconds: 100)).then((a) {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => NewTaskRequest(
                      cusUid: uid, transId: id, from: from, fromTime: fromTime, to: to)));
        });
      }
      setState(() {});
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      showCenterToast(result.notification.payload.additionalData["trans_id"], context);

      String uid = result.notification.payload.additionalData["cus_uid"];

      String id = result.notification.payload.additionalData["trans_id"];

      String from = result.notification.payload.additionalData["from"];

      String fromTime = result.notification.payload.additionalData["fromTime"];

      List to = result.notification.payload.additionalData["to"];
      Future.delayed(Duration(milliseconds: 100)).then((a) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                NewTaskRequest(cusUid: uid, transId: id, from: from, fromTime: fromTime, to: to),
          ),
        );
      });
    });

    OneSignal.shared.setInAppMessageClickedHandler((OSInAppMessageAction action) {});

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges changes) {
      print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    OneSignal.shared.init(oneSignalAppID, iOSSettings: settings);

    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared.consentGranted(true);
    OneSignal.shared.setLocationShared(true);
    _handleSetExternalUserId();
  }

  void _handleSetExternalUserId() {
    print("Setting external user ID");
    String _externalUserId = MY_UID;
    OneSignal.shared.setExternalUserId(_externalUserId).then((results) {
      if (results == null) return;
    });
  }

  void _handleRemoveExternalUserId() {
    OneSignal.shared.removeExternalUserId().then((results) {
      if (results == null) return;
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
    online = _prefs.then((prefs) {
      return (prefs.getBool('online') ?? false);
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
    IS_ONLINE = await online;

    setState(() {});
  }

  addTags() {
    OneSignal.shared.sendTag("dispatcher", "online").then((response) async {
      print("Successfully sent tags with response: $response");

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("online", true);
      IS_ONLINE = true;
      Firestore.instance.collection("All").document(MY_UID).updateData({"online": true});

      showCenterToast("You are online", context);
    }).catchError((error) {
      print("Encountered an error sending tags: $error");
    });
  }

  removeTags() {
    OneSignal.shared.deleteTag("dispatcher").then((response) async {
      print("Successfully deleted tag with response: $response");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("online", false);
      IS_ONLINE = false;
      Firestore.instance.collection("All").document(MY_UID).updateData({"online": false});

      showCenterToast("You are offline", context);
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
                      color: IS_ONLINE ? Colors.blue[300] : Colors.red[200],
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              moveTo(context, UpdateProfile());
                            },
                            child: FutureBuilder(
                                future: image,
                                builder: (context, snap) {
                                  if (snap.connectionState == ConnectionState.done) {
                                    return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(30.0),
                                          child: CachedNetworkImage(
                                            imageUrl: snap.data ?? "ere",
                                            height: 60,
                                            width: 60,
                                            placeholder: (context, url) => Image(
                                                image: AssetImage("assets/images/person.png"),
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.contain),
                                            errorWidget: (context, url, error) => Image(
                                                image: AssetImage("assets/images/person.png"),
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
                                        child: Image.asset("assets/images/person.png",
                                            height: 50, width: 50)),
                                  );
                                }),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FutureBuilder(
                                      future: name,
                                      builder: (context, snap) {
                                        if (snap.connectionState == ConnectionState.done) {
                                          return Text(
                                            snap.data,
                                            style: TextStyle(
                                                fontSize: 18, fontWeight: FontWeight.w600),
                                          );
                                        }
                                        return Text(
                                          "Name",
                                          style:
                                              TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        );
                                      }),
                                  FutureBuilder(
                                      future: phone,
                                      builder: (context, snap) {
                                        if (snap.connectionState == ConnectionState.done) {
                                          return Text(
                                            snap.data,
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.w500),
                                          );
                                        }
                                        return Text(
                                          "Phone",
                                          style:
                                              TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ),
                          Switch(
                              value: IS_ONLINE,
                              onChanged: (a) {
                                if (a == true) {
                                  addTags();
                                } else {
                                  removeTags();
                                }
                                IS_ONLINE = a;
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
                        _onSelectItem(5);
                      },
                      child: ListTile(
                        leading: Icon(EvaIcons.activity),
                        title: Text(
                          "Task Pool",
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
                      Icon(Icons.logout, color: Colors.red),
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
                              CupertinoPageRoute(builder: (context) => SigninPage()),
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
