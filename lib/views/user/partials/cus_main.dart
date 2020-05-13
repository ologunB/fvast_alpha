import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/partials/widgets/drawerbehavior.dart';
import 'package:fvastalpha/views/user/home/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

DrawerScaffoldController scaffoldController = DrawerScaffoldController();

class CusMainPage extends StatefulWidget {
  @override
  _CusMainPageState createState() => _CusMainPageState();
}

class _CusMainPageState extends State<CusMainPage> {
  final menu = new Menu(
    items: [
      MenuItem(
        id: 'Home',
        title: 'Home',
        icon: IconData(0xe88a, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'My Garage',
        title: 'My Garage',
        icon: IconData(0xe531, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Nearby Services',
        title: 'Mechanic/Service Nearby',
        icon: IconData(0xe55e, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Shop',
        title: 'Shop',
        icon: IconData(0xeb3f, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Orders',
        title: 'Orders',
        icon: IconData(0xeb3f, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'My Jobs',
        title: 'My Jobs',
        icon: IconData(0xe7ee, fontFamily: 'MaterialIcons'),
      ),
    ],
  );

  var title = 'Home';
  var selectedMenuItemId = 'Home';
  Widget currentWidget = HomeView();
  final List<Widget> pages = [
    HomeView(),
    HomeView(),
    HomeView(),
    HomeView(),
    HomeView(),
  ];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

/*

  Future afterLogout() async {
    final SharedPreferences prefs = await _prefs;

    setState(() {
      prefs.setBool("isLoggedIn", false);
      prefs.remove("type");
      prefs.remove("uid");
      prefs.remove("email");
      prefs.remove("name");
      prefs.remove("phone");
    });
  }
*/

  Future<String> uid, email, name, type, phone;

  @override
  void initState() {
    super.initState();

    uid = _prefs.then((prefs) {
      return (prefs.getString('uid') ?? "customerUID");
    });
    email = _prefs.then((prefs) {
      return (prefs.getString('email') ?? "customerEmail");
    });
    name = _prefs.then((prefs) {
      return (prefs.getString('name') ?? "customerName");
    });
    type = _prefs.then((prefs) {
      return (prefs.getString('type') ?? "customerName");
    });
    phone = _prefs.then((prefs) {
      return (prefs.getString('phone') ?? "customerName");
    });
    doAssign();
  }

  void doAssign() async {
    MY_NAME = await name;
    MY_TYPE = await type;
    MY_EMAIL = await email;
    MY_NUMBER = await phone;
    MY_UID = await uid;
  }

  bool isSearchingShop = false;
  @override
  Widget build(BuildContext context) {
    Widget _footerView() {
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FutureBuilder<String>(
                  future: type,
                  builder: (context, snapshot) {
                    MY_TYPE = snapshot.data;

                    return Center(
                        /*child: Text(
                        "$userType : ",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),*/
                        );
                  }),
              FutureBuilder<String>(
                  future: uid,
                  builder: (context, snapshot) {
                    MY_UID = snapshot.data;

                    return Flexible(
                      child: Container(
                        padding: EdgeInsets.only(right: 13.0),
                        /*child: Text(
                          mUID,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),*/
                      ),
                    );
                  }),
            ],
          ),
          Divider(
            color: Colors.white.withAlpha(200),
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CustomDialog(
                      title: "Are you sure you want to log out?",
                      onClicked: () async {
                        Navigator.pop(context);
                        /*          Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) {
                              return LogOn();
                            },
                          ),
                        );*/
                      },
                      includeHeader: true,
                    ),
                  );
                },
              ),
              VerticalDivider(
                width: 5,
                thickness: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "v1.0.0",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            ],
          ),
        ],
      );
    }

    Widget _headerView() {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/person.png"),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder<String>(
                        future: name,
                        builder: (context, snapshot) {
                          MY_NAME = snapshot.data;

                          return Text(
                            MY_NAME,
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(color: Colors.white),
                          );
                        },
                      ),
                      FutureBuilder<String>(
                        future: email,
                        builder: (context, snapshot) {
                          MY_EMAIL = snapshot.data;

                          return Text(
                            MY_EMAIL,
                            style:
                                Theme.of(context).textTheme.subtitle.copyWith(
                                      color: Colors.white.withAlpha(200),
                                    ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.white.withAlpha(200),
            height: 16,
          )
        ],
      );
    }

    return WillPopScope(
        onWillPop: () async {
          showDialog(
              context: context,
              builder: (_) {
                return CustomDialog(
                  title: "Do you want to exit the app?",
                  includeHeader: true,
                  onClicked: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                );
              });
          return false;
        },
        child: DrawerScaffold(
          controller: scaffoldController,
          percentage: 0.7,
          contentShadow: [
            BoxShadow(
                color: Color(0x44000000),
                offset: Offset(0.0, 0.0),
                blurRadius: 50.0,
                spreadRadius: 5.0)
          ],
          cornerRadius: 50,
          //  appBar: AppBarProps(title: Text(title), elevation: 0.0),
          menuView: MenuView(
            menu: menu,
            selectorColor: Colors.blue,
            headerView: _headerView(),
            animation: false,
            color: Theme.of(context).primaryColor,
            selectedItemId: selectedMenuItemId,
            onMenuItemSelected: (String itemId) {
              selectedMenuItemId = itemId;
              if (itemId == "Home") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[0];
                });
              } else if (itemId == "My Garage") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[1];
                });
              } else if (itemId == "Nearby Services") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[2];
                });
              } else if (itemId == "Shop") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[3];
                });
              } else if (itemId == "Orders") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[4];
                });
              } else if (itemId == "My Jobs") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[5];
                });
              }
            },
            footerView: _footerView(),
          ),
          contentView: Screen(
            contentBuilder: (context) => currentWidget,
            color: Colors.white,
          ),
        ));
  }
}
