import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/screens/petugas/add_program_screen.dart';
import 'package:e_masjid/screens/petugas/program_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class ProgramScreen extends StatefulWidget {
  static const String routeName = '/program';

  const ProgramScreen({super.key});

  static Route route() {
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        pageBuilder: (_, __, ___) => const ProgramScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        });
  }

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen>
    with SingleTickerProviderStateMixin {
  bool _isPetugas = false;
  bool _isLoading = true;
  bool _showCalendarView = false; // To toggle between list and calendar view

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Map<String, dynamic>> _allProgramsData = [];
  List<Map<String, dynamic>> _displayedPrograms = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _viewOptions = ['Semua', 'Kalendar'];
  String _currentView = 'Semua';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    initializeDateFormatting('ms_MY', null).then((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    await _checkUserRole();
    await _fetchProgramsData();
    if (mounted) {
      _animationController.forward();
    }
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

  Future<void> _fetchProgramsData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("program").get();
      final programsData = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        data['firstDate'] = data['firstDate'] is Timestamp
            ? data['firstDate']
            : Timestamp.now(); // Fallback
        data['lastDate'] =
            data['lastDate'] is Timestamp ? data['lastDate'] : Timestamp.now();
        return data;
      }).toList();

      programsData.sort((a, b) {
        Timestamp adate = a['firstDate'];
        Timestamp bdate = b['firstDate'];
        return adate.compareTo(bdate);
      });

      if (mounted) {
        setState(() {
          _allProgramsData = programsData;
          _updateDisplayedPrograms(); // Initial display based on current view
        });
      }
    } catch (e) {
      print("Error fetching programs: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateDisplayedPrograms() {
    if (_showCalendarView) {
      _filterProgramsBySelectedDate(_selectedDay);
    } else {
      // "Semua" view
      setState(() {
        _displayedPrograms = List.from(_allProgramsData);
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Normalize day to ignore time component for comparison
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _allProgramsData.where((program) {
      DateTime startDate =
          (program['firstDate'] as Timestamp).toDate();
      DateTime endDate = (program['lastDate'] as Timestamp).toDate();

      // Normalize program dates
      DateTime normalizedStartDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      DateTime normalizedEndDate =
          DateTime(endDate.year, endDate.month, endDate.day);

      // Check if the normalized day falls within the normalized program range (inclusive)
      return (normalizedDay.isAtSameMomentAs(normalizedStartDate) ||
              normalizedDay.isAfter(normalizedStartDate)) &&
          (normalizedDay.isAtSameMomentAs(normalizedEndDate) ||
              normalizedDay.isBefore(normalizedEndDate));
    }).toList();
  }

  void _filterProgramsBySelectedDate(DateTime selectedDate) {
    if (mounted) {
      setState(() {
        _displayedPrograms = _getEventsForDay(selectedDate);
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay; // Update focusedDay as well
        _filterProgramsBySelectedDate(selectedDay);
      });
    }
  }

  void _onViewChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _currentView = newValue;
      _showCalendarView = (newValue == 'Kalendar');
      if (_showCalendarView) {
        _selectedDay = DateTime.now(); // Reset to today when switching to calendar
        _focusedDay = DateTime.now();
      }
      _updateDisplayedPrograms();
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
    // ... (Same as previous refactor)
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
      floatingActionButton: _isPetugas
          ? FloatingActionButton.extended(
              heroTag: 'add_program_hero_calendar', // Ensure unique heroTag
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProgramScreen()));
                if (result == true) {
                  _fetchProgramsData(); // Refetch and update display
                }
              },
              label: const Text("Tambah Program",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.white,
              foregroundColor: kPrimaryColor,
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
            )
          : null,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jadual',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          'Program Masjid',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // View Toggle Chips
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _viewOptions.map((String view) {
                        bool isSelected = _currentView == view;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: ChoiceChip(
                            label: Text(view),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) _onViewChanged(view);
                            },
                            backgroundColor: Colors.white.withOpacity(0.1),
                            selectedColor: Colors.white,
                            labelStyle: TextStyle(
                                color: isSelected
                                    ? kPrimaryColorDark
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                side: BorderSide(
                                    color: isSelected
                                        ? kPrimaryColor
                                        : Colors.white.withOpacity(0.2),
                                    width: 1.2)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w, vertical: 9.h),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Conditional Calendar View
                  if (_showCalendarView && !_isLoading)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.w),
                      padding: EdgeInsets.only(bottom: 10.h, left: 5.w, right: 5.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TableCalendar<Map<String, dynamic>>(
                        locale: 'ms_MY', // Malay locale
                        firstDay: DateTime.utc(DateTime.now().year - 2, 1, 1),
                        lastDay: DateTime.utc(DateTime.now().year + 2, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: _onDaySelected,
                        eventLoader: _getEventsForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          selectedDecoration: const BoxDecoration(
                              color: kPrimaryColor, shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.4),
                              shape: BoxShape.circle),
                          markerDecoration: BoxDecoration(
                              color: kPrimaryColorDark.withOpacity(0.8),
                              shape: BoxShape.circle),
                          weekendTextStyle: TextStyle(color: Colors.red[600]),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          titleTextStyle: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                          formatButtonTextStyle:
                              const TextStyle(color: Colors.white),
                          formatButtonDecoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          leftChevronIcon: const Icon(Icons.chevron_left,
                              color: kPrimaryColor),
                          rightChevronIcon: const Icon(Icons.chevron_right,
                              color: kPrimaryColor),
                        ),
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() => _calendarFormat = format);
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                  if(_showCalendarView) SizedBox(height: 10.h),

                  // List of Programs
                  Expanded(
                    child: _isLoading
                        ? _buildShimmerList()
                        : _displayedPrograms.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 60.sp,
                                          color:
                                              Colors.white.withOpacity(0.5)),
                                      SizedBox(height: 15.h),
                                      Text(
                                        _showCalendarView
                                            ? 'Tiada program pada tarikh ini.'
                                            : 'Tiada program dijumpai.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            color:
                                                Colors.white.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : AnimationLimiter(
                                child: ListView.builder(
                                  key: ValueKey(_currentView + _focusedDay.toString()), // Ensure list rebuilds
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.only(bottom: 80.h, top: _showCalendarView ? 0 : 5.h),
                                  itemCount: _displayedPrograms.length,
                                  itemBuilder: ((context, index) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      child: SlideAnimation(
                                        verticalOffset: 60.0,
                                        child: FadeInAnimation(
                                          child: _ProgramCard(
                                              program: _displayedPrograms[index]),
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
      //bottomNavigationBar: _isPetugas ? null : const CustomNavBar(),
    );
  }

  Widget _buildShimmerList() {
    // ... (Same as previous refactor)
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
                borderRadius: BorderRadius.circular(16.r)),
            child: SizedBox(
              height: 120.h,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 18.h, color: Colors.white),
                    SizedBox(height: 8.h),
                    Container(width: MediaQuery.of(context).size.width * 0.6, height: 14.h, color: Colors.white),
                    SizedBox(height: 12.h),
                    Container(width: MediaQuery.of(context).size.width * 0.4, height: 12.h, color: Colors.white),
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

class _ProgramCard extends StatelessWidget {
  // ... (Same as previous _ProgramCard refactor)
  final Map<String, dynamic> program;

  const _ProgramCard({required this.program});

  String _formatTimestamp(Timestamp ts, String format) {
    return DateFormat(format, "ms_MY").format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    String title = program['title'] ?? 'Tiada Tajuk';
    String description = program['description'] ?? 'Tiada deskripsi.';
    String dateDisplay;
    Timestamp firstDateTs = program['firstDate'] as Timestamp;
    Timestamp lastDateTs = program['lastDate'] as Timestamp;

    DateTime firstDate = firstDateTs.toDate();
    DateTime lastDate = lastDateTs.toDate();

    // Check if it's a single-day event by comparing year, month, and day
    if (firstDate.year == lastDate.year &&
        firstDate.month == lastDate.month &&
        firstDate.day == lastDate.day) {
      dateDisplay = _formatTimestamp(firstDateTs, "dd MMM yyyy");
    } else {
      dateDisplay =
          "${_formatTimestamp(firstDateTs, "dd MMM")} - ${_formatTimestamp(lastDateTs, "dd MMM yyyy")}";
    }

    String timeRange =
        "${program['masaMula'] ?? ''} - ${program['masaTamat'] ?? ''}";

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
      elevation: 2.0, // Reduced elevation for a flatter modern look on cards
      color: Colors.white.withOpacity(0.93), // Slightly more opaque
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), // Slightly less rounded
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => ProgramDetail(data: program),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(14.w), // Adjusted padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16.sp, // Slightly smaller title
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColorDark),
              ),
              SizedBox(height: 5.h),
              if (description.isNotEmpty) ...[
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5.sp, color: Colors.black87.withOpacity(0.7)), // Adjusted description
                  ),
                  SizedBox(height: 8.h),
                  Divider(color: Colors.grey.shade200, height: 1), // Thinner divider
                  SizedBox(height: 8.h),
              ],
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13.sp, color: kPrimaryColor.withOpacity(0.8)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      dateDisplay,
                      style: TextStyle(
                          fontSize: 12.sp, // Adjusted date/time font
                          color: Colors.black.withOpacity(0.85),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.access_time_outlined,
                      size: 13.sp, color: kPrimaryColor.withOpacity(0.8)),
                  SizedBox(width: 6.w),
                  Text(
                    timeRange,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black.withOpacity(0.85),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}