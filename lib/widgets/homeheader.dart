import 'package:flutter/material.dart';
import 'package:e_masjid/providers/user.provider.dart';
import 'package:e_masjid/widgets/widgets.dart';
import 'package:e_masjid/screens/screens.dart';

class HomeHeaderWidget extends StatelessWidget {
  final String username;
  final AppUser appUser;

  const HomeHeaderWidget({
    super.key,
    required this.username,
    required this.appUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Assalamu'alaikum",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "e-Masjid Halim Shah",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LogoutButtonWidget(
            appUser: appUser,
            loginScreen: const LoginScreen(),
          ),
        ],
      ),
    );
  }
}
