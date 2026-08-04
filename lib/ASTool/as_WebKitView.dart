import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'as_extension_help.dart';

class ASWebkitview extends StatefulWidget {
  final String url;
  final String title;

  const ASWebkitview({super.key, required this.url, required this.title});

  @override
  State<ASWebkitview> createState() => _ASWebkitviewState();
}

class _ASWebkitviewState extends State<ASWebkitview> {
  late final WebViewController _controller;
  final String TAG = "ASWebkitview";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            "$TAG intercept: $url".log();

            // if (navRedirect(url)) {
            //   urlJump(url);
            //   return NavigationDecision.prevent; // 拦截特殊 scheme，不加载
            // }

            return NavigationDecision.navigate; // 正常加载
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  urlJump(String url) async {
    "$TAG==_jumpNext=canJump:$url=".log();
    if (url.startsWith("intent://")) {
      try {
        // StepWinUtils().parse_android_intent(data: u);
        // Gs152webkit().openBrowser(url.toString());
      } catch (e) {
        //
      }
    } else {
      try {
        String u_go = url;
        if (u_go.startsWith("market://details?id=")) {
          u_go = u_go.replaceAll(
            "market://details",
            "https://play.google.com/store/apps/details",
          );
        }
        launchUrl(Uri.parse(u_go), mode: LaunchMode.externalApplication);
      } catch (e) {
        //
      }
    }
  }

  bool navRedirect(String uuuu) {
    if (uuuu.startsWith("market:") ||
        uuuu.startsWith("http://play.google.com/store/") ||
        uuuu.contains("lz_open_browser=1") ||
        uuuu.startsWith("https://play.google.com/store/") ||
        (uuuu.startsWith("intent://") && Platform.isAndroid) ||
        uuuu.endsWith(".apk")) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
