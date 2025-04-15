import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoadPrivacyPage extends StatefulWidget {
  const LoadPrivacyPage({Key? key,}) : super(key: key);

  @override
  State<LoadPrivacyPage> createState() => _LoadPrivacyPageState();
}

class _LoadPrivacyPageState extends State<LoadPrivacyPage> {

  final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(const Color(0x00000000))
  ..setNavigationDelegate(
  NavigationDelegate(
  onProgress: (int progress) {

  // Update loading bar.
  },
  onPageStarted: (String url) {},
  onPageFinished: (String url) {},
  onWebResourceError: (WebResourceError error) {},
  onNavigationRequest: (NavigationRequest request) {
  if (request.url.startsWith('https://www.youtube.com/')) {
  return NavigationDecision.prevent;
  }
  return NavigationDecision.navigate;
  },
  ),
  )
  ..loadRequest(Uri.parse('https://privacypolicy.eventqc.com/'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Terms & Privacy Policy\nEventQc",textAlign: TextAlign.center,),
          centerTitle: false,
        ),

        body: WebViewWidget(controller: controller),
    );
  }

  // final Completer<WebViewController> _controller = Completer<WebViewController>();
  //
  //
  // @override
  // void initState() {
  //   _launchURL();
  //   super.initState();
  //
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text("Terms & Privacy Policy\nEventQc",textAlign: TextAlign.center,),
  //       centerTitle: false,
  //       actions: [
  //         NavigationControls(_controller.future),
  //       ],
  //     ),
  //
  //     body:Container(),
  //     // isLoading? const Center(child: CircularProgressIndicator(),) :
  //     //TOdo: edit
  //     // WebView(
  //     //   initialUrl: "https://privacypolicy.eventqc.com/",
  //     //   javascriptMode: JavascriptMode.unrestricted,
  //     //   onWebViewCreated: (WebViewController controller) {
  //     //     _controller.complete(controller);
  //     //   },
  //     //   onWebResourceError: (WebResourceError webResourceError){
  //     //     Navigator.pop(context);
  //     //     _launchURL();
  //     //   },
  //     //   gestureNavigationEnabled: true,
  //     // ),
  //   );
  // }
  // _launchURL() async {
  //   if (await canLaunchUrl(Uri.parse("https://privacypolicy.eventqc.com/"))) {
  //     await launchUrl(Uri.parse("https://privacypolicy.eventqc.com/"), mode: LaunchMode.externalApplication);
  //   } else {
  //     // throw 'Could not launch ${widget.liveLinkUrl}';
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     // Navigator.pop(context);
  //   }
  // }
}

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
//             // IconButton(
//             //   icon: const Icon(Icons.arrow_back_ios),
//             //   onPressed: !webViewReady
//             //       ? null
//             //       : () async {
//             //     if (await controller!.canGoBack()) {
//             //       await controller.goBack();
//             //     } else {
//             //       ScaffoldMessenger.of(context).showSnackBar(
//             //         const SnackBar(content: Text('No back history item')),
//             //       );
//             //       return;
//             //     }
//             //   },
//             // ),
//             // IconButton(
//             //   icon: const Icon(Icons.arrow_forward_ios),
//             //   onPressed: !webViewReady
//             //       ? null
//             //       : () async {
//             //     if (await controller!.canGoForward()) {
//             //       await controller.goForward();
//             //     } else {
//             //       ScaffoldMessenger.of(context).showSnackBar(
//             //         const SnackBar(
//             //             content: Text('No forward history item')),
//             //       );
//             //       return;
//             //     }
//             //   },
//             // ),
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
