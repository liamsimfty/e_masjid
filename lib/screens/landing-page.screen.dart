import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_masjid/screens/screens.dart';


import '../services/firestore_service.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({Key? key}) : super(key: key);

  String role = "";

  FireStoreService fireStoreService = FireStoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // UserHelper.saveUser(snapshot.data);
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(snapshot.data!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final userDoc = snapshot.data;
                  final user = userDoc?.data();
                  print(user);

                  //check role
                  if ((user as Map<String, dynamic>)['role'] == 'petugas') {
                    return PetugasHomeScreen(maxSlide: MediaQuery
                        .of(context)
                        .size
                        .width * 0.835);
                  } else {
                    return const HomeScreen();
                  }
                } else {
                  return const Material(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            );
          } else {
            return const LoginScreen();
          }
        });
  }}