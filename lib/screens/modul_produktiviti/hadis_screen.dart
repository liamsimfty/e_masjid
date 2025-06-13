import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:e_masjid/widgets/widgets.dart';

class HadisScreen extends StatefulWidget {
  static const String routeName = '/hadis';
  const HadisScreen({super.key});
  
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const HadisScreen(),
    );
  }
  
  @override
  State<HadisScreen> createState() => _HadisScreenState();
}

class _HadisScreenState extends State<HadisScreen> {
  late WebViewController controller;
  
  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            try {
              if (url.contains('https://rumaysho.com/25050-hadits-arbain-40-hidup-di-dunia-hanya-sebentar.html')) {
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
      ..loadRequest(Uri.parse('https://rumaysho.com/25050-hadits-arbain-40-hidup-di-dunia-hanya-sebentar.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Hadis 40'),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}