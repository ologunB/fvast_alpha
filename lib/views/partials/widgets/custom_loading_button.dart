import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';

class CustomLoadingButton extends StatefulWidget {
  final String title;
  final Widget icon;
  final bool hasColor;
  final bool iconLeft;
  final Color bgColor;
  final void Function() onPress;
  final BuildContext context;

  CustomLoadingButton(
      {Key key,
      @required this.title,
      @required this.onPress,
      this.icon,
      this.bgColor,
      this.iconLeft = true,
      this.hasColor = false,
      this.context})
      : super(key: key);
  @override
  _CustomLoadingButtonState createState() => _CustomLoadingButtonState();
}

class _CustomLoadingButtonState extends State<CustomLoadingButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Styles.appPrimaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FlatButton(
          onPressed: () {
            widget.onPress();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              widget.iconLeft ? widget.icon : Text(""),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
              !widget.iconLeft ? widget.icon : Text(""),
            ],
          ),
        ),
      ),
    );
  }
}
