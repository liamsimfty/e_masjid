import 'package:e_masjid/models/quran/ayat/ayat.dart';
import 'package:e_masjid/providers/user.provider.dart';
import 'package:e_masjid/screens/landing-page.screen.dart';
import 'package:e_masjid/screens/splash_screen.dart';


import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'config/app_router.dart';
import 'config/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models/quran/juzz/juz.dart';
import 'models/quran/juzz/juz_list.dart';
import 'models/quran/sajda/sajda.dart';
import 'models/quran/sajda/sajda_list.dart';
import 'models/quran/surah/surah.dart';
import 'models/quran/surah/surah_list.dart';

Future<void> main() async {
  try {
    print('Initializing Flutter bindings...');
    WidgetsFlutterBinding.ensureInitialized();
    
    print('Initializing Firebase...');
    await Firebase.initializeApp();
    print('Firebase initialized successfully');

    print('Initializing Hive...');
    await Hive.initFlutter();
    print('Hive initialized successfully');

    print('Registering Hive adapters...');
    Hive.registerAdapter<Ayat>(AyatAdapter());
    Hive.registerAdapter<JuzList>(JuzListAdapter());
    Hive.registerAdapter<JuzAyahs>(JuzAyahsAdapter());
    Hive.registerAdapter<SajdaList>(SajdaListAdapter());
    Hive.registerAdapter<SajdaAyat>(SajdaAyatAdapter());
    Hive.registerAdapter<SurahsList>(SurahsListAdapter());
    Hive.registerAdapter<Surah>(SurahAdapter());
    print('Hive adapters registered successfully');

    print('Opening Hive box...');
    await Hive.openBox('data');
    print('Hive box opened successfully');

    print('Starting app...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');
    // You might want to show an error screen here instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  // DarkThemeProvider darkThemeProvider = DarkThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(480.0, 965.3333333333334),
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AppUser>(create: (_) => AppUser())
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'E-Masjid',
            theme: theme(),
            builder: EasyLoading.init(),
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/home': (context) => LandingScreen(),
              // '/': (context) => PetugasHomeScreen(maxSlide: MediaQuery.of(context).size.width * 0.835),

            },
          ),
        );
      },

    );
  }
}
