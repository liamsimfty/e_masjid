import 'package:e_masjid/models/temujanji_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';


class TemuJanjiProvider extends ChangeNotifier {
  List<Program> temujanjiList;

  TemuJanjiProvider({required this.temujanjiList});

  update() {
    final box = GetStorage();
    box.write('temujanjiList', temujanjiList.map((e) => e.toMap()).toList());

    final list = box.read('temujanjiList');
    print(list);
    notifyListeners();
  }

  addTemujanji(Program temujanji) {
    temujanjiList.add(temujanji);
    update();
  }

  deleteTemujanji(int index) {
    temujanjiList.removeAt(index);
    update();
  }
}