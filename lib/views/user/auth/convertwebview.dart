import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class ConvertWebView extends StatefulWidget {
  @override
  ConvertWebViewState createState() => ConvertWebViewState();
}

class ConvertWebViewState extends State<ConvertWebView> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
  //  if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          title: Text("Sign up as Driver",style: TextStyle(fontWeight: FontWeight.w700)),centerTitle: true
      ),
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: 'https://fvast.com.ng',
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading ? Center( child: CircularProgressIndicator(),)
              : Stack(),
        ],
      ),
    );
  }
}