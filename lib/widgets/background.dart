import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';

class DecorativeCircle {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final double opacity;
  final Color? color;

  const DecorativeCircle({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    this.opacity = 0.1,
    this.color,
  });
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final List<double>? stops;
  final double? opacity;
  final BorderRadius? borderRadius;
  final bool showDecorativeCircles;
  final List<DecorativeCircle>? customCircles;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
    this.begin,
    this.end,
    this.stops,
    this.opacity,
    this.borderRadius,
    this.showDecorativeCircles = false,
    this.customCircles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget gradientContainer = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
          colors: colors ?? _getDefaultColors(),
          stops: stops ?? const [0.0, 0.5, 1.0],
        ),
        borderRadius: borderRadius,
      ),
      child: child,
    );

    if (showDecorativeCircles) {
      return Stack(
        children: [
          gradientContainer,
          _buildDecorativeCircles(context),
        ],
      );
    }

    return gradientContainer;
  }

  List<Color> _getDefaultColors() {
    final baseOpacity = opacity ?? 0.7;
    return [
      kPrimaryColor.withOpacity(baseOpacity),
      kPrimaryColor,
      kPrimaryColor.withOpacity(baseOpacity + 0.2),
    ];
  }

  Widget _buildDecorativeCircles(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use custom circles if provided, otherwise use default circles
    List<DecorativeCircle> circles = customCircles ?? [
      DecorativeCircle(
        top: screenHeight * -0.05,
        left: screenWidth * -0.15,
        size: screenWidth * 0.45,
        opacity: 0.07,
      ),
      DecorativeCircle(
        bottom: screenHeight * -0.1,
        right: screenWidth * -0.2,
        size: screenWidth * 0.6,
        opacity: 0.05,
      ),
    ];

    return Stack(
      children: circles.map((circle) => _buildCircle(circle)).toList(),
    );
  }

  Widget _buildCircle(DecorativeCircle circle) {
    return Positioned(
      top: circle.top,
      bottom: circle.bottom,
      left: circle.left,
      right: circle.right,
      child: Container(
        width: circle.size,
        height: circle.size,
        decoration: BoxDecoration(
          color: (circle.color ?? Colors.white).withOpacity(circle.opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// Widget helper untuk berbagai variasi gradient
class GradientBackgroundVariations {
  // Gradient diagonal (default)
  static Widget diagonal({
    required Widget child,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return GradientBackground(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      borderRadius: borderRadius,
      child: child,
    );
  }

  // Gradient vertikal
  static Widget vertical({
    required Widget child,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return GradientBackground(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      borderRadius: borderRadius,
      child: child,
    );
  }

  // Gradient horizontal
  static Widget horizontal({
    required Widget child,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return GradientBackground(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      borderRadius: borderRadius,
      child: child,
    );
  }

  // Gradient dengan custom colors
  static Widget custom({
    required Widget child,
    required List<Color> colors,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    List<double>? stops,
    BorderRadius? borderRadius,
  }) {
    return GradientBackground(
      colors: colors,
      begin: begin,
      end: end,
      stops: stops,
      borderRadius: borderRadius,
      child: child,
    );
  }

  // Gradient dengan efek glassmorphism
  static Widget glassmorphism({
    required Widget child,
    BorderRadius? borderRadius,
  }) {
    return GradientBackground(
      colors: [
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: child,
    );
  }

  // Gradient dengan decorative circles (moved from orphaned static method)
  static Widget withCircles({
    required Widget child,
    List<Color>? colors,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    BorderRadius? borderRadius,
    List<DecorativeCircle>? customCircles,
  }) {
    return GradientBackground(
      colors: colors,
      begin: begin,
      end: end,
      borderRadius: borderRadius,
      showDecorativeCircles: true,
      customCircles: customCircles,
      child: child,
    );
  }
}

// Example usage widget
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradient Background Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Contoh 1: Basic usage
            Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 16),
              child: GradientBackground(
                borderRadius: BorderRadius.circular(12),
                child: const Center(
                  child: Text(
                    'Basic Gradient',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Contoh 2: Vertical gradient
            Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 16),
              child: GradientBackgroundVariations.vertical(
                borderRadius: BorderRadius.circular(12),
                child: const Center(
                  child: Text(
                    'Vertical Gradient',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Contoh 3: Custom colors
            Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 16),
              child: GradientBackgroundVariations.custom(
                colors: [
                  Colors.purple.withOpacity(0.8),
                  Colors.blue,
                  Colors.cyan.withOpacity(0.8),
                ],
                borderRadius: BorderRadius.circular(12),
                child: const Center(
                  child: Text(
                    'Custom Colors',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Contoh 4: Glassmorphism effect
            Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: GradientBackgroundVariations.glassmorphism(
                child: const Center(
                  child: Text(
                    'Glassmorphism',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Contoh 5: Gradient dengan decorative circles
            Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 16),
              child: GradientBackgroundVariations.withCircles(
                child: const Center(
                  child: Text(
                    'Gradient with Circles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Contoh 6: Card dengan gradient background
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GradientBackground(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Title',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is an example of using gradient background in a card layout. You can put any content here.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kPrimaryColor,
                        ),
                        child: const Text('Action Button'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}