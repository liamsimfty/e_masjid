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
import 'package:e_masjid/widgets/widgets.dart';

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
          decoration: CustomInputDecoration.getDecoration(
            hintText: 'Full Name',
            icon: Icons.person_outline,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter your full name';
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
          decoration: CustomInputDecoration.getDecoration(
            hintText: 'Email',
            icon: Icons.email_outlined,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter your email';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Invalid email format';
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
          decoration: CustomInputDecoration.getDecoration(
            hintText: 'Password',
            icon: Icons.lock_outline,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
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
          decoration: CustomInputDecoration.getDecoration(
            hintText: 'Confirm Password',
            icon: Icons.lock_outline,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirm your password';
            }
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}

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
      EasyLoading.showInfo("Please correct the errors in the form.");
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
      EasyLoading.showSuccess('User created successfully!');

      // Navigate to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }

    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "Email already in use. Please use a different email.";
          break;
        case 'weak-password':
          message = "Password is too weak.";
          break;
        case 'operation-not-allowed':
          message = "Operation not allowed.";
          break;
        default:
          message = "Registration error: ${e.message ?? e.code}";
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
        EasyLoading.showError("Unexpected error: ${e.toString()}");
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
      appBar: CustomAppBar(showLogo: false, title: 'Register'),
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
                        'Create New Account',
                        textAlign: TextAlign.center,
                        style: titleText.copyWith( // Use styles from constants
                            color: Colors.white,
                            fontSize: 28, // Adjusted size
                            fontWeight: FontWeight.bold),
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
                                  'Register',
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
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Login',
                              style: textButton.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
