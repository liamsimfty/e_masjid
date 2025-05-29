import 'package:e_masjid/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart';
import 'package:e_masjid/providers/user.provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:e_masjid/widgets/signup_form.dart';
import 'package:e_masjid/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/loading-indicator.dart';

class SignUpScreen extends StatelessWidget {
  String role = "kariah";

  AppUser appUser = AppUser();
  FireStoreService fireStoreService = FireStoreService();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUser>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Padding(
              padding: kDefaultPadding,
              child: Text('Cipta Akaun', style: titleText),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: kDefaultPadding,
              child: Row(
                children: [
                  Text('Sudah menjadi ahli?', style: subTitle),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: Text(
                      'Log Masuk',
                      style: textButton.copyWith(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: kDefaultPadding,
              child: SignUpForm(),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: kDefaultPadding,
              child: GestureDetector(
                onTap: () async {
                  print("Signup button pressed"); // Debug log
                  
                  try {
                    // Validate input fields
                    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                      EasyLoading.showInfo("Sila isi maklumat pendaftaran pengguna");
                      return;
                    }

                    if (nameController.text.isEmpty) {
                      EasyLoading.showInfo("Sila isi nama pengguna");
                      return;
                    }

                    print("Input validation passed"); // Debug log
                    print("Email: ${emailController.text}"); // Debug log
                    print("Name: ${nameController.text}"); // Debug log
                    
                    LoadingIndicator.showLoadingDialog(context);

                    // Step 1: Create Firebase Auth user
                    print("Creating Firebase Auth user..."); // Debug log
                    await AppUser.instance.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    print("Firebase Auth user created successfully"); // Debug log
                    print("User UID: ${AppUser.instance.user!.uid}"); // Debug log

                    // Step 2: Create Firestore user data with proper error handling
                    try {
                      print("Creating Firestore user data..."); // Debug log
                      await fireStoreService.createUserData(
                        nameController.text,
                        AppUser.instance.user!.uid,
                        emailController.text,
                        role,
                      );
                      print("Firestore user data created successfully"); // Debug log
                      
                      // Both operations succeeded
                      Navigator.pop(context); // loading dialog
                      Navigator.pop(context); // back to previous screen
                      EasyLoading.showSuccess('Pengguna berjaya dicipta');
                      
                    } catch (firestoreError) {
                      print("Firestore error occurred: ${firestoreError.toString()}"); // Debug log
                      
                      // Firestore failed but Auth succeeded - clean up the Auth user
                      try {
                        print("Cleaning up Firebase Auth user..."); // Debug log
                        await AppUser.instance.user?.delete();
                        await FirebaseAuth.instance.signOut();
                        print("Firebase Auth user cleaned up"); // Debug log
                      } catch (deleteError) {
                        print("Error cleaning up auth user: $deleteError");
                      }
                      
                      Navigator.pop(context); // dismiss loading dialog
                      EasyLoading.showError("Gagal menyimpan data pengguna: ${firestoreError.toString()}");
                    }

                  } on FirebaseAuthException catch (e) {
                    print("FirebaseAuthException: ${e.code} - ${e.message}"); // Debug log
                    Navigator.pop(context); // dismiss loading dialog
                    
                    String message;
                    switch (e.code) {
                      case 'email-already-in-use':
                        message = "Emel telah digunakan. Sila guna emel lain.";
                        break;
                      case 'invalid-email':
                        message = "Format emel tidak sah.";
                        break;
                      case 'weak-password':
                        message = "Katalaluan terlalu lemah.";
                        break;
                      default:
                        message = "Ralat: ${e.message}";
                    }
                    EasyLoading.showError(message);
                    
                  } catch (e) {
                    print("General error: ${e.toString()}"); // Debug log
                    Navigator.pop(context); // dismiss loading dialog
                    EasyLoading.showError("Ralat tidak dijangka: ${e.toString()}");
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kPrimaryColor),
                  child: Text(
                    'Daftar',
                    style: textButton.copyWith(color: kWhiteColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(padding: kDefaultPadding),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}