import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.provider.dart';

class DrawerAppName extends StatelessWidget {
  const DrawerAppName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUser>(context);
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 60.0),
          child: Image.asset('assets/images/e_masjid2.png', height: height * 0.17),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

          ],
        ),
      ],
    );
  }
}
