import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/models/temujanji_model.dart';

Future<List<Program>> getTaskList() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('temujanji')
      // .where('authorId', isEqualTo: AppUser().user!.uid)
      .get();
  return snapshot.docs.map((e) => Program.fromMap(e.data())).toList();
}

Stream<List<Program>> getNikahListStream() {
  final snapshots = FirebaseFirestore.instance
      .collection('nikah')
  // .where('authorId', isEqualTo: AppUser().user!.uid)
      .orderBy('Tarikh', descending: true)
      .snapshots();
  return snapshots.map((snapshot) => snapshot.docs
      .map(
        (e) => Program.fromMap(e.data(), id: e.id),
  )
      .toList());
}

Stream<List<Program>> getTaskListStream() {
  final snapshots = FirebaseFirestore.instance
      .collection('tanya')
      // .where('authorId', isEqualTo: AppUser().user!.uid)
      .orderBy('Tarikh', descending: true)
      .snapshots();
  final snapshots1 = FirebaseFirestore.instance
      .collection('nikah')
  // .where('authorId', isEqualTo: AppUser().user!.uid)
      .orderBy('Tarikh', descending: true)
      .snapshots();

  return snapshots.map((snapshot) => snapshot.docs
      .map(
        (e) => Program.fromMap(e.data(), id: e.id),
  )
      .toList());


}

Future<bool> addTanya(Program temujanji) async {
  try {
    await FirebaseFirestore.instance.collection('tanya').add(temujanji.toMap());
    return true;
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<bool> deleteTemujanji(String temujanjiID) async {
  try {
    await FirebaseFirestore.instance.doc('temujanji/$temujanjiID').delete();
    return true;
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<bool> addNikah(Program temujanji) async {
  try {
    await FirebaseFirestore.instance.collection('nikah').add(temujanji.toMap());
    return true;
  } catch (e) {
    print(e);
    rethrow;
  }
}