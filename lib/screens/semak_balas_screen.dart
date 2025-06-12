import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:e_masjid/widgets/widgets.dart';


class SemakBalas extends StatefulWidget {
  static const String routeName = '/semak_balas';
  final String id;

  const SemakBalas({
    super.key,
    required this.id,
  });

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
        });
  }

  @override
  State<SemakBalas> createState() => _SemakBalasState();
}

class _SemakBalasState extends State<SemakBalas>
    with TickerProviderStateMixin {
  final FireStoreService _fireStoreService = FireStoreService();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSaving = false;
  DocumentSnapshot<Map<String, dynamic>>? _data;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final balasanController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  int _characterCount = 0;
  final int _maxCharacters = 500;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchData();
    balasanController.addListener(_updateCharacterCount);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = balasanController.text.length;
    });
  }

  Future<void> _fetchData() async {
    try {
      final value = await _fireStoreService.getdataTanya(widget.id);
      if (mounted) {
        setState(() {
          _data = value;
          titleController.text = _data?["title"] ?? "";
          descController.text = _data?["description"] ?? "";
          balasanController.text = _data?["balasan"] ?? "";
          _characterCount = balasanController.text.length;
          _isLoading = false;
        });
        _animationController.forward();
        Future.delayed(const Duration(milliseconds: 500), () {
          _fabAnimationController.forward();
        });
      }
    } catch (e) {
      print("Error fetching data for SemakBalas: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Gagal memuatkan data: ${e.toString()}");
        Navigator.of(context).pop();
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    balasanController.dispose();
    _animationController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Animated floating circles
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: (100 + index * 150).h * _fadeAnimation.value,
                right: (50 + index * 80).w,
                child: Transform.rotate(
                  angle: _fadeAnimation.value * 0.5 + index,
                  child: Container(
                    width: (60 + index * 20).w,
                    height: (60 + index * 20).w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05 + index * 0.02),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
        // Geometric shapes
        Positioned(
          top: 200.h,
          left: 30.w,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _fadeAnimation.value,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: kPrimaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Pertanyaan Asal',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              icon: Icons.title_rounded,
              label: 'Tajuk',
              content: titleController.text,
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.description_outlined,
              label: 'Huraian',
              content: descController.text,
              isMultiline: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String content,
    bool isMultiline = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
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
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
            ],
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.blue.shade700,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Tulis Balasan Anda',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: balasanController,
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
                if (value.trim().length < 10) {
                  return "Balasan mesti sekurang-kurangnya 10 aksara";
                }
                return null;
              },
            ),
            SizedBox(height: 8.h),
            Row(
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
                if (_characterCount > 0)
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Delete button
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade600,
                    size: 24.sp,
                  ),
                  tooltip: "Padam Soalan",
                  onPressed: _padamSoalan,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Cancel button
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Batal",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Save button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpanBalasan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
                child: _isSaving
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
                          Text(
                            "Menyimpan...",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "Simpan Balasan",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simpanBalasan() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar("Sila isi ruangan balasan dengan lengkap.");
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _fireStoreService.updateBalasan(
        titleController.text,
        descController.text,
        balasanController.text.trim(),
        widget.id,
      );
      
      _showSuccessSnackBar('Balasan berjaya disimpan!');
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (e) {
      _showErrorSnackBar("Gagal menyimpan balasan: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _padamSoalan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, 
                   color: Colors.orange.shade600, size: 24.sp),
              SizedBox(width: 8.w),
              const Text("Padam Pertanyaan?"),
            ],
          ),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.grey.shade800,
          ),
          content: Text(
            "Tindakan ini tidak boleh dibatalkan. Anda pasti mahu padam pertanyaan ini?",
            style: TextStyle(fontSize: 14.sp, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text(
                "Ya, Padam",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                EasyLoading.show(status: 'Memadam...');
                try {
                  await FirebaseFirestore.instance
                      .collection("tanya")
                      .doc(widget.id)
                      .delete();
                  EasyLoading.dismiss();
                  _showSuccessSnackBar('Pertanyaan berjaya dipadam!');
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) {
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                    }
                  });
                } catch (e) {
                  EasyLoading.dismiss();
                  _showErrorSnackBar("Gagal memadam: ${e.toString()}");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                  CircularProgressIndicator(
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

    if (_data == null) {
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
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 48.sp,
                  ),
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Balas Pertanyaan'),
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
      ),
      body: Stack(
        children: [
          const GradientBackground(
            showDecorativeCircles: true,
            child: SizedBox.expand(),
          ),
          _buildFloatingElements(),
          Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        top: 100.h,
                        bottom: 20.h,
                      ),
                      child: Form(
                        key: _formKey,
                        child: AnimationLimiter(
                          child: Column(
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 600),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(child: widget),
                              ),
                              children: [
                                _buildQuestionCard(),
                                SizedBox(height: 20.h),
                                _buildReplyCard(),
                                SizedBox(height: 100.h), // Space for bottom actions
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }
}