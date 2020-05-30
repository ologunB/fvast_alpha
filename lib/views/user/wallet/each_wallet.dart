import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:fvastalpha/views/user/wallet/each_order_item.dart';

class WalletView extends StatefulWidget {
  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  TextEditingController notifiMessage = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //  User user = widget.user;

    int totalConfirmed = 0;
    int totalCancelled = 0;
    int totalPending = 0;
    return SafeArea(
        child: Scaffold(
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
                    cusMainScaffoldKey.currentState.openDrawer();
                  }),
              title: Text(
                "Wallet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
              ],
            ),
            body: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      "assets/images/wallet.svg",
                      semanticsLabel: 'Acme Logo',
                      height: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Balance: #500",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomButton(title: "Deposit", onPress: () {}),
                        CustomButton(title: "Withdrawal", onPress: () {}),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection("Transactions")
                                .document("Confirmed")
                                .collection("fwfwf")
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
                                    totalConfirmed = 0;
                                    snapshot.data.documents
                                        .map((document) {})
                                        .toList();
                                  }
                                  return snapshot.data.documents.isEmpty
                                      ? Container(
                                          child: item("Total Deposit", "0"),
                                        )
                                      : Container(
                                          child: item(
                                              "Total Deposit",
                                              commaFormat
                                                  .format(totalConfirmed)));
                              }
                            },
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection("Transactions")
                                .document("Pending")
                                .collection("erfefr")
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
                                    totalPending = 0;
                                    snapshot.data.documents
                                        .map((document) {})
                                        .toList();
                                  }
                                  return snapshot.data.documents.isEmpty
                                      ? Container(
                                          child: item("Total Withdrawal", "0"))
                                      : Container(
                                          child: item(
                                              "Total Withdrawal",
                                              commaFormat
                                                  .format(totalPending)));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Transactions",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance
                            .collection("Utils")
                            .document("Wallet")
                            .collection(MY_UID)
                            .orderBy("Timestamp", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return new Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CupertinoActivityIndicator(),
                                    SizedBox(height: 30),
                                    Text(
                                      "Getting Data",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22),
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                                height: 300,
                                width: 300,
                              );
                            default:
                              return /*snapshot.data.documents.isEmpty
                                  ? Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          //  Image.asset("assets/images/confirmed.png"),
                                          // SizedBox(height: 30),
                                          Text(
                                            "No transactions yet",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 22),
                                          ),
                                          SizedBox(height: 30),
                                        ],
                                      ),
                                    )
                                  : */
                                  ListView(
                                children: /*snapshot.data.documents*/ [
                                  "",
                                  ""
                                ].map((document) {
                                  return EachOrderItem(
                                    color: Colors.blue,
                                    type: "greu",
                                  );
                                }).toList(),
                              );
                          }
                        },
                      ),
                    )
                  ],
                ))));
  }
}

Widget item(String type, String amount) => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          type,
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
        Text(
          "₦ $amount",
          style: TextStyle(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ],
    );
