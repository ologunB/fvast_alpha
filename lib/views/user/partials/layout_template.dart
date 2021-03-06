import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/settings/settings.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/user/auth/convertwebview.dart';
import 'package:fvastalpha/views/user/auth/signin_page.dart';
import 'package:fvastalpha/views/user/contact_us/contact_us.dart';
import 'package:fvastalpha/views/user/home/home_view.dart';
import 'package:fvastalpha/views/user/home/order_done.dart';
import 'package:fvastalpha/views/user/settings/update_profile.dart';
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

  Future<String> uid, name, phone, email, type, image;

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

    setState(() {});
  }

  bool _requireConsent = true;

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      setState(() {
        if (notification.appInFocus) {
          String status = notification.payload.additionalData["status"];
          var logger = Logger();
          logger.d(status);

          showCenterToast(status, context);
          int routeType = notification.payload.additionalData["routeType"];
          String type = notification.payload.additionalData["type"];
          String paymentType = notification.payload.additionalData["paymentType"];
          String reName = notification.payload.additionalData["reName"];
          String reNum = notification.payload.additionalData["reNum"];
          int amount = notification.payload.additionalData["amount"];

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

        } else {
          String status = notification.payload.additionalData["status"];

          int routeType = notification.payload.additionalData["routeType"];
          String type = notification.payload.additionalData["type"];
          String paymentType = notification.payload.additionalData["paymentType"];
          String reName = notification.payload.additionalData["reName"];
          String reNum = notification.payload.additionalData["reNum"];

          int amount = notification.payload.additionalData["amount"];

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
        }
      });
      setState(() {});
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      setState(() {
        if (result.notification.appInFocus) {
          String status = result.notification.payload.additionalData["status"];
          var logger = Logger();
          logger.d(status);

          showCenterToast(status, context);
          int routeType = result.notification.payload.additionalData["routeType"];
          String type = result.notification.payload.additionalData["type"];
          String paymentType = result.notification.payload.additionalData["paymentType"];
          String reName = result.notification.payload.additionalData["reName"];
          String reNum = result.notification.payload.additionalData["reNum"];

          int amount = result.notification.payload.additionalData["amount"];

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
        } else {
          String status = result.notification.payload.additionalData["status"];
          int routeType = result.notification.payload.additionalData["routeType"];
          String type = result.notification.payload.additionalData["type"];
          String paymentType = result.notification.payload.additionalData["paymentType"];
          String reName = result.notification.payload.additionalData["reName"];
          String reNum = result.notification.payload.additionalData["reNum"];
          int amount = result.notification.payload.additionalData["amount"];

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
        }
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

    await OneSignal.shared.init(oneSignalAppID, iOSSettings: settings);

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
                          GestureDetector(
                            onTap: () {
                              moveTo(context, UpdateCusProfile());
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
                            builder: (context) => ConvertWebView() // ConvertFromUser()

                            ));
                  }),
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
                          _handleRemoveExternalUserId();
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
