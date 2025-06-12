import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/screens/semak_balas_screen.dart';
import 'package:e_masjid/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:e_masjid/widgets/background.dart';


// Keys for accessing data from the widget's map to avoid "magic strings".
class _AppKeys {
  static const id = "id";
  static const isApproved = "isApproved";
  static const status = "status";
  static const jenisTemuJanji = "JenisTemuJanji";
  static const title = "title";
  static const namaPeserta = "namaPeserta";
  static const pemohon = "pemohon";
  static const namaProgram = "nama_program";
  static const description = "description";
  static const mesejPertanyaan = "mesej_pertanyaan";
  static const balasan = "balasan";
  static const tarikh = "tarikh";
  static const date = "date";
  static const firstDate = "firstDate";
  static const lastDate = "lastDate";
  static const masaMula = "masaMula";
  static const masaTamat = "masaTamat";
  static const price = "price";
  static const amount = "amount";
  static const imageUrl = "imageUrl";
  static const role = "role";
}


class SemakDetail extends StatefulWidget {
  static const String routeName = '/semak_detail';
  final Map<String, dynamic> data;

  const SemakDetail({
    super.key,
    required this.data,
  });

  static Route route({required Map<String, dynamic> data}) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      pageBuilder: (_, __, ___) => SemakDetail(data: data),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  State<SemakDetail> createState() => _SemakDetailState();
}

class _SemakDetailState extends State<SemakDetail> {
  // region State Variables
  bool _isPetugas = false;
  bool _isLoading = true;
  bool _isLoadingConfirmation = false;

