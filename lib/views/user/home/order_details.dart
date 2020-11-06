import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_view.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:http/http.dart' as http;

class OrderDetails extends StatefulWidget {
  final Task task;final Map dataMap;

  const OrderDetails({Key key, this.task, this.dataMap}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  Widget _tabStep() => Container(
        margin: EdgeInsets.only(top: 10),
        child: Stepper(
          physics: ClampingScrollPhysics(),
          currentStep: 1,
          steps: [
            Step(
              title: Column(
                children: <Widget>[
                  Text(
                    widget.task.startDate,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: Text(
                      widget.task.from + " - " + todo1(widget.task.status),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              content: Container(),
            ),
            Step(
              title: Column(
                children: <Widget>[
                  Text(
                    widget.task.acceptedDate ?? "--",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: Text(
                      widget.task.to + " - " + todo2(widget.task.status),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              content: SizedBox(),
            ),
          ],
          controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
              Container(),
        ),
      );
  double ratingNum = 2;

  @override
  Widget build(BuildContext context) {
    int routeType = widget.task.routeType;

    int baseFare = routeTypes[routeType].baseFare;
    int distance = widget.task.distance;
    int perKiloCharge = (routeTypes[routeType].perKilo * distance / 10).round();
    int tax = (0.07 * (baseFare + perKiloCharge)).floor();

    int total = baseFare + perKiloCharge + tax;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.task.id),
          ),
          actions: <Widget>[
            widget.task.status != "Completed"
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: widgetColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          userHomeNext(widget.task.status),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
          ],
          elevation: 0,
        ),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Dispatcher Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.task.disImage ?? "img",
                            height: 70,
                            width: 70,
                            placeholder: (context, url) => Image(
                                image: AssetImage("assets/images/person.png"),
                                height: 70,
                                width: 70,
                                fit: BoxFit.contain),
                            errorWidget: (context, url, error) => Image(
                                image: AssetImage("assets/images/person.png"),
                                height: 70,
                                width: 70,
                                fit: BoxFit.contain),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.task.disName ?? "--",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  widget.task.disNumber ?? "--",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  widget.task.plateNumber ?? "--",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                // Text( widget.task.disImage ?? "--"),
                              ],
                            ),
                          ),
                        ),
                        IconButton(icon: Icon(Icons.call), onPressed: () {})
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Stages",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: _tabStep()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Task Summary",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Route: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(routeTypes[routeType].type,
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Payment Type: ",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.task.paymentType ?? "r",
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Coupon: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(" -- ", style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Receiver's Name: ",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.task.reName ?? "r",
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Receiver's  Mobile",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.task.reNum ?? "r",
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Package Size/Weight",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.task.size ?? "r",
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Package Type ",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(widget.task.type ?? "r",
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Payment Summary",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Base Fare: ",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(" \₦ " + commaFormat.format((baseFare)),
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Distance charge: ",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(" \₦ " + commaFormat.format(perKiloCharge),
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Tax: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(" \₦ " + commaFormat.format(tax),
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Others: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(
                                  " \₦ " +
                                      commaFormat
                                          .format(widget.task.amount - total),
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Total: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(
                                  " \₦ " +
                                      commaFormat.format(widget.task.amount),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.task.status == "Completed"
                      ? CustomButton(
                          title: "Rate Dispatcher",
                          onPress: () {
                            reviewFromCustomer(context);
                          })
                      : SizedBox(),
                  widget.task.status != "Completed"
                      ? SizedBox()
                      : GestureDetector (
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => CustomDialog(
                                title: "Do you want to cancel the order?",
                                onClicked: () {
                                  cancelOrder();
                                },
                                includeHeader: true,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.red,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Cancel Order",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void reviewFromCustomer(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
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
                          primaryColor: Colors.grey[100],
                          hintColor: Styles.commonDarkBackground),
                      child: TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                            fillColor: Colors.grey[50],
                            filled: true,
                            hintText: "Type feedback",
                            contentPadding: EdgeInsets.all(10),
                            hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
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
                                Navigator.pop(context);
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

  void cancelOrder() {
    //  Navigator.pop(context);
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Almost Done",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: CupertinoActivityIndicator(radius: 20),
          );
        });
    Firestore.instance
        .collection("Orders")
        .document("Pending") //delete for dispatcher
        .collection(widget.task.disUid)
        .document(widget.task.id)
        .delete();
    Firestore.instance
        .collection("Orders")
        .document("Pending") //delete the customer
        .collection(widget.task.userUid)
        .document(widget.task.id)
        .delete();

    Firestore.instance
        .collection("Orders")
        .document("Cancelled") //delete for dispatcher
        .collection(widget.task.disUid)
        .document(widget.task.id)
        .setData(widget.dataMap);

    Firestore.instance
        .collection("Orders")
        .document("Cancelled") //delete the customer
        .collection(widget.task.userUid)
        .document(widget.task.id)
        .setData(widget.dataMap);
    _sendCancelNotification();

    showCenterToast("Order Cancelled", context);
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => LayoutTemplate()),
        (Route<dynamic> route) => false);
  }

  void _sendCancelNotification() async {
    const url = "https://onesignal.com/api/v1/notifications";
    const imgUrlString =
        "https://firebasestorage.googleapis.com/v0/b/fvast-d08d6.appspot.com/o/logo.png?alt=media&token=6b63a858-7625-4640-a79a-b0b0fd5c04a8";
    var client = http.Client();

    const headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic NDA4Mjc0MGUtMTMxYS00YjFlLTgwZTktMmRiYmVmYjRjZWFj"
    };

    var body = {
      "app_id": oneOnlineSignalKey,
      "include_external_user_ids": [widget.task.adminUid],
      "headings": {"en": "Cancelled"},
      "contents": {"en": "User has cancelled the order"},
      "data": {
        "routeType": "em",
        "type": "em",
        "paymentType": "em",
        "reName": "em",
        "reNum": "em",
        "amount": "em",
        "status": "Cancelled",
      },
      "android_background_layout": {
        "image": imgUrlString,
        "headings_color": "ff000000",
        "contents_color": "ff0000FF"
      }
    };
    await client
        .post(url, headers: headers, body: jsonEncode(body))
        .then((http.Response value) {})
        .catchError((a) {
      print(a.toString());
    });
  }
}
