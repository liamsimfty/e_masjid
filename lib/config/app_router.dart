import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart';

import '../screens/petugas/program_detail_screen.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    print('This is route: ${settings.name}');

    switch (settings.name) {
      //user
      case '/home':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case '/derma':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DermaScreen(),
        );
      case '/tanya-imam':
        return TanyaImamScreen.route();
      case SewaAulaScreen.routeName:
        return SewaAulaScreen.route();
      case TempahQurbanScreen.routeName:
        return TempahQurbanScreen.route();
      case SemakStatusScreen.routeName:
        return SemakStatusScreen.route();
      case HadisScreen.routeName:
        return HadisScreen.route();
      case DoaScreen.routeName:
        return DoaScreen.route();
      case SurahIndex.routeName:
        return SurahIndex.route();
      case PetugasHomeScreen.routeName:
        return PetugasHomeScreen.route();
      case ProgramScreen.routeName:
        return ProgramScreen.route();
      case ProgramDetail.routeName:
        return ProgramDetail.route(data: settings.arguments as Map<String, dynamic>);
        //admin
      case SahPermohonanScreen.routeName:
        return SahPermohonanScreen.route();


      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (_) => Scaffold(
          appBar: AppBar(
        title: const Text('Error'),
      )),
    );
  }
}
