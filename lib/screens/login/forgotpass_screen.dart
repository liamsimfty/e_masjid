import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/constants.dart';
import 'package:e_masjid/widgets/widgets.dart';

class ForgotPassword extends StatefulWidget {
  static const String routeName = '/forgot_password';
  const ForgotPassword({super.key});

  static Route route() => PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        pageBuilder: (context, animation, secondaryAnimation) => const ForgotPassword(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      );

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final Animation<double> _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Processing...');

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Check your email to reset your password.');
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      String errorMessage = switch (e.code) {
        'user-not-found' => 'No user found for this email.',
        'invalid-email' => 'Invalid email format.',
        _ => e.message ?? "Unknown error. Please try again."
      };
      print("FirebaseAuthException in resetPassword: ${e.code} - $errorMessage");
      EasyLoading.showError(errorMessage, duration: const Duration(seconds: 3));
    } catch (e) {
      EasyLoading.dismiss();
      print("Generic error in resetPassword: $e");
      EasyLoading.showError('Unexpected error. Please try again.', duration: const Duration(seconds: 3));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(showLogo: false, title: 'Forgot Password'),
      body: Stack(
        children: [
          const GradientBackground(showDecorativeCircles: true, child: SizedBox.expand()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.1),
                      Image.asset(
                        "assets/images/e_masjid1.jpg",
                        height: screenHeight * 0.2,
                        errorBuilder: (_, __, ___) => Icon(Icons.lock_reset, size: screenHeight * 0.15, color: Colors.white.withOpacity(0.5)),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Enter your email to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85)),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: kInputTextColor, fontSize: 16),
                          cursorColor: kPrimaryColor,
                          textInputAction: TextInputAction.done,
                          decoration: CustomInputDecoration.getDecoration(hintText: 'Email Anda', icon: Icons.email_outlined),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Enter your email";
                            if (!RegExp(r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*").hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      GestureDetector(
                        onTap: _isLoading ? null : resetPassword,
                        child: Container(
                          alignment: Alignment.center,
                          height: screenHeight * 0.07,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _isLoading
                                ? null
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.95),
                                      Colors.white.withOpacity(0.85),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: _isLoading ? Colors.grey.shade400 : null,
                            boxShadow: _isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: kPrimaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_outlined, color: kPrimaryColor, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Send Reset Link',
                                      style: textButton.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.8), size: 16),
                            const SizedBox(width: 5),
                            Text(
                              "Back to Login",
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
