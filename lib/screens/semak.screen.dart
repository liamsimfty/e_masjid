import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/screens/semak_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/user.provider.dart';
import '../widgets/custom_navbar.dart';

class SemakStatusScreen extends StatefulWidget {
  static const String routeName = '/semak';

  const SemakStatusScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const SemakStatusScreen(),
    );
  }

  @override
  State<SemakStatusScreen> createState() => _SemakStatusScreenState();
}

class _SemakStatusScreenState extends State<SemakStatusScreen> {
  bool loading = true;
  bool visible = false;
  bool isTanya = true;
  bool isNikah = false;
  bool notvisible = false;
  String date = '';
  String? _selectedView = "Tanya Imam";
  final List<String> _type = ['Tanya Imam', 'Nikah', 'Qurban'];

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  List<Map<String, dynamic>> mainList = [];
  List<Map<String, dynamic>> pertanyaanList = [];
  List<Map<String, dynamic>> nikahList = [];
  List<Map<String, dynamic>> qurbanList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      'Semak',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Status',
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
                      mainList.clear();
                      if (newValue == "Nikah") {
                        setState(() {
                          _selectedView = newValue;
                          mainList.addAll(nikahList);
                        });
                      } else if (newValue == "Qurban") {
                        setState(() {
                          _selectedView = newValue;
                          mainList.addAll(qurbanList);
                        });
                      } else {
                        setState(() {
                          _selectedView = newValue;
                          mainList.addAll(pertanyaanList);
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
                    itemCount: mainList.length,
                    itemBuilder: ((context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => SemakDetail(
                                        data: mainList[index],
                                      )));
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                          height: 110,
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                         Text(
                                          mainList[index]["title"],
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),

                                        mainList[index]["isApproved"]
                                            ?  const Padding(
                                              padding: EdgeInsets.only(right: 20.0),
                                              child: Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                ),
                                            )
                                            : const Padding(
                                              padding: EdgeInsets.only(right: 20.0),
                                              child: Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
                                            )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    Row(children: [
                                      // const Icon(Icons.calendar_month_rounded),
                                      Flexible(
                                        child: Text(
                                          mainList[index]["description"],
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ]),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    // Row(children: [getDate(index)]),
                                  ],
                                ),
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
      bottomNavigationBar: Visibility(
          visible: notvisible,
          child: const CustomNavBar()),
    );
  }

  //get specific user tanya data into list
  Future getTanyaData() async {
    await FirebaseFirestore.instance.collection("tanya").where("authorId", isEqualTo: AppUser().user!.uid ).get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        pertanyaanList.add(data);
      }
      mainList.addAll(pertanyaanList);


      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //get all tanya data into list
  Future getAllTanyaData() async {
    await FirebaseFirestore.instance.collection("tanya").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        pertanyaanList.add(data);
      }
      mainList.addAll(pertanyaanList);

      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //get only nikah data for specific user into list
  Future getNikahData() async {
    await FirebaseFirestore.instance.collection("nikah").where("authorId", isEqualTo: AppUser().user!.uid ).get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        nikahList.add(data);
      }


      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //get all nikah data into list
  Future getAllNikahData() async {
    await FirebaseFirestore.instance.collection("nikah").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        nikahList.add(data);
      }
      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }
  //get specific user qurban data into list
  Future getQurbanData() async {
    await FirebaseFirestore.instance.collection("qurban").where("authorId", isEqualTo: AppUser().user!.uid ).get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        qurbanList.add(data);
      }


      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  //get qurban data into list
  Future getAllQurbanData() async {
    await FirebaseFirestore.instance.collection("qurban").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data();
        data.addAll({'id': element.id});
        qurbanList.add(data);
      }
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
        getAllTanyaData();
        getAllNikahData();
        getAllQurbanData();
        visible = true;
      } else {
        getTanyaData();
        getNikahData();
        getQurbanData();
        visible = false;
        notvisible = true;
      }
      setState(() {});
    });
  }
}
