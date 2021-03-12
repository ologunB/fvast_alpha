import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
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

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: "https://fvast.com.ng",
      withJavascript: true,
      withZoom: true,
      allowFileURLs: true,
      appBar: AppBar(
          title: Text("Sign up as Driver", style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: true),
    );
  }
}
