import 'package:e_masjid/screens/petugas/edit_program.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';
import 'package:intl/intl.dart';

class ProgramDetail extends StatefulWidget {
  static const String routeName = '/program_detail';
  final Map<String, dynamic> data;

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const ProgramDetail(
        data: {},
      ),
    );
  }

  const ProgramDetail({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<ProgramDetail> {
  bool visible = false;

  String formatDate = "";
  String formatDate2 = "";

  @override
  void initState() {
    super.initState();
    checkUserRole();
    convertTimestampToString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: visible,
        child: FloatingActionButton.extended(
          heroTag: 'sunting_hero',
          onPressed: () {
            setState(() {});
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProgram(id: widget.data["id"]),
                ));
          },
          label: const Text("Sunting"),
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
          icon: const Icon(
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
          children: [
            Padding(
              padding: const EdgeInsets.only(left:24.0, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      "Program : ",
                      style:
                      TextStyle(fontSize: 20.sp),
                    ),
                  ),
                  Container(
                    child: Text(
                      widget.data["title"],
                      style:
                          TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold, color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5.h,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 1, 5),
              child: Row(children: [
                Text(
                  'Tentatif Program',
                  style:
                  TextStyle(fontSize: 20.sp,),
                )
              ]),
            ),

            //content
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
              child: Container(
                height: 130.h,
                decoration: const BoxDecoration(
                    color: Color(0xFFA6E9FC),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // const Icon(Icons.calendar_month_rounded),
                          const Text(
                            ' Tarikh :',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(width: 11.w),
                          Row(
                            children: [
                              Text(
                                formatDate,
                                style: const TextStyle(
                                  fontSize: 15,),
                              ),
                              const Text(
                                '  -  ',
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                formatDate2,
                                style: const TextStyle(
                                  fontSize: 15, ),
                              ),
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
                          const Text(
                            ' Masa :  ',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            widget.data["masaMula"],
                            style: const TextStyle(
                                fontSize: 15),
                          ),
                          const Text(
                            '  -  ',
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            widget.data["masaTamat"],
                            style: const TextStyle(
                                fontSize: 15),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 1, 5),
              child: Row(children: [
                Text(
                  'Huraian Program',
                  style:
                  TextStyle(fontSize: 20.sp, ),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 25, right: 25, bottom: 25, top: 10),
              child: Container(
                height: 200.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Color(0xFFA6E9FC),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    widget.data["description"],
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                    
                  ),
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
        visible = true;
      } else {
        visible = false; 
      }

      setState(() {});
    });
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

}
