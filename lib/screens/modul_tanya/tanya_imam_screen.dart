import 'package:e_masjid/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/user.provider.dart';
import '../../services/firestore_service.dart';
import 'package:e_masjid/widgets/widgets.dart';


class TanyaImamScreen extends StatefulWidget {
  const TanyaImamScreen({super.key});
  static const String routeName = '/tanya';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const TanyaImamScreen(),
    );
  }

  @override
  _TanyaImamScreenState createState() => _TanyaImamScreenState();
}

class _TanyaImamScreenState extends State<TanyaImamScreen> {
  FireStoreService fireStoreService = FireStoreService();
  DateTimeRange dateRange =
      DateTimeRange(start: DateTime(2022, 11, 5), end: DateTime(2022, 12, 24));
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: 'Ask Imam'),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: Center(
            child: Text(
              'Ask Imam',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold ,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(right:10.0 , left: 10.0, bottom: 10.0),
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
                                  Icons.lightbulb_rounded,
                                  color: Colors.yellow,
                                ),
                                SizedBox(
                                  width: 7.w,
                                ),
                                Text(
                                  'Case',
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
                            controller: titleController,
                            autofocus: false,
                            cursorColor: kZambeziColor,
                            keyboardType: TextInputType.name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{5,}$');
                              if (value!.isEmpty) {
                                return ("Please fill in the question title");
                              }
                              if (!regex.hasMatch(value)) {
                                return ("enter at least 5 characters");
                              }
                              return null;
                            },
                            onSaved: (value) {
                              titleController.text = value!;
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              labelText: 'Cth : Apakah Hukum BitCoin..',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Description
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
                                'Question',
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
                          const SizedBox(height: 5),

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
                                return ("Please fill in the question description");
                              }
                              if (!regex.hasMatch(value)) {
                                return ("enter at least 5 characters");
                              }
                              return null;
                            },
                            onSaved: (value) {
                              descController.text = value!;
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              labelText:
                                  'Cth : Cryptocurrency ibarat cendawan tumbuh selepas hujan..',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 15),

                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF43afce)),
                                  onPressed: () {
                                    addTanyaImam();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Ask",
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
                                      backgroundColor: const Color(0xFF43afce)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Cancel",
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

  void addTanyaImam() async {
    try {
      EasyLoading.show(status: 'processing...');
      
      // Validate input
      if (titleController.text.isEmpty || descController.text.isEmpty) {
        EasyLoading.showInfo("Please fill in the question information");
        return;
      }

      // Validate minimum length
      if (titleController.text.length < 5) {
        EasyLoading.showInfo("Title must be at least 5 characters");
        return;
      }

      if (descController.text.length < 5) {
        EasyLoading.showInfo("Description must be at least 5 characters");
        return;
      }

      // Upload data
      await fireStoreService.uploadTanyaData(
        titleController.text, 
        descController.text,
        AppUser().user!.uid
      );

      EasyLoading.showSuccess('Question added successfully');
      Navigator.of(context).popAndPushNamed('/semak');

    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      print('Error in addTanyaImam: $e');
    }
  }
}
