import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inAppWebView;
import 'package:webview_flutter/webview_flutter.dart';

class IFramePlayerPage extends StatefulWidget {
  final String? url;
  IFramePlayerPage({this.url});

  @override
  _IFramePlayerPageState createState() => _IFramePlayerPageState();
}

class _IFramePlayerPageState extends State<IFramePlayerPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  var playerResponse;
  GlobalKey sc = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("iFrame Video URL :-> ${widget.url}");
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
      return JavascriptChannel(
          name: 'Toaster',
          onMessageReceived: (JavascriptMessage message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message.message),
              ),
            );
          });
    }

    return Scaffold(
      key: sc,
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          child: (widget.url?.substring(0, 24) == 'https://drive.google.com')
              ? inAppWebView.InAppWebView(
                  initialUrlRequest: inAppWebView.URLRequest(
                    url: Uri.parse(widget.url!),
                  ),
                )
              : WebView(
                  initialUrl: Uri.dataFromString(
                    '''
                      <html>
                      <body style="width:100%;height:100%;display:block;background:black;">
                      <iframe width="100%" height="100%"
                      style="width:100%;height:100%;display:block;background:black;"
                      src="${widget.url}"
                      frameborder="0"
                      allow="accelerometer; autoplay; encrypted-media; gyroscope;"
                       allowfullscreen="allowfullscreen"
                        mozallowfullscreen="mozallowfullscreen"
                        msallowfullscreen="msallowfullscreen"
                        oallowfullscreen="oallowfullscreen"
                        webkitallowfullscreen="webkitallowfullscreen"
                       >
                      </iframe>
                      </body>
                      </html>
                    ''',
                    mimeType: 'text/html',
                    encoding: Encoding.getByName('utf-8'),
                  ).toString(),
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                  },
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                ),
        ),
      ),
    );
  }
}
