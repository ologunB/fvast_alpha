import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/toast.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsF extends StatefulWidget {
  final String from;

  const ContactUsF({Key key, this.from}) : super(key: key);

  @override
  _ContactUsFState createState() => _ContactUsFState();
}

class _ContactUsFState extends State<ContactUsF> {
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Styles.appPrimaryColor,
      child: Container(
        color: Colors.grey[100],
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: 30,
                        ),
                        onPressed: () {
                          widget.from == "dis"
                              ? disMainScaffoldKey.currentState.openDrawer()
                              : cusMainScaffoldKey.currentState.openDrawer();
                        }),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        "Help",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    )),
                    IconButton(
                        icon: Icon(Icons.notifications), onPressed: () {}),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Write your Message",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: CupertinoTextField(
                    placeholder: "Type something here...",
                    placeholderStyle: TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.black38),
                    padding: EdgeInsets.all(10),
                    maxLines: 10,
                    onChanged: (e) {
                      setState(() {});
                    },
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    controller: _messageController,
                  ),
                ),
              ),
              CustomButton(
                title: "   SEND   ",
                onPress: () async {
                  if (_messageController.text.toString().isEmpty) {
                    return showEmptyToast("Message", context);
                  }
                  String _messageTitle = "Messsage To FVAST";
                  String _messageBody = _messageController.text.toString();
                  String _url =
                      "mailto:fvastsupp0rt@gmail.com?subject=$_messageTitle&body=$_messageBody%20";

                  if (await canLaunch(_url)) {
                    await launch(_url);
                  } else {
                    Toast.show(" Could not launch $_url", context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                    throw 'Could not launch $_url';
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: InkWell(
                      child: Image(
                        image: AssetImage("assets/images/instagram.png"),
                        height: 40,
                        width: 40,
                      ),
                      onTap: () async {
                        String _url1 =
                            "http://instagram.com/_u/officialfabatmngt";
                        String _url2 = "http://instagram.com/officialfabatmngt";

                        if (await canLaunch(_url1)) {
                          await launch(_url1);
                        } else {
                          await launch(_url2);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: InkWell(
                      child: Image(
                        image: AssetImage("assets/images/facebook.png"),
                        height: 40,
                        width: 40,
                      ),
                      onTap: () async {
                        String _url1 = "fb://profile/100039244757529";
                        String _url2 = "https://www.facebook.com/fabat.mngt.1";

                        if (await canLaunch(_url1)) {
                          await launch(_url1);
                        } else {
                          await launch(_url2);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: InkWell(
                      child: Image(
                        image: AssetImage("assets/images/twitter.png"),
                        height: 40,
                        width: 40,
                      ),
                      onTap: () async {
                        String _url1 =
                            "twitter://user?screen_name=fabatmanagement";
                        String _url2 =
                            "https://twitter.com/fabatmanagement?s=09";

                        if (await canLaunch(_url1)) {
                          await launch(_url1);
                        } else {
                          await launch(_url2);
                        }
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Divider(
                  color: Colors.black.withAlpha(200),
                  height: 16,
                ),
              ),
              Text(
                "Reach Us Through",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
