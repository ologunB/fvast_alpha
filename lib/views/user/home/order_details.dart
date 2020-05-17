import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  Widget _tabStep() => Container(
        margin: EdgeInsets.only(top: 10),
        child: Stepper(
          physics: ClampingScrollPhysics(),
          currentStep: 2,
          steps: [
            Step(
              title: Column(
                children: <Widget>[
                  Text(
                    "Yesteday, 12th May, 2020",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: Text(
                      "12, Koforidua Street, Wuse zone 2, Abuja.",
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
                    "Yesteday, 12th May, 2020",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: Text(
                      "12, Koforidua Street, Wuse zone 2, Abuja.",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              content: Text(" "),
            ),
            Step(
              title: Column(
                children: <Widget>[
                  Text(
                    "Yesteday, 12th May, 2020",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: Text(
                      "12, Koforidua Street, Wuse zone 2, Abuja.",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              content: Text(" "),
            ),
          ],
          controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
              Container(),
        ),
      );
  @override
  Widget build(BuildContext context) {
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
            child: Text("Task #0023"),
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
                    "Accepted",
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
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset("assets/images/person.png",
                                  height: 70, width: 70)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Audu Daniel",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text("efe"),
                                Text("efe"),
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
                              Text("Bike ", style: TextStyle(fontSize: 16))
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
                              Text("Cash", style: TextStyle(fontSize: 16))
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
                              Text("Richard Ray",
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
                              Text("08173893833",
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
                              Text("Medium/<2kg",
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
                              Text(" Loads ", style: TextStyle(fontSize: 16))
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
                              Text("Charge: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text("\₦ 678 ", style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Tax: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(" ₦ 678 ", style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Sub-total: ",
                                  style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(" ₦678 ", style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text("Total: ", style: TextStyle(fontSize: 16)),
                              Expanded(child: Divider(thickness: 2)),
                              Text(" ₦ 678 ", style: TextStyle(fontSize: 16))
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
