import 'package:flutter/material.dart';
import 'package:e_masjid/widgets/widgets.dart';

class SahPermohonanScreen extends StatefulWidget {
  static const String routeName = '/sah_permohonan';

  const SahPermohonanScreen({Key? key}) : super(key: key);

  static Route route(){
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const SahPermohonanScreen(),
    );
  }

  @override
  State<SahPermohonanScreen> createState() => _SahPermohonanScreenState();
}

class _SahPermohonanScreenState extends State<SahPermohonanScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Sah Permohonan'),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}