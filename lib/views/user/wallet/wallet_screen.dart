import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fvastalpha/models/wallet.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:fvastalpha/views/user/partials/layout_template.dart';
import 'package:fvastalpha/views/user/wallet/each_order_item.dart';
import 'package:rave_flutter/rave_flutter.dart';

class WalletView extends StatefulWidget {
  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  TextEditingController notifiMessage = TextEditingController();

  double mBalance = 0;
  int totalDeposit = 0;
  int totalWithdrawals = 0;
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("Utils")
                      .document("Wallet")
                      .collection(MY_UID)
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
                          totalDeposit = 0;
                          totalWithdrawals = 0;

                          snapshot.data.documents.map((document) {
                            EachTransaction item =
                                EachTransaction.map(document);

                            if (item.type == "Deposit") {
                              mBalance = mBalance + item.amount;
                              totalDeposit = totalDeposit + item.amount.floor();
                            } else {
                              mBalance = mBalance - item.amount;
                              totalWithdrawals =
                                  totalWithdrawals + item.amount.floor();
                            }
                          }).toList();
                          return Column(
                            children: <Widget>[
                              Text("Balance: ₦ " + commaFormat.format(mBalance),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CustomButton(
                                      title: "Deposit",
                                      onPress: () {
                                        deposit(context);
                                      }),
                                  CustomButton(
                                      title: "Withdrawal",
                                      onPress: () {
                                        showCenterToast(
                                            "Withdrawal option isn't available now",
                                            context);
                                      }),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  item("Total Deposit",
                                      commaFormat.format(totalDeposit)),
                                  SizedBox(width: 20),
                                  item("Total Withdrawal",
                                      commaFormat.format(totalWithdrawals))
                                ],
                              )
                            ],
                          );
                        } else {
                          return Column(
                            children: <Widget>[
                              Text("Balance: ₦ " + "0",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CustomButton(
                                      title: "Deposit",
                                      onPress: () {
                                        deposit(context);
                                      }),
                                  CustomButton(
                                      title: "Withdrawal",
                                      onPress: () {
                                        showCenterToast(
                                            "Withdrawal option isn't available now",
                                            context);
                                      }),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  item("Total Deposit", "0"),
                                  item("Total Withdrawal", "0")
                                ],
                              )
                            ],
                          );
                        }
                    }
                  },
                ),
              ),
              /*     Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomButton(
                      title: "Deposit",
                      onPress: () {
                        deposit(context);
                      }),
                  CustomButton(
                      title: "Withdrawal",
                      onPress: () {
                        showCenterToast(
                            "Withdrawal option isn't available now", context);
                      }),
                ],
              ),
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("Utils")
                      .document("Wallet")
                      .collection(MY_UID)
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
                          totalDeposit = 0;
                          totalWithdrawals = 0;
                          snapshot.data.documents.map((document) {
                            EachTransaction item =
                                EachTransaction.map(document);

                            if (item.type == "Deposit") {
                              totalDeposit = totalDeposit + item.amount.floor();
                            } else {
                              totalWithdrawals =
                                  totalWithdrawals + item.amount.floor();
                            }
                          }).toList();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              item("Total Deposit",
                                  commaFormat.format(totalDeposit)),
                              SizedBox(width: 20),
                              item("Total Withdrawal",
                                  commaFormat.format(totalWithdrawals))
                            ],
                          );
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              item("Total Deposit", "0"),
                              item("Total Withdrawal", "0")
                            ],
                          );
                        }
                    }
                  },
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Transactions",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
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
                                    fontSize: 20),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                          height: 300,
                          width: 300,
                        );
                      default:
                        return snapshot.data.documents.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "No transactions yet",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20),
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              )
                            : ListView(
                                children:
                                    snapshot.data.documents.map((document) {
                                  EachTransaction transaction =
                                      EachTransaction.map(document);
                                  return EachOrderItem(
                                    transaction: transaction,
                                  );
                                }).toList(),
                              );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  processCardTransaction(context) async {
    Navigator.pop(context);

    var initializer = RavePayInitializer(
        amount: totalAmount,
        publicKey: ravePublicKey,
        encryptionKey: raveEncryptKey)
      ..country = "NG"
      ..currency = "NGN"
      ..email = MY_EMAIL
      ..fName = MY_NAME
      ..lName = "lName"
      ..narration = "FVAST"
      ..txRef = "SCH${DateTime.now().millisecondsSinceEpoch}"
      ..acceptAccountPayments = false
      ..acceptCardPayments = true
      ..acceptAchPayments = false
      ..acceptGHMobileMoneyPayments = false
      ..acceptUgMobileMoneyPayments = false
      ..staging = false
      ..isPreAuth = true
      ..companyName = Text(
        "FVast Payment",
        style: TextStyle(fontSize: 14),
      )
      ..companyLogo = Image.asset("assets/images/logo.png")
      ..displayFee = true;

    RavePayManager()
        .prompt(context: context, initializer: initializer)
        .then((result) {
      if (result.status == RaveStatus.success) {
        doAfterSuccess(result.message);
      } else if (result.status == RaveStatus.cancelled) {
        if (mounted) {
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                "Closed!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: Styles.appPrimaryColor,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else if (result.status == RaveStatus.error) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                  "Error",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
                content: Text(
                  "An error has occured ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
      }

      print(result);
    });
  }

  TextEditingController depositAmount = TextEditingController();
  void deposit(context) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "How much do you want to add to wallet",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            content: CupertinoTextField(
              placeholder: "Amount",
              placeholderStyle:
                  TextStyle(fontWeight: FontWeight.w300, color: Colors.black38),
              padding: EdgeInsets.all(10),
              maxLines: 1,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20, color: Colors.black),
              controller: depositAmount,
            ),
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.red),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Styles.appPrimaryColor,
                    ),
                    child: FlatButton(
                      onPressed: () {
                        if (depositAmount.text.isEmpty) {
                          showCenterToast("Enter a number", context);
                          return;
                        } else if (double.tryParse(depositAmount.text) < 500) {
                          showCenterToast(
                              "You can't deposit less than ₦500", context);
                          return;
                        }
                        totalAmount = double.tryParse(depositAmount.text);
                        processCardTransaction(context);
                      },
                      child: Text(
                        "Proceed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  double totalAmount;
  bool depositIsLoading = false;
  void doAfterSuccess(String serverData) async {
    String orderID = "WAL" + DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      depositIsLoading = true;
    });

    final Map<String, Object> data = Map();
    data.putIfAbsent("Amount", () => totalAmount);
    data.putIfAbsent("uid", () => MY_UID);
    data.putIfAbsent("date", () => presentDateTime());
    data.putIfAbsent("id", () => orderID);
    data.putIfAbsent("type", () => "Deposit");
    data.putIfAbsent("Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Finishing processing",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: CupertinoActivityIndicator(radius: 20),
          );
        });

    Firestore.instance
        .collection("Utils")
        .document("Wallet")
        .collection(MY_UID)
        .document(orderID)
        .setData(data)
        .then((a) {
      Navigator.pop(context);

      showCenterToast("Deposit Made", context);
      // TODO add to balance
    });
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
}
