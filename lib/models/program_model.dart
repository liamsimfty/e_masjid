
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

class Program{
  String ?title;
  String description;
  // String ?KariahID;
  // String ?PetugasID;
  // String? pemohon;
  // String? pasangan;
  // String? tajuk;
  // String? huraian;
  // DateTime? tarikh;
  // Bool ?privasi;

  Program({
    this.title,
    required this.description,
    // this.pemohon,
    // this.pasangan,
    // this.KariahID,
    // this.PetugasID,
    // this.tajuk,
    // this.huraian,
    // required this.tarikh,
    // this.privasi,
  });



  static Program fromMap(Map<String, dynamic> data, {String? id}) {
    try {
      return Program(
          title: data['title'] ?? '',
          description: data['description'] ?? '');
          // pemohon: data['namaPemohon'],
          // pasangan: data['namaPasangan'],
          // tajuk: data['Tajuk'] ?? '',
          // huraian: data['Huraian'] ?? '',
          // tarikh: data['Tarikh'] != null
          //     ? (data['Tarikh'] as Timestamp).toDate()
          //     : null);
    } catch (e) {
      print(e);
      rethrow;
    }

  }

  // to convert object to map string dynamic
  Map<String, Object?> toMap() {
    return {
      'title' : title,
      'description' : description
    };
  }

  Stream<List<Program>> getProgramListStream() {

    final snapshots = FirebaseFirestore.instance
        .collection('program')
        // .orderBy('createdDate', descending: true)
        .snapshots();

    return snapshots.map(
            (snapshot) => snapshot.docs
            .map(
                (e) => Program.fromMap(e.data(), id: e.id)).toList());

  }

}

