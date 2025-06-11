import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/screens/semak_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shimmer/shimmer.dart';

class SemakStatusScreen extends StatefulWidget {
  static const String routeName = '/semak';

  const SemakStatusScreen({super.key});

  static Route route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      pageBuilder: (_, __, ___) => const SemakStatusScreen(),
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
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  State<SemakStatusScreen> createState() => _SemakStatusScreenState();
}

class _SemakStatusScreenState extends State<SemakStatusScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isPetugas = false;
  String _selectedFilter = "Tanya Imam";
  
  final List<FilterOption> _filters = [
    FilterOption("Tanya Imam", Icons.help_outline_rounded, Colors.blue),
    FilterOption("Sewa Aula", Icons.meeting_room_outlined, Colors.purple),
    FilterOption("Sumbangan", Icons.volunteer_activism_outlined, Colors.green),
  ];

  List<Map<String, dynamic>> _displayedItems = [];
  late AnimationController _refreshController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    initializeDateFormatting('ms_MY', null).then((_) {
      _initializeDetails();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _initializeDetails() async {
    try {
      await _checkUserRole();
      await _fetchItems();
      
      if (mounted) {
        setState(() => _isLoading = false);
        _listController.forward();
      }
    } catch (e) {
      debugPrint("Error initializing details: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Ralat memuat data. Sila cuba lagi.");
      }
    }
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      
      if (mounted) {
        setState(() {
          _isPetugas = (doc.exists && doc.data()?["role"] == "petugas");
        });
      }
    }
  }

  Future<void> _fetchItems() async {
    try {
      final collectionName = _getCollectionNameForFilter();
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy("createdAt", descending: true)
          .limit(50) // Add pagination limit
          .get();

      if (mounted) {
        setState(() {
          _displayedItems = querySnapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching items: $e");
      _showErrorSnackBar("Ralat mengambil data.");
    }
  }

  String _getCollectionNameForFilter() {
    switch (_selectedFilter) {
      case "Tanya Imam":
        return "tanya";
      case "Nikah":
        return "nikah";
      case "Sewa Aula":
        return "sewa_aula";
      case "Sumbangan":
        return "sumbangan";
      default:
        return "tanya";
    }
  }

  void _onFilterChanged(String newValue) {
    if (_selectedFilter == newValue) return;
    
    setState(() {
      _selectedFilter = newValue;
      _isLoading = true;
    });
    
    _listController.reset();
    _fetchItems().then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _listController.forward();
      }
    });
  }

  void _onRefresh() async {
    _refreshController.repeat();
    await _initializeDetails();
    _refreshController.stop();
    _refreshController.reset();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildDecorativeElements(context),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilterSection(),
                SizedBox(height: 16.h),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Hero(
        tag: 'app_logo',
        child: Image.asset(
          'assets/images/e_masjid.png',
          height: 35.h,
          fit: BoxFit.contain,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.9),
            kPrimaryColor,
            kPrimaryColor.withOpacity(0.85),
            kPrimaryColorDark.withOpacity(0.8),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildDecorativeElements(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Stack(
      children: [
        // Top left circle
        Positioned(
          top: screenHeight * -0.08,
          left: screenWidth * -0.2,
          child: Container(
            width: screenWidth * 0.5,
            height: screenWidth * 0.5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom right circle
        Positioned(
          bottom: screenHeight * -0.15,
          right: screenWidth * -0.25,
          child: Container(
            width: screenWidth * 0.7,
            height: screenWidth * 0.7,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Additional accent circles
        Positioned(
          top: screenHeight * 0.15,
          right: screenWidth * -0.1,
          child: Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lihat',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Status Permohonan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: _onRefresh,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: AnimatedBuilder(
                    animation: _refreshController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _refreshController.value * 2 * 3.14159,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter.name;
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _buildFilterChip(filter, isSelected),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(FilterOption filter, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25.r),
          onTap: () => _onFilterChanged(filter.name),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: isSelected 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter.icon,
                  size: 18.sp,
                  color: isSelected 
                      ? filter.color 
                      : Colors.white,
                ),
                SizedBox(width: 8.w),
                Text(
                  filter.name,
                  style: TextStyle(
                    color: isSelected 
                        ? kPrimaryColorDark 
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_displayedItems.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _listController.value)),
          child: Opacity(
            opacity: _listController.value,
            child: ListView.builder(
              key: ValueKey(_selectedFilter),
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
              itemCount: _displayedItems.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _listController,
                  builder: (context, child) {
                    final delay = index * 0.1;
                    final animationValue = Curves.easeOutCubic.transform(
                      (_listController.value - delay).clamp(0.0, 1.0),
                    );
                    
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - animationValue)),
                      child: Opacity(
                        opacity: animationValue,
                        child: StatusItemCard(
                          itemData: _displayedItems[index],
                          filterOption: _filters.firstWhere(
                            (f) => f.name == _selectedFilter,
                            orElse: () => _filters.first,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.find_in_page_outlined,
                size: 64.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Tiada permohonan dijumpai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'untuk kategori "$_selectedFilter"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 8,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.2),
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Filter option model
class FilterOption {
  final String name;
  final IconData icon;
  final Color color;

  FilterOption(this.name, this.icon, this.color);
}

// Enhanced Status Item Card
class StatusItemCard extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final FilterOption filterOption;

  const StatusItemCard({
    super.key,
    required this.itemData,
    required this.filterOption,
  });

  String _getDisplayTitle() {
    return itemData['title'] ?? 
           itemData['nama_penuh'] ?? 
           itemData['pemohon'] ?? 
           itemData['nama_program'] ?? 
           'Tiada Tajuk';
  }

  String _getDisplayDate() {
    Timestamp? ts;
    if (itemData['tarikh'] is Timestamp) {
      ts = itemData['tarikh'];
    } else if (itemData['firstDate'] is Timestamp) {
      ts = itemData['firstDate'];
    } else if (itemData['date'] is Timestamp) {
      ts = itemData['date'];
    } else if (itemData['createdAt'] is Timestamp) {
      ts = itemData['createdAt'];
    }
    
    if (ts != null) {
      return DateFormat("dd MMM yyyy", "ms_MY").format(ts.toDate());
    }
    return "Tarikh tidak tersedia";
  }

  StatusInfo _getStatusInfo() {
    final statusText = itemData['status']?.toString();
    final isApproved = itemData['isApproved'] ?? false;

    if (statusText != null && statusText.isNotEmpty) {
      switch (statusText.toLowerCase()) {
        case 'diluluskan':
        case 'disahkan':
        case 'diterima':
          return StatusInfo(
            label: statusText,
            color: Colors.green,
            icon: Icons.check_circle_outline_rounded,
            bgColor: Colors.green.shade50,
          );
        case 'ditolak':
          return StatusInfo(
            label: statusText,
            color: Colors.red,
            icon: Icons.cancel_outlined,
            bgColor: Colors.red.shade50,
          );
        default:
          return StatusInfo(
            label: statusText,
            color: Colors.orange,
            icon: Icons.schedule_rounded,
            bgColor: Colors.orange.shade50,
          );
      }
    }

    return StatusInfo(
      label: isApproved ? 'Diluluskan' : 'Dalam Proses',
      color: isApproved ? Colors.green : Colors.orange,
      icon: isApproved ? Icons.check_circle_outline_rounded : Icons.schedule_rounded,
      bgColor: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _getDisplayTitle();
    final date = _getDisplayDate();
    final statusInfo = _getStatusInfo();
    final imageUrl = itemData['imageUrl'];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              SemakDetail.route(data: itemData),
            );
          },
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildLeadingIcon(imageUrl),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildContent(title, date),
                ),
                SizedBox(width: 12.w),
                _buildStatusChip(statusInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(String? imageUrl) {
    if (imageUrl != null && itemData['JenisTemuJanji'] == "Sumbangan") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          imageUrl,
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon();
          },
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: filterOption.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        filterOption.icon,
        color: filterOption.color,
        size: 24.sp,
      ),
    );
  }

  Widget _buildContent(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColorDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          itemData['JenisTemuJanji'] ?? 'Permohonan',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 12.sp,
              color: Colors.grey.shade500,
            ),
            SizedBox(width: 4.w),
            Text(
              date,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(StatusInfo statusInfo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusInfo.bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            color: statusInfo.color.shade700,
            size: 14.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: statusInfo.color.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// Status info model
class StatusInfo {
  final String label;
  final MaterialColor color;
  final IconData icon;
  final Color bgColor;

  StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
    required this.bgColor,
  });
}