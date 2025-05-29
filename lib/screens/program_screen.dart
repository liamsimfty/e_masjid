import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/screens/petugas/program_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// import 'package:e_masjid/screens/petugas/add_program_screen.dart';
import '../config/constants.dart';
import 'package:e_masjid/screens/petugas/add_program_screen.dart';
import '../widgets/custom_navbar.dart';

class ProgramScreen extends StatefulWidget {
  static const String routeName = '/program';

  const ProgramScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const ProgramScreen(),
    );
  }

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  bool isDaily = false;
  bool visible = false;
  bool notvisible = false;
  bool loading = true;
  String date = '';
  String date2 = '';
  String masaMula = '';
  String masaTamat = '';
  String formatDate = "";
  String formatDate2 = "";

  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now();

  String? _selectedView = "Semua";
  final List<String> _type = ['Harian', 'Mingguan', 'Bulanan', 'Semua'];

  @override
  void initState() {
    super.initState();
    getData();
    calculateDaily();
    checkUserRole();
  }

  List<Map<String, dynamic>> programs = [];
  List<Map<String, dynamic>> dailyList = [];
  List<Map<String, dynamic>> weeklyList = [];
  List<Map<String, dynamic>> monthlyList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating action button sunting
      floatingActionButton: Visibility(
        visible: visible,
        child: FloatingActionButton.extended(
          heroTag: 'servis_hero',
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddProgramScreen()));
          },
          label: const Text(" Program"),
          icon: const Icon(Icons.add),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 10),
                    child: Text(
                      'Jadual',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Program',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, top: 20, right: 20, bottom: 10),
                  child: DropdownButtonFormField<String>(
                    hint: Text(_selectedView!),
                    items: _type.map((view) {
                      return DropdownMenuItem<String>(
                        value: view,
                        child: Text(view),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      //daily view
                      if (newValue == "Harian") {
                        setState(() {
                          _selectedView = newValue;

                          programs.clear();
                          dailyList.clear();
                          getDataDaily();
                        });

                        //weekly view
                      } else if (newValue == "Mingguan") {
                        setState(() {
                          _selectedView = newValue;
                          programs.clear();
                          weeklyList.clear();
                          //get all data from db into programsList
                          //the output is programs[] (list full of programs item)

                          getDataWeekly();
                        });

                        //all view
                      } else if (newValue == "Semua") {
                        programs.clear();
                        setState(() {
                          _selectedView = newValue;
                          getData();
                        });

                        //monthly view
                      } else {
                        setState(() {
                          _selectedView = newValue;
                          programs.clear();
                          monthlyList.clear();
                          getDataMonthly();
                        });
                      }
                    },
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: loading
                ? const SizedBox(
                    width: double.infinity,
                    child: Center(child: CircularProgressIndicator()))
                : ListView.builder(
                    key: UniqueKey(),
                    physics: const BouncingScrollPhysics(),
                    itemCount: programs.length,
                    itemBuilder: ((context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => ProgramDetail(
                                        data: programs[index],
                                      )));
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                          height: 130,
                          decoration: const BoxDecoration(
                              color: Color(0xFFA6E9FC),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 35.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    programs[index]["title"],
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Row(children: [
                                    // const Icon(Icons.calendar_month_rounded),
                                    Text(
                                      programs[index]["description"],
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Row(children: [getDate(index)]),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Row(children: [getTime(index)]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
      bottomNavigationBar:
          Visibility(visible: notvisible, child: const CustomNavBar()),
    );
  }

  //get all data into list
  Future getData() async {
    await FirebaseFirestore.instance.collection("program").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        programs.add(data);
      }

      //to sort list item
      programs.sort((a, b) {
        var adate = a['firstDate'];
        var bdate = b['lastDate'];
        return adate.compareTo(bdate);
      });

      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //get all data into list (WEEKLY)
  Future getDataWeekly() async {
    await FirebaseFirestore.instance.collection("program").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        programs.add(data);
      }

      DateTime now = DateTime.now();
      print(now);
      final dateWeek = DateTime(now.year, now.month, now.day + 7);

      //we have a full programs[list] here

      for (final program in programs) {
        Timestamp dateWeekly = program['firstDate'];
        DateTime dateWeekly2 = dateWeekly.toDate();

        if (now.isBefore(dateWeekly2) && dateWeek.isAfter(dateWeekly2)) {
          weeklyList.add(program);
        }
        // if(now==dateWeekly2){
        //   weeklyList.add(program);
        // }
      }
      programs.clear();
      programs.addAll(weeklyList);

      programs.sort((a, b) {
        var adate = a['firstDate'];
        var bdate = b['lastDate'];
        return adate.compareTo(bdate);
      });

      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //get all data into list (DAILY)
  Future getDataDaily() async {
    await FirebaseFirestore.instance.collection("program").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        programs.add(data);
      }

      DateTime now = DateTime.now();

      //we have a full programs[list] here
      for (final program in programs) {
        Timestamp dateWeekly = program['firstDate'];
        DateTime dateWeekly2 = dateWeekly.toDate();

        print(dateWeekly2);
        print(now);

        if (now.compareTo(dateWeekly2) > 0) {
          dailyList.add(program);
        }
      }
      programs.clear();
      programs.addAll(dailyList);

      programs.sort((a, b) {
        var adate = a['firstDate'];
        var bdate = b['lastDate'];
        return adate.compareTo(bdate);
      });

      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //get all data into list (MONTHLY)
  Future getDataMonthly() async {
    await FirebaseFirestore.instance.collection("program").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        programs.add(data);
      }

      DateTime now = DateTime.now();

      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

      //we have a full programs[list] here
      for (final program in programs) {
        Timestamp dateWeekly = program['firstDate'];
        DateTime dateWeekly2 = dateWeekly.toDate();

        if (firstDayOfMonth.isBefore(dateWeekly2) &&
            lastDayOfMonth.isAfter(dateWeekly2)) {
          monthlyList.add(program);
        }
      }
      programs.clear();
      programs.addAll(monthlyList);

      programs.sort((a, b) {
        var adate = a['firstDate'];
        var bdate = b['lastDate'];
        return adate.compareTo(bdate);
      });

      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //check user role
  checkUserRole() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.data()!["role"].toString() == "petugas") {
        visible = true;
      } else {
        notvisible = true;
        visible = false;
      }
      setState(() {});
    });
  }

  showBottomBar() {
    if (visible = true) {
    } else {
      return const CustomNavBar();
    }
  }

  Widget getDate(int index) {
    // getData();
    date = programs[index]['firstDate'].toDate().toString();
    DateTime parsedDateTime = DateTime.parse(date);
    formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime);

    date2 = programs[index]['lastDate'].toDate().toString();
    DateTime parsedDateTime2 = DateTime.parse(date2);
    formatDate2 = DateFormat("dd-MM-yyyy").format(parsedDateTime2);

    return Text("Tarikh : $formatDate  -  $formatDate2", style: const TextStyle(fontSize: 12),);
  }

  Widget getFirstDate(int index) {
    // getData();
    date = programs[index]['firstDate'].toDate().toString();
    DateTime parsedDateTime = DateTime.parse(date);
    formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime);

    return Text("Tarikh : $formatDate  ");
  }

  Widget getTime(int index) {
    masaMula = programs[index]['masaMula'];
    masaTamat = programs[index]['masaTamat'];
    return Text("Masa : $masaMula  -  $masaTamat", style: const TextStyle(fontSize: 12));
  }


  calculateDaily() {
    DateTime now = DateTime.now();
    final day = DateTime.now().day;
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    for (var day in programs) {
      if (day == today) {
        dailyList.add(day);
      }
    }

    if (mounted) {
      loading = false;
      setState(() {});
    }
  }

  calculateWeekly(int index) {
    //get current date
    DateTime now = DateTime.now();
    final dateWeek = DateTime(now.year, now.month, now.day + 7);

    firstDate = programs[index]['firstDate'];

    if (now.isBefore(firstDate) && dateWeek.isAfter(firstDate)) {
      print("this is in the week");
    }
  }

  calculateMonthly() {
    final month = DateTime.now().month;
    final day = DateTime.now().day;
    final year = DateTime.now().year;
    final days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
  }
}
