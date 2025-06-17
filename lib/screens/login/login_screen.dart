import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart';
import 'package:e_masjid/providers/user.provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/widgets/widgets.dart';
import 'package:e_masjid/config/constants.dart';

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
    '@gmail.com', '@yahoo.com', '@hotmail.com', '@outlook.com', '@icloud.com', ''
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: kInputTextColor),
                decoration: CustomInputDecoration.getDecoration(
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                ),
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
                  items: _emailProviders.map((provider) => DropdownMenuItem<String>(
                    value: provider,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(provider, style: const TextStyle(color: kInputTextColor)),
                    ),
                  )).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedProvider = newValue ?? _selectedProvider;
                      if (_selectedProvider == '') {
                        // Clear the email suffix if custom is selected
                        widget.emailController.text = widget.emailController.text.split('@')[0];
                      }
                    });
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
        TextFormField(
          controller: widget.passwordController,
          obscureText: true,
          style: const TextStyle(color: kInputTextColor),
          decoration: CustomInputDecoration.getDecoration(
            hintText: 'Password',
            icon: Icons.lock_outline,
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
        ),
      ],
    );
  }

  String get selectedProvider => _selectedProvider;
}

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  static Route route() => PageRouteBuilder(
    settings: const RouteSettings(name: routeName),
    pageBuilder: (context, _, __) => const LoginScreen(),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
  );

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final form = _formKey.currentContext?.findAncestorStateOfType<_LogInFormState>();
      String email = emailController.text.trim();
        
      // Handle email based on selected provider
      if (form?.selectedProvider == 'Custom') {
        // If custom is selected, use the email as is
        if (!email.contains('@')) {
          throw Exception("Please enter a complete email address");
        }
      } else {
        // For predefined providers, append the domain if not present
        if (!email.contains('@')) {
          email = '$email${form?.selectedProvider ?? '@gmail.com'}';
        }
      }

      await AppUser.instance.signIn(
        email: email,
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(AppUser.instance.user!.uid)
          .get();

      if (userDoc.exists) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString().contains('user-not-found') || e.toString().contains('wrong-password')
          ? "Email or password is incorrect."
          : e.toString().replaceFirst("Exception: ", "Login failed. ");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(showDecorativeCircles: true, child: SizedBox.expand()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.07),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.08),
                    Image.asset('assets/images/e_masjid2.png', height: height * 0.15),
                    SizedBox(height: height * 0.02),
                    Text('Welcome',
                        style: subTitle.copyWith(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: height * 0.01),
                    Text('Login to continue',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
                    SizedBox(height: height * 0.05),
                    Container(
                      padding: const EdgeInsets.all(25.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            LogInForm(
                              emailController: emailController,
                              passwordController: passwordController,
                            ),
                            SizedBox(height: height * 0.02),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPassword())),
                                child: Text('Forgot Password?',
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleLogin,
                      child: Container(
                        alignment: Alignment.center,
                        height: height * 0.07,
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
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                              )
                            : Text('Login',
                                style: textButton.copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen())),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No account? ',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15)),
                          Text('Register here!',
                              style: textButton.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
