import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';

class CustomLoadingButton extends StatefulWidget {
  final String title;
  final void Function() onPress;
  bool isLoading;
  final BuildContext context;

  CustomLoadingButton(
      {Key key,
      @required this.title,
      @required this.onPress,
      @required this.isLoading,
      @required this.context})
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
              Padding(
                padding: EdgeInsets.all(5.0),
                child: widget.isLoading
                    ? CupertinoActivityIndicator()
                    : Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
