import 'package:e_masjid/screens/semak_detail_screen.dart';
import 'package:e_masjid/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants.dart';

class SemakBalas extends StatefulWidget {
  final String id;

  const SemakBalas({
    super.key,
    required this.id,
  });

  @override
  State<SemakBalas> createState() => _SemakBalasState();
}

class _SemakBalasState extends State<SemakBalas> {
  FireStoreService fireStoreService = FireStoreService();

  bool loading = true;
  late DocumentSnapshot<Map<String, dynamic>> data;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final balasanController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fireStoreService.getdataTanya(widget.id).then((value) {
      data = value;
      titleController.text = data["title"];
      descController.text = data["description"];
      balasanController.text = data["balasan"];

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                SizedBox(
                  height: 10.h,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Balas',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 25.0,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'TemuJanji',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: 20.w, right: 20.w, top: 20.w),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: kZambeziColor, width: 1),
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 20,
                                      top: 20,
                                      bottom: 25),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //title
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.lightbulb_rounded,
                                            color: Colors.yellow,
                                          ),
                                          SizedBox(
                                            width: 7.w,
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
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
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
                                      const SizedBox(height: 3),
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
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  20, 15, 20, 15),
                                          labelText: '',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      //Balasan
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.note_alt,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(
                                            width: 7.w,
                                          ),
                                          Text(
                                            'Balasan',
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
                                      const SizedBox(height: 3),
                                      TextFormField(
                                        controller: balasanController,
                                        maxLines: 5,
                                        maxLength: 256,
                                        autofocus: false,
                                        cursorColor: Colors.white,
                                        keyboardType: TextInputType.name,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (value) {
                                          RegExp regex = RegExp(r'^.{5,}$');
                                          if (value!.isEmpty) {
                                            return ("Sila isi butiran balasan");
                                          }
                                          if (!regex.hasMatch(value)) {
                                            return ("masukkan minimum 5 huruf");
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          balasanController.text = value!;
                                        },
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  20, 15, 20, 15),
                                          labelText: '',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),

                                       SizedBox(
                                        height: 20.h,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10, bottom: 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(
                                              width: 15.w,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: kPrimaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  minimumSize: const Size(100, 40),
                                                ),
                                                onPressed: () {
                                                  EasyLoading.show(
                                                      status:
                                                          'Sedang diproses');

                                                  setState(() {
                                                    fireStoreService
                                                        .updateBalasan(
                                                      titleController.text,
                                                      descController.text,
                                                      balasanController.text,
                                                      widget.id,
                                                    )
                                                        .then((value) {
                                                      EasyLoading.showSuccess(
                                                          "Kemaskini Info Program Berjaya");
                                                      Map<String, dynamic> a =
                                                      data.data()!;
                                                      a.addAll({'id': widget.id});
                                                      // a.update('ser_pic',
                                                      //         (value) => imageNetworkList);

                                                      a.update(
                                                          'title',
                                                              (value) =>
                                                          titleController
                                                              .text);
                                                      a.update(
                                                          'description',
                                                              (value) =>
                                                          descController
                                                              .text);
                                                      a.update(
                                                          'balasan',
                                                              (value) =>
                                                          balasanController
                                                              .text);


                                                      Navigator.pop(context);

                                                      setState(() {

                                                      });

                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SemakDetail(
                                                                      data: a)));

                                                    });
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.save,
                                                      color: Colors
                                                          .lightGreenAccent,
                                                    ),
                                                    SizedBox(
                                                      width: 7.w,
                                                    ),
                                                    Text(
                                                      "Simpan",
                                                      style: TextStyle(
                                                          fontSize: 16.sp),
                                                    ),
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
                                                  backgroundColor: kPrimaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  minimumSize: const Size(100, 40),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.cancel,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(
                                                      width: 7.w,
                                                    ),
                                                    Text(
                                                      "Batal",
                                                      style: TextStyle(
                                                          fontSize: 16.sp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                // set up the buttons
                                                Widget cancelButton =
                                                    TextButton(
                                                  child: const Text("Tidak"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                Widget continueButton =
                                                    TextButton(
                                                  child: const Text("Ya"),
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection("tanya")
                                                        .doc(widget.id)
                                                        .delete();
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                    // Navigator.of(context).pop();
                                                    Navigator.of(context)
                                                        .popAndPushNamed(
                                                            '/semak');
                                                  },
                                                );

                                                // set up the AlertDialog
                                                AlertDialog alert = AlertDialog(
                                                  title: const Text(
                                                      "Padam Soalan"),
                                                  content: const Text(
                                                      "Anda pasti mahu padam soalan?"),
                                                  actions: [
                                                    continueButton,
                                                    cancelButton,
                                                  ],
                                                );

                                                // show the dialog
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
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
                      ])),
                )
              ]));
  }
}
