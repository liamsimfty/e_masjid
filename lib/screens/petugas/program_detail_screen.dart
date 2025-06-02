import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/screens/petugas/edit_program.dart'; // For navigation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class ProgramDetail extends StatefulWidget {
  static const String routeName = '/program_detail';
  final Map<String, dynamic> data;

  static Route route({required Map<String, dynamic> data}) {
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        pageBuilder: (_, __, ___) => ProgramDetail(data: data),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        });
  }

  const ProgramDetail({
    super.key,
    required this.data,
  });

  @override
  State<ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<ProgramDetail>
    with SingleTickerProviderStateMixin {
  bool _isPetugas = false;

  String _formattedStartDate = "N/A";
  String _formattedEndDate = "N/A";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Adjusted duration
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _checkUserRole();
    _prepareDateStrings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isPetugas = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          _isPetugas = (doc.exists && doc.data()?["role"] == "petugas");
        });
      }
    } catch (e) {
      print("Error checking user role: $e");
      if (mounted) setState(() => _isPetugas = false);
    }
  }

  void _prepareDateStrings() {
    try {
      dynamic firstDateData = widget.data["firstDate"];
      dynamic lastDateData = widget.data["lastDate"];
      DateFormat formatter = DateFormat("dd MMMM yyyy", "ms_MY");

      if (firstDateData is Timestamp) {
        _formattedStartDate = formatter.format(firstDateData.toDate());
      } else if (firstDateData is DateTime) {
        _formattedStartDate = formatter.format(firstDateData);
      }

      if (lastDateData is Timestamp) {
        _formattedEndDate = formatter.format(lastDateData.toDate());
      } else if (lastDateData is DateTime) {
        _formattedEndDate = formatter.format(lastDateData);
      }

      // If dates are the same, only show start date effectively
      if (_formattedStartDate == _formattedEndDate) {
        _formattedEndDate = ""; // Clear end date to avoid "Date - "
      }
    } catch (e) {
      print("Error formatting dates in ProgramDetail: $e");
      _formattedStartDate = "Ralat Tarikh";
      _formattedEndDate = "";
    }
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.85),
            kPrimaryColor,
            kPrimaryColor.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: screenHeight * -0.05,
          left: screenWidth * -0.15,
          child: Container(
            width: screenWidth * 0.45,
            height: screenWidth * 0.45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: screenHeight * -0.1,
          right: screenWidth * -0.2,
          child: Container(
            width: screenWidth * 0.6,
            height: screenWidth * 0.6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.data["title"] ?? "Tiada Tajuk";
    String description = widget.data["description"] ?? "Tiada huraian.";
    String masaMula = widget.data["masaMula"] ?? "N/A";
    String masaTamat = widget.data["masaTamat"] ?? "N/A";

    // Prepare list of widgets for animation
    List<Widget> contentWidgets = [
      _buildTitleCard(title),
      SizedBox(height: 16.h),
      _buildScheduleCard(masaMula, masaTamat),
      SizedBox(height: 16.h),
      _buildDescriptionCard(description),
      SizedBox(height: 80.h), // Space for FAB
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: Visibility(
        visible: _isPetugas,
        child: FloatingActionButton.extended(
          heroTag: 'sunting_program_hero_detail', // Ensure unique heroTag
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProgram(
                    id: widget.data["id"], programData: widget.data),
              ),
            );
            // If EditProgram returns true (or some indicator of change), refresh data
            if (result == true && mounted) {
              // You might need to re-fetch widget.data or have a way to update it.
              // For simplicity, this example assumes the parent screen handles refresh
              // or that Firestore streams update the data.
              // If you need to force a refresh of this specific screen's data,
              // you'd typically call a method here that re-fetches and updates `widget.data` via `setState`.
              // However, since widget.data is final, this screen would need to be re-instantiated
              // or the parent would pass updated data.
              // A common pattern is to pop with a result that tells the parent to refresh.
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Memuat semula data... (Contoh)")));
            }
          },
          label: const Text("Sunting",
              style: TextStyle(fontWeight: FontWeight.w600)),
          icon: const Icon(Icons.edit_outlined),
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColor,
          elevation: 6.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
      ),
      appBar: AppBar(
        title: const Text('Butiran Program'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildDecorativeCircles(context),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      contentWidgets.length,
                      (index) => AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: (index * 50)), // Stagger delay
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: contentWidgets[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard(String title) {
    return Card(
      elevation: 4.0, // Slightly more elevation for the main title card
      shadowColor: Colors.black.withOpacity(0.2),
      color: Colors.white.withOpacity(0.95), // More opaque card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.w, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article_outlined, // Changed icon
                    color: kPrimaryColorDark,
                    size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  "Nama Program / Aktiviti",
                  style: TextStyle(
                      fontSize: 13.sp, // Sub-header style
                      color: kPrimaryColorDark.withOpacity(0.8),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColorDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String masaMula, String masaTamat) {
    return Card(
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.15),
      color: Colors.white.withOpacity(0.93),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    color: kPrimaryColorDark, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  "Jadual & Masa",
                  style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColorDark),
                ),
              ],
            ),
            Divider(height: 22.h, thickness: 0.8, color: Colors.grey.shade200),
            _buildDetailRow(
              icon: Icons.calendar_month_outlined,
              label: "Tarikh:",
              value: _formattedEndDate.isEmpty || _formattedStartDate == "Ralat Tarikh"
                  ? _formattedStartDate // Show only start date if single day or error
                  : "$_formattedStartDate\nhingga $_formattedEndDate", // Multiline for range
            ),
            SizedBox(height: 10.h),
            _buildDetailRow(
              icon: Icons.access_time_filled_rounded,
              label: "Masa:",
              value: (masaMula == "N/A" && masaTamat == "N/A") ? "N/A" : "$masaMula - $masaTamat",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Card(
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.15),
      color: Colors.white.withOpacity(0.93),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_rounded,
                    color: kPrimaryColorDark, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  "Huraian Program",
                  style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColorDark),
                ),
              ],
            ),
            Divider(height: 22.h, thickness: 0.8, color: Colors.grey.shade200),
            Text(
              description.isEmpty ? "Tiada huraian diberikan." : description,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87.withOpacity(0.85),
                  height: 1.5,
                  fontStyle: description.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: kPrimaryColor.withOpacity(0.9)),
          SizedBox(width: 12.w), // Increased spacing
          Text(
            '$label ',
            style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87.withOpacity(0.75), // Slightly lighter label
                fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// Ensure kPrimaryColor and kPrimaryColorDark are defined in your constants.dart
// const Color kPrimaryColor = Color(0xFF00796B); // Example
// const Color kPrimaryColorDark = Color(0xFF004D40); // Example