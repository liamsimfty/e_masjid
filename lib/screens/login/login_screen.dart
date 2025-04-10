
import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/widgets/login_form.dart';
import 'package:e_masjid/providers/user.provider.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: kDefaultPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 70,
              ),
              Center(child: Image.asset('assets/images/e_masjid2.png')),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: Text(
                  'Selamat Datang.',
                  style: subTitle,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      'Daftar akaun!',
                      style: textButton.copyWith(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 7,
              ),
              const LogInForm(),


              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPassword()));
                },
                child: const Center(
                  child: Text(
                    'Terlupa kata laluan?',
                    style: TextStyle(
                      color: kZambeziColor,
                      fontSize: 14,
                      decorationThickness: 1,
                    ),
                  ),

                ),
              ),
              const SizedBox(
                height: 20,
              ),


              GestureDetector(
                onTap: () async {
                    AppUser.instance.signIn(
                        email: emailController.text,
                        password: passwordController.text);

                },
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kPrimaryColor),
                  child: Text(
                    'Log Masuk',
                    style: textButton.copyWith(color: kWhiteColor),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
