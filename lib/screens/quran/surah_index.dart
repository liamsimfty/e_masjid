import 'package:e_masjid/animations/bottom_animation.dart';
import 'package:e_masjid/services/quran_controller.dart';
import 'package:e_masjid/widgets/quran/back_btn.dart';
import 'package:e_masjid/widgets/quran/custom_image.dart';
import 'package:e_masjid/widgets/loading_shimmer.dart';
import 'package:e_masjid/widgets/quran/title.dart';
import 'package:e_masjid/models/quran/surah/surah.dart';
import 'package:e_masjid/models/quran/surah/surah_list.dart';
import 'package:e_masjid/screens/quran/surah.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class SurahIndex extends StatefulWidget {
  const SurahIndex({super.key});

  static const String routeName = '/quran';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const SurahIndex(),
    );
  }
  @override
  State<SurahIndex> createState() => _SurahIndexState();
}

class _SurahIndexState extends State<SurahIndex> {
  final _hiveBox = Hive.box('data');
  List<Surah>? _surahs = [];

  @override
  void initState() {
    _getSurahData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              _surahs!.isEmpty
                  ? const Center(
                child: LoadingShimmer(
                  text: "Surahs",
                ),
              )
                  : Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.22,
                ),
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Color(0xffee8f8b),
                      height: 2.0,
                    );
                  },
                  itemCount: _surahs!.length,
                  itemBuilder: (context, index) {
                    return WidgetAnimator(
                      child: ListTile(
                        onLongPress: () => _surahInforBox(index),
                        leading: Text(
                          "${_surahs![index].number}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        title: Text(
                          "${_surahs![index].englishName}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle:
                        Text("${_surahs![index].englishNameTranslation}"),
                        trailing: Text(
                          "${_surahs![index].name}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahAyats(
                                ayatsList: _surahs![index].ayahs,
                                surahName: _surahs![index].name,
                                surahEnglishName: _surahs![index].englishName,
                                englishMeaning:
                                _surahs![index].englishNameTranslation,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              CustomImage(
                opacity: 0.3,
                height: height * 0.17,
                imagePath: 'assets/images/logo.png',
              ),
              const BackBtn(),
              const CustomTitle(
                title: "Surah Index",
              ),
              // themeChange.darkTheme
              //     ? Flare(
              //   color: const Color(0xfff9e9b8),
              //   offset: Offset(width, -height),
              //   bottom: -50,
              //   flareDuration: const Duration(seconds: 17),
              //   left: 100,
              //   height: 60,
              //   width: 60,
              // )
                   Container(),
              // themeChange.darkTheme
              //     ? Flare(
              //   color: const Color(0xfff9e9b8),
              //   offset: Offset(width, -height),
              //   bottom: -50,
              //   flareDuration: const Duration(seconds: 12),
              //   left: 10,
              //   height: 25,
              //   width: 25,
              // )
              //     : Container(),
              // themeChange.darkTheme
              //     ? Flare(
              //   color: const Color(0xfff9e9b8),
              //   offset: Offset(width, -height),
              //   bottom: -40,
              //   left: -100,
              //   flareDuration: const Duration(seconds: 18),
              //   height: 50,
              //   width: 50,
              // )
              //     :
              Container(),

              // themeChange.darkTheme
              //     ? Flare(
              //   color: const Color(0xfff9e9b8),
              //   offset: Offset(width, -height),
              //   bottom: -50,
              //   left: -80,
              //   flareDuration: const Duration(seconds: 15),
              //   height: 50,
              //   width: 50,
              // )
              //     :
                  Container(),
              // themeChange.darkTheme
              //     ? Flare(
              //   color: const Color(0xfff9e9b8),
              //   offset: Offset(width, -height),
              //   bottom: -20,
              //   left: -120,
              //   flareDuration: const Duration(seconds: 12),
              //   height: 40,
              //   width: 40,
              // )
              //     :
              Container(),
            ],
          ),
        ));
  }

  void _surahInforBox(int index) {
    showDialog(
      context: context,
      builder: (context) => SurahInformation(
        surahNumber: _surahs![index].number,
        arabicName: "${_surahs![index].name}",
        englishName: "${_surahs![index].englishName}",
        ayahs: _surahs![index].ayahs!.length,
        revelationType: "${_surahs![index].revelationType}",
        englishNameTranslation: "${_surahs![index].englishNameTranslation}",
      ),
    );
  }

  // getting data
  Future<void> _getSurahData() async {
    SurahsList? cacheSurahList = await _hiveBox.get('surahList');
    if (cacheSurahList == null || cacheSurahList.surahs!.isEmpty) {
      SurahsList newSurahsList = await QuranAPI.getSurahList();
      if (mounted) {
        setState(() {
          _surahs = newSurahsList.surahs;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _surahs = cacheSurahList.surahs;
        });
      }
    }
  }
}

class SurahInformation extends StatefulWidget {
  final int? surahNumber;
  final String? arabicName;
  final String? englishName;
  final String? englishNameTranslation;
  final int? ayahs;
  final String? revelationType;

  const SurahInformation(
      {super.key,
        this.arabicName,
        this.surahNumber,
        this.ayahs,
        this.englishName,
        this.englishNameTranslation,
        this.revelationType});

  @override
  _SurahInformationState createState() => _SurahInformationState();
}

class _SurahInformationState extends State<SurahInformation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return ScaleTransition(
      scale: scaleAnimation,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            width: width * 0.75,
            height: height * 0.37,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Surah Information",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.englishName!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      widget.arabicName!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Text("Ayahs: ${widget.ayahs}"),
                Text("Surah Number: ${widget.surahNumber}"),
                Text("Chapter: ${widget.revelationType}"),
                Text("Meaning: ${widget.englishNameTranslation}"),
                SizedBox(
                  height: height * 0.02,
                ),
                SizedBox(
                  height: height * 0.05,
                  child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK")),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
