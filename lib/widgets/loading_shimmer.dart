import 'package:e_masjid/animations/bottom_animation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final String? text;
  const LoadingShimmer({super.key, this.text});
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.transparent,
      highlightColor: const Color(0xfff9e9b8),
      enabled: true,
      child: Container(
        width: width,
        height: height,
        color: Colors.transparent,
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', height: height * 0.1),
            WidgetAnimator(
                child: Text("Loading $text..!",
                    style: TextStyle(fontSize: height * 0.02)))
          ],
        )),
      ),
    );
  }
}
