import 'package:e_masjid/animations/bottom_animation.dart';
import 'package:e_masjid/models/quran/ayat/ayat.dart';
import 'package:flutter/material.dart';

class SurahAyats extends StatelessWidget {
  final List<Ayat>? ayatsList;
  final String? surahName;
  final String? surahEnglishName;
  final String? englishMeaning;

  const SurahAyats(
      {Key? key,
      this.ayatsList,
      this.englishMeaning,
      this.surahEnglishName,
      this.surahName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leading: const BackButton(
                color: Colors.black54,
              ),
              backgroundColor: Colors.white,
              pinned: true,
              expandedHeight: height * 0.27,
              flexibleSpace: flexibleAppBar(context, height, width),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => line(height, index, width),
                  childCount: ayatsList!.length),
            )
          ],
        ));
  }

  Widget line(double height, int index, double width) {
    return Padding(
      padding: EdgeInsets.fromLTRB(width * 0.015, 0, 0, 0),
      child: WidgetAnimator(
        child: ListTile(
          trailing: CircleAvatar(
            radius: height * 0.013,
            backgroundColor: const Color(0xff04364f),
            child: CircleAvatar(
                radius: height * 0.012,
                backgroundColor: Colors.white,
                child: Text(
                  ayatsList![index].number.toString(),
                  style: TextStyle(fontSize: height * 0.015),
                )),
          ),
          title: Text(ayatsList![index].text!,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: height * 0.03, color: Colors.black)),
        ),
      ),
    );
  }

  Widget flexibleAppBar(BuildContext context, double width, double height) {
    return FlexibleSpaceBar(
        centerTitle: true,
        title: Text(surahEnglishName!,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: height * 0.045)),
        background: Stack(
          children: <Widget>[
            quranImageAppBar(height),
            infoInAppBar(context),
          ],
        ));
  }

  Widget infoInAppBar(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(englishMeaning!),
          Text(
            surahName!,
            style: Theme.of(context).textTheme.displayLarge,
          )
        ],
      ),
    );
  }

  Widget quranImageAppBar(double height) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Opacity(
          opacity: 0.3,
          child: Image.asset(
            'assets/images/quranRail.png',
            height: height * 0.4,
          )),
    );
  }
}
