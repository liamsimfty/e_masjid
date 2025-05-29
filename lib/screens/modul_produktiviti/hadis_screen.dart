import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
              if (url.contains('http://www.al-ahkam.net/home/bahan-ilmiah/hadis-40-imam-al-nawawi')) {
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
      ..loadRequest(Uri.parse('http://www.al-ahkam.net/home/bahan-ilmiah/hadis-40-imam-al-nawawi'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(right: 50.0, top: 15),
          child: Center(
            child: Image.asset(
              'assets/images/e_masjid.png',
              height: 50,
            )
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}