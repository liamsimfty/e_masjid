import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:e_masjid/widgets/widgets.dart';

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
      appBar: CustomAppBar(title: 'Doa Harian'),
      body: WebViewWidget(controller: controller),
    );
  }
}