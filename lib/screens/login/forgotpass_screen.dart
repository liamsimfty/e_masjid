import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/constants.dart';
import 'package:e_masjid/widgets/widgets.dart';


// import '../../providers/user.provider.dart'; // AppUser instance not used in resetPassword directly

class ForgotPassword extends StatefulWidget {
  static const String routeName = '/forgot_password'; // For navigation consistency
  const ForgotPassword({super.key});

   static Route route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) => const ForgotPassword(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }


  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Slightly slower fade for a calmer feel
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
      {required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: kPrimaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      // Validator will show individual field errors.
      // Optionally, show a generic message if preferred.
      // EasyLoading.showInfo('Sila perbetulkan ralat pada borang.');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    EasyLoading.show(status: 'Sedang diproses...');

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      EasyLoading.dismiss(); // Dismiss before showing success
      EasyLoading.showSuccess('Pautan tetapan semula kata laluan telah dihantar ke emel anda.');
      // Optionally navigate back or clear field after a delay
      // Future.delayed(Duration(seconds: 2), () {
      //   if(mounted) Navigator.pop(context);
      // });
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss(); // Dismiss before showing error
      String errorMessage = "Operasi gagal.";
      if (e.code == 'user-not-found') {
        errorMessage = 'Tiada pengguna ditemui untuk emel tersebut.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format emel tidak sah.';
      } else {
        errorMessage = e.message ?? "Ralat tidak diketahui. Sila cuba lagi.";
      }
      print("FirebaseAuthException in resetPassword: ${e.code} - $errorMessage");
      EasyLoading.showError(errorMessage, duration: const Duration(seconds: 3));
    } catch (e) {
      EasyLoading.dismiss();
      print("Generic error in resetPassword: $e");
      EasyLoading.showError('Ralat tidak dijangka. Sila cuba lagi.', duration: const Duration(seconds: 3));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lupa Kata Laluan'), // Changed from 'Tetapan semula...'
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      body: Stack(
        children: [
          const GradientBackground(
            showDecorativeCircles: true,
            child: const SizedBox.expand(),
          ),
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
                      SizedBox(height: screenHeight * 0.1), // Space from AppBar
                      Image.asset(
                        "assets/images/e_masjid1.jpg", // Consider a more abstract or themed image
                        height: screenHeight * 0.2,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.lock_reset, size: screenHeight * 0.15, color: Colors.white.withOpacity(0.5)),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Masukkan emel anda untuk menerima pautan tetapan semula kata laluan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85)),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Container( // Wrapper for form field for subtle background/padding
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                         decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                           boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0,4),
                            )
                           ]
                        ),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color:kInputTextColor, fontSize: 16), // Text color inside field
                          cursorColor: kPrimaryColor, // Cursor color matching theme
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            hintText: 'Emel Anda',
                            icon: Icons.email_outlined,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Sila masukkan emel";
                            }
                            if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                .hasMatch(value)) { // More robust regex
                              return "Sila masukkan emel yang sah";
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
                             boxShadow: _isLoading ? [] : [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ]
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_outlined, color: kPrimaryColor, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Hantar Pautan', // Changed text
                                    style: textButton.copyWith(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to previous screen (Login)
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.8), size: 16),
                             const SizedBox(width: 5),
                             Text(
                              "Kembali ke Log Masuk",
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05), // Bottom padding
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
