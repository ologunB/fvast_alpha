import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/models/wallet.dart';
import 'package:fvastalpha/views/cou_service/partials/dis_layout_template.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/partials/widgets/custom_dialog.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisOrderCompletedPage extends StatefulWidget {
  final Task task;

  const DisOrderCompletedPage({Key key, this.task}) : super(key: key);

  @override
  _DisOrderCompletedPageState createState() => _DisOrderCompletedPageState();
}

class _DisOrderCompletedPageState extends State<DisOrderCompletedPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double mBalance = 0;
  String comments = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => DisLayoutTemplate()),
            (Route<dynamic> route) => false);

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
                  Container(
                    padding: EdgeInsets.all(20),
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
                              Text(routeTypes[widget.task.routeType].type,
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
                              Text(widget.task.paymentType,
                                  style: TextStyle(fontSize: 16))
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
                              Text(widget.task.reName,
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
                              Text(widget.task.reNum,
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
                              Text(widget.task.type,
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection("Utils")
                          .document("Wallet")
                          .collection(widget.task.userUid) // change to cus
                          .snapshots(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container(
                              alignment: Alignment.center,
                              child: CupertinoActivityIndicator(),
                              height: 100,
                              width: 100,
                            );
                          default:
                            if (snapshot.data.documents.isNotEmpty) {
                              mBalance = 0;

                              snapshot.data.documents.map((document) {
                                EachTransaction item = EachTransaction.map(document);
                                if (item.type == "Deposit") {
                                  mBalance = mBalance + item.amount;
                                } else if (item.type == "Withdrawal") {
                                  mBalance = mBalance - item.amount;
                                }
                              }).toList();

                              if (mBalance > widget.task.amount) {
                                comments = "Customer has paid with the Balance";
                              } else {
                                comments =
                                    "Customer has a balance of ${mBalance - widget.task.amount} to Balance";
                              }
                              return Column(
                                children: <Widget>[
                                  Text(
                                      "Balance: ₦ " +
                                          commaFormat.format(mBalance),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    "Comments: $comments",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              );
                            } else {
                              comments =
                                  "Customer has a balance of ${mBalance - widget.task.amount} to Balance";
                              return Column(
                                children: <Widget>[
                                  Text("Balance: ₦ 0",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ],
                              );
                            }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "₦ ${widget.task.amount}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: CustomButton(
                        title: "DONE",
                        onPress: () {
                          showDialog(
                              context: context,
                              builder: (_) => CustomDialog(
                                    title:
                                        "Are you sure you have completed the task and balanced out the debits and credits?",
                                    isLoading: isLoading,
                                    onClicked: () {
                                      Map<String, Object> disWalletData = Map();
                                      disWalletData.putIfAbsent(
                                          "Amount", () => widget.task.amount);
                                      disWalletData.putIfAbsent(
                                          "uid", () => MY_UID);
                                      disWalletData.putIfAbsent(
                                          "date", () => presentDateTime());
                                      disWalletData.putIfAbsent(
                                          "id", () => widget.task.id);
                                      disWalletData.putIfAbsent("type",
                                          () => widget.task.paymentType);
                                      disWalletData.putIfAbsent(
                                          "Timestamp",
                                          () => DateTime.now()
                                              .millisecondsSinceEpoch);

                                      setState(() {
                                        isLoading = true;
                                      });
                                      Firestore.instance
                                          .collection("Utils")
                                          .document(
                                              "Wallet") //create for dispatcher
                                          .collection(MY_UID)
                                          .document(widget.task.id)
                                          .setData(disWalletData)
                                          .then((value) {
                                        Firestore.instance
                                            .collection("Utils")
                                            .document(
                                                "Wallet") //create for dispatcher
                                            .collection(widget.task.userUid)
                                            .document(widget.task.id)
                                            .setData(disWalletData)
                                            .then((value) {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      DisLayoutTemplate()),
                                              (Route<dynamic> route) => false);
                                        });
                                      });
                                    },
                                  ));
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

  bool isLoading = false;
}
