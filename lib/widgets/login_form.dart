import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';

import 'package:email_validator/email_validator.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class LogInForm extends StatefulWidget {
  const LogInForm({Key? key}) : super(key: key);

  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _isObscure = true;
  bool pass = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            obscureText: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Masukkan emel yang sah'
                    : null,
            onSaved: (value) {
              emailController.text = value!;
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
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: TextFormField(
            controller: passwordController,
            obscureText: pass ? _isObscure : false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value != null && value.length < 6
                ? 'Masukkan minimum 6 aksara'
                : null,
            onSaved: (value) {
              passwordController.text = value!;
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
    );
  }
}
