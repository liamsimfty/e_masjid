import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    super.key,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {




  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey,
            blurRadius: 20,
          ),
        ],
      ),
      child: BottomAppBar(
        notchMargin: 6.0,
        shape: const CircularNotchedRectangle(),
        color: kWhiteColor,
        elevation: 1,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //icon for home
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(
                        Icons.home,
                        color:  Colors.teal,
                      ),
                      onPressed: () {
                        if (ModalRoute.of(context)?.settings.name == '/home') {
                          DoNothingAction;
                        } else {
                          Navigator.pushNamedAndRemoveUntil(context, '/home',
                              (_) => false);
                        }
                      }),
                  const Text('Home',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.0,
                          color: Colors.black45)),
                ],
              ),

              //icon for program
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color:  Colors.lightBlueAccent,
                      ),
                      onPressed: () {
                        if (ModalRoute.of(context)?.settings.name == '/program') {
                          DoNothingAction;
                        } else {
                          Navigator.pushNamed(context, '/program');
                        }
                      }),
                  const Text('Program',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.0,
                          color: Colors.black45)),
                ],
              ),

              //icon for derma
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(
                        Icons.monetization_on,
                        color:  Colors.yellow,
                      ),
                      onPressed: () {
                        if (ModalRoute.of(context)?.settings.name == '/derma') {
                          DoNothingAction;
                        } else {
                          Navigator.pushNamed(context, '/derma');
                        }
                      }),
                  const Text('Derma',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.0,
                          color: Colors.black45)),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
}
