import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_masjid/widgets/widgets.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:provider/provider.dart';
import 'package:e_masjid/providers/user.provider.dart';
import '../services/firestore_service.dart';
import 'dart:math' as math;
import 'package:e_masjid/screens/screens.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// --- PrayerTimes Model (remains the same) ---
class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String dateReadable;
  final String hijriDateReadable;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.dateReadable,
    required this.hijriDateReadable,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final gregorianDate = json['data']['date']['readable'];
    final hijri = json['data']['date']['hijri'];
    final hijriDateReadable =
        "${hijri['day']} ${hijri['month']['en']} ${hijri['year']}";
    String formatTime(String timeWithOffset) => timeWithOffset.split(" ")[0];

    return PrayerTimes(
      fajr: formatTime(timings['Fajr']),
      sunrise: formatTime(timings['Sunrise']),
      dhuhr: formatTime(timings['Dhuhr']),
      asr: formatTime(timings['Asr']),
      maghrib: formatTime(timings['Maghrib']),
      isha: formatTime(timings['Isha']),
      dateReadable: gregorianDate,
      hijriDateReadable: hijriDateReadable,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String username = "";
  bool isLoading = true;
  late AnimationController _headerAnimationController;
  late AnimationController _gridAnimationController;
  late AnimationController _prayerTimesAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _prayerTimesFadeAnimation;

  final FireStoreService fireStoreService = FireStoreService();
  PrayerTimes? _prayerTimes;
  bool _isLoadingPrayerTimes = true;
  String? _prayerTimesError;

  // --- State for highlighting and scrolling prayer times ---
  String? _highlightedPrayerName; // Stores the API name like 'Fajr', 'Dhuhr'
  int _highlightedPrayerIndex = -1; // Index in the prayerDataList
  final ScrollController _prayerListScrollController = ScrollController();
  final List<Map<String, dynamic>> _prayerUIData = []; // To store UI data for prayers

  // Define fixed card width and margin for scroll calculation
  static const double _prayerCardWidth = 100.0;
  static const double _prayerCardMarginHorizontal = 6.0;
  static const double _totalCardWidthWithMargins =
      _prayerCardWidth + (_prayerCardMarginHorizontal * 2);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _fetchPrayerTimes();
  }

  void _initializeAnimations() {
    // ... (animation initializations remain the same)
    _headerAnimationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _gridAnimationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _prayerTimesAnimationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _gridAnimationController, curve: Curves.easeInOut));
    _prayerTimesFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _prayerTimesAnimationController, curve: Curves.easeInOut));
  }

  void _loadUserData() async {
    // ... (user data loading remains the same)
    try {
      var value = await fireStoreService.getdata();
      if (mounted) {
        setState(() {
          username = value.data()?["name"] ?? "Guest";
        });
      }
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () => _gridAnimationController.forward());
    } catch (e) {
      if (mounted) setState(() => username = "Guest");
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchPrayerTimes() async {
    if (mounted) {
      setState(() {
        _isLoadingPrayerTimes = true;
        _prayerTimesError = null;
        _highlightedPrayerName = null;
        _highlightedPrayerIndex = -1;
      });
    }

    DateTime now = DateTime.now();
    String date = DateFormat('dd-MM-yyyy').format(now);
    double latitude = -6.2088; // Jakarta
    double longitude = 106.8456; // Jakarta
    int method = 4; // Umm al-Qura, Makkah. Consider local alternatives if better.
    final String url = 'https://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=$method&tune=0,0,0,0,0,0,0,0,0';

    try {
      final response = await http.get(Uri.parse(url));
      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['code'] == 200) {
            _prayerTimes = PrayerTimes.fromJson(data);
            _preparePrayerUIData(); // Prepare UI data and determine highlight
            _isLoadingPrayerTimes = false;
            _prayerTimesAnimationController.forward();
             // Call setState once after all updates
            setState(() {});
          } else {
            throw Exception('API Error: ${data['status']}');
          }
        } else {
          throw Exception('Failed to load prayer times. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      if (mounted) {
        _prayerTimesError = 'Gagal memuat waktu shalat.\nPeriksa koneksi internet Anda.';
        _isLoadingPrayerTimes = false;
        setState(() {});
      }
    } finally {
      if (mounted) {
        // Ensure isLoading is set to false only after all attempts
        if(!_isLoadingPrayerTimes || _prayerTimesError != null) {
            isLoading = false;
            setState((){});
        }
      }
    }
  }

  void _preparePrayerUIData() {
    if (_prayerTimes == null) return;
    _prayerUIData.clear();
    _prayerUIData.addAll([
      {'name': 'Subuh', 'time': _prayerTimes!.fajr, 'icon': Icons.brightness_4_outlined, 'apiName': 'Fajr'},
      {'name': 'Terbit', 'time': _prayerTimes!.sunrise, 'icon': Icons.wb_sunny_outlined, 'apiName': 'Sunrise'},
      {'name': 'Dzuhur', 'time': _prayerTimes!.dhuhr, 'icon': Icons.brightness_5_outlined, 'apiName': 'Dhuhr'},
      {'name': 'Ashar', 'time': _prayerTimes!.asr, 'icon': Icons.brightness_6_outlined, 'apiName': 'Asr'},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib, 'icon': Icons.brightness_3_outlined, 'apiName': 'Maghrib'},
      {'name': 'Isya', 'time': _prayerTimes!.isha, 'icon': Icons.nights_stay_outlined, 'apiName': 'Isha'},
    ]);
    _determineAndSetHighlightedPrayer();
  }

  void _determineAndSetHighlightedPrayer() {
    if (_prayerTimes == null || _prayerUIData.isEmpty) return;

    DateTime now = DateTime.now();
    String? nextPrayerApiName;
    int nextPrayerIndex = -1;

    DateTime? closestFuturePrayerTime;

    for (int i = 0; i < _prayerUIData.length; i++) {
      final prayerEntry = _prayerUIData[i];
      final timeParts = (prayerEntry['time'] as String).split(':');
      if (timeParts.length != 2) continue;

      try {
        DateTime prayerDt = DateTime(now.year, now.month, now.day,
            int.parse(timeParts[0]), int.parse(timeParts[1]));

        // We are looking for the first prayer that is after 'now'
        if (prayerDt.isAfter(now)) {
          // Only consider actual prayers for highlighting, not Sunrise, unless it's the only option
          if (prayerEntry['apiName'] != 'Sunrise') {
             if (closestFuturePrayerTime == null || prayerDt.isBefore(closestFuturePrayerTime)) {
                closestFuturePrayerTime = prayerDt;
                nextPrayerApiName = prayerEntry['apiName'] as String;
                nextPrayerIndex = i;
             }
          } else if (nextPrayerApiName == null) { // If no actual prayer found yet, sunrise might be next
             if (closestFuturePrayerTime == null || prayerDt.isBefore(closestFuturePrayerTime)) {
                // Tentatively pick Sunrise if it's next and no other prayer is found yet
                // but prioritize actual prayers
             }
          }
        }
      } catch (e) {
        print("Error parsing time for ${prayerEntry['name']}: $e");
      }
    }
    
    // If all prayers for today have passed, highlight Fajr (implying next day)
    if (nextPrayerApiName == null && _prayerUIData.isNotEmpty) {
        // Check if current time is after Isha
        final ishaData = _prayerUIData.lastWhere((p) => p['apiName'] == 'Isha', orElse: () => {});
        if (ishaData.isNotEmpty) {
            final ishaTimeParts = (ishaData['time'] as String).split(':');
            if (ishaTimeParts.length == 2) {
                try {
                    DateTime ishaDt = DateTime(now.year, now.month, now.day,
                        int.parse(ishaTimeParts[0]), int.parse(ishaTimeParts[1]));
                    if (now.isAfter(ishaDt)) {
                        nextPrayerApiName = 'Fajr'; // Highlight Fajr for next day
                        nextPrayerIndex = _prayerUIData.indexWhere((p) => p['apiName'] == 'Fajr');
                    } else { // If it's before Isha but after Maghrib (and somehow Maghrib wasn't picked)
                         nextPrayerApiName = 'Isha';
                         nextPrayerIndex = _prayerUIData.indexWhere((p) => p['apiName'] == 'Isha');
                    }
                } catch(e) {/* ignore */}
            }
        }
        if(nextPrayerApiName == null) { // Ultimate fallback if Isha check failed or not applicable
            nextPrayerApiName = _prayerUIData.firstWhere((p) => p['apiName'] != 'Sunrise', orElse: () => _prayerUIData.first)['apiName'] as String;
            nextPrayerIndex = _prayerUIData.indexWhere((p) => p['apiName'] == nextPrayerApiName);
        }
    }


    _highlightedPrayerName = nextPrayerApiName;
    _highlightedPrayerIndex = nextPrayerIndex;

    if (_highlightedPrayerIndex != -1) {
      _scrollToHighlightedPrayer();
    }
  }

  void _scrollToHighlightedPrayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_prayerListScrollController.hasClients && _highlightedPrayerIndex != -1) {
        double screenWidth = MediaQuery.of(context).size.width;
        // Calculate the offset to center the card
        // Target position for the card's left edge: (screenWidth / 2) - (cardWidthWithMargin / 2)
        // Scroll amount: (highlightedIndex * totalCardWidth) - targetXForCardLeftEdge
        double targetScrollOffset = (_highlightedPrayerIndex * _totalCardWidthWithMargins) -
                                   (screenWidth / 2) +
                                   (_totalCardWidthWithMargins / 2);

        // Clamp the offset
        targetScrollOffset = targetScrollOffset.clamp(
          _prayerListScrollController.position.minScrollExtent,
          _prayerListScrollController.position.maxScrollExtent,
        );

        _prayerListScrollController.animateTo(
          targetScrollOffset,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _gridAnimationController.dispose();
    _prayerTimesAnimationController.dispose();
    _prayerListScrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUser>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8), kPrimaryColor.withOpacity(0.6)],
              ),
            ),
          ),
          Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
          Positioned(top: 100, left: -80, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
          SafeArea(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, -20 * (1 - _headerAnimation.value.clamp(0.0, 1.0))), 
                    child: Opacity(
                      opacity: _headerAnimation.value.clamp(0.0, 1.0), 
                      child: _buildHeader(appUser)
                    )
                  ),
                ),
                AnimatedBuilder(
                  animation: _prayerTimesFadeAnimation,
                  builder: (context, child) => Opacity(opacity: _prayerTimesFadeAnimation.value, child: _buildPrayerTimesSection()),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) => Opacity(opacity: _fadeAnimation.value, child: _buildGridContent()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
            ),
        ],
      ),
      //bottomNavigationBar: const CustomNavBar(),
    );
  }

  Widget _buildHeader(AppUser appUser) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Assalamu'alaikum", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(username, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text("e-Masjid Halim Shah", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          _buildLogoutButton(appUser),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection() {
    if (_isLoadingPrayerTimes && _prayerTimes == null) {
      // Shimmer/Placeholder View
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 20, margin: const EdgeInsets.only(left: 8.0, bottom: 4.0), decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(8))),
            Container(width: 150, height: 16, margin: const EdgeInsets.only(left: 8.0, bottom: 10.0), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6))),
            SizedBox(
              height: 85, // Match highlighted card height
              child: ListView.builder(
                scrollDirection: Axis.horizontal, itemCount: 5,
                itemBuilder: (context, index) => Container(width: _prayerCardWidth, margin: const EdgeInsets.symmetric(horizontal: _prayerCardMarginHorizontal), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12.0))),
              ),
            ),
          ],
        ),
      );
    }

    if (_prayerTimesError != null) {
      return Container(
        padding: const EdgeInsets.all(20.0), margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.yellow[300], size: 30),
            const SizedBox(height: 8),
            Text(_prayerTimesError!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: kPrimaryColor, size: 18),
              label: Text("Coba Lagi", style: TextStyle(color: kPrimaryColor, fontSize: 14)),
              onPressed: _fetchPrayerTimes,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontSize: 14)),
            )
          ],
        ),
      );
    }

    if (_prayerTimes == null || _prayerUIData.isEmpty) return const SizedBox.shrink();

    String nextPrayerDisplay = "";
    if (_highlightedPrayerName != null) {
        final highlightedPrayerInfo = _prayerUIData.firstWhere((p) => p['apiName'] == _highlightedPrayerName, orElse: () => {});
        if (highlightedPrayerInfo.isNotEmpty) {
             nextPrayerDisplay = " • Berikutnya: ${highlightedPrayerInfo['name']}";
        }
    }


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 0.0),
            child: Text("Jadwal Shalat (${_prayerTimes!.dateReadable})", style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 10.0),
            child: Text(_prayerTimes!.hijriDateReadable + nextPrayerDisplay, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            height: 85, // Adjusted for potentially larger highlighted card
            child: ListView.builder(
              controller: _prayerListScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _prayerUIData.length,
              itemBuilder: (context, index) {
                final prayerItem = _prayerUIData[index];
                // Sunrise is generally not highlighted as a "prayer" in the same way
                bool isHighlighted = prayerItem['apiName'] == _highlightedPrayerName && prayerItem['apiName'] != 'Sunrise';
                return _buildPrayerTimeCard(
                  name: prayerItem['name'] as String,
                  time: prayerItem['time'] as String,
                  icon: prayerItem['icon'] as IconData,
                  isHighlighted: isHighlighted,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeCard({
    required String name,
    required String time,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    // Define styles for normal and highlighted states
    final cardWidth = isHighlighted ? _prayerCardWidth + 10 : _prayerCardWidth; // Highlighted card a bit wider
    final cardHeight = isHighlighted ? 85.0 : 75.0; // Highlighted card a bit taller
    final bgColor = isHighlighted ? Colors.white.withOpacity(0.35) : Colors.white.withOpacity(0.15);
    final borderColor = isHighlighted ? Colors.white : Colors.white.withOpacity(0.2);
    final borderWidth = isHighlighted ? 1.5 : 0.5;
    final borderRadius = isHighlighted ? 16.0 : 12.0;
    final iconSize = isHighlighted ? 22.0 : 20.0;
    final nameFontSize = isHighlighted ? 13.0 : 12.0;
    final timeFontSize = isHighlighted ? 15.0 : 14.0;
    final nameFontWeight = isHighlighted ? FontWeight.bold : FontWeight.w500;
    final iconColor = isHighlighted ? Colors.white : Colors.white.withOpacity(0.9);

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.symmetric(horizontal: _prayerCardMarginHorizontal, vertical: (85 - cardHeight)/2), // Center vertically
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isHighlighted
            ? [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2))]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          SizedBox(height: isHighlighted ? 6 : 5),
          Text(
            name,
            style: TextStyle(color: isHighlighted ? Colors.white : Colors.white.withOpacity(0.85), fontSize: nameFontSize, fontWeight: nameFontWeight),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(color: Colors.white, fontSize: timeFontSize, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


  Widget _buildLogoutButton(AppUser appUser) {
    // ... (logout button build logic remains the same)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)]),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _showLogoutDialog(appUser),
          child: Container(width: 50, height: 50, decoration: const BoxDecoration(shape: BoxShape.circle), child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24)),
        ),
      ),
    );
  }

  void _showLogoutDialog(AppUser appUser) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 10), Text("Log Keluar")]),
        content: const Text("Anda pasti mahu log keluar?", style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Tidak", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () async {
              await appUser.signOut();
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Ya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Layanan",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 20, childAspectRatio: 0.9),
              itemCount: choices.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _gridAnimationController,
                  builder: (context, child) {
                    final delay = index * 0.1;
                    final progress = math.max(0.0, math.min(1.0, (_gridAnimationController.value - delay) / (1 - delay).clamp(0.1, 1.0)));
                    final animationValue = Curves.easeOutBack.transform(progress);
                    return Transform.scale(scale: math.max(0.0, animationValue), child: SelectCard(choice: choices[index], index: index));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- SelectCard and Choice classes (remain the same) ---
class SelectCard extends StatefulWidget {
  const SelectCard({super.key, required this.choice, required this.index});
  final Choice choice;
  final int index;
  @override
  State<SelectCard> createState() => _SelectCardState();
}
class _SelectCardState extends State<SelectCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) { setState(() => _isPressed = true); _animationController.forward(); },
            onTapUp: (_) {
              setState(() => _isPressed = false); _animationController.reverse();
              Future.delayed(const Duration(milliseconds: 100), () { if (mounted) Navigator.pushNamed(context, widget.choice.route); });
            },
            onTapCancel: () { setState(() => _isPressed = false); _animationController.reverse(); },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey.shade50]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed ? widget.choice.iconColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                    blurRadius: _isPressed ? 15 : 10, offset: Offset(0, _isPressed ? 8 : 5), spreadRadius: _isPressed ? 2 : 0,
                  )],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(color: widget.choice.iconColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(widget.choice.icon, color: widget.choice.iconColor, size: 44),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(widget.choice.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color.fromARGB(255, 0, 0, 0), height: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Choice {
  const Choice({required this.title, required this.icon, required this.cardColor, required this.iconColor, required this.route});
  final String title;
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final String route;
}

const List<Choice> choices = <Choice>[ // Your choices list remains the same
  Choice(title: 'Tanya Imam', icon: Icons.edit_note_outlined, cardColor: Colors.yellow, iconColor: Color(0xFF6366F1), route: '/tanya-imam'),
  Choice(title: 'Sewa Aula', icon: Icons.assessment_outlined, cardColor: Colors.yellow, iconColor: Color(0xFFEF4444), route: '/sewa-aula'),
  Choice(title: 'Tempah Qurban', icon: Icons.payment_outlined, cardColor: Colors.yellow, iconColor: Color(0xFFF59E0B), route: '/qurban'),
  Choice(title: 'Jadual Program', icon: Icons.calendar_today, cardColor: Colors.yellow, iconColor: Color(0xFF06B6D4), route: '/program'),
  Choice(title: 'Sumbangan', icon: Icons.volunteer_activism, cardColor: Colors.yellow, iconColor: Color(0xFFFBBF24), route: '/derma'),
  Choice(title: 'Semak Status', icon: Icons.check_circle_outline, cardColor: Colors.yellow, iconColor: Color(0xFF10B981), route: '/semak'),
  Choice(title: 'Al-Quran', icon: Icons.menu_book_outlined, cardColor: Colors.yellow, iconColor: Color(0xFF8B5CF6), route: '/quran'),
  Choice(title: 'Hadis 40', icon: Icons.note_outlined, cardColor: Colors.yellow, iconColor: Color(0xFF14B8A6), route: '/hadis'),
  Choice(title: 'Doa Harian', icon: Icons.description_outlined, cardColor: Colors.yellow, iconColor: Color(0xFFEC4899), route: '/doa'),
];