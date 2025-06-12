import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart'; // Assuming this imports HomeScreen, PetugasHomeScreen, LoginScreen


import '../services/firestore_service.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({super.key});

  String role = "";

  FireStoreService fireStoreService = FireStoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, now check their role from Firestore
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(snapshot.data!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the document to load
                  return const Material(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  // Handle any errors from Firestore
                  print('Error fetching user document: ${snapshot.error}');
                  // Optionally, you might want to log out or show an error screen
                  return const LoginScreen(); // Or an error screen
                }

                // Check if the document exists and has data
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  final userDoc = snapshot.data;
                  final user = userDoc?.data() as Map<String, dynamic>?; // Cast with nullable type

                  if (user != null && user.containsKey('role')) {
                    print('User data: $user');
                    return const HomeScreen();
                  } else {
                    // Case: Document exists but user data is null or 'role' field is missing
                    print("User document exists but data is null or 'role' field is missing. Navigating to LoginScreen.");
                    // Go to LoginScreen if data is not properly structured
                    return const LoginScreen();
                  }
                } else {
                  // Case: Document does not exist for this UID (meaning no user data setup in Firestore)
                  print("User document does not exist for UID: ${FirebaseAuth.instance.currentUser?.uid}. Navigating to LoginScreen.");
                  return const LoginScreen();
                }
              },
            );
          } else {
            // User is not logged in, show LoginScreen
            return const LoginScreen();
          }
        });
  }
}