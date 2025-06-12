import 'package:e_masjid/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart';
import 'package:e_masjid/providers/user.provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:provider/provider.dart'; // Not explicitly used in this version's logic beyond AppUser.instance
// import 'package:e_masjid/widgets/signup_form.dart'; // We'll create a placeholder
import 'package:e_masjid/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/loading-indicator.dart'; // Assuming this is your custom loading dialog
import 'package:e_masjid/widgets/background.dart';

// --- Placeholder for SignUpFormWidget ---
// Replace this with your actual SignUpForm and pass the controllers
class SignUpFormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const SignUpFormWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Name Field
        TextFormField(
          controller: nameController,
          keyboardType: TextInputType.name,
          style: const TextStyle(color: kInputTextColor),
          decoration: _inputDecoration(
            hintText: 'Nama Penuh',
            icon: Icons.person_outline,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila masukkan nama anda';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Email Field
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: kInputTextColor),
          decoration: _inputDecoration(
            hintText: 'Emel',
            icon: Icons.email_outlined,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila masukkan emel anda';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Format emel tidak sah';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Password Field
        TextFormField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: kInputTextColor),
          decoration: _inputDecoration(
            hintText: 'Kata Laluan',
            icon: Icons.lock_outline,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila masukkan kata laluan';
            }
            if (value.length < 6) {
              return 'Kata laluan mesti sekurang-kurangnya 6 aksara';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Confirm Password Field
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: kInputTextColor),
          decoration: _inputDecoration(
            hintText: 'Sahkan Kata Laluan',
            icon: Icons.lock_outline,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila sahkan kata laluan';
            }
            if (value != passwordController.text) {
              return 'Kata laluan tidak sepadan';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: kPrimaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9), // Slightly transparent white
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
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 13),
    );
  }
}
// --- End of Placeholder SignUpFormWidget ---

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignUpScreen({super.key});

  static Route route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final String _role = "kariah"; // Default role

  final FireStoreService _fireStoreService = FireStoreService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      EasyLoading.showInfo("Sila perbetulkan ralat pada borang.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Show loading indicator
      if (mounted) {
        LoadingIndicator.showLoadingDialog(context);
      }

      // Step 1: Create Firebase Auth user
      final success = await AppUser.instance.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!success) {
        throw Exception("Failed to create user account");
      }

      // Get the current user after successful signup
      final currentUser = AppUser.instance.user;
      if (currentUser == null) {
        throw Exception("User not found after signup");
      }

      // Step 2: Create Firestore user data
      await _fireStoreService.createUserData(
        nameController.text.trim(),
        currentUser.uid,
        emailController.text.trim(),
        _role,
      );

      // Clear form data
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // Dismiss loading dialog
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      // Show success message
      EasyLoading.showSuccess('Pengguna berjaya dicipta!');

      // Navigate to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }

    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "Emel telah digunakan. Sila guna emel lain.";
          break;
        case 'invalid-email':
          message = "Format emel tidak sah.";
          break;
        case 'weak-password':
          message = "Kata laluan terlalu lemah.";
          break;
        case 'operation-not-allowed':
          message = "Operasi tidak dibenarkan.";
          break;
        default:
          message = "Ralat Pendaftaran: ${e.message ?? e.code}";
      }
      
      // Clean up if needed
      try {
        await AppUser.instance.user?.delete();
        await FirebaseAuth.instance.signOut();
      } catch (cleanupError) {
        print("Error during cleanup: $cleanupError");
      }

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        EasyLoading.showError(message);
      }
    } catch (e) {
      // Handle other errors
      print("Signup error: $e");
      
      // Clean up if needed
      try {
        await AppUser.instance.user?.delete();
        await FirebaseAuth.instance.signOut();
      } catch (cleanupError) {
        print("Error during cleanup: $cleanupError");
      }

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        EasyLoading.showError("Ralat tidak dijangka: ${e.toString()}");
      }
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
      extendBodyBehindAppBar: true, // Allows gradient to go behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
      ),
      body: Stack(
        children: [
          const GradientBackground(
            showDecorativeCircles: true,
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Cipta Akaun Baharu',
                        textAlign: TextAlign.center,
                        style: titleText.copyWith( // Use styles from constants
                            color: Colors.white,
                            fontSize: 28, // Adjusted size
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                       Text(
                        'Sila isi maklumat di bawah.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Container(
                        padding: const EdgeInsets.all(25.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                           boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0,5),
                            )
                           ]
                        ),
                        child: Form(
                          key: _formKey,
                          child: SignUpFormWidget(
                            nameController: nameController,
                            emailController: emailController,
                            passwordController: passwordController,
                            confirmPasswordController: confirmPasswordController,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      GestureDetector(
                        onTap: _isLoading ? null : _handleSignUp,
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
                              : Text(
                                  'Daftar Akaun',
                                  style: textButton.copyWith(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah menjadi ahli? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Log Masuk',
                              style: textButton.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                // decoration: TextDecoration.underline,
                                // decorationColor: Colors.white,
                              ),
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

// Ensure these are defined in your config/constants.dart
// const Color kPrimaryColor = Color(0xFF00796B); // Example
// const Color kInputTextColor = Color(0xFF333333); // Example for text in fields
// final TextStyle titleText = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87); // Example
// final TextStyle subTitle = TextStyle(fontSize: 16, color: Colors.black54); // Example
// final TextStyle textButton = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor); // Example
// const Color kWhiteColor = Colors.white;
// const EdgeInsets kDefaultPadding = EdgeInsets.all(20.0);