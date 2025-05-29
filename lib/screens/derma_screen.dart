import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DermaScreen extends StatefulWidget {
  static const String routeName = '/derma';
  const DermaScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const DermaScreen(),
    );
  }

  @override
  State<DermaScreen> createState() => _DermaScreenState();
}

class _DermaScreenState extends State<DermaScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    
    // Initialize the controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            try {
              if (url.contains('https://dev.toyyibpay.com/derma-masjid-halim-shah')) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  // Remove header
                  controller.runJavaScript(
                    "document.getElementsByTagName('header')[0].style.display='none'");
                  // Remove footer
                  controller.runJavaScript(
                    "document.getElementsByTagName('footer')[0].style.display='none'");
                });
              }
            } catch (e) {
              print(e);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://dev.toyyibpay.com/derma-masjid-halim-shah'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}