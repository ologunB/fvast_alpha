import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/models/task.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';

class OrderDetails extends StatefulWidget {
  final Task task;

  const OrderDetails({Key key, this.task}) : super(key: key);
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
                      widget.task.from,
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
                    widget.task.endDate ?? "--",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: Text(
                      widget.task.to,
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

  @override
  Widget build(BuildContext context) {
    int routeType = widget.task.routeType;

    int baseFare = routeTypes[routeType].baseFare;
    int distance = widget.task.distance;
    int tax = routeTypes[routeType].tax;
    int perKiloCharge = (routeTypes[routeType].perKilo * distance / 10).round();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blue[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.task.status,
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
                            imageUrl: widget.task.disImage ?? "--",
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
                              Text("Total: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(
                                  " \₦ " +
                                      commaFormat.format(widget.task.amount),
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
