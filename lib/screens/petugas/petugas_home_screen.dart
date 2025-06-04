import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/providers/user.provider.dart'; // For AppUser.instance.signOut()
import 'package:e_masjid/screens/screens.dart'; // For LoginScreen
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

  const PetugasHomeScreen({super.key, required this.maxSlide});

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

  // REMOVED: _canBeDragged, _onDragStart, _onDragUpdate, _onDragEnd
  // as swipe gesture for drawer is being removed.

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // If drawer is open, close it first
    if (animationController.isCompleted) {
      toggle();
      return false; // Prevent app exit
    }
    return (await (showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              "Keluar Aplikasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Anda pasti untuk keluar?"),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Ya",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  exit(0);
                },
              ),
              TextButton(
                child: const Text(
                  "Tidak",
                  style: TextStyle(color: kPrimaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
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
      // REMOVED: GestureDetector drag handlers. The GestureDetector itself can be removed
      // if it served no other purpose than drag, or kept if hitTestBehavior is important for other interactions.
      // For now, keeping it but drag handlers are effectively disabled by removing their assignment.
      child: GestureDetector( // Kept GestureDetector in case it's used for other interactions or hit testing for the main screen area
        // onHorizontalDragStart: _onDragStart, // REMOVED
        // onHorizontalDragUpdate: _onDragUpdate, // REMOVED
        // onHorizontalDragEnd: _onDragEnd, // REMOVED
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            return Material(
              color: kPrimaryColor.withOpacity(0.1),
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
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10.0 * animationController.value,
                              spreadRadius: 2.0 * animationController.value,
                            )
                          ]),
                          // Pass the animation controller if MainScreen needs to react to drawer state
                          child: MainScreen(animationController: animationController),
                        ),
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
  final AnimationController animationController; // Receive animation controller
  const MainScreen({super.key, required this.animationController});

  Widget _buildDecorativeCircles(BuildContext context) {
    // ... (decorative circles implementation from previous step)
    return Stack(
      children: [
        Positioned(
          top: -MediaQuery.of(context).size.height * 0.1,
          left: -MediaQuery.of(context).size.width * 0.2,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -MediaQuery.of(context).size.height * 0.05,
          right: -MediaQuery.of(context).size.width * 0.3,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            height: MediaQuery.of(context).size.width * 0.65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
          ),
        ),
         Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Log Keluar")
            ]
          ),
          content: const Text("Anda pasti mahu log keluar?", style: TextStyle(fontSize: 16)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text("Tidak", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600))
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text("Ya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await AppUser.instance.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          LoginScreen.route(),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal log keluar: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return ClipRRect(
      // Use the passed animationController for dynamic border radius
      borderRadius: BorderRadius.circular(animationController.isDismissed ? 0 : 20.0 * animationController.value),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimaryColor,
              kPrimaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildDecorativeCircles(context),
            const Positioned(
              top: 0, left: 0, bottom: 0,
              child: QuranRail(),
            ),

            // Logout Button
            Positioned(
              top: 24.0,
              right: 20.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1)
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5)
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => _handleLogout(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 24
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: height * 0.08),
                    Text(
                      "Panel Petugas",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 3, offset: Offset(1,1))
                        ]
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Image.asset(
                      "assets/images/e_masjid2.png",
                      height: height * 0.2,
                    ),
                    SizedBox(height: height * 0.05),
                    const SahPermohonanBtn(),
                    const ProgramPetugasBtn(),
                    const Spacer(),
                    const AyahBottom(),
                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (SahPermohonanBtn, ProgramPetugasBtn, AyahBottom, WidgetAnimator classes remain the same as in previous step)
class SahPermohonanBtn extends StatelessWidget {
  const SahPermohonanBtn({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.015),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/semak'),
        child: Container(
          width: width * 0.8,
          height: height * 0.07,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            "Pengesahan Permohonan",
            style: TextStyle(
              fontSize: height * 0.022,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgramPetugasBtn extends StatelessWidget {
  const ProgramPetugasBtn({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.015),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/program");
        },
        child: Container(
          width: width * 0.8,
          height: height * 0.07,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            "Sunting Program",
            style: TextStyle(
              fontSize: height * 0.022,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class AyahBottom extends StatelessWidget {
  const AyahBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "\"Indeed, It is We who sent down the Qur'an\nand indeed, We will be its Guardian\"",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "Surah Al-Hijr",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}

class WidgetAnimator extends StatelessWidget {
  final Widget child;
  const WidgetAnimator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}