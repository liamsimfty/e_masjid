import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      elevation: 0,
      title: Center(
            child: Text(title,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.white,
                    )),
          ),
      iconTheme: const IconThemeData(color: Colors.white),

    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(75.0);
}
