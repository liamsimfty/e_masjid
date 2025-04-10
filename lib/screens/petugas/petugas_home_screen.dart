import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'package:e_masjid/animations/bottom_animation.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/widgets/quran_rail.dart';
import '../../widgets/drawer/custom_drawer.dart';
import 'package:flutter/material.dart';

class PetugasHomeScreen extends StatefulWidget {
  static const String routeName = '/petugas_home';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => PetugasHomeScreen(
        maxSlide: MediaQuery.of(context).size.width * 0.835,
      ),
    );
  }

  final double maxSlide;

  const PetugasHomeScreen({Key? key, required this.maxSlide}) : super(key: key);

  @override
  _PetugasHomeScreenState createState() => _PetugasHomeScreenState();
}

class _PetugasHomeScreenState extends State<PetugasHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  late bool _canBeDragged;

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed;
    bool isDragCloseFromRight = animationController.isCompleted;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta! / widget.maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    double _kMinFlingVelocity = 365.0;

    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  Future<bool> _onWillPop() async {
    return (await (showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              "Exit Application",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Are You Sure?"),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  exit(0);
                },
              ),
              TextButton(
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ) as FutureOr<bool>?)) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            return Material(
              color: Colors.white70,
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    Transform.translate(
                      offset: Offset(
                          widget.maxSlide * (animationController.value - 1), 0),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(
                              math.pi / 2 * (1 - animationController.value)),
                        alignment: Alignment.centerRight,
                        child: const MyDrawer(),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(
                          widget.maxSlide * animationController.value, 0),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(-math.pi / 2 * animationController.value),
                        alignment: Alignment.centerLeft,
                        child: const MainScreen(),
                      ),
                    ),
                    Positioned(
                      top: 4.0 + MediaQuery.of(context).padding.top,
                      left: width * 0.01 +
                          animationController.value * widget.maxSlide,
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: toggle,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            right: width * 0.170,
            top: height * 0.135,
            child: Image.asset(
              "assets/images/e_masjid2.png",
              height: height * 0.28,
            ),
          ),
          // const AppName(),
          // const Calligraphy(),
          const QuranRail(),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[SahPermohonanBtn(), ProgramPetugasBtn()],
            ),
          ),
          const AyahBottom(),
        ],
      ),
    );
  }
}

class SahPermohonanBtn extends StatelessWidget {
  const SahPermohonanBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: SizedBox(
        width: width * 0.7,
        height: height * 0.06,
        child: MaterialButton(
            shape: const StadiumBorder(),
            onPressed: () => Navigator.pushNamed(context, '/semak'),
            child: WidgetAnimator(
              child: Text(
                "Pengesahan Permohonan",
                style: TextStyle(
                    fontSize: height * 0.026,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            color: kPrimaryColor),
      ),
    );
  }
}

class ProgramPetugasBtn extends StatelessWidget {
  const ProgramPetugasBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: SizedBox(
        width: width * 0.7,
        height: height * 0.06,
        child: MaterialButton(
            shape: const StadiumBorder(),
            onPressed: () {
              // MaterialPageRoute(builder: (context) => ProgramPetugasScreen());
              Navigator.pushNamed(context, "/program");
            },
            child: WidgetAnimator(
              child: Text(
                "Sunting Program",
                style: TextStyle(
                    fontSize: height * 0.025,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            color: kPrimaryColor),
      ),
    );
  }
}

class AyahBottom extends StatelessWidget {
  const AyahBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            "\"Indeed, It is We who sent down the Qur'an\nand indeed, We will be its Guardian\"\n",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            
            "Surah Al-Hijr\n",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        
      ),
    );
  }
}
