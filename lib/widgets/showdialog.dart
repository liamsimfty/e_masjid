import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.cancelText = "Tidak",
    this.confirmText = "Ya",
    this.confirmColor = Colors.red,
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 24.sp),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          )
        ]
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 16.sp,
          height: 1.4,
          color: Colors.grey.shade700,
        )
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: Text(
            cancelText,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            )
          )
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: Text(
            confirmText,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            )
          ),
        ),
      ],
    );
  }
}

class DialogHelper {
  static Future<bool?> showCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    String cancelText = "Tidak",
    String confirmText = "Ya",
    Color confirmColor = Colors.red,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.w),
        duration: duration,
      ),
    );
  }
}

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
    DialogHelper.showCustomDialog(
      context: context,
      title: "Log Keluar",
      message: "Anda pasti mahu log keluar?",
      icon: Icons.logout,
      iconColor: Colors.red,
      onConfirm: () async {
        await appUser.signOut();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => loginScreen),
            (route) => false,
          );
        }
      },
    );
  }
}