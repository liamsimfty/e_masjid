import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/providers/user_role_provider.dart';
import 'package:e_masjid/mixins/role_checker_mixin.dart';
import 'package:provider/provider.dart';

// Choice class definition - should be in a separate file or at the top
class Choice {
  const Choice({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });

  final String title;
  final IconData icon;
  final String route;
  final Color color;
}

class SelectCard extends StatefulWidget {
  const SelectCard({super.key, required this.choice, required this.index});
  final Choice choice;
  final int index;
  
  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.pushNamed(context, widget.choice.route);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.choice.color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.choice.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.choice.icon,
                  size: 32,
                  color: widget.choice.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.choice.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.choice.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This should be part of a larger widget class that contains the choices list
class ServiceGridWidget extends StatelessWidget {
  final List<Choice> choices;
  
  const ServiceGridWidget({super.key, required this.choices});

  @override
  Widget build(BuildContext context) {
    return _buildGridContent();
  }

  Widget _buildGridContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<UserRoleProvider>(
                  builder: (context, roleProvider, child) {
                    return Text(
                      roleProvider.isPetugas ? "Kuasa Admin" : "Layanan",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, 
                crossAxisSpacing: 16, 
                mainAxisSpacing: 20, 
                childAspectRatio: 0.9
              ),
              itemCount: choices.length,
              itemBuilder: (context, index) {
                return SelectCard(choice: choices[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget with RoleCheckerMixin {
  // ... existing code ...

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        return Container(
          // ... existing container code ...
          child: Column(
            children: [
              // ... other widgets ...
              Text(
                isPetugas(context) ? "Kuasa Admin" : "Layanan",
                style: TextStyle(
                  // ... existing style ...
                ),
              ),
              // ... other widgets ...
            ],
          ),
        );
      },
    );
  }
}