import 'dart:developer';

import 'package:e_masjid/screens/petugas/edit_program.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/screens/semak_balas_screen.dart';
import 'package:e_masjid/services/firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';
import 'package:intl/intl.dart';

class SemakDetail extends StatefulWidget {
  static const String routeName = '/semak_detail';
  final Map<String, dynamic> data;

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => SemakDetail(
        data: {},
      ),
    );
  }

  const SemakDetail({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<SemakDetail> createState() => _SemakDetailState();
}

class _SemakDetailState extends State<SemakDetail> {
  bool floating_visible = false;
  bool sahkan_visible = false;
  bool diSahkan = false;

  String category = "";
  String formatDate = "";
  String formatDate2 = "";

  @override
  void initState() {
    super.initState();

    checkUserRole();
    checkCategory();
    convertTimestampToString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: floating_visible,
        child: FloatingActionButton.extended(
          heroTag: 'sunting_hero',
          onPressed: () {
            setState(() {});
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SemakBalas(id: widget.data["id"]),
                ));
          },
          label: const Text("Balas"),
          icon: const Icon(Icons.edit),
          backgroundColor: kPrimaryColor,
        ),
      ),
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      "Tajuk : ",
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                  Container(
                    child: Text(
                      widget.data["title"],
                      style: TextStyle(
                          fontSize: 25.sp, fontWeight: FontWeight.bold, color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 5.h,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 1, 0),
              child: Text(
                "Jenis Temujanji : " + widget.data["JenisTemuJanji"],
                style: TextStyle(fontSize: 17.sp, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 12, 0),
              child: Text(
                widget.data["description"],
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 40, 1, 0),
              child: Row(children: [
                Text(
                  'Maklumat Temujanji',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                )
              ]),
            ),

            //content
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
              child: Container(
                height: 150.h,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // const Icon(Icons.calendar_month_rounded),

                          widget.data["JenisTemuJanji"] == "Qurban"
                              ? Text(
                                  ' Bilangan Bahagian :',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic),
                                )
                              : Text(
                                  "Tarikh :",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),

                          SizedBox(width: 11.w),
                          Row(
                            children: [
                              //pertanyaan
                              if (widget.data["JenisTemuJanji"] == "Pertanyaan")
                                displayTarikh()

                              //nikah
                              else if (widget.data["JenisTemuJanji"] == "Nikah")
                                displayTarikh()
                              else
                                Text(
                                  widget.data["bilangan"].toString(),
                                  style: TextStyle(fontSize: 15.sp),
                                )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Row(
                        children: [
                          // const Icon(Icons.calendar_month_rounded),
                          Text(
                            ' Pengesahan :  ',
                            style: const TextStyle(
                                fontSize: 15, fontStyle: FontStyle.italic),
                          ),

                          displayIconPengesahan()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 1, 3),
              child: Row(children: [
                Text(
                  'Balasan',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                )
              ]),
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, bottom: 10, top: 10),
                child: Text(
                  widget.data["balasan"],
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                )),
            Visibility(
              visible: sahkan_visible,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, bottom: 25, top: 0),
                child: Center(
                  child: ElevatedButton(
                      onPressed:  () {
                        if (widget.data["isApproved"]) {
                          EasyLoading.showToast("Permohonan sudah disahkan");
                        } else {
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
                              if (category == "Qurban") {
                                sahkanPermohonanQurban();
                              } else if (category == "Nikah") {
                                sahkanPermohonanNikah();
                              } else {
                                sahkanPertanyaan();
                              }

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              // Navigator.of(context).pop();
                              Navigator.of(context).popAndPushNamed('/semak');

                              // Navigator.pushNamed(context, "/semak");
                            },
                          );
                          // set up the AlertDialog
                          AlertDialog alert = AlertDialog(
                            title: const Text("Sahkan Permohonan"),
                            content: const Text(
                                "Anda pasti mahu mengesahkan permohonan?"),
                            actions: [
                              continueButton,
                              cancelButton,
                            ],
                          );

                          // show the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        }
                        setState(() {});
                      },
                      child: Text('Sahkan')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkUserRole() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.data()!["role"].toString() == "petugas") {
        sahkan_visible = true;
        if (category == "Pertanyaan") {
          floating_visible = true;
        }
      } else {
        floating_visible = false;
      }
      setState(() {});
    });
  }

  isButtonDisabled() {
    if (diSahkan = true) {
      return null;
    }
  }

  checkCategory() {
    if (widget.data["JenisTemuJanji"] == "Nikah") {
      category = "Nikah";
    }
    // FireStoreService.updateApprovalNikah();
    else if (widget.data["JenisTemuJanji"] == "Qurban") {
      category = "Qurban";
    } else
      category = "Pertanyaan";
  }

  sahkanPermohonanQurban() {
    try {
      setState(() {
        FireStoreService().updateApprovalQurban(widget.data["id"]);
        diSahkan = true;
      });
    } catch (e) {
      print(e);
    }
  }

  sahkanPermohonanNikah() {
    try {
      setState(() {
        FireStoreService().updateApprovalNikah(widget.data["id"]);
        diSahkan = true;
      });
    } catch (e) {
      print(e);
    }
  }

  sahkanPertanyaan() {
    try {
      setState(() {
        FireStoreService().updateApprovalPertanyaan(widget.data["id"]);
        diSahkan = true;
      });
    } catch (e) {
      print(e);
    }
  }

  convertTimestampToString() {
    //first date
    try {
      if (widget.data['firstDate'] is Timestamp) {
        Timestamp t = widget.data["firstDate"];
        String d = t.toDate().toString();
        DateTime parsedDateTime = DateTime.parse(d);
        formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime);

        //second date
        Timestamp t1 = widget.data["lastDate"];
        String d1 = t1.toDate().toString();
        DateTime parsedDateTime1 = DateTime.parse(d1);
        formatDate2 = DateFormat("dd-MM-yyyy").format(parsedDateTime1);
      } else {
        DateTime t = widget.data["firstDate"];
        String d = t.toString();
        DateTime parsedDateTime = DateTime.parse(d);
        formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime);

        //second date
        DateTime t1 = widget.data["lastDate"];
        String d1 = t1.toString();
        DateTime parsedDateTime1 = DateTime.parse(d1);
        formatDate2 = DateFormat("dd-MM-yyyy").format(parsedDateTime1);
      }
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  isApprovedIcon() {
    if (widget.data["isApproved"])
      return Icon(
        Icons.check,
        color: Colors.green,
      );
    else
      return Icon(
        Icons.close,
        color: Colors.red,
      );
  }

  Widget displayIconPengesahan() {
    if (widget.data["isApproved"])
      return Icon(
        Icons.check,
        color: Colors.green,
      );
    else
      return Icon(
        Icons.close,
        color: Colors.red,
      );
  }

  Widget displayTarikh() {
    //first date

    Timestamp t = widget.data["tarikh"];
    print(t);
    String d = t.toDate().toString();
    DateTime parsedDateTime = DateTime.parse(d);
    formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime);
    return Text(
      formatDate,
      style: TextStyle(fontSize: 15.sp),
    );

    // setState(() {});
  }
}
