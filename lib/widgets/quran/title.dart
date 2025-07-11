
import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

class CustomTitle extends StatelessWidget {
  final String? title;

  const CustomTitle({super.key, this.title});
  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Positioned(
      top: height * 0.12,
      left: width * 0.05,
      child: Shimmer.fromColors(
        baseColor:  Colors.black,
        highlightColor: Colors.grey,
        enabled: true,
        child: Text(
          title!,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
