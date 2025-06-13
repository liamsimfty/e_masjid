import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUtils {
  static Future<Map<String, dynamic>> getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        "isPetugas": false,
        "name": "Guest",
      };
    }

    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      final data = doc.data();
      return {
        "isPetugas": data?["role"] == "petugas",
        "name": data?["name"] ?? "Guest",
      };
    } catch (e) {
      print("Error retrieving user info: $e");
      return {
        "isPetugas": false,
        "name": "Guest",
      };
    }
  }
}
