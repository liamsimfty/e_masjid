import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:e_masjid/screens/petugas/add_program_screen.dart';
import 'package:e_masjid/screens/petugas/program_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:e_masjid/widgets/widgets.dart';
import 'package:e_masjid/mixins/role_checker_mixin.dart';
import 'package:provider/provider.dart';
import 'package:e_masjid/providers/user_role_provider.dart';

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
    with SingleTickerProviderStateMixin, RoleCheckerMixin {
  bool _isLoading = true;
  bool _showCalendarView = false; // To toggle between list and calendar view

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Map<String, dynamic>> _allProgramsData = [];
  List<Map<String, dynamic>> _displayedPrograms = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _viewOptions = ['All', 'Calendar'];
  String _currentView = 'All';

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
    _initializeData();
  }

  Future<void> _initializeData() async {
    await initializeUserRole(context);
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

  bool _canEditProgram() {
    return isAdmin(context) || isPetugas(context);
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
      _showCalendarView = (newValue == 'Calendar');
      if (_showCalendarView) {
        _selectedDay = DateTime.now(); // Reset to today when switching to calendar
        _focusedDay = DateTime.now();
      }
      _updateDisplayedPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        if (roleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(title: 'Jadwal Program'),
          floatingActionButton: _canEditProgram()
              ? FloatingActionButton.extended(
                  heroTag: 'add_program_hero_calendar',
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProgramScreen()));
                    if (result == true) {
                      _fetchProgramsData();
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
              const GradientBackground(child: SizedBox.expand()),
              const GradientBackground(
                showDecorativeCircles: true,
                child: const SizedBox.expand(),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Schedule',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 23.sp,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Masjid Program',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 31.sp,
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
                                  borderRadius: BorderRadius.circular(6.r),
                                  onTap: _fetchProgramsData,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // View Toggle Chips
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _viewOptions.map((String view) {
                            bool isSelected = _currentView == view;
                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25.r),
                                  onTap: () => _onViewChanged(view),
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
                                          view == 'Semua' ? Icons.list_rounded : Icons.calendar_month_rounded,
                                          size: 18.sp,
                                          color: isSelected 
                                              ? kPrimaryColor 
                                              : Colors.white,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          view,
                                          style: TextStyle(
                                            color: isSelected 
                                                ? kPrimaryColorDark 
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.sp,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Conditional Calendar View
                      if (_showCalendarView && !_isLoading)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
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
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: false,
                              selectedDecoration: BoxDecoration(
                                color: kPrimaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                              defaultTextStyle: TextStyle(
                                color: kPrimaryColorDark,
                                fontWeight: FontWeight.w500,
                              ),
                              selectedTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              todayTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                              formatButtonShowsNext: false,
                              titleTextStyle: TextStyle(
                                fontSize: 21.sp,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColorDark,
                              ),
                              formatButtonTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              formatButtonDecoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: kPrimaryColor,
                                size: 24.sp,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: kPrimaryColor,
                                size: 24.sp,
                              ),
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
                      if(_showCalendarView) SizedBox(height: 16.h),

                      // List of Programs
                      Expanded(
                        child: _isLoading
                            ? const LoadingShimmer()
                            : _displayedPrograms.isEmpty
                                ? Center(
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
                                              Icons.search_off_rounded,
                                              size: 64.sp,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                          SizedBox(height: 24.h),
                                          Text(
                                            _showCalendarView
                                                ? 'Tiada program pada tarikh ini.'
                                                : 'Tiada program dijumpai.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 25.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.9),
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : AnimationLimiter(
                                    child: ListView.builder(
                                      key: ValueKey(_currentView + _focusedDay.toString()),
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.only(bottom: 80.h, top: _showCalendarView ? 0 : 5.h),
                                      itemCount: _displayedPrograms.length,
                                      itemBuilder: ((context, index) {
                                        return AnimationConfiguration.staggeredList(
                                          position: index,
                                          duration: const Duration(milliseconds: 400),
                                          child: SlideAnimation(
                                            verticalOffset: 60.0,
                                            child: FadeInAnimation(
                                              child: _ProgramCard(
                                                program: _displayedPrograms[index],
                                              ),
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
        );
      },
    );
  }
}

class _ProgramCard extends StatelessWidget {
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => ProgramDetail(data: program),
              ),
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
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: kPrimaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryColorDark,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 17.sp,
                            color: kPrimaryColor.withOpacity(0.8),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            dateDisplay,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.access_time_outlined,
                            size: 17.sp,
                            color: kPrimaryColor.withOpacity(0.8),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            timeRange,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}