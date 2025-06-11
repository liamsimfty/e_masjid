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
      },
    );
  }

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isPetugas = false;
  bool _isLoading = true;
  bool _showCalendarView = false;

  // Calendar state
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Data
  List<Map<String, dynamic>> _allProgramsData = [];
  List<Map<String, dynamic>> _displayedPrograms = [];

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // UI constants
  static const List<String> _viewOptions = ['Semua', 'Kalendar'];
  String _currentView = 'Semua';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDateFormatting();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Initialization methods
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _initializeDateFormatting() {
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

  // Data fetching methods
  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _updatePetugasState(false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      
      final isPetugas = doc.exists && doc.data()?["role"] == "petugas";
      _updatePetugasState(isPetugas);
    } catch (e) {
      debugPrint("Error checking user role: $e");
      _updatePetugasState(false);
    }
  }

  void _updatePetugasState(bool isPetugas) {
    if (mounted) {
      setState(() => _isPetugas = isPetugas);
    }
  }

  Future<void> _fetchProgramsData() async {
    _setLoadingState(true);
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("program")
          .get();
      
      final programsData = _processProgramsData(querySnapshot.docs);
      _updateProgramsState(programsData);
    } catch (e) {
      debugPrint("Error fetching programs: $e");
    } finally {
      _setLoadingState(false);
    }
  }

  List<Map<String, dynamic>> _processProgramsData(
      List<QueryDocumentSnapshot> docs) {
    final programsData = docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data() as Map);
      data['id'] = doc.id;
      data['firstDate'] = _ensureTimestamp(data['firstDate']);
      data['lastDate'] = _ensureTimestamp(data['lastDate']);
      return data;
    }).toList();

    // Sort by first date
    programsData.sort((a, b) {
      final aDate = a['firstDate'] as Timestamp;
      final bDate = b['firstDate'] as Timestamp;
      return aDate.compareTo(bDate);
    });

    return programsData;
  }

  Timestamp _ensureTimestamp(dynamic value) {
    return value is Timestamp ? value : Timestamp.now();
  }

  void _updateProgramsState(List<Map<String, dynamic>> programsData) {
    if (mounted) {
      setState(() {
        _allProgramsData = programsData;
        _updateDisplayedPrograms();
      });
    }
  }

  void _setLoadingState(bool isLoading) {
    if (mounted) {
      setState(() => _isLoading = isLoading);
    }
  }

  // Program filtering methods
  void _updateDisplayedPrograms() {
    if (_showCalendarView) {
      _filterProgramsBySelectedDate(_selectedDay);
    } else {
      setState(() {
        _displayedPrograms = List.from(_allProgramsData);
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    
    return _allProgramsData.where((program) {
      final startDate = (program['firstDate'] as Timestamp).toDate();
      final endDate = (program['lastDate'] as Timestamp).toDate();
      final normalizedStartDate = _normalizeDate(startDate);
      final normalizedEndDate = _normalizeDate(endDate);

      return _isDateInRange(normalizedDay, normalizedStartDate, normalizedEndDate);
    }).toList();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isDateInRange(DateTime date, DateTime startDate, DateTime endDate) {
    return (date.isAtSameMomentAs(startDate) || date.isAfter(startDate)) &&
           (date.isAtSameMomentAs(endDate) || date.isBefore(endDate));
  }

  void _filterProgramsBySelectedDate(DateTime selectedDate) {
    if (mounted) {
      setState(() {
        _displayedPrograms = _getEventsForDay(selectedDate);
      });
    }
  }

  // Event handlers
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _filterProgramsBySelectedDate(selectedDay);
      });
    }
  }

  void _onViewChanged(String? newValue) {
    if (newValue == null || newValue == _currentView) return;
    
    setState(() {
      _currentView = newValue;
      _showCalendarView = (newValue == 'Kalendar');
      
      if (_showCalendarView) {
        _resetCalendarToToday();
      }
      
      _updateDisplayedPrograms();
    });
  }

  void _resetCalendarToToday() {
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  Future<void> _onAddProgram() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProgramScreen()),
    );
    
    if (result == true) {
      await _fetchProgramsData();
    }
  }

  // UI Building methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_isPetugas) return null;
    
    return FloatingActionButton.extended(
      heroTag: 'add_program_hero_calendar',
      onPressed: _onAddProgram,
      label: const Text(
        "Tambah Program",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.add),
      backgroundColor: Colors.white,
      foregroundColor: kPrimaryColor,
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildGradientBackground(),
        _buildDecorativeCircles(),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildViewToggle(),
                if (_showCalendarView && !_isLoading) _buildCalendar(),
                if (_showCalendarView) SizedBox(height: 10.h),
                Expanded(child: _buildProgramsList()),
              ],
            ),
          ),
        ),
      ],
    );
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

  Widget _buildDecorativeCircles() {
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadual',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            'Program Masjid',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _viewOptions.map(_buildViewChip).toList(),
      ),
    );
  }

  Widget _buildViewChip(String view) {
    final isSelected = _currentView == view;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: ChoiceChip(
        label: Text(view),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) _onViewChanged(view);
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? kPrimaryColorDark : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: isSelected 
                ? kPrimaryColor 
                : Colors.white.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
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
          ),
        ],
      ),
      child: TableCalendar<Map<String, dynamic>>(
        locale: 'ms_MY',
        firstDay: DateTime.utc(DateTime.now().year - 2, 1, 1),
        lastDay: DateTime.utc(DateTime.now().year + 2, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: _buildCalendarStyle(),
        headerStyle: _buildCalendarHeaderStyle(),
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      outsideDaysVisible: false,
      selectedDecoration: const BoxDecoration(
        color: kPrimaryColor,
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      markerDecoration: BoxDecoration(
        color: kPrimaryColorDark.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      weekendTextStyle: TextStyle(color: Colors.red[600]),
    );
  }

  HeaderStyle _buildCalendarHeaderStyle() {
    return HeaderStyle(
      formatButtonVisible: true,
      titleCentered: true,
      formatButtonShowsNext: false,
      titleTextStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      formatButtonTextStyle: const TextStyle(color: Colors.white),
      formatButtonDecoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      leftChevronIcon: const Icon(Icons.chevron_left, color: kPrimaryColor),
      rightChevronIcon: const Icon(Icons.chevron_right, color: kPrimaryColor),
    );
  }

  Widget _buildProgramsList() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_displayedPrograms.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: ListView.builder(
        key: ValueKey('${_currentView}_${_focusedDay.toString()}'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: 80.h,
          top: _showCalendarView ? 0 : 5.h,
        ),
        itemCount: _displayedPrograms.length,
        itemBuilder: (context, index) => _buildAnimatedProgramCard(index),
      ),
    );
  }

  Widget _buildAnimatedProgramCard(int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 60.0,
        child: FadeInAnimation(
          child: _ProgramCard(program: _displayedPrograms[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60.sp,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 15.h),
            Text(
              _showCalendarView
                  ? 'Tiada program pada tanggal ini.'
                  : 'Tiada program dijumpai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      padding: EdgeInsets.only(top: 5.h),
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: kPrimaryColor.withOpacity(0.15),
      highlightColor: kPrimaryColor.withOpacity(0.08),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          height: 120.h,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 18.h,
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14.h,
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 12.h,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;

  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    final cardData = _ProgramCardData.fromProgram(program);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
      elevation: 2.0,
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _navigateToDetail(context),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(cardData),
              if (cardData.hasDescription) ...[
                SizedBox(height: 8.h),
                _buildDescription(cardData),
                SizedBox(height: 12.h),
                _buildDivider(),
                SizedBox(height: 12.h),
              ] else
                SizedBox(height: 12.h),
              _buildDateTimeRow(cardData),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramDetail(data: program),
      ),
    );
  }

  Widget _buildTitle(_ProgramCardData cardData) {
    return Text(
      cardData.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: kPrimaryColorDark,
        height: 1.3,
      ),
    );
  }

  Widget _buildDescription(_ProgramCardData cardData) {
    return Text(
      cardData.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.black87.withOpacity(0.7),
        height: 1.4,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildDateTimeRow(_ProgramCardData cardData) {
    return Row(
      children: [
        _buildDateInfo(cardData),
        SizedBox(width: 16.w),
        _buildTimeInfo(cardData),
      ],
    );
  }

  Widget _buildDateInfo(_ProgramCardData cardData) {
    return Expanded(
      flex: 3,
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14.sp,
            color: kPrimaryColor.withOpacity(0.8),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              cardData.dateDisplay,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(_ProgramCardData cardData) {
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          Icon(
            Icons.access_time_outlined,
            size: 14.sp,
            color: kPrimaryColor.withOpacity(0.8),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              cardData.timeRange,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCardData {
  final String title;
  final String description;
  final String dateDisplay;
  final String timeRange;
  final bool hasDescription;

  const _ProgramCardData({
    required this.title,
    required this.description,
    required this.dateDisplay,
    required this.timeRange,
    required this.hasDescription,
  });

  factory _ProgramCardData.fromProgram(Map<String, dynamic> program) {
    final title = program['title']?.toString() ?? 'Tiada Tajuk';
    final description = program['description']?.toString() ?? '';
    final hasDescription = description.isNotEmpty;

    final firstDateTs = program['firstDate'] as Timestamp;
    final lastDateTs = program['lastDate'] as Timestamp;
    final dateDisplay = _formatDateRange(firstDateTs, lastDateTs);

    final timeRange = _formatTimeRange(
      program['masaMula']?.toString() ?? '',
      program['masaTamat']?.toString() ?? '',
    );

    return _ProgramCardData(
      title: title,
      description: description,
      dateDisplay: dateDisplay,
      timeRange: timeRange,
      hasDescription: hasDescription,
    );
  }

  static String _formatDateRange(Timestamp firstDateTs, Timestamp lastDateTs) {
    final firstDate = firstDateTs.toDate();
    final lastDate = lastDateTs.toDate();

    final isSingleDay = firstDate.year == lastDate.year &&
        firstDate.month == lastDate.month &&
        firstDate.day == lastDate.day;

    if (isSingleDay) {
      return DateFormat("dd MMM yyyy", "ms_MY").format(firstDate);
    } else {
      final startFormatted = DateFormat("dd MMM", "ms_MY").format(firstDate);
      final endFormatted = DateFormat("dd MMM yyyy", "ms_MY").format(lastDate);
      return "$startFormatted - $endFormatted";
    }
  }

  static String _formatTimeRange(String startTime, String endTime) {
    if (startTime.isEmpty && endTime.isEmpty) {
      return 'Masa tidak ditetapkan';
    }
    if (startTime.isEmpty) {
      return 'Hingga $endTime';
    }
    if (endTime.isEmpty) {
      return 'Dari $startTime';
    }
    return '$startTime - $endTime';
  }
}