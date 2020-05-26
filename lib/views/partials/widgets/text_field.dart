import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';

class CustomTextField extends StatefulWidget {
  TextEditingController controller;
  String text;
  TextInputType inputType;
  CustomTextField({this.inputType, this.controller, this.text});
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          primaryColor: Styles.commonDarkBackground,
          hintColor: Styles.commonDarkBackground),
      child: TextField(
        controller: widget.controller,
        onTap: () {},
        keyboardType: widget.inputType,
        decoration: InputDecoration(
            fillColor: Styles.commonDarkBackground,
            filled: true,
            contentPadding: EdgeInsets.all(10),
            hintText: widget.text,
            hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            )),
        style: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
      ),
    );
  }
}