  String _formattedFirstDate = "";
  String _formattedLastDate = "";
  String _formattedSingleDate = "";
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _initializeDetails();
  }

  Future<void> _initializeDetails() async {
    await _checkUserRole();
    _prepareDateStrings();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  // endregion

  // region Core Logic
  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isPetugas = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (mounted) {
        setState(() {
          _isPetugas = (doc.exists && doc.data()?[_AppKeys.role] == "petugas");
        });
      }
    } catch (e) {
      print("Error checking user role: $e");
      if (mounted) setState(() => _isPetugas = false);
    }
  }

  void _prepareDateStrings() {
    final displayFormatter = DateFormat("dd MMMM yyyy", "ms_MY");
    try {
      // Handle single date fields like 'tarikh' or 'date'
      final singleDateTimestamp = widget.data[_AppKeys.tarikh] ?? widget.data[_AppKeys.date];
      if (singleDateTimestamp is Timestamp) {
        _formattedSingleDate = displayFormatter.format(singleDateTimestamp.toDate());
      }

      // Handle date range fields 'firstDate' and 'lastDate'
      final firstDateValue = widget.data[_AppKeys.firstDate];
      if (firstDateValue is Timestamp) {
        _formattedFirstDate = displayFormatter.format(firstDateValue.toDate());
      } else if (firstDateValue is DateTime) {
        _formattedFirstDate = displayFormatter.format(firstDateValue);
      }

      final lastDateValue = widget.data[_AppKeys.lastDate];
      if (lastDateValue is Timestamp) {
        _formattedLastDate = displayFormatter.format(lastDateValue.toDate());
      } else if (lastDateValue is DateTime) {
        _formattedLastDate = displayFormatter.format(lastDateValue);
      }

      // If it's a single-day event, no need to show the end date.
      if (_formattedFirstDate.isNotEmpty && _formattedFirstDate == _formattedLastDate) {
        _formattedLastDate = "";
      }
    } catch (e) {
      print("Error formatting dates in SemakDetail: $e");
      _formattedFirstDate = "Ralat Tarikh";
      _formattedLastDate = "";
      _formattedSingleDate = "Ralat Tarikh";
    }
    if (mounted) setState(() {});
  }
  // endregion

  // region UI Builders
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    final String jenisTemuJanji = widget.data[_AppKeys.jenisTemuJanji]?.toString() ?? "N/A";
    final String balasan = widget.data[_AppKeys.balasan] ?? "";
    final bool isApproved = widget.data[_AppKeys.isApproved] ?? false;

    // Determine visibility of action buttons
    final bool showBalasFab = _isPetugas && jenisTemuJanji == "Tanya Imam" && (balasan.isEmpty || balasan == "tiada");
    final bool showSahkanButton = _isPetugas && !isApproved;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      floatingActionButton: Visibility(
        visible: showBalasFab,
        child: _buildFloatingActionButton(),
      ),
      body: Stack(
        children: [
          const GradientBackground(
            showDecorativeCircles: true,
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 16.h),
                  _buildDetailsCard(isApproved: isApproved, jenisTemuJanji: jenisTemuJanji),
                  SizedBox(height: 16.h),
                  if (balasan.isNotEmpty) _buildReplyCard(reply: balasan),
                  if (showSahkanButton) ...[
                    SizedBox(height: 25.h),
                    _buildSahkanButton(jenisTemuJanji),
                  ],
                  SizedBox(height: _isPetugas ? 80.h : 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Butiran Permohonan'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  /// Builds the primary information card with title, type, and description.
  Widget _buildInfoCard() {
    final String jenisTemuJanji = widget.data[_AppKeys.jenisTemuJanji]?.toString() ?? "N/A";
    final String title = widget.data[_AppKeys.title] ??
        widget.data[_AppKeys.namaPeserta] ??
        widget.data[_AppKeys.pemohon] ??
        widget.data[_AppKeys.namaProgram] ??
        "Tiada Tajuk";
    final String description = widget.data[_AppKeys.description] ??
        widget.data[_AppKeys.mesejPertanyaan] ??
        "Tiada deskripsi.";

    IconData typeIcon;
    switch (jenisTemuJanji) {
      case "Tanya Imam":
        typeIcon = Icons.contact_support_outlined;
        break;
      case "Sewa Aula":
        typeIcon = Icons.meeting_room_outlined;
        break;
      case "Sumbangan":
        typeIcon = Icons.volunteer_activism_outlined;
        break;
      default:
        typeIcon = Icons.article_outlined;
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
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: kPrimaryColorDark),
            ),
            SizedBox(height: 8.h),
            Chip(
              avatar: Icon(typeIcon, color: kPrimaryColor, size: 16.sp),
              label: Text(
                jenisTemuJanji,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              backgroundColor: kPrimaryColor.withOpacity(0.15),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              visualDensity: VisualDensity.compact,
            ),
            if (description.isNotEmpty && description != "Tiada deskripsi.") ...[
              SizedBox(height: 12.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87.withOpacity(0.8),
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the card containing detailed information like status, date, time, and price.
  Widget _buildDetailsCard({required String jenisTemuJanji, required bool isApproved}) {
    List<Widget> details = [];
    String? statusText = widget.data[_AppKeys.status]?.toString();

    // 1. Add Status Row
    details.add(_buildDetailRow(
      icon: isApproved ? Icons.check_circle_rounded : (statusText == 'Ditolak' ? Icons.cancel_rounded : Icons.hourglass_empty_rounded),
      label: 'Status:',
      value: statusText ?? (isApproved ? 'Diluluskan' : 'Dalam Proses'),
      valueColor: isApproved ? Colors.green.shade700 : (statusText == 'Ditolak' ? Colors.red.shade700 : Colors.orange.shade700),
      iconColor: isApproved ? Colors.green.shade600 : (statusText == 'Ditolak' ? Colors.red.shade600 : Colors.orange.shade600),
    ));
    details.add(SizedBox(height: 10.h));

    // 2. Add Category-Specific Details
    final imageUrl = widget.data[_AppKeys.imageUrl]?.toString();

    switch(jenisTemuJanji) {
      case "Sewa Aula":
        if (_formattedFirstDate.isNotEmpty && _formattedFirstDate != "Ralat") {
          String dateRangeDisplay = _formattedFirstDate;
          if (_formattedLastDate.isNotEmpty) {
            dateRangeDisplay += " - $_formattedLastDate";
          }
          details.add(_buildDetailRow(icon: Icons.date_range_outlined, label: 'Tempoh Sewaan:', value: dateRangeDisplay));
          details.add(SizedBox(height: 8.h));
        }
        if (widget.data[_AppKeys.masaMula] != null && widget.data[_AppKeys.masaTamat] != null) {
          details.add(_buildDetailRow(icon: Icons.access_time_rounded, label: 'Masa:', value: "${widget.data[_AppKeys.masaMula]} - ${widget.data[_AppKeys.masaTamat]}"));
          details.add(SizedBox(height: 8.h));
        }
        if (widget.data[_AppKeys.price] != null) {
          details.add(_buildDetailRow(icon: Icons.payments_outlined, label: 'Anggaran Bayaran:', value: "RM ${(widget.data[_AppKeys.price] as num).toStringAsFixed(2)}"));
        }
        if (_isPetugas && imageUrl != null && imageUrl.isNotEmpty) {
          details.add(SizedBox(height: 16.h));
          details.add(_buildImageDetail(imageUrl: imageUrl, title: 'Bukti Pembayaran:'));
        }
        break;

      case "Sumbangan":
        if (widget.data[_AppKeys.amount] != null) {
          details.add(_buildDetailRow(icon: Icons.attach_money_rounded, label: 'Jumlah Sumbangan:', value: "RM ${widget.data[_AppKeys.amount]}"));
          details.add(SizedBox(height: 8.h));
        }
        if (_formattedSingleDate.isNotEmpty && _formattedSingleDate != "Ralat") {
          details.add(_buildDetailRow(icon: Icons.calendar_today_outlined, label: 'Tarikh Transaksi:', value: _formattedSingleDate));
        }
        if (imageUrl != null && imageUrl.isNotEmpty) {
          details.add(SizedBox(height: 16.h));
          details.add(_buildImageDetail(imageUrl: imageUrl, title: 'Bukti Donasi:'));
        }
        break;

      case "Tanya Imam":
      case "Pertanyaan":
        if (_formattedSingleDate.isNotEmpty && _formattedSingleDate != "Ralat") {
          details.add(_buildDetailRow(icon: Icons.calendar_today_outlined, label: 'Tanggal Hantar:', value: _formattedSingleDate));
        }
        break;
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
                Icon(Icons.info_outline_rounded, color: kPrimaryColorDark, size: 20.sp),
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

  /// Builds the reply card from the 'petugas'.
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
                Icon(Icons.rate_review_outlined, color: kPrimaryColorDark, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  'Balasan Petugas',
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: kPrimaryColorDark),
                ),
              ],
            ),
            Divider(height: 22.h, thickness: 0.8, color: Colors.grey.shade200),
            Text(
              reply,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87.withOpacity(0.8),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "Sahkan Permohonan" button.
  Widget _buildSahkanButton(String jenisTemuJanji) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColor,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 4.0,
        ),
        icon: _isLoadingConfirmation
            ? SizedBox(
                width: 18.w,
                height: 18.h,
                child: const CircularProgressIndicator(strokeWidth: 2.0, color: kPrimaryColor),
              )
            : const Icon(Icons.check_circle_outline_rounded),
        label: Text(
          'Sahkan Permohonan',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        onPressed: _isLoadingConfirmation ? null : () => _showConfirmationDialog(jenisTemuJanji),
      ),
    );
  }

  /// Builds the "Balas" floating action button.
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      heroTag: 'balas_hero_semak_detail_v4',
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SemakBalas(id: widget.data[_AppKeys.id]),
          ),
        );
      },
      label: const Text("Balas", style: TextStyle(fontWeight: FontWeight.w600)),
      icon: const Icon(Icons.reply_all_outlined),
      backgroundColor: Colors.white,
      foregroundColor: kPrimaryColor,
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    );
  }
  // endregion

  // region Helper Widgets & Methods
  /// A reusable row for displaying a piece of detail (Icon, Label, Value).
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: iconColor ?? kPrimaryColor.withOpacity(0.9)),
          SizedBox(width: 12.w),
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "N/A" : value,
              style: TextStyle(
                fontSize: 14.sp,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A reusable widget to display an image with a title, tappable for fullscreen view.
  Widget _buildImageDetail({required String imageUrl, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Icon(Icons.image_outlined, size: 18.sp, color: kPrimaryColor.withOpacity(0.9)),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Stack(
                  children: [
                    InteractiveViewer(child: Image.network(imageUrl, fit: BoxFit.contain)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              imageUrl,
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200.h,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 40.sp, color: Colors.grey[400]),
                    SizedBox(height: 8.h),
                    Text('Gagal memuatkan imej', style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(String jenisTemuJanji) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: const Text("Sahkan Permohonan?", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Tindakan ini tidak boleh dibatalkan. Anda pasti?"),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text("Batal", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text("Ya, Sahkan", style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _processApproval(jenisTemuJanji);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _processApproval(String category) async {
    setState(() => _isLoadingConfirmation = true);
    EasyLoading.show(status: 'Mengemaskini...');
    try {
      final firestoreService = FireStoreService();
      final id = widget.data[_AppKeys.id];

      switch(category) {
        case "Pertanyaan":
          await firestoreService.updateApprovalPertanyaan(id);
          break;
        case "Sewa Aula":
          await firestoreService.updateApprovalSewaAula(id);
          break;
        case "Sumbangan":
          await firestoreService.updateApprovalSumbangan(id);
          break;
        default:
           EasyLoading.showInfo('Jenis permohonan "$category" tidak dikenali.');
           return; // Exit early if category is not recognized
      }

      EasyLoading.showSuccess('Permohonan telah disahkan!');
      if (mounted) {
        setState(() {
          widget.data[_AppKeys.isApproved] = true;
          widget.data[_AppKeys.status] = (category == "Sumbangan") ? "Diterima" : "Diluluskan";
        });
      }
    } catch (e) {
      print("Error in _processApproval: $e");
      EasyLoading.showError("Gagal mengesahkan: ${e.toString().substring(0, (e.toString().length > 100 ? 100 : e.toString().length))}");
    } finally {
      if (mounted) {
        setState(() => _isLoadingConfirmation = false);
        EasyLoading.dismiss();
      }
    }
  }
  // endregion
}