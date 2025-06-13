import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/screens/petugas/edit_program.dart'; // For navigation
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:e_masjid/widgets/widgets.dart';
import 'package:e_masjid/utils/date_formatter.dart';
import 'package:e_masjid/utils/auth_user.dart'; // adjust path if needed
import 'package:e_masjid/providers/user_role_provider.dart';
import 'package:e_masjid/mixins/role_checker_mixin.dart';
import 'package:provider/provider.dart';

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
    with SingleTickerProviderStateMixin, RoleCheckerMixin {
  String _formattedStartDate = "N/A";
  String _formattedEndDate = "N/A";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _initializeData();
    final dates = DateFormatter.formatDates(widget.data);
    _formattedStartDate = dates.firstDate;
    _formattedEndDate = dates.lastDate;
    _animationController.forward();
  }

  Future<void> _initializeData() async {
    await initializeUserRole(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        if (roleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

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
          appBar: CustomAppBar(title: 'Jadwal Program'),
          floatingActionButton: isPetugas(context)
              ? FloatingActionButton.extended(
                  heroTag: 'sunting_program_hero_detail', // Ensure unique heroTag
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProgram(
                            id: widget.data["id"], programData: widget.data),
                      ),
                    );
                    if (result == true && mounted) {
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
                )
              : null,
          body: Stack(
            children: [
              const GradientBackground(
                showDecorativeCircles: true,
                child: SizedBox.expand(),
              ),
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
      },
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
                  "Jadwal & Waktu",
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