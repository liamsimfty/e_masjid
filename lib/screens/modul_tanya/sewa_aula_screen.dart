import 'package:e_masjid/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/user.provider.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/image_picker_widget.dart';

class SewaAulaScreen extends StatefulWidget {
  const SewaAulaScreen({super.key});
  static const String routeName = '/sewa-aula';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const SewaAulaScreen(),
    );
  }

  @override
  _SewaAulaScreenState createState() => _SewaAulaScreenState();
}

class _SewaAulaScreenState extends State<SewaAulaScreen> {
  FireStoreService fireStoreService = FireStoreService();
  String? _imageUrl;
  bool _isUploadingImage = false;
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
  );
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  String startTimeString = '';
  String endTimeString = '';

  bool pickedDateRange = false;
  bool pickedStartTime = false;
  bool pickedEndTime = false;

  final pemohonController = TextEditingController();
  final jenisKegiatanController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  String formatDate = '';
  String formatDate2 = '';

  String getStartDate() {
    if (!pickedDateRange) {
      return 'Pilih Tanggal Mula';
    } else {
      return formatDate;
    }
  }

  String getEndDate() {
    if (!pickedDateRange) {
      return 'Pilih Tanggal Tamat';
    } else {
      return formatDate2;
    }
  }

  String getStartTime() {
    if (pickedStartTime != true) {
      return 'Pilih Waktu Mulai';
    } else {
      return startTimeString;
    }
  }

  String getEndTime() {
    if (pickedEndTime != true) {
      return 'Pilih Waktu Tamat';
    } else {
      return endTimeString;
    }
  }

  double calculatePrice() {
    if (!pickedDateRange || !pickedStartTime || !pickedEndTime) return 0.0;
    
    // Calculate number of days
    int days = dateRange.end.difference(dateRange.start).inDays + 1;
    
    // Calculate hours per day
    final startTime24 = DateFormat('HH:mm').parse(startTimeString);
    final endTime24 = DateFormat('HH:mm').parse(endTimeString);
    
    int hoursPerDay = endTime24.hour - startTime24.hour;
    if (endTime24.minute > startTime24.minute) {
      hoursPerDay += 1;
    }
    
    // Calculate total hours
    int totalHours = days * hoursPerDay;
    
    // RM100 per hour
    return totalHours * 100.0;
  }

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
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: Center(
            child: Text(
              'Sewa Aula',
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
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0, bottom: 10.0),
              child: Container(
                margin: EdgeInsets.all(20.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: kPrimaryColor, width: 10),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 0, top: 5, right: 8, bottom: 5),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.lightBlue,
                                ),
                                SizedBox(
                                  width: 9.w,
                                ),
                                Text(
                                  'Pemohon',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: pemohonController,
                            autofocus: false,
                            cursorColor: kZambeziColor,
                            keyboardType: TextInputType.name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{2,}$');
                              if (value!.isEmpty) {
                                return ("Sila isi nama pemohon");
                              }
                              if (!regex.hasMatch(value)) {
                                return ("masukkan minimum 2 aksara");
                              }
                              return null;
                            },
                            onSaved: (value) {
                              pemohonController.text = value!;
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              labelText: 'Nama penuh pemohon',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Jenis Kegiatan
                          Row(
                            children: [
                              const Icon(
                                Icons.event,
                                color: Colors.orange,
                              ),
                              SizedBox(
                                width: 9.w,
                              ),
                              Text(
                                'Jenis Kegiatan',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: jenisKegiatanController,
                            autofocus: false,
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.text,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{2,}$');
                              if (value!.isEmpty) {
                                return ("Sila isi jenis kegiatan");
                              }
                              if (!regex.hasMatch(value)) {
                                return ("masukkan minimum 2 Aksara");
                              }
                              return null;
                            },
                            onSaved: (value) {
                              jenisKegiatanController.text = value!;
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              labelText: 'Jenis Kegiatan',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tarikh
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 9.w),
                              Text(
                                'Tarikh',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // TextField Tarikh
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  enabled: false,
                                  controller: startDateController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  enabled: false,
                                  controller: endDateController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          //button Tarikh
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: pickDateRange,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor),
                                  child: const Text(
                                    'Pilih Waktu',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Masa Mula
                          Row(
                            children: [
                              const Icon(
                                Icons.timelapse,
                                color: Colors.black,
                              ),
                              SizedBox(width: 9.w),
                              Text(
                                'Masa Mula',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          //button masa mula
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    pickStartTime(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor),
                                  child: Text(
                                    getStartTime(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Masa Tamat
                          Row(
                            children: [
                              const Icon(
                                Icons.timelapse,
                                color: Colors.black,
                              ),
                              SizedBox(width: 9.w),
                              Text(
                                'Masa Tamat',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          //button masa tamat
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    pickEndTime(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor),
                                  child: Text(
                                    getEndTime(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Harga
                          if (pickedDateRange && pickedStartTime && pickedEndTime)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Jumlah Hari:',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${dateRange.end.difference(dateRange.start).inDays + 1} hari',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Jumlah Bayaran:',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'RM ${calculatePrice().toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // Add Image Upload Section
                          const SizedBox(height: 20),
                          ImagePickerWidget(
                            label: 'Bukti Pembayaran',
                            onImageUploaded: (String url) {
                              setState(() {
                                _imageUrl = url;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF43afce)),
                                  onPressed: () {
                                    addSewaAula();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Mohon",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF43afce)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Batal",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ]),
      //bottomNavigationBar: const CustomNavBar(),
    );
  }

  void addSewaAula() async {
    try {
      EasyLoading.show(status: 'sedang diproses...');
      if (pemohonController.text.isNotEmpty &&
          jenisKegiatanController.text.isNotEmpty &&
          pickedDateRange &&
          pickedStartTime &&
          pickedEndTime) {
        await fireStoreService.uploadSewaAula(
          pemohonController.text,
          jenisKegiatanController.text,
          dateRange.start,
          startTimeString,
          endTimeString,
          AppUser().user!.uid,
          _imageUrl,
        );
        EasyLoading.showSuccess('Permohonan berjaya ditambah');
        Navigator.of(context).popAndPushNamed('/semak');
        setState(() {});
      } else {
        EasyLoading.showInfo("Sila isi semua maklumat sewa aula");
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      pickedDateRange = true;

      // Format start date
      String a = dateRange.start.toString();
      DateTime parsedDateTime1 = DateTime.parse(a);
      formatDate = DateFormat("dd-MM-yyyy").format(parsedDateTime1);
      startDateController.text = formatDate;

      // Format end date
      String b = dateRange.end.toString();
      DateTime parsedDateTime2 = DateTime.parse(b);
      formatDate2 = DateFormat("dd-MM-yyyy").format(parsedDateTime2);
      endDateController.text = formatDate2;
    });
  }

  Future pickStartTime(BuildContext context) async {
    final newTime = await showTimePicker(context: context, initialTime: startTime);

    if (newTime == null) {
      return;
    } else {
      pickedStartTime = true;
    }

    setState(() {
      startTime = newTime;
      startTimeString = startTime.format(context);
    });
  }

  Future pickEndTime(BuildContext context) async {
    final newTime = await showTimePicker(context: context, initialTime: endTime);

    if (newTime == null) {
      return;
    } else {
      pickedEndTime = true;
    }

    setState(() {
      endTime = newTime;
      endTimeString = endTime.format(context);
    });
  }
}
