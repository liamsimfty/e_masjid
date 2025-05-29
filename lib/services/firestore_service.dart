import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FireStoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String error = "";
  String formatDate = "";

  // Get current user ID safely
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> createUserData(
      String name, String userid, String email, String role) async {
    try {
      print("Creating user data for: $email, userid: $userid");
      
      await _firebaseFirestore.collection("users").doc(userid).set({
        "email": email,
        "userid": userid,
        "name": name,
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });
      
      print("User data created successfully");
    } catch (e) {
      print("Error creating user data: ${e.toString()}");
      log(e.toString());
      error = e.toString();
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getdata() async {
    try {
      if (currentUserId == null) {
        throw Exception("No authenticated user found");
      }
      
      var data = await _firebaseFirestore
          .collection("users")
          .doc(currentUserId)
          .get();
      return data;
    } catch (e) {
      log("Error getting user data: ${e.toString()}");
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getdataProgram(String id) async {
    try {
      var data = await _firebaseFirestore.collection("program").doc(id).get();
      return data;
    } catch (e) {
      log("Error getting program data: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> updateServiceData(
    String title,
    String desc,
    DateTime firstDate,
    DateTime lastDate,
    String time, String time2,
    String id,
  ) async {
    try {
      await _firebaseFirestore.collection("program").doc(id).update({
        "title": title,
        "description": desc,
        "firstDate": Timestamp.fromDate(firstDate),
        "lastDate": Timestamp.fromDate(lastDate),
        "masaMula": time,
        "masaTamat": time2,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error updating program: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> uploadProgramData(String title, String desc, DateTime firstDate,
      DateTime lastDate, String time, String time2) async {
    try {
      await _firebaseFirestore.collection("program").doc().set({
        "title": title,
        "description": desc,
        "firstDate": Timestamp.fromDate(firstDate),
        "lastDate": Timestamp.fromDate(lastDate),
        "masaMula": time,
        "masaTamat": time2,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error uploading program: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> uploadTanyaData(String title, String desc, String authorId) async {
    try {
      await _firebaseFirestore.collection("tanya").doc().set({
        "title": title,
        "description": desc,
        "tarikh": FieldValue.serverTimestamp(),
        "JenisTemuJanji": "Pertanyaan",
        "balasan": "tiada",
        "isApproved": false,
        "authorId": authorId,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error uploading question: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> uploadMohonNikah(
      String pemohon, String pasangan, DateTime date, String time, String authorId) async {
    try {
      await _firebaseFirestore.collection("nikah").doc().set({
        "pemohon": pemohon,
        "pasangan": pasangan,
        "tarikh": Timestamp.fromDate(date),
        "masa": time,
        "JenisTemuJanji": "Nikah",
        "isApproved": false,
        "title": "$pemohon & $pasangan",
        "description":
            "Permohonan Nikah $pemohon & $pasangan pada tarikh : ${date.day}/${date.month}/${date.year}, jam : $time",
        "balasan": "Tidak perlu balasan",
        "authorId": authorId,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error uploading nikah application: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> uploadTempahQurban(String pemohon, int bilangan, String authorId) async {
    try {
      await _firebaseFirestore.collection("qurban").doc().set({
        "pemohon": pemohon,
        "bilangan": bilangan,
        "JenisTemuJanji": "Qurban",
        "isApproved": false,
        "title": "$pemohon (Tempah Qurban)",
        "description":
            "Tempahan Qurban oleh $pemohon iaitu sebanyak bilangan : $bilangan",
        "balasan": "Tempahan Qurban",
        "authorId": authorId,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error uploading qurban booking: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> updateBalasan(
    String title,
    String desc,
    String balas,
    String id,
  ) async {
    try {
      await _firebaseFirestore.collection("tanya").doc(id).update({
        "title": title,
        "description": desc,
        "balasan": balas,
        "isApproved": true,
        "repliedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error updating reply: ${e.toString()}");
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getdataTanya(String id) async {
    try {
      var data = await _firebaseFirestore.collection("tanya").doc(id).get();
      return data;
    } catch (e) {
      log("Error getting question data: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> updateApprovalNikah(String id) async {
    try {
      await _firebaseFirestore.collection("nikah").doc(id).update({
        "isApproved": true,
        "approvedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error approving nikah: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> updateApprovalQurban(String id) async {
    try {
      await _firebaseFirestore.collection("qurban").doc(id).update({
        "isApproved": true,
        "approvedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error approving qurban: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> updateApprovalPertanyaan(String id) async {
    try {
      await _firebaseFirestore.collection("tanya").doc(id).update({
        "isApproved": true,
        "approvedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error approving question: ${e.toString()}");
      rethrow;
    }
  }

  // Additional helper methods
  Future<List<DocumentSnapshot>> getPendingApprovals() async {
    try {
      List<DocumentSnapshot> pending = [];
      
      // Get pending questions
      var tanyaQuery = await _firebaseFirestore
          .collection("tanya")
          .where("isApproved", isEqualTo: false)
          .get();
      pending.addAll(tanyaQuery.docs);
      
      // Get pending nikah
      var nikahQuery = await _firebaseFirestore
          .collection("nikah")
          .where("isApproved", isEqualTo: false)
          .get();
      pending.addAll(nikahQuery.docs);
      
      // Get pending qurban
      var qurbanQuery = await _firebaseFirestore
          .collection("qurban")
          .where("isApproved", isEqualTo: false)
          .get();
      pending.addAll(qurbanQuery.docs);
      
      return pending;
    } catch (e) {
      log("Error getting pending approvals: ${e.toString()}");
      rethrow;
    }
  }

  String convertTimestampToString(DateTime a) {
    try {
      formatDate = DateFormat("dd-MM-yyyy").format(a);
      return formatDate;
    } catch (e) {
      print("Error formatting date: $e");
      return "";
    }
  }

  String convertTimestampToStringWithTime(DateTime a) {
    try {
      return DateFormat("dd-MM-yyyy HH:mm").format(a);
    } catch (e) {
      print("Error formatting date with time: $e");
      return "";
    }
  }
}