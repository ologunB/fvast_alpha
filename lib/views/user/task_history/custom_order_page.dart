import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/user/home/choose_location.dart';

import 'each_order_item.dart';

class CustomOrderPage extends StatefulWidget {
  final String type;
  final Color color;
  final String theUID;
  final String from;

  const CustomOrderPage({Key key, this.type, this.color, this.theUID, this.from}) : super(key: key);

  @override
  _ListViewNoteState createState() => _ListViewNoteState();
}

class _ListViewNoteState extends State<CustomOrderPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("Orders")
          .document(widget.type)
          .collection(MY_UID)
          .orderBy("Timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 30),
                  Text(
                    "Getting Data",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 22),
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
                              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 22),
                        ),
                        SizedBox(height: 30),
                        MY_TYPE == "Dispatcher"
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(20),
                                child: Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Styles.appPrimaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => ChooseLocation()));
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(
                                            Icons.add,
                                            size: 28,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Create Task",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  )
                : ListView(
                    children: snapshot.data.documents.map((document) {
                      return EachOrderItem(
                          task: Task.map(document),
                          color: widget.color,
                          type: widget.type,
                          map: document.data);
                    }).toList(),
                  );
        }
      },
    );
  }
}
