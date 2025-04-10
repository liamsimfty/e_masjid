import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FireStoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String error = "";
  String formatDate = "";

  Future<void> createUserData(
      String name, String userid, String email, String role) async {
    try {
      await _firebaseFirestore.collection("users").doc(userid).set({
        "email": email,
        "userid": userid,
        "name": name,
        "role": role,
      });
    } catch (e) {
      log(e.toString());
      error = e.toString();
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getdata() async {
    var data = await _firebaseFirestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    return data;
  }

  //used in edit_program.dart
  Future<DocumentSnapshot<Map<String, dynamic>>> getdataProgram(
      String id) async {
    var data = await _firebaseFirestore.collection("program").doc(id).get();
    return data;
  }

  //used in edit_program.dart
  Future<void> updateServiceData(
    String title,
    String desc,
    DateTime firstDate,
    DateTime lastDate,
    String time, String time2,
    String id,
  ) async {
    await _firebaseFirestore.collection("program").doc(id).update({
      "title": title,
      "description": desc,
      "firstDate": firstDate,
      "lastDate": lastDate,
      "masaMula": time,
      "masaTamat": time2,
    });
  }

  // use in add Program screen
  Future<void> uploadProgramData(String title, String desc, DateTime firstDate,
      DateTime lastDate, String time, String time2) async {
    await _firebaseFirestore.collection("program").doc().set({
      "title": title,
      "description": desc,
      "firstDate": firstDate,
      "lastDate": lastDate,
      "masaMula": time,
      "masaTamat": time2,
    });
  }

  // use in to add pertanyaan imam
  Future<void> uploadTanyaData(String title, String desc, String authorId) async {
    DateTime date = DateTime.now();

    await _firebaseFirestore.collection("tanya").doc().set({
      "title": title,
      "description": desc,
      "tarikh": date,
      "JenisTemuJanji": "Pertanyaan",
      "balasan": "tiada",
      "isApproved": false,
      "authorId" : authorId
    });
  }

  // use in to add permohonan nikah
  Future<void> uploadMohonNikah(
      String pemohon, String pasangan, DateTime date, String time, String authorId) async {


    await _firebaseFirestore.collection("nikah").doc().set({
      "pemohon": pemohon,
      "pasangan": pasangan,
      "tarikh": date,
      "masa": time,
      "JenisTemuJanji": "Nikah",
      "isApproved": false,
      "title": "$pemohon & $pasangan",
      "description":
          "Permohonan Nikah $pemohon & $pasangan pada tarikh : ${date.month}/${date.day}/${date.year}, jam : $time",
      "balasan": "Tidak perlu balasan",
      "authorId" : authorId
    });
  }

  // use in to add tempahan qurban
  Future<void> uploadTempahQurban(String pemohon, int bilangan, String authorId) async {
    await _firebaseFirestore.collection("qurban").doc().set({
      "pemohon": pemohon,
      "bilangan": bilangan,
      "JenisTemuJanji": "Qurban",
      "isApproved": false,
      "title": "$pemohon (Tempah Qurban)",
      "description":
          "Tempahan Qurban oleh $pemohon iaitu sebanyak bilangan : $bilangan",
      "balasan": "Tempahan Qurban",
      "authorId" : authorId
    });
  }

  //used in semak_balas_screen.dart
  Future<void> updateBalasan(
    String title,
    String desc,
    String balas,
    String id,
  ) async {
    await _firebaseFirestore.collection("tanya").doc(id).update({
      "title": title,
      "description": desc,
      "balasan": balas,
      "isApproved": true
    });
  }

  //used in semak_balas_screen.dart
  Future<DocumentSnapshot<Map<String, dynamic>>> getdataTanya(String id) async {
    var data = await _firebaseFirestore.collection("tanya").doc(id).get();
    return data;
  }

  //used in semak_balas_screen.dart
  Future<void> updateApprovalNikah(
    String id,
  ) async {
    await _firebaseFirestore
        .collection("nikah")
        .doc(id)
        .update({"isApproved": true});
  }

  Future<void> updateApprovalQurban(
    String id,
  ) async {
    await _firebaseFirestore
        .collection("qurban")
        .doc(id)
        .update({"isApproved": true});
  }

  Future<void> updateApprovalPertanyaan(
    String id,
  ) async {
    await _firebaseFirestore
        .collection("tanya")
        .doc(id)
        .update({"isApproved": true});
  }

  convertTimestampToString(DateTime a) {
    //first date
    try {
      String b = a.toString();
      DateTime parsedDateTime = DateTime.parse(b);
      formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime);
    } catch (e) {
      print(e);
    }
  }
}
