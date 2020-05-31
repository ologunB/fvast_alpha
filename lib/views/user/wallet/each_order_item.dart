import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/wallet.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';

class EachOrderItem extends StatefulWidget {
  final EachTransaction transaction;

  const EachOrderItem({Key key, @required this.transaction}) : super(key: key);

  @override
  _EachOrderItemState createState() => _EachOrderItemState();
}

class _EachOrderItemState extends State<EachOrderItem> {
  @override
  Widget build(BuildContext context) {
    Color color =
        widget.transaction.type == "Deposit" ? Colors.green : Colors.red;
    EachTransaction transaction = widget.transaction;

    return Container(
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
                    transaction.id,
                    style: TextStyle(
                        fontSize: 16,
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
              Text("₦ " + commaFormat.format(transaction.amount),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
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
                    Text(transaction.date,
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
                    transaction.type,
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
    );
  }
}
