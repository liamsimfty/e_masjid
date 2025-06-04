import 'package:flutter/material.dart';
// For ImageFilter

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  AnimationController? _animationController;
  Animation<double>? _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Only animate if controller is initialized
    if (_animationController != null) {
      _animationController!.forward().then((_) {
        _animationController!.reverse();
      });
    }

    // Navigate to home screen
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 150, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E8B57), // Sea green
            Color(0xFF20B2AA), // Light sea green
            Color(0xFF008B8B), // Dark cyan
          ],
        ),
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          height: 75,
          child: Center(
            child: _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: '',
              index: 0,
              isCenter: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isCenter ? 12 : 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(isCenter ? 20 : 15),
                  border: isSelected 
                    ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                    : null,
                ),
                child: _animation != null
                  ? ScaleTransition(
                      scale: isSelected 
                        ? Tween<double>(begin: 1.0, end: 1.2).animate(_animation!)
                        : const AlwaysStoppedAnimation(1.0),
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        color: Colors.white,
                        size: isCenter ? 28 : 24,
                      ),
                    )
                  : Icon(
                      isSelected ? activeIcon : icon,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      size: isCenter ? 28 : 24,
                    ),
              ),
              const SizedBox(height: 4),
              if (isSelected)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(top: 2),
                  height: 2,
                  width: 20,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simplified version without complex animations (Recommended)
class SimpleCustomNavBar extends StatefulWidget {
  const SimpleCustomNavBar({super.key});

  @override
  State<SimpleCustomNavBar> createState() => _SimpleCustomNavBarState();
}

class _SimpleCustomNavBarState extends State<SimpleCustomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to home screen
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E8B57), // Sea green
            Color(0xFF20B2AA), // Light sea green
            Color(0xFF008B8B), // Dark cyan
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          height: 75,
          child: Center(
            child: _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'EE',
              index: 0,
              isCenter: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isCenter ? 12 : 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(isCenter ? 20 : 15),
                  border: isSelected 
                    ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                    : null,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: Colors.white,
                    size: isCenter ? 28 : 24,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                child: Text(label),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 2),
                height: isSelected ? 2 : 0,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}