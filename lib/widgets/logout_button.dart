import 'package:flutter/material.dart';

class LogoutButtonWidget extends StatelessWidget {
  final dynamic appUser;
  final Widget loginScreen;

  const LogoutButtonWidget({
    Key? key,
    required this.appUser,
    required this.loginScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)]
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
          onTap: () => _showLogoutDialog(context),
          child: Container(
            width: 50, 
            height: 50, 
            decoration: const BoxDecoration(shape: BoxShape.circle), 
            child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24)
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red), 
            SizedBox(width: 10), 
            Text("Log Keluar")
          ]
        ),
        content: const Text(
          "Anda pasti mahu log keluar?", 
          style: TextStyle(fontSize: 16)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(
              "Tidak", 
              style: TextStyle(
                color: Colors.grey[600], 
                fontWeight: FontWeight.w600
              )
            )
          ),
          ElevatedButton(
            onPressed: () async {
              await appUser.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => loginScreen),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text(
              "Ya", 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w600
              )
            ),
          ),
        ],
      ),
    );
  }
}