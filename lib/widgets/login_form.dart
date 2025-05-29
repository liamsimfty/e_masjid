import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';

import 'package:email_validator/email_validator.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _isObscure = true;
  bool pass = true;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void handleAuthError(String errorCode) {
    String message;
    switch (errorCode) {
      case 'invalid-credential':
        message = 'Emel atau kata laluan tidak sah';
        break;
      case 'user-not-found':
        message = 'Pengguna tidak dijumpai';
        break;
      case 'wrong-password':
        message = 'Kata laluan tidak sah';
        break;
      case 'invalid-email':
        message = 'Format emel tidak sah';
        break;
      case 'user-disabled':
        message = 'Akaun telah dinyahaktifkan';
        break;
      case 'too-many-requests':
        message = 'Terlalu banyak percubaan. Sila cuba sebentar lagi';
        break;
      default:
        message = 'Ralat semasa log masuk. Sila cuba lagi';
    }
    setState(() {
      _errorMessage = message;
    });
    _showErrorSnackBar(message);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              obscureText: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) {
                if (email == null || email.isEmpty) {
                  return 'Sila masukkan emel anda';
                }
                if (!EmailValidator.validate(email)) {
                  return 'Masukkan emel yang sah';
                }
                return null;
              },
              onChanged: (_) {
                setState(() {
                  _errorMessage = null;
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: kTextFieldColor,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              controller: passwordController,
              obscureText: pass ? _isObscure : false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sila masukkan kata laluan';
                }
                if (value.length < 6) {
                  return 'Masukkan minimum 6 aksara';
                }
                return null;
              },
              onChanged: (_) {
                setState(() {
                  _errorMessage = null;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.vpn_key),
                labelText: 'Kata Laluan',
                labelStyle: const TextStyle(
                  color: kTextFieldColor,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                suffixIcon: pass
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                        icon: _isObscure
                            ? const Icon(
                                Icons.visibility_off,
                                color: kTextFieldColor,
                              )
                            : const Icon(
                                Icons.visibility,
                                color: kPrimaryColor,
                              ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
