import 'package:e_masjid/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/user.provider.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/widgets.dart';

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
  final FireStoreService fireStoreService = FireStoreService();
  String? _imageUrl;
  
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
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

  @override
  void dispose() {
    pemohonController.dispose();
    jenisKegiatanController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  String getStartTime() {
    return pickedStartTime ? startTimeString : 'Pick Start Time';
  }

  String getEndTime() {
    return pickedEndTime ? endTimeString : 'Pick End Time';
  }

  double calculatePrice() {
    if (!pickedDateRange || !pickedStartTime || !pickedEndTime) return 0.0;
    
    int days = dateRange.end.difference(dateRange.start).inDays + 1;
    
    final startTime24 = DateFormat('HH:mm').parse(startTimeString);
    final endTime24 = DateFormat('HH:mm').parse(endTimeString);
    
    int hoursPerDay = endTime24.hour - startTime24.hour;
    if (endTime24.minute > startTime24.minute) {
      hoursPerDay += 1;
    }
    
    int totalHours = days * hoursPerDay;
    return totalHours * 100.0; // RM100 per hour
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: 'Rent Aula'),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    'Rent Aula',
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
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPemohonSection(),
                            const SizedBox(height: 20),
                            _buildJenisKegiatanSection(),
                            const SizedBox(height: 20),
                            DateTimeRangeSection(
                              startDateController: startDateController,
                              endDateController: endDateController,
                              startTimeText: getStartTime(),
                              endTimeText: getEndTime(),
                              onPickDate: pickDateRange,
                              onPickStartTime: () => pickStartTime(context),
                              onPickEndTime: () => pickEndTime(context),
                            ),
                            _buildPriceSection(),
                            const SizedBox(height: 20),
                            _buildImageUploadSection(),
                            const SizedBox(height: 20),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPemohonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.person, 'Pemohon', Colors.lightBlue),
        const SizedBox(height: 5),
        TextFormField(
          controller: pemohonController,
          autofocus: false,
          cursorColor: kZambeziColor,
          keyboardType: TextInputType.name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value?.isEmpty ?? true) return "Sila isi nama pemohon";
            if (value!.length < 2) return "masukkan minimum 2 aksara";
            return null;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            labelText: 'Full name of applicant',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildJenisKegiatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.event, 'Jenis Kegiatan', Colors.orange),
        const SizedBox(height: 10),
        TextFormField(
          controller: jenisKegiatanController,
          autofocus: false,
          cursorColor: Colors.white,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value?.isEmpty ?? true) return "Sila isi jenis kegiatan";
            if (value!.length < 2) return "masukkan minimum 2 Aksara";
            return null;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            labelText: 'Activity type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    if (!(pickedDateRange && pickedStartTime && pickedEndTime)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Days:',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                'Total Payment:',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildImageUploadSection() {
    return ImagePickerWidget(
      label: 'Payment Proof',
      onImageUploaded: (String url) {
        setState(() {
          _imageUrl = url;
        });
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43afce)),
            onPressed: addSewaAula,
            child: const Text("Apply", style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43afce)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 9.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  void addSewaAula() async {
    try {
      EasyLoading.show(status: 'processing...');
      
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
        EasyLoading.showSuccess('Application added successfully');
        Navigator.of(context).popAndPushNamed('/semak');
      } else {
      EasyLoading.showInfo("Please fill in all the rent aula information");
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  Future<void> pickDateRange() async {
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDateRange != null) {
      setState(() {
        dateRange = newDateRange;
        pickedDateRange = true;
        startDateController.text = DateFormat("dd-MM-yyyy").format(dateRange.start);
        endDateController.text = DateFormat("dd-MM-yyyy").format(dateRange.end);
      });
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (newTime != null) {
      setState(() {
        startTime = newTime;
        startTimeString = startTime.format(context);
        pickedStartTime = true;
      });
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: endTime,
    );

    if (newTime != null) {
      setState(() {
        endTime = newTime;
        endTimeString = endTime.format(context);
        pickedEndTime = true;
      });
    }
  }
}