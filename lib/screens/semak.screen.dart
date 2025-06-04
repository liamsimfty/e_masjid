import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/providers/user.provider.dart'; // Assuming AppUser().user is accessible
import 'package:e_masjid/screens/semak_detail_screen.dart';
import 'package:e_masjid/widgets/custom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart'; // For date formatting if needed, though not explicitly used in current item display
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
          return FadeTransition(opacity: animation, child: child);
        });
  }

  @override
  State<SemakStatusScreen> createState() => _SemakStatusScreenState();
}

class _SemakStatusScreenState extends State<SemakStatusScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isPetugas = false;

  String _selectedFilter = "Tanya Imam"; // Default filter
  final List<String> _filters = ['Tanya Imam', 'Sewa Aula', 'Sumbangan']; // Added more options

  List<Map<String, dynamic>> _displayedItems = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ms_MY', null).then((_) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _fadeAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );
      _initializeDetails();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeDetails() async {
    try {
      // Check user role
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

      // Fetch items based on selected filter
      await _fetchItems();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      print("Error initializing details: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchItems() async {
    try {
      List<Map<String, dynamic>> items = [];
      
      // Fetch based on selected filter
      if (_selectedFilter == "Tanya Imam") {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("tanya")
            .orderBy("createdAt", descending: true)
            .get();
        items.addAll(querySnapshot.docs.map((doc) => doc.data()));
      } else if (_selectedFilter == "Sewa Aula") {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("sewa_aula")
            .orderBy("createdAt", descending: true)
            .get();
        items.addAll(querySnapshot.docs.map((doc) => doc.data()));
      } else if (_selectedFilter == "Sumbangan") {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("sumbangan")
            .orderBy("createdAt", descending: true)
            .get();
        items.addAll(querySnapshot.docs.map((doc) => doc.data()));
      }

      if (mounted) {
        setState(() {
          _displayedItems = items;
        });
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  String _getCollectionNameForFilter() {
    switch (_selectedFilter) {
      case "Tanya Imam":
        return "tanya";
      case "Nikah":
        return "nikah";
      case "Sewa Aula":
        return "sewa_aula"; // Assuming this collection name
      case "Sumbangan":
        return "sumbangan"; // Assuming this collection name
      default:
        return "tanya"; // Default or throw error
    }
  }

  void _onFilterChanged(String? newValue) {
    if (newValue == null || _selectedFilter == newValue) return;
    setState(() {
      _selectedFilter = newValue;
      _fetchItems(); // Fetch data for the new filter
    });
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/e_masjid.png',
          height: 40.h,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildDecorativeCircles(context),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Semak',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              'Status Permohonan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            _initializeDetails();
                          },
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                          tooltip: 'Segarkan',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Filter Chips
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters.map((String filter) {
                          bool isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                if (selected) _onFilterChanged(filter);
                              },
                              backgroundColor: Colors.white.withOpacity(0.1),
                              selectedColor: Colors.white,
                              labelStyle: TextStyle(
                                  color: isSelected
                                      ? kPrimaryColorDark
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  side: BorderSide(
                                      color: isSelected
                                          ? kPrimaryColor
                                          : Colors.white.withOpacity(0.2),
                                      width: 1.2)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 7.h),
                              elevation: isSelected ? 2 : 0,
                              pressElevation: 4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: _isLoading
                        ? _buildShimmerList()
                        : _displayedItems.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.find_in_page_outlined,
                                          size: 60.sp,
                                          color:
                                              Colors.white.withOpacity(0.5)),
                                      SizedBox(height: 15.h),
                                      Text(
                                        'Tiada permohonan dijumpai.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            color:
                                                Colors.white.withOpacity(0.7)),
                                      ),
                                       Text(
                                        'untuk kategori "$_selectedFilter"',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color:
                                                Colors.white.withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : AnimationLimiter(
                                child: ListView.builder(
                                  key: ValueKey(_selectedFilter),
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      EdgeInsets.only(bottom: 80.h, top: 5.h),
                                  itemCount: _displayedItems.length,
                                  itemBuilder: ((context, index) {
                                    return AnimationConfiguration
                                        .staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      child: SlideAnimation(
                                        verticalOffset: 60.0,
                                        child: FadeInAnimation(
                                          child: _StatusItemCard(
                                              itemData:
                                                  _displayedItems[index]),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar:
      //     _isPetugas ? null : const CustomNavBar(),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      padding: EdgeInsets.only(top: 5.h),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: kPrimaryColor.withOpacity(0.15),
          highlightColor: kPrimaryColor.withOpacity(0.08),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)), // Matched card rounding
            child: SizedBox(
              height: 80.h, // Adjusted height for status card
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(width: 40.w, height: 40.h, color: Colors.white), // Icon placeholder
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: double.infinity, height: 16.h, color: Colors.white),
                          SizedBox(height: 6.h),
                          Container(width: MediaQuery.of(context).size.width * 0.4, height: 12.h, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusItemCard extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const _StatusItemCard({required this.itemData});

  String _getDisplayTitle() {
    return itemData['title'] ?? 
           itemData['nama_penuh'] ?? // For Nikah
           itemData['namaPeserta'] ?? // For Qurban
           itemData['pemohon'] ?? // For Sewa Aula
           itemData['nama_program'] ?? // For Sumbangan
           'Tiada Tajuk';
  }

   String _getDisplayDate() {
    Timestamp? ts;
    if (itemData['tarikh'] is Timestamp) { // Tanya Imam, Nikah
      ts = itemData['tarikh'];
    } else if (itemData['firstDate'] is Timestamp) { // Qurban, Sewa Aula
      ts = itemData['firstDate'];
    } else if (itemData['date'] is Timestamp) { // Sumbangan
      ts = itemData['date'];
    }
    
    if (ts != null) {
      return DateFormat("dd MMM yyyy", "ms_MY").format(ts.toDate());
    }
    return "Tarikh tidak tersedia";
  }


  Widget _getStatusChip(bool isApproved, String? statusText) {
    Color chipColor;
    String label;
    IconData iconData;

    if (statusText != null && statusText.isNotEmpty) {
        // Use status text if available
        if (statusText == 'Diluluskan' || statusText == 'Disahkan' || statusText == 'Diterima') {
            chipColor = Colors.green.shade100;
            label = statusText;
            iconData = Icons.check_circle_outline_rounded;
        } else if (statusText == 'Ditolak') {
            chipColor = Colors.red.shade100;
            label = statusText;
            iconData = Icons.cancel_outlined;
        } else { // Dalam Proses or other
            chipColor = Colors.orange.shade100;
            label = statusText;
            iconData = Icons.hourglass_empty_rounded;
        }
    } else { // Fallback to isApproved boolean
        if (isApproved) {
            chipColor = Colors.green.shade100;
            label = 'Diluluskan';
            iconData = Icons.check_circle_outline_rounded;
        } else {
            chipColor = Colors.orange.shade100; // Default to pending if no status text
            label = 'Dalam Proses';
            iconData = Icons.hourglass_empty_rounded;
        }
    }


    return Chip(
      avatar: Icon(iconData,
          color: isApproved ? Colors.green.shade700 : (statusText == 'Ditolak' ? Colors.red.shade700 : Colors.orange.shade700), size: 16.sp),
      label: Text(
        label,
        style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: isApproved ? Colors.green.shade800 : (statusText == 'Ditolak' ? Colors.red.shade800 : Colors.orange.shade800)),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide.none
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = _getDisplayTitle();
    String date = _getDisplayDate();
    bool isApproved = itemData['isApproved'] ?? false;
    String? status = itemData['status']?.toString(); // Optional status field

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
      elevation: 2.5,
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.push(
              context, SemakDetail.route(data: itemData)); // Use static route method
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                itemData['JenisTemuJanji'] == "Tanya Imam" ? Icons.help_outline_rounded :
                itemData['JenisTemuJanji'] == "Nikah" ? Icons.favorite_border_rounded :
                itemData['JenisTemuJanji'] == "Sewa Aula" ? Icons.meeting_room_outlined :
                itemData['JenisTemuJanji'] == "Sumbangan" ? Icons.volunteer_activism_outlined :
                Icons.article_outlined,
                color: kPrimaryColor,
                size: 28.sp,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColorDark),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      itemData['JenisTemuJanji'] ?? 'Permohonan', // Display application type
                      style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    ),
                     SizedBox(height: 4.h),
                     Text(
                      date,
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black54.withOpacity(0.7),
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              _getStatusChip(isApproved, status),
            ],
          ),
        ),
      ),
    );
  }
}