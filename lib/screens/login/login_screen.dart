import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart'; // Assuming HomeScreen, SignUpScreen, ForgotPassword are here
import 'package:e_masjid/config/constants.dart';
// import 'package:e_masjid/widgets/login_form.dart'; // Assuming LogInForm is here
import 'package:e_masjid/providers/user.provider.dart';
import 'dart:math' as math; // For animations if needed

// Define constants if not in constants.dart
const Color kInputTextColor = Color(0xFF333333);

// --- Placeholder for LogInForm if you don't provide it ---
// If you have your own LogInForm, ensure it accepts these controllers.
class LogInForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LogInForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  String _selectedProvider = '@gmail.com';
  final List<String> _emailProviders = [
    '@gmail.com',
    '@yahoo.com',
    '@hotmail.com',
    '@outlook.com',
    '@icloud.com',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Email Field with Provider Dropdown
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: kInputTextColor),
                decoration: InputDecoration(
                  hintText: 'Emel',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.email_outlined, color: kPrimaryColor.withOpacity(0.7)),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila masukkan emel anda';
                  }
                  if (value.contains('@') || value.contains(' ')) {
                    return 'Format emel tidak sah';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedProvider,
                  items: _emailProviders.map((String provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          provider,
                          style: const TextStyle(color: kInputTextColor),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedProvider = newValue;
                      });
                    }
                  },
                  icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor.withOpacity(0.7)),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Password Field
        TextFormField(
          controller: widget.passwordController,
          obscureText: true,
          style: const TextStyle(color: kInputTextColor),
          decoration: InputDecoration(
            hintText: 'Kata Laluan',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.lock_outline, color: kPrimaryColor.withOpacity(0.7)),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila masukkan kata laluan anda';
            }
            return null;
          },
        ),
      ],
    );
  }
}
// --- End of Placeholder LogInForm ---


class LoginScreen extends StatefulWidget {
  static const String routeName = '/login'; // Define routeName for consistency
  const LoginScreen({super.key});

  static Route route() { // Optional: For named routing with transitions
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Define controllers here
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) { // Use form validation
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the LogInForm state to access the selected provider
      final formState = _formKey.currentState as FormState;
      final form = formState.context.findAncestorStateOfType<_LogInFormState>();
      
      // Format email with selected provider
      String email = emailController.text.trim();
      if (!email.contains('@')) {
        email = '$email${form?._selectedProvider ?? '@gmail.com'}';
      }

      // Ensure AppUser.instance is correctly initialized if it's a singleton
      // or use Provider to access it if it's part of your state management.
      await AppUser.instance.signIn(
        email: email,
        password: passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = "Log masuk gagal. Sila cuba lagi.";
        if (e is FormatException) { // Example of more specific error
          errorMessage = e.message;
        } else if (e.toString().contains('user-not-found') || e.toString().contains('wrong-password')) {
          errorMessage = "Emel atau kata laluan tidak sah.";
        } else {
           errorMessage = e.toString().replaceFirst("Exception: ", ""); // Clean up generic exception message
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.8),
            kPrimaryColor,
            kPrimaryColor.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          top: -MediaQuery.of(context).size.height * 0.1,
          right: -MediaQuery.of(context).size.width * 0.2,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -MediaQuery.of(context).size.height * 0.15,
          left: -MediaQuery.of(context).size.width * 0.25,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildDecorativeCircles(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), // Responsive padding
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.08),
                      Image.asset(
                        'assets/images/e_masjid2.png', // Ensure this path is correct
                        height: screenHeight * 0.15, // Responsive height
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Selamat Datang', // Kept it simple
                        style: subTitle.copyWith( // Use styles from constants
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Log masuk untuk teruskan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),

                      // Form Area with a subtle background
                      Container(
                        padding: const EdgeInsets.all(25.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05), // Very subtle background
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
                          child: Column(
                            children: [
                              LogInForm( // Pass controllers to your LogInForm
                                emailController: emailController,
                                passwordController: passwordController,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Terlupa kata laluan?',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      // decoration: TextDecoration.underline,
                                      // decorationColor: Colors.white.withOpacity(0.9)
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      GestureDetector(
                        onTap: _isLoading ? null : _handleLogin,
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
                            color: _isLoading ? Colors.grey.shade400 : null, // Fallback for gradient
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
                                  'Log Masuk',
                                  style: textButton.copyWith(
                                      color: kPrimaryColor, // Text color on light button
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(), // Removed const
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tiada akaun? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Daftar di sini!',
                              style: textButton.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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

