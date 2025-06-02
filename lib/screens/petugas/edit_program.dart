import 'package:e_masjid/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/screens/petugas/program_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../config/constants.dart';

class EditProgram extends StatefulWidget {
  final String id;
  final Map<String, dynamic> programData;

  const EditProgram({
    super.key,
    required this.id,
    required this.programData,
  });

  @override
  State<EditProgram> createState() => _EditProgramState();
}

class _EditProgramState extends State<EditProgram> {
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  TimeOfDay time2 = TimeOfDay.now();
  String timeString = '';
  String timeString2 = '';

  bool pickedDate = false;
  bool pickedTime = false;
  bool pickedTime2 = false;

  FireStoreService fireStoreService = FireStoreService();
  DateTimeRange dateRange = DateTimeRange(
      start: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      end: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day));
  String formatDate = '';
  String formatDate2 = '';
  bool loading = true;
  late DocumentSnapshot<Map<String, dynamic>> data;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final startDateController = TextEditingController();
  final lastDateController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fireStoreService.getdataProgram(widget.id).then((value) {
      data = value;
      titleController.text = data["title"];
      descController.text = data["description"];

      //first date
      Timestamp t = data["firstDate"];
      print(t);
      String d = t.toDate().toString();
      DateTime parsedDateTime = DateTime.parse(d);
      formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime);

      //first date
      Timestamp t2 = data["lastDate"];
      print(t2);
      String d2 = t2.toDate().toString();
      DateTime parsedDateTime2 = DateTime.parse(d2);
      formatDate2 = DateFormat("dd-MM-yyyy").format(parsedDateTime2);

      startDateController.text = formatDate;

      lastDateController.text = formatDate2;

      print(formatDate);
      print(formatDate2);
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  String getMasa() {
    if (pickedTime != true) {
      return 'Pilih Masa Mula';
    } else {
      final hours = time.hour.toString().padLeft(2, '0');
      final minutes = time.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    }
  }

  String getMasaTamat() {
    if (pickedTime2 != true) {
      return 'Pilih Masa Tamat';
    } else {
      final hours2 = time2.hour.toString().padLeft(2, '0');
      final minutes2 = time2.minute.toString().padLeft(2, '0');
      return '$hours2:$minutes2';
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 50.0, top: 15),
          child: Center(
              child: Image.asset(
            'assets/images/e_masjid.png',
            height: 50,
          )),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: loading
          ? Center(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  child: const CircularProgressIndicator()))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    'Sunting Program',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [
                    Container(
                      margin:
                          EdgeInsets.only(left: 20.w, right: 20.w, top: 20.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: kPrimaryColor, width: 10),
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20, top: 20, bottom: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //title
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_rounded,
                                      color: Colors.yellow,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      'Tajuk',
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                TextFormField(
                                  controller: titleController,
                                  autofocus: false,
                                  cursorColor: Colors.white,
                                  keyboardType: TextInputType.name,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    RegExp regex = RegExp(r'^.{5,}$');
                                    if (value!.isEmpty) {
                                      return ("Sila isi butiran nama program");
                                    }
                                    if (!regex.hasMatch(value)) {
                                      return ("masukkan minimum 5 huruf");
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    titleController.text = value!;
                                  },
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 15, 20, 15),
                                    labelText: '',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                //description
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_note_outlined,
                                      color: Colors.teal,
                                    ),
                                    SizedBox(
                                      width: 7.w,
                                    ),
                                    Text(
                                      'Huraian',
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: descController,
                                  autofocus: false,
                                  cursorColor: Colors.white,
                                  keyboardType: TextInputType.name,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    RegExp regex = RegExp(r'^.{5,}$');
                                    if (value!.isEmpty) {
                                      return ("Sila isi butiran description");
                                    }
                                    if (!regex.hasMatch(value)) {
                                      return ("masukkan minimum 5 huruf");
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    titleController.text = value!;
                                  },
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 15, 20, 15),
                                    labelText: '',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Tarikh
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Text(
                                      'Tarikh',
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                //TextField Tarikh
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        enabled: false,
                                        controller: startDateController,
                                        autofocus: false,
                                        cursorColor: Colors.white,
                                        keyboardType: TextInputType.name,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onSaved: (value) {
                                          startDateController.text = value!;
                                        },
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  20, 15, 20, 15),
                                          // labelText:
                                          // '${start.year}/${start.month}/${start.day}',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        enabled: false,
                                        controller: lastDateController,
                                        autofocus: false,
                                        cursorColor: Colors.white,
                                        keyboardType: TextInputType.name,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onSaved: (value) {
                                          lastDateController.text = value!;
                                        },
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  20, 15, 20, 15),
                                          // labelText:
                                          // '${end.year}/${end.month}/${end.day}',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: ElevatedButton(
                                      onPressed: pickDateRange,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimaryColor),
                                      child: const Text(
                                        'Pilih Tarikh',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )),
                                  ],
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                // Masa Mula
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.query_builder_rounded,
                                      color: Colors.pink,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      'Masa Mula',
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),

                                //button masa mula
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          pickTime(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor),
                                        child: Text(
                                          getMasa(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.query_builder_rounded,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      'Masa Tamat',
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),

                                //button masa Tamat
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          pickTimeEnd(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor),
                                        child: Text(
                                          getMasaTamat(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                //button
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10, bottom: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 15.w,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF43afce),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      minimumSize: const Size(100, 40),
                                    ),
                                    onPressed: () {
                                      EasyLoading.show(
                                          status: 'Sedang diproses');
                                      print(timeString);
                                      print(timeString2);
                                      fireStoreService
                                          .updateServiceData(
                                        titleController.text,
                                        descController.text,
                                        dateRange.start,
                                        dateRange.end,
                                        timeString,
                                        timeString2,
                                        widget.id,
                                      )
                                          // imageNetworkList)
                                          .then((value) {
                                        EasyLoading.showSuccess(
                                            "Kemaskini Info Program Berjaya");
                                        Map<String, dynamic> a = data.data()!;
                                        a.addAll({'id': widget.id});
                                        // a.update('ser_pic',
                                        //         (value) => imageNetworkList);

                                        a.update('title',
                                            (value) => titleController.text);
                                        a.update('description',
                                            (value) => descController.text);

                                        a.update('firstDate',
                                            (value) => dateRange.start);
                                        a.update('lastDate',
                                            (value) => dateRange.end);
                                        a.update(
                                            'masaMula', (value) => timeString);
                                        a.update('masaTamat',
                                            (value) => timeString2);

                                        Navigator.pop(context);
                                        // Navigator.pushNamed(
                                        //     context, '/program_detail');
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProgramDetail(data: a)));
                                      });
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Simpan",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF43afce),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      minimumSize: const Size(100, 40),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Batal",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // set up the buttons
                                    Widget cancelButton = TextButton(
                                      child: const Text("Tidak"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                    Widget continueButton = TextButton(
                                      child: const Text("Ya"),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection("program")
                                            .doc(widget.id)
                                            .delete();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        // Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .popAndPushNamed('/program');
                                      },
                                    );

                                    // set up the AlertDialog
                                    AlertDialog alert = AlertDialog(
                                      title: const Text("Padam Program"),
                                      content: const Text(
                                          "Anda pasti mahu padam program?"),
                                      actions: [
                                        cancelButton,
                                        continueButton,
                                      ],
                                    );

                                    // show the dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ]),
                ),
              )
            ]),
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    //press cancel x
    if (newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;

      //first date
      String a = dateRange.start.toString();
      DateTime parsedDateTime1 = DateTime.parse(a);
      formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime1);
      startDateController.text = formatDate;

      //first date
      String b = dateRange.end.toString();
      DateTime parsedDateTime2 = DateTime.parse(b);
      formatDate2 = DateFormat("dd-MM-yyyy").format(parsedDateTime2);
      lastDateController.text = formatDate2;
    });
  }

  Future pickTime(BuildContext context) async {
    const initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
        context: context, initialTime: time ?? initialTime);

    if (newTime == null) return;

    pickedTime = true;

    setState(() => time = newTime);

    timeString = time.format(context).toString();
  }

  Future pickTimeEnd(BuildContext context) async {
    const initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
        context: context, initialTime: time2 ?? initialTime);

    if (newTime == null) return;

    pickedTime2 = true;

    setState(() => time2 = newTime);
    timeString2 = time2.format(context).toString();
  }
}
