import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser extends ChangeNotifier {
  bool _isPetugas = false;
  
  bool get isPetugas => _isPetugas;

  void setPetugasStatus(bool status) {
    _isPetugas = status;
    notifyListeners();
  }

  update() {
    notifyListeners();
  }

  AppUser._() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Check role when auth state changes
        await _checkUserRole(user.uid);
      } else {
        _isPetugas = false;
      }
      notifyListeners();
    });
  }

  Future<void> _checkUserRole(String userId) async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      
      if (userData.exists) {
        _isPetugas = userData.data()?['role'] == 'petugas';
        notifyListeners();
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  User? get user => FirebaseAuth.instance.currentUser;

  factory AppUser() => AppUser._();

  static AppUser get instance => AppUser();

  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

//sign in
  Future<void> signIn({required String email, required String password}) async {
    print('Email: $email');
    print('Password: $password');

    try {
      EasyLoading.show(status: 'sedang melog masuk...');
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      // Check if user is petugas (staff) from Firestore
      final user = userCredential.user;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        
        if (userData.exists) {
          _isPetugas = userData.data()?['role'] == 'petugas';
          notifyListeners();
        }
      }
      
      EasyLoading.showSuccess('Log Masuk berjaya.');
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      if (e.code == 'user-not-found') {}
      if (e.code == 'user-not-found') {
        EasyLoading.showToast('No user found for that email.');
        throw ('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        EasyLoading.showToast('Wrong password provided for that user.');
        throw ('Wrong password provided for that user.');
      } else
        throw (e.toString());
    }
  }

  //sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  //sign up
  Future<bool> signUp({
    required String email,
    required String password,
    // required String name,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // user!.updateDisplayName(name);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

getUser() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) print(user);
}
