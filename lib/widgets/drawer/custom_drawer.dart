import 'package:e_masjid/screens/landing-page.screen.dart';
import '../../providers/user.provider.dart';
import 'drawer_app_name.dart';
import 'package:e_masjid/models/drawer_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final List<DrawerListItem> _items = [
    DrawerListItem(
      iconData: Icons.logout_rounded,
      title: 'Log Keluar',
      route: '/',
    ),

    // DrawerListItem(
    // iconData: Icons.format_list_bulleted,
    // title: 'Quran',
    // route: '/quran',
    // ),
    // DrawerListItem(
    //   iconData: Icons.format_list_numbered,
    //   title: 'Surah Index',
    //   route: '/surahIndex',
    // ),
    // DrawerListItem(
    //   iconData: Icons.format_align_left,
    //   title: 'Sajda Index',
    //   route: '/sajda',
    // ),
    // DrawerListItem(
    //   iconData: Icons.info,
    //   title: 'Help Guide',
    //   route: '/help',
    // ),
    // DrawerListItem(
    //   iconData: Icons.book,
    //   title: 'Introduction',
    //   route: '/introduction',
    // ),
    // DrawerListItem(
    //   iconData: Icons.share,
    //   title: 'Share App',
    //   route: '/shareApp',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUser>(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: width * 0.835,
      height: height,
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const DrawerAppName(),
              Column(
                children: _items
                    .map(
                      (tile) => GestureDetector(
                        child: Card(
                          color: Colors.white,
                          child: ListTile(
                              leading: Icon(tile.iconData),
                              title: Text(tile.title!),
                              onTap: () async {
                                Widget continueButton = TextButton(
                                  child: const Text("Ya"),
                                  onPressed: () async {
                                    await appUser.signOut();
                                    Navigator.pop(context);

                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => LandingScreen()));
                                  },
                                );
                                Widget cancelButton = TextButton(
                                  child: const Text("Tidak"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                );


                                // set up the AlertDialog
                                AlertDialog alert = AlertDialog(
                                  title: const Text("Log Keluar"),
                                  content: const Text("Anda pasti mahu log keluar?"),
                                  actions: [
                                    continueButton,
                                    cancelButton,
                                  ],
                                );

                                // show the dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );

                              }),
                        ),
                      ),
                    )
                    .toList(),
              ),
              // const AppVersion()
            ],
          ),
        ),
      ),
    );
  }
}
