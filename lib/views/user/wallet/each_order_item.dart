import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EachOrderItem extends StatefulWidget {
  final Color color;
  final String type;

  const EachOrderItem({Key key, @required this.color, @required this.type})
      : super(key: key);

  @override
  _EachOrderItemState createState() => _EachOrderItemState();
}

class _EachOrderItemState extends State<EachOrderItem> {
  @override
  Widget build(BuildContext context) {
    Color color = widget.color;
    return InkWell(
      onTap: () {
        /*      Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => OrderDetails(
                      investment: widget.investment,
                      color: color,
                      type: widget.type,
                    )));*/
      },
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "j,b mkj",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ),
                Icon(
                  Icons.payment,
                  color: color,
                ),
                SizedBox(width: 10),
                Text("₦egve",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black))
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.label, color: color),
                SizedBox(width: 10),
                Text(widget.type == "Pending" ? "--" : "egref",
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w300,
                        color: Colors.black))
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.date_range, color: color),
                      SizedBox(width: 10),
                      Text("date",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              color: Colors.black))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300].withAlpha(111),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(5),
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      widget.type,
                      style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Divider(),
            )
          ],
        ),
      ),
    );
  }
}
