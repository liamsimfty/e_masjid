import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/screens/semak_balas_screen.dart';
import 'package:e_masjid/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemUiOverlayStyle
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// For list animations
import 'package:intl/intl.dart';

class SemakDetail extends StatefulWidget {
  static const String routeName = '/semak_detail';
  final Map<String, dynamic> data;

  static Route route({required Map<String, dynamic> data}) {
    // Pass data to the route for proper instantiation
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        pageBuilder: (_, __, ___) => SemakDetail(data: data),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        });
  }

  const SemakDetail({
    super.key, // Use super.key for modern Flutter
    required this.data,
  });

  @override
  State<SemakDetail> createState() => _SemakDetailState();
}

class _SemakDetailState extends State<SemakDetail> {
  bool _isPetugas = false; // Combined visibility logic
  bool _isLoadingConfirmation = false; // For the Sahkan button
  bool _isLoading = true; // Add loading state

  // Date strings derived in initState or build
  String _formattedFirstDate = "";
  String _formattedLastDate = ""; // For date ranges
  String _formattedSingleDate = ""; // For single date entries like 'tarikh'

  @override
  void initState() {
    super.initState();
    _initializeDetails();
  }

  Future<void> _initializeDetails() async {
    await _checkUserRole();
    _prepareDateStrings(); // Prepare dates after checking role and data availability
    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Debug: User is not logged in");
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
          print("Debug: User role check - exists: ${doc.exists}, role: ${doc.data()?["role"]}, isPetugas: $_isPetugas");
        });
      }
    } catch (e) {
      print("Error checking user role: $e");
      if (mounted) setState(() => _isPetugas = false);
    }
  }

  void _prepareDateStrings() {
    // Use a consistent formatter for display
    final DateFormat displayFormatter = DateFormat("dd MMMM yyyy", "ms_MY"); // e.g., 02 Jun 2025
    try {
      // Handle 'tarikh' field (common for Nikah, Pertanyaan)
      if (widget.data['tarikh'] is Timestamp) {
        _formattedSingleDate = displayFormatter
            .format((widget.data['tarikh'] as Timestamp).toDate());
      }
      // Handle 'date' field (common for Sumbangan)
      else if (widget.data['date'] is Timestamp) {
         _formattedSingleDate = displayFormatter
            .format((widget.data['date'] as Timestamp).toDate());
      }

      if (widget.data['firstDate'] is Timestamp) {
        _formattedFirstDate = displayFormatter
            .format((widget.data['firstDate'] as Timestamp).toDate());
      } else if (widget.data['firstDate'] is DateTime) {
         _formattedFirstDate = displayFormatter.format(widget.data['firstDate']);
      }


      if (widget.data['lastDate'] is Timestamp) {
        _formattedLastDate = displayFormatter
            .format((widget.data['lastDate'] as Timestamp).toDate());
      } else if (widget.data['lastDate'] is DateTime) {
         _formattedLastDate = displayFormatter.format(widget.data['lastDate']);
      }

      // If it's a single day event based on firstDate/lastDate, clear lastDate for display
      if (_formattedFirstDate.isNotEmpty && _formattedFirstDate == _formattedLastDate) {
        _formattedLastDate = ""; // No need to show end date if same as start
      }


    } catch (e) {
      print("Error formatting dates in SemakDetail: $e");
      // Assign default empty strings or error messages if formatting fails
      _formattedFirstDate = "Ralat Tarikh";
      _formattedLastDate = "";
      _formattedSingleDate = "Ralat Tarikh";
    }
    if(mounted) setState(() {}); // Update UI with formatted dates
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
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          ),
        ),
      );
    }

    bool isApproved = widget.data["isApproved"] ?? false;
    String jenisTemuJanji =
        widget.data["JenisTemuJanji"]?.toString() ?? "N/A";

    // Determine title based on available fields, specific to application type
    String title = widget.data["title"] ??
        widget.data["nama_penuh"] ?? // For Nikah
        widget.data["namaPeserta"] ?? // For Qurban
        widget.data["pemohon"] ?? // For Sewa Aula
        widget.data["nama_program"] ?? // For Sumbangan
        "Tiada Tajuk";

    String description = widget.data["description"] ??
        widget.data["mesej_pertanyaan"] ?? // For Tanya Imam
        "Tiada deskripsi.";
    String balasan = widget.data["balasan"] ?? "";

    // Visibility for "Balas" FAB (Petugas only, and for "Pertanyaan" if no reply yet)
    bool showBalasFab = _isPetugas && jenisTemuJanji == "Tanya Imam" && (balasan.isEmpty || balasan == "tiada");
    print("Debug: Balas button conditions - isPetugas: $_isPetugas, jenisTemuJanji: $jenisTemuJanji, balasan: $balasan, showBalasFab: $showBalasFab");
    // Visibility for "Sahkan" button (Petugas only, and not already approved)
    bool showSahkanButton = _isPetugas && !isApproved;

    // Prepare list of widgets for animation
    List<Widget> contentCards = [
      _buildInfoCard(
        title: title,
        jenisTemuJanji: jenisTemuJanji,
        description: description,
      ),
      SizedBox(height: 16.h),
      _buildDetailsCard(
        jenisTemuJanji: jenisTemuJanji,
        data: widget.data,
        isApproved: isApproved,
      ),
      SizedBox(height: 16.h),
      // Only show reply card if balasan exists and is not empty
      if (balasan.isNotEmpty)
        _buildReplyCard(reply: balasan),
      if (showSahkanButton) ...[
        SizedBox(height: 25.h),
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kPrimaryColor,
              padding:
                  EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              elevation: 4.0,
            ),
            icon: _isLoadingConfirmation
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.0, color: kPrimaryColor))
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              'Sahkan Permohonan',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            onPressed: _isLoadingConfirmation
                ? null
                : () => _showConfirmationDialog(jenisTemuJanji),
          ),
        ),
      ],
      SizedBox(height: _isPetugas ? 80.h : 20.h), // Space for FAB or general padding
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, // Make AppBar transparent over gradient
      floatingActionButton: Visibility(
        visible: showBalasFab,
        child: FloatingActionButton.extended(
          heroTag: 'balas_hero_semak_detail_v4', // Ensure unique heroTag
          onPressed: () async {
             final result = await Navigator.push( // Use push to come back
                context,
                MaterialPageRoute(
                    builder: (context) => SemakBalas(id: widget.data["id"])));
            if (result == true && mounted) {
                // Potentially refresh this screen's data if SemakBalas indicates a change
                // For now, this requires a more complex state update or parent callback
            }
          },
          label: const Text("Balas",
              style: TextStyle(fontWeight: FontWeight.w600)),
          icon: const Icon(Icons.reply_all_outlined), // Changed icon
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColor,
          elevation: 6.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
      ),
      appBar: AppBar(
        title: const Text('Butiran Permohonan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
        systemOverlayStyle: SystemUiOverlayStyle.light, // For light status bar icons
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildDecorativeCircles(context),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contentCards,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required String jenisTemuJanji,
      required String description}) {
    IconData typeIcon = Icons.article_outlined; // Default
    switch (jenisTemuJanji) {
      case "Tanya Imam": typeIcon = Icons.contact_support_outlined; break;
      case "Nikah": typeIcon = Icons.church_outlined; break; // Or Icons.favorite
      case "Sewa Aula": typeIcon = Icons.meeting_room_outlined; break;
      case "Sumbangan": typeIcon = Icons.volunteer_activism_outlined; break;
    }

    return Card(
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.15),
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColorDark),
            ),
            SizedBox(height: 8.h),
            Chip(
              avatar: Icon(typeIcon, color: kPrimaryColor, size: 16.sp),
              label: Text(jenisTemuJanji,
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp)),
              backgroundColor: kPrimaryColor.withOpacity(0.15),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(height: 12.h),
            if (description.isNotEmpty && description != "Tiada deskripsi.")
              Text(
                description,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87.withOpacity(0.8),
                    height: 1.45), // Line height
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
      {required String jenisTemuJanji,
      required Map<String, dynamic> data,
      required bool isApproved}) {
    List<Widget> details = [];
    String? statusText = data['status']?.toString();

    // General Approval Status
    details.add(_buildDetailRow(
      icon: isApproved
          ? Icons.check_circle_rounded
          : (statusText == 'Ditolak'
              ? Icons.cancel_rounded
              : Icons.hourglass_empty_rounded),
      label: 'Status:',
      value: statusText ?? (isApproved ? 'Diluluskan' : 'Dalam Proses'),
      valueColor: isApproved
          ? Colors.green.shade700
          : (statusText == 'Ditolak'
              ? Colors.red.shade700
              : Colors.orange.shade700),
      iconColor: isApproved
          ? Colors.green.shade600
          : (statusText == 'Ditolak'
              ? Colors.red.shade600
              : Colors.orange.shade600),
    ));
    details.add(SizedBox(height: 10.h));

    // Category Specific Details
    if (jenisTemuJanji == "Pertanyaan" || jenisTemuJanji == "Nikah") {
      if (_formattedSingleDate.isNotEmpty && _formattedSingleDate != "Ralat") {
        details.add(_buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: jenisTemuJanji == "Nikah"
                ? 'Tarikh Nikah Dicadang:'
                : 'Tarikh Hantar:',
            value: _formattedSingleDate));
      }
    } else if (jenisTemuJanji == "Sewa Aula") {
      if (_formattedFirstDate.isNotEmpty && _formattedFirstDate != "Ralat") {
        String dateRangeDisplay = _formattedFirstDate;
        if (_formattedLastDate.isNotEmpty && _formattedFirstDate != _formattedLastDate) {
          dateRangeDisplay += " - $_formattedLastDate";
        }
        details.add(_buildDetailRow(
            icon: Icons.date_range_outlined,
            label: 'Tempoh Sewaan:',
            value: dateRangeDisplay));
        details.add(SizedBox(height: 8.h));
      }
      if (data["masaMula"] != null && data["masaTamat"] != null) {
        details.add(_buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Masa:',
            value: "${data['masaMula']} - ${data['masaTamat']}"));
      }
      if (data["price"] != null) {
        details.add(SizedBox(height: 8.h));
        details.add(_buildDetailRow(
            icon: Icons.payments_outlined,
            label: 'Anggaran Bayaran:',
            value: "RM ${(data['price'] as num).toStringAsFixed(2)}"));
      }

      // Show image only for petugas
      if (_isPetugas && data["imageUrl"] != null && data["imageUrl"].toString().isNotEmpty) {
        details.add(SizedBox(height: 34.h));
        details.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.image_outlined,
                        size: 18.sp, color: kPrimaryColor.withOpacity(0.9)),
                    SizedBox(width: 12.w),
                    Text(
                      'Dokumen Sokongan:',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87.withOpacity(0.75),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Show full screen image
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          children: [
                            InteractiveViewer(
                              child: Image.network(
                                data["imageUrl"],
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    data["imageUrl"],
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200.h,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 40.sp, color: Colors.grey[400]),
                            SizedBox(height: 8.h),
                            Text(
                              'Gagal memuatkan imej',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (jenisTemuJanji == "Sumbangan") {
      if (data["amount"] != null) {
        details.add(_buildDetailRow(
            icon: Icons.attach_money_rounded,
            label: 'Jumlah Sumbangan:',
            value: "RM ${data['amount']}"));
        details.add(SizedBox(height: 8.h));
      }
      if (_formattedSingleDate.isNotEmpty && _formattedSingleDate != "Ralat") {
        details.add(_buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tarikh Transaksi:',
            value: _formattedSingleDate));
      }
      
      // Add image display for donations
      if (data["imageUrl"] != null && data["imageUrl"].toString().isNotEmpty) {
        details.add(SizedBox(height: 16.h));
        details.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.image_outlined,
                        size: 18.sp, color: kPrimaryColor.withOpacity(0.9)),
                    SizedBox(width: 12.w),
                    Text(
                      'Bukti Derma:',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87.withOpacity(0.75),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Show full screen image
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          children: [
                            InteractiveViewer(
                              child: Image.network(
                                data["imageUrl"],
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    data["imageUrl"],
                    height: 500.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200.h,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 40.sp, color: Colors.grey[400]),
                            SizedBox(height: 8.h),
                            Text(
                              'Gagal memuatkan imej',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

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
                Icon(Icons.info_outline_rounded,
                    color: kPrimaryColorDark,
                    size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  'Maklumat Lanjut',
                  style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColorDark),
                ),
              ],
            ),
            Divider(height: 22.h, thickness: 0.8, color: Colors.grey.shade200),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon,
      required String label,
      required String value,
      Color? valueColor,
      Color? iconColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18.sp, color: iconColor ?? kPrimaryColor.withOpacity(0.9)),
          SizedBox(width: 12.w),
          Text(
            '$label ',
            style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87.withOpacity(0.75),
                fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "N/A" : value,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard({required String reply}) {
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
                Icon(Icons.rate_review_outlined,
                    color: kPrimaryColorDark, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  'Balasan Petugas',
                  style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColorDark),
                ),
              ],
            ),
            Divider(height: 22.h, thickness: 0.8, color: Colors.grey.shade200),
            Text(
              reply.isEmpty ? "Tiada balasan lagi." : reply,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: reply.isEmpty
                      ? Colors.grey.shade600
                      : Colors.black87.withOpacity(0.8),
                  fontStyle:
                      reply.isEmpty ? FontStyle.italic : FontStyle.normal,
                  height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(String jenisTemuJanji) {
    // The category for Firestore update is derived from jenisTemuJanji
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: const Text("Sahkan Permohonan?",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content:
              const Text("Tindakan ini tidak boleh dibatalkan. Anda pasti?"),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text("Batal",
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
              child: const Text("Ya, Sahkan",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _processApproval(jenisTemuJanji); // Pass jenisTemuJanji directly
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _processApproval(String category) async { // category is jenisTemuJanji
    setState(() => _isLoadingConfirmation = true);
    EasyLoading.show(status: 'Mengemaskini...');
    try {
      FireStoreService firestoreService = FireStoreService();
      String id = widget.data["id"];
      bool success = false;

      // Ensure these methods exist in your FireStoreService and handle updates correctly
      // The `category` variable here IS `jenisTemuJanji`
      if (category == "Nikah") {
        await firestoreService.updateApprovalNikah(id); success = true;
      } else if (category == "Pertanyaan") {
        await firestoreService.updateApprovalPertanyaan(id); success = true;
      } else if (category == "Sewa Aula") {
        await firestoreService.updateApprovalSewaAula(id); success = true;
      } else if (category == "Sumbangan") {
        await firestoreService.updateApprovalSumbangan(id); success = true;
      }

      if (success) {
        EasyLoading.showSuccess('Permohonan telah disahkan!');
        if (mounted) {
          setState(() {
            widget.data["isApproved"] = true;
            widget.data["status"] = (category == "Sumbangan") ? "Diterima" : "Diluluskan";
          });
        }
      } else {
        EasyLoading.showInfo(
            'Jenis permohonan "$category" tidak dikenali atau gagal disahkan.');
      }
    } catch (e) {
      print("Error in _processApproval: $e");
      EasyLoading.showError(
          "Gagal mengesahkan: ${e.toString().substring(0, (e.toString().length > 100 ? 100 : e.toString().length))}");
    } finally {
      if (mounted) {
        setState(() => _isLoadingConfirmation = false);
        EasyLoading.dismiss();
      }
    }
  }
}