import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class OrderCompletedPage extends StatefulWidget {
  final payment, receiversName, receiversNumber, type, amount, route, from;

  const OrderCompletedPage(
      {Key key,
      this.payment,
      this.receiversName,
      this.receiversNumber,
      this.type,
      this.amount,
      this.route,
      this.from})
      : super(key: key);

  @override
  _OrderCompletedPageState createState() => _OrderCompletedPageState();
}

class _OrderCompletedPageState extends State<OrderCompletedPage> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 20)).then((a) {
      Navigator.pop(context);
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double ratingNum = 0;
  String feedback = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.from == "Customer") {
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => LayoutTemplate()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
              (Route<dynamic> route) => false);
        }
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: ListView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    "TASK COMPLETED",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: SvgPicture.asset(
                      "assets/images/complete.svg",
                      semanticsLabel: 'Acme Logo',
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "₦ ${commaFormat.format(widget.amount)}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Route: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(routeTypes[widget.route].type, style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Payment Type: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.payment, style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Receiver's Name: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.receiversName, style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Receiver's  Mobile", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.receiversNumber, style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Package Type ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.type, style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: CustomButton(
                        title: "DONE",
                        onPress: () {
                          if (widget.from == "Customer") {
                            reviewFromCustomer(context);
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
                                (Route<dynamic> route) => false);
                          }
                        }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void reviewFromCustomer(context) {
    _scaffoldKey.currentState.showBottomSheet(
        (context) => StatefulBuilder(
              builder: (context, _setState) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 8,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Styles.appPrimaryColor,
                              borderRadius: BorderRadius.circular(5)),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Please select some stars and give some feedback based on the task",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, _setState) => SmoothStarRating(
                        allowHalfRating: true,
                        onRatingChanged: (val) {
                          _setState(() {
                            ratingNum = val;
                          });
                        },
                        starCount: 5,
                        rating: ratingNum,
                        size: 50.0,
                        filledIconData: Icons.star,
                        halfFilledIconData: Icons.star_half,
                        color: Styles.appPrimaryColor,
                        borderColor: Styles.appPrimaryColor,
                        spacing: 0.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Colors.grey[100], hintColor: Styles.commonDarkBackground),
                      child: TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                            fillColor: Colors.grey[50],
                            filled: true,
                            hintText: "Type feedback",
                            contentPadding: EdgeInsets.all(10),
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        onChanged: (a) {
                          feedback = a;
                        },
                        style: TextStyle(
                            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "CANCEL",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Styles.appPrimaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                Map<String, Object> mData = Map();
                                mData.putIfAbsent("Star Rating", () => ratingNum);
                                mData.putIfAbsent("Feedback", () => feedback);

                                /*           Firestore.instance
                                    .collection("Orders")
                                    .document("Completed") //create for dispatcher
                                    .collection(MY_UID)
                                    .document(widget.transId)
                                    .setData(mData);
                                */
                                if (widget.from == "Customer") {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoPageRoute(builder: (context) => LayoutTemplate()),
                                      (Route<dynamic> route) => false);
                                } else {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
                                      (Route<dynamic> route) => false);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "RATE",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20)
                ],
              ),
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        elevation: 20,
        backgroundColor: Colors.grey[200]);
  }
}
