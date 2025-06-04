import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../services/firestore_service.dart';
import '../../providers/user.provider.dart';
import '../../widgets/image_picker_widget.dart';

class DermaScreen extends StatefulWidget {
  static const String routeName = '/derma';
  const DermaScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const DermaScreen(),
    );
  }

  @override
  State<DermaScreen> createState() => _DermaScreenState();
}

class _DermaScreenState extends State<DermaScreen> {
  final amountController = TextEditingController();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  FireStoreService fireStoreService = FireStoreService();
  String? _imageUrl;

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
            ),
          ),
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
          const Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: Center(
              child: Text(
                'Derma Masjid',
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
                            // Image Picker
                            ImagePickerWidget(
                              label: 'Bukti Derma',
                              onImageUploaded: (String url) {
                                setState(() {
                                  _imageUrl = url;
                                });
                              },
                            ),
                            const SizedBox(height: 15),

                            // Amount
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 0,
                                top: 5,
                                right: 8,
                                bottom: 5,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 7.w),
                                  Text(
                                    'Jumlah Derma (RM)',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                labelText: 'Masukkan jumlah derma',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Name
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 7.w),
                                Text(
                                  'Nama',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                labelText: 'Masukkan nama anda',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Description
                            Row(
                              children: [
                                const Icon(
                                  Icons.description,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 7.w),
                                Text(
                                  'Deskripsi',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: descController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                labelText: 'Masukkan Deskripsi',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF43afce),
                                    ),
                                    onPressed: () {
                                      processDonation();
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Derma",
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
                                      backgroundColor: const Color(0xFF43afce),
                                    ),
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
        ],
      ),
    );
  }

  void processDonation() async {
    try {
      EasyLoading.show(status: 'sedang diproses...');
      
      // Validate input
      if (amountController.text.isEmpty || 
          nameController.text.isEmpty || 
          descController.text.isEmpty) {
        EasyLoading.showInfo("Sila isi semua maklumat");
        return;
      }

      // Upload donation data
      await fireStoreService.uploadDonationData(
        amountController.text,
        nameController.text,
        descController.text,
        AppUser().user!.uid,
        _imageUrl,
      );

      EasyLoading.showSuccess('Derma berjaya dihantar');
      Navigator.of(context).pop();

    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Ralat: ${e.toString()}');
      print('Error in processDonation: $e');
    }
  }
}