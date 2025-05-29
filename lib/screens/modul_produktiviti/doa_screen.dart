import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DoaScreen extends StatefulWidget {
  static const String routeName = '/doa';
  const DoaScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const DoaScreen(),
    );
  }

  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
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
              if (url.contains('https://akuislam.com/blog/ibadah/doa-harian/')) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  //remove header
                  controller.runJavaScript(
                    "document.getElementsByTagName('header')[0].style.display='none'");
                  //remove footer
                  controller.runJavaScript(
                    "document.getElementsByTagName('footer')[0].style.display='none'");
                });
              }
            } catch (e) {
              print(e);
              const Text('error');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://akuislam.com/blog/ibadah/doa-harian/'));
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
              )),
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
      body: WebViewWidget(controller: controller),
    );
  }
}