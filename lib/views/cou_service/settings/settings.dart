import 'package:flutter/material.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:fvastalpha/views/cou_service/settings/privacy_policy.dart';
import 'package:fvastalpha/views/cou_service/settings/terms_conditions.dart';
import 'package:fvastalpha/views/cou_service/settings/update_bank.dart';
import 'package:fvastalpha/views/cou_service/settings/update_profile.dart';
import 'package:fvastalpha/views/partials/notification_page.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:fvastalpha/views/user/settings/update_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsDisView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final String from;

    SettingsDisView({Key key, this.from}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: IconButton(
                icon: Icon(
                  Icons.menu,
                  size: 30,
                ),
                onPressed: () {
                  from == "dis"
                      ? disMainScaffoldKey.currentState.openDrawer()
                      : cusMainScaffoldKey.currentState.openDrawer();
                }),
            title: Text(
              "Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.notifications), onPressed: () {
                moveTo(context, NotificationPage());
              }),
            ],
          ),
          body: Container(
            child: Column(
              children: [
                ListTile(
                  title: Text("Update Bank Details"),
                  trailing: Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () {
                    moveTo(context, UpdateBankView());
                  },
                ),
                ListTile(
                  title: Text("Update Profile"),
                  trailing: Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () {
                    moveTo(context, from == "cus" ? UpdateCusProfile():  UpdateProfile());
                  },
                ),
                ListTile(
                  title: Text("Terms and Conditions"),
                  trailing: Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () {
                    moveTo(context, TandCs());
                  },
                ),
                ListTile(
                  title: Text("Privacy Policy"),
                  trailing: Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () {
                    moveTo(context, PrivacyPo());
                  },
                ),
                ListTile(
                  title: Text("About Us"),
                  trailing: Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Image.asset(
                              "assets/images/logo.png",
                              height: 70,
                            ),
                            content: Text(
"FVAST is a web based app for ordering logistics; it communicates logistics service requests to the logistics service providers who have been registered as users of the FVAST app. FVAST makes it easy for customers who require logistics services in any part of Nigeria and beyond to be linked up to riders who are willing to render such services provided both parties are signed on to the FVAST app.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("CLOSE"))
                            ],
                          );
                        });
                  },
                ),
                ListTile(
                  title: Text("Share app"),
                  trailing: Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () async {
                    String _url =
                        "https://play.google.com/store/apps/details?id=com.ologunb.fvastalpha&hl=en";
                    if (await canLaunch(_url)) {
                      await launch(_url);
                    } else {
                      showCenterToast(" Could not launch $_url", context);
                      throw 'Could not launch $_url';
                    }
                  },
                ),
              ],
            ),
          )),
    );
  }
}
