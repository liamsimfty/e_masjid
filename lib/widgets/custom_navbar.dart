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
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //icon for home
              SizedBox(
                height: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32, // Reduced from 40 to 32
                        minHeight: 32, // Reduced from 40 to 32
                      ),
                      icon: const Icon(
                        Icons.home,
                        color: Colors.teal,
                        size: 20, // Reduced from 22 to 20
                      ),
                      onPressed: () {
                        if (ModalRoute.of(context)?.settings.name == '/home') {
                          DoNothingAction;
                        } else {
                          Navigator.pushNamedAndRemoveUntil(context, '/home',
                              (_) => false);
                        }
                      }),
                    const Padding(
                      padding: EdgeInsets.only(top: 2), // Small padding to prevent overflow
                      child: Text('Home',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10.0, // Reduced from 11.0 to 10.0
                              color: Colors.black45)),
                    ),
                  ],
                ),
              ),

              //icon for program
              SizedBox(
                height: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32, // Reduced from 40 to 32
                        minHeight: 32, // Reduced from 40 to 32
                      ),
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.lightBlueAccent,
                        size: 20, // Reduced from 22 to 20
                      ),
                      onPressed: () {
                        if (ModalRoute.of(context)?.settings.name == '/program') {
                          DoNothingAction;
                        } else {
                          Navigator.pushNamed(context, '/program');
                        }
                      }),
                    const Padding(
                      padding: EdgeInsets.only(top: 2), // Small padding to prevent overflow
                      child: Text('Program',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10.0, // Reduced from 11.0 to 10.0
                              color: Colors.black45)),
                    ),
                  ],
                ),
              ),

              //icon for derma
              SizedBox(
                height: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32, // Reduced from 40 to 32
                        minHeight: 32, // Reduced from 40 to 32
                      ),
                      icon: const Icon(
                        Icons.monetization_on,
                        color: Colors.yellow,
                        size: 20, // Reduced from 22 to 20
                      ),
                      onPressed: () {
                        if (ModalRoute.of(context)?.settings.name == '/derma') {
                          DoNothingAction;
                        } else {
                          Navigator.pushNamed(context, '/derma');
                        }
                      }),
                    const Padding(
                      padding: EdgeInsets.only(top: 2), // Small padding to prevent overflow
                      child: Text('Derma',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10.0, // Reduced from 11.0 to 10.0
                              color: Colors.black45)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}