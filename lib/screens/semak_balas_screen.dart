import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/services/firestore_service.dart';
import 'package:e_masjid/widgets/showdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:e_masjid/widgets/widgets.dart';

class SemakBalas extends StatefulWidget {
  static const String routeName = '/semak_balas';
  final String id;

  const SemakBalas({super.key, required this.id});

  static Route route({required String id}) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      pageBuilder: (_, __, ___) => SemakBalas(id: id),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  State<SemakBalas> createState() => _SemakBalasState();
}

class _SemakBalasState extends State<SemakBalas> {
  // Services
  final FireStoreService _fireStoreService = FireStoreService();
  
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _balasanController = TextEditingController();
  
  // State
  bool _isLoading = true;
  bool _isSaving = false;
  DocumentSnapshot<Map<String, dynamic>>? _data;
  int _characterCount = 0;
  
  // Constants
  static const int _maxCharacters = 500;
  static const int _minCharacters = 10;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _balasanController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _balasanController.dispose();
    super.dispose();
  }

  // Data Management
  Future<void> _fetchData() async {
    try {
      final value = await _fireStoreService.getdataTanya(widget.id);
      if (!mounted) return;
      
      setState(() {
        _data = value;
        _titleController.text = _data?["title"] ?? "";
        _descController.text = _data?["description"] ?? "";
        _balasanController.text = _data?["balasan"] ?? "";
        _characterCount = _balasanController.text.length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data for SemakBalas: $e");
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      DialogHelper.showSnackBar(
        context: context,
        message: "Gagal memuatkan data: ${e.toString()}",
        isError: true,
      );
      Navigator.of(context).pop();
    }
  }

  void _updateCharacterCount() {
    setState(() => _characterCount = _balasanController.text.length);
  }

  // Actions
  Future<void> _simpanBalasan() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _fireStoreService.updateBalasan(
        _titleController.text,
        _descController.text,
        _balasanController.text.trim(),
        widget.id,
      );
      
      DialogHelper.showSnackBar(
        context: context,
        message: 'Balasan berjaya disimpan!',
      );
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.of(context).pop(true);
      });
    } catch (e) {
      DialogHelper.showSnackBar(
        context: context,
        message: "Gagal menyimpan balasan: ${e.toString()}",
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _padamSoalan() async {
    final confirmed = await DialogHelper.showCustomDialog(
      context: context,
      title: "Padam Pertanyaan?",
      message: "Tindakan ini tidak boleh dibatalkan. Anda pasti mahu padam pertanyaan ini?",
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange.shade600,
      cancelText: "Batal",
      confirmText: "Ya, Padam",
      confirmColor: Colors.red.shade600,
      onConfirm: () async {
        EasyLoading.show(status: 'Memadam...');
        
        try {
          await FirebaseFirestore.instance
              .collection("tanya")
              .doc(widget.id)
              .delete();
          
          EasyLoading.dismiss();
          DialogHelper.showSnackBar(
            context: context,
            message: 'Pertanyaan berjaya dipadam!',
          );
          
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
            }
          });
        } catch (e) {
          EasyLoading.dismiss();
          DialogHelper.showSnackBar(
            context: context,
            message: "Gagal memadam: ${e.toString()}",
            isError: true,
          );
        }
      },
    );
  }

  // Widget Builders
  Widget _buildQuestionCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.help_outline_rounded,
              title: 'Pertanyaan Asal',
              color: kPrimaryColor,
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Tajuk', _titleController.text),
            SizedBox(height: 12.h),
            _buildInfoRow('Huraian', _descController.text, isMultiline: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String content, {bool isMultiline = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content.isEmpty ? "Tiada maklumat" : content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
            maxLines: isMultiline ? null : 2,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.edit_note_rounded,
              title: 'Tulis Balasan Anda',
              color: Colors.blue.shade700,
            ),
            SizedBox(height: 16.h),
            _buildReplyTextField(),
            SizedBox(height: 8.h),
            _buildCharacterCounter(),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyTextField() {
    return TextFormField(
      controller: _balasanController,
      style: TextStyle(
        color: Colors.grey.shade800,
        fontSize: 14.sp,
        height: 1.5,
      ),
      maxLines: 8,
      maxLength: _maxCharacters,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: 'Taip balasan anda di sini...\n\nBerikan jawapan yang jelas dan membantu.',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14.sp,
          height: 1.5,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: kPrimaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.all(16.w),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Sila masukkan balasan";
        }
        if (value.trim().length < _minCharacters) {
          return "Balasan mesti sekurang-kurangnya $_minCharacters aksara";
        }
        return null;
      },
    );
  }

  Widget _buildCharacterCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$_characterCount/$_maxCharacters aksara',
          style: TextStyle(
            fontSize: 12.sp,
            color: _characterCount > _maxCharacters * 0.8
                ? Colors.orange.shade600
                : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (_characterCount >= _minCharacters)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, 
                     color: Colors.green.shade600, size: 12.sp),
                SizedBox(width: 4.w),
                Text(
                  'Siap untuk hantar',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          // Delete Button
          FloatingActionButton(
            onPressed: _padamSoalan,
            heroTag: "btn_delete",
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade800,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.delete_outline_rounded, size: 24.sp),
          ),
          SizedBox(width: 12.w),

          // Cancel Button
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pop(),
              heroTag: "btn_cancel",
              label: Text("Batal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
              icon: Icon(Icons.close_rounded, size: 20.sp),
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade800,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
          SizedBox(width: 12.w),

          // Save Button
          Expanded(
            flex: 2,
            child: FloatingActionButton.extended(
              onPressed: _isSaving ? null : _simpanBalasan,
              heroTag: "btn_save",
              label: _isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text("Menyimpan...", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Text("Simpan", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp)),
              icon: _isSaving ? null : Icon(Icons.save_alt_rounded, size: 22.sp),
              backgroundColor: _isSaving ? Colors.grey.shade300 : kPrimaryColor,
              foregroundColor: _isSaving ? Colors.grey.shade600 : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(
            showDecorativeCircles: true,
            child: SizedBox.expand(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3.0,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Memuatkan data...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          const GradientBackground(
            showDecorativeCircles: true,
            child: SizedBox.expand(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white, size: 48.sp),
                SizedBox(height: 16.h),
                Text(
                  "Gagal memuatkan data.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingState();
    if (_data == null) return _buildErrorState();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: 'Balas Pertanyaan'),
      body: Stack(
        children: [
          const GradientBackground(
            showDecorativeCircles: true,
            child: SizedBox.expand(),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 100.h,
              bottom: 16.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildQuestionCard(),
                  SizedBox(height: 20.h),
                  _buildReplyCard(),
                  SizedBox(height: 20.h),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}