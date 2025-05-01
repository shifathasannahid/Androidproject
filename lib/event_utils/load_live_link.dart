import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class LoadLiveLink extends StatefulWidget {
  final String liveLinkUrl;
  final String eventName;
  const LoadLiveLink({Key? key, required this.liveLinkUrl, required this.eventName}) : super(key: key);

  @override
  State<LoadLiveLink> createState() => _LoadLiveLinkState();
}

class _LoadLiveLinkState extends State<LoadLiveLink> {

  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if(progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
            else{
              setState((){
                isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            Fluttertoast.showToast(msg: "Something went wrong...");
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.liveLinkUrl));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: Text(widget.eventName),
        centerTitle: false,
        actions: <Widget>[
          NavigationControls(webViewController: _controller),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }



}


class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }
}


//   final Completer<WebViewController> _controller = Completer<WebViewController>();
//   // CookieManager cookieManager = CookieManager();
//   //
//   // Future<void> _onListCookies(
//   //     WebViewController controller, BuildContext context) async {
//   //   final String cookies =
//   //   await controller.runJavascriptReturningResult('document.cookie').whenComplete((){
//   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //       content: Column(
//   //         mainAxisAlignment: MainAxisAlignment.end,
//   //         mainAxisSize: MainAxisSize.min,
//   //         children: const <Widget>[
//   //           Text('Cookies:'),
//   //         ],
//   //       ),
//   //     ));
//   //   });
//   //   _getCookieList(cookies);
//   //
//   // }
//
//   // Widget _getCookieList(String cookies) {
//   //   if (cookies == null || cookies == '""') {
//   //     return Container();
//   //   }
//   //   final List<String> cookieList = cookies.split(';');
//   //   final Iterable<Text> cookieWidgets =
//   //   cookieList.map((String cookie) => Text(cookie));
//   //   return Column(
//   //     mainAxisAlignment: MainAxisAlignment.end,
//   //     mainAxisSize: MainAxisSize.min,
//   //     children: cookieWidgets.toList(),
//   //   );
//   // }
//
//   // bool isLoading = true;
//
//   @override
//   void initState() {
//     // if (Platform.isAndroid) {
//     //   WebView.platform = SurfaceAndroidWebView();
//     // }
//     // _onListCookies(_controller, context)
//     super.initState();
//
//   }
//   // @override
//   // void dispose(){
//   //
//   //   super.dispose();
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.eventName),
//         centerTitle: false,
//         actions: [
//           NavigationControls(_controller.future),
//         ],
//       ),
//
//       body:Container(),
//       // isLoading? const Center(child: CircularProgressIndicator(),) :
//       // todo: edit
//       // WebView(
//       //   initialUrl: widget.liveLinkUrl,
//       //   javascriptMode: JavascriptMode.unrestricted,
//       //   onWebViewCreated: (WebViewController controller) {
//       //     _controller.complete(controller);
//       //   },
//       //   onWebResourceError: (WebResourceError webResourceError){
//       //     // Fluttertoast.showToast(msg: "Something went wrong");
//       //     // Fluttertoast.showToast(msg: webResourceError.description, toastLength: Toast.LENGTH_LONG);
//       //     Navigator.pop(context);
//       //     _launchURL();
//       //   },
//       //   gestureNavigationEnabled: true,
//       //   // onProgress: (int process){
//       //   //   if(process == 100) {
//       //   //     setState(() {
//       //   //       isLoading = false;
//       //   //     });
//       //   //   }
//       //   //   else{
//       //   //     setState((){
//       //   //       isLoading = true;
//       //   //     });
//       //   //   }
//       //   // },
//       //   // onPageFinished: (String string){
//       //   //   setState((){
//       //   //     isLoading = false;
//       //   //   });
//       //   // },
//       // ),
//     );
//   }
//   _launchURL() async {
//     if (await canLaunchUrl(Uri.parse(widget.liveLinkUrl))) {
//       await launchUrl(Uri.parse(widget.liveLinkUrl), mode: LaunchMode.externalApplication);
//     } else {
//       // throw 'Could not launch ${widget.liveLinkUrl}';
//       Fluttertoast.showToast(msg: "Something went wrong");
//       // Navigator.pop(context);
//     }
//   }
// }
//
//
//
// class NavigationControls extends StatelessWidget {
//   const NavigationControls(this._webViewControllerFuture, {Key? key})
//       : assert(_webViewControllerFuture != null),
//         super(key: key);
//
//   final Future<WebViewController> _webViewControllerFuture;
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<WebViewController>(
//       future: _webViewControllerFuture,
//       builder:
//           (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
//         final bool webViewReady =
//             snapshot.connectionState == ConnectionState.done;
//         final WebViewController? controller = snapshot.data;
//         return Row(
//           children: <Widget>[
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               onPressed: !webViewReady
//                   ? null
//                   : () async {
//                 if (await controller!.canGoBack()) {
//                   await controller.goBack();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('No back history item')),
//                   );
//                   return;
//                 }
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.arrow_forward_ios),
//               onPressed: !webViewReady
//                   ? null
//                   : () async {
//                 if (await controller!.canGoForward()) {
//                   await controller.goForward();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('No forward history item')),
//                   );
//                   return;
//                 }
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.replay),
//               onPressed: !webViewReady
//                   ? null
//                   : () {
//                 controller!.reload();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
