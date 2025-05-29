import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_masjid/widgets/widgets.dart'; // Assuming CustomNavBar is here
import 'package:e_masjid/config/constants.dart'; // Assuming kPrimaryColor is here
import 'package:provider/provider.dart';
import 'package:e_masjid/providers/user.provider.dart'; // Assuming AppUser is here
import '../services/firestore_service.dart';
import 'dart:math' as math;

// Import for HTTP requests and JSON decoding
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import for date formatting
import 'package:intl/intl.dart';

// --- PrayerTimes Model ---
// You can move this to a separate file e.g., models/prayer_times_model.dart
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

    // Helper to format time from "HH:mm (Offset)" to "HH:mm"
    String formatTime(String timeWithOffset) {
      return timeWithOffset.split(" ")[0];
    }

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
// --- End of PrayerTimes Model ---

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  static Route route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String username = "";
  bool isLoading = true; // Overall loading state
  late AnimationController _headerAnimationController;
  late AnimationController _gridAnimationController;
  late AnimationController _prayerTimesAnimationController; // For prayer times
  late Animation<double> _headerAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _prayerTimesFadeAnimation; // For prayer times

  final FireStoreService fireStoreService = FireStoreService();

  // Prayer Times State
  PrayerTimes? _prayerTimes;
  bool _isLoadingPrayerTimes = true; // Specific loading for prayer times
  String? _prayerTimesError;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _fetchPrayerTimes(); // Fetch prayer times
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _prayerTimesAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Animation for prayer times
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeInOut,
    ));

    _prayerTimesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _prayerTimesAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadUserData() async {
    // No longer setting isLoading to true here, _fetchPrayerTimes will handle the overall
    try {
      var value = await fireStoreService.getdata();
      if (mounted) {
        setState(() {
          username = value.data()?["name"] ?? "Guest";
        });
      }

      // Start header and grid animations
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _gridAnimationController.forward();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          username = "Guest";
        });
      }
      print('Error loading user data: $e');
    }
    // isLoading will be set to false in _fetchPrayerTimes' finally block
  }

  Future<void> _fetchPrayerTimes() async {
    if (mounted) {
      setState(() {
        _isLoadingPrayerTimes = true;
        _prayerTimesError = null;
      });
    }

    DateTime now = DateTime.now();
    String date = DateFormat('dd-MM-yyyy').format(now);
    double latitude = -6.2088; // Jakarta latitude
    double longitude = 106.8456; // Jakarta longitude
    int method = 4; // Calculation method (e.g., University of Islamic Sciences, Karachi)
                    // You might want to make this configurable or use a more common one for Indonesia.
                    // For Indonesia, method 20 (Kemenag) is often used if available or if you use their specific API.
                    // AlAdhan API method 3 is Diyanet İşleri Başkanlığı, Turkey.
                    // Method 4 is Umm al-Qura University, Makkah.
                    // Check AlAdhan documentation for the best method for your target audience.

    final String url =
        'https://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=$method&tune=0,0,0,0,0,0,0,0,0'; // Added tune for no offsets

    try {
      final response = await http.get(Uri.parse(url));
      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['code'] == 200) {
            setState(() {
              _prayerTimes = PrayerTimes.fromJson(data);
              _isLoadingPrayerTimes = false;
            });
            _prayerTimesAnimationController.forward(); // Start animation on success
          } else {
            throw Exception('API Error: ${data['status']}');
          }
        } else {
          throw Exception(
              'Failed to load prayer times. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      if (mounted) {
        setState(() {
          _prayerTimesError =
              'Gagal memuat waktu shalat.\nPeriksa koneksi internet Anda.';
          _isLoadingPrayerTimes = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // All initial loading attempts are done
        });
      }
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _gridAnimationController.dispose();
    _prayerTimesAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUser>(context);
    // final size = MediaQuery.of(context).size; // Not used, can be removed

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryColor,
                  kPrimaryColor.withOpacity(0.8),
                  kPrimaryColor.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -80,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    final animValue = _headerAnimation.value.clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(0, -50 * (1 - animValue)),
                      child: Opacity(
                        opacity: animValue,
                        child: _buildHeader(appUser),
                      ),
                    );
                  },
                ),
                // --- Prayer Times Section ---
                AnimatedBuilder(
                  animation: _prayerTimesFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _prayerTimesFadeAnimation.value,
                      child: _buildPrayerTimesSection(),
                    );
                  },
                ),
                // --- End of Prayer Times Section ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10), // Adjusted margin
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildGridContent(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  Widget _buildHeader(AppUser appUser) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0), // Reduced bottom padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start vertically
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space
              children: [
                Text(
                  "Assalamu'alaikum,",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "e-Masjid Halim Shah",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
            Container(
              width: 200,
              height: 20,
              margin: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              width: 150,
              height: 16,
              margin: const EdgeInsets.only(left: 8.0, bottom: 10.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            SizedBox(
              height: 75,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Number of shimmer cards
                itemBuilder: (context, index) => Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_prayerTimesError != null) {
      return Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.yellow[300], size: 30),
            const SizedBox(height: 8),
            Text(
              _prayerTimesError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: kPrimaryColor, size: 18,),
              label: Text("Coba Lagi", style: TextStyle(color: kPrimaryColor, fontSize: 14)),
              onPressed: _fetchPrayerTimes,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14)
              ),
            )
          ],
        ),
      );
    }

    if (_prayerTimes == null) {
      // This case should ideally be covered by isLoading or error state
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Horizontal padding handled by cards
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 0.0), // Align with header
            child: Text(
              "Jadwal Shalat (${_prayerTimes!.dateReadable})",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 10.0), // Align with header
            child: Text(
              _prayerTimes!.hijriDateReadable,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 75,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0), // Padding for the list itself
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildPrayerTimeCard(
                    "Subuh", _prayerTimes!.fajr, Icons.brightness_4_outlined),
                _buildPrayerTimeCard(
                    "Terbit", _prayerTimes!.sunrise, Icons.wb_sunny_outlined),
                _buildPrayerTimeCard(
                    "Dzuhur", _prayerTimes!.dhuhr, Icons.brightness_5_outlined),
                _buildPrayerTimeCard(
                    "Ashar", _prayerTimes!.asr, Icons.brightness_6_outlined),
                _buildPrayerTimeCard("Maghrib", _prayerTimes!.maghrib,
                    Icons.brightness_3_outlined),
                _buildPrayerTimeCard(
                    "Isya", _prayerTimes!.isha, Icons.nights_stay_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getCurrentPrayerTime() {
    if (_prayerTimes == null) return null;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final prayerTimes = [
      {'name': 'Subuh', 'time': _prayerTimes!.fajr},
      {'name': 'Terbit', 'time': _prayerTimes!.sunrise},
      {'name': 'Dzuhur', 'time': _prayerTimes!.dhuhr},
      {'name': 'Ashar', 'time': _prayerTimes!.asr},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib},
      {'name': 'Isya', 'time': _prayerTimes!.isha},
    ];

    // Find the next prayer time
    for (int i = 0; i < prayerTimes.length; i++) {
      if (prayerTimes[i]['time']!.compareTo(currentTime) > 0) {
        return prayerTimes[i]['name'];
      }
    }
    
    // If all prayer times have passed, return the first prayer of the next day
    return 'Subuh';
  }

  Widget _buildPrayerTimeCard(String name, String time, IconData icon) {
    final isCurrentPrayer = name == _getCurrentPrayerTime();
    
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isCurrentPrayer ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isCurrentPrayer ? Colors.white : Colors.white.withOpacity(0.2),
          width: isCurrentPrayer ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isCurrentPrayer ? Colors.white : Colors.white.withOpacity(0.9),
            size: isCurrentPrayer ? 24 : 20,
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(
              color: isCurrentPrayer ? Colors.white : Colors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: isCurrentPrayer ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isCurrentPrayer ? FontWeight.w800 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AppUser appUser) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _showLogoutDialog(appUser),
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(AppUser appUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text("Log Keluar"),
          ],
        ),
        content: const Text(
          "Anda pasti mahu log keluar?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tidak",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await appUser.signOut();
              if (mounted) {
                Navigator.pop(context);
                // Optional: Navigate to login screen
                // Navigator.of(context).pushNamedAndRemoveUntil('/login_or_splash', (Route<dynamic> route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Ya",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Adjusted top padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 12),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              itemCount: choices.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _gridAnimationController,
                  builder: (context, child) {
                    final delay = index * 0.1;
                    final progress = math.max(
                        0.0,
                        math.min(
                            1.0,
                            (_gridAnimationController.value - delay) /
                                (1 - delay).clamp(0.1, 1.0)));
                    final animationValue =
                        Curves.easeOutBack.transform(progress);

                    return Transform.scale(
                      scale: math.max(0.0, animationValue),
                      child: SelectCard(
                        choice: choices[index],
                        index: index,
                      ),
                    );
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

class SelectCard extends StatefulWidget {
  const SelectCard({
    super.key,
    required this.choice,
    required this.index,
  });

  final Choice choice;
  final int index;

  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  Navigator.pushNamed(context, widget.choice.route);
                }
              });
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? widget.choice.iconColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: _isPressed ? 15 : 10,
                    offset: Offset(0, _isPressed ? 8 : 5),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: widget.choice.iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.choice.icon,
                      color: widget.choice.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        widget.choice.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF2D3748),
                          height: 1.2,
                        ),
                      ),
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
  const Choice({
    required this.title,
    required this.icon,
    required this.cardColor, // Not actively used in SelectCard's current design
    required this.iconColor,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final String route;
}

const List<Choice> choices = <Choice>[
  Choice(
    title: 'Tanya Imam',
    icon: Icons.edit_note_outlined,
    cardColor: Colors.yellow,
    iconColor: Color(0xFF6366F1),
    route: '/tanya',
  ),
  Choice(
    title: 'Mohon Nikah',
    icon: Icons.favorite,
    cardColor: Colors.yellow,
    iconColor: Color(0xFFEF4444),
    route: '/nikah',
  ),
  Choice(
    title: 'Tempah Qurban',
    icon: Icons.payment_outlined, // Was Icons.mosque_outlined, using payment for consistency
    cardColor: Colors.yellow,
    iconColor: Color(0xFFF59E0B),
    route: '/qurban',
  ),
  Choice(
    title: 'Jadual Program',
    icon: Icons.calendar_today,
    cardColor: Colors.yellow,
    iconColor: Color(0xFF06B6D4),
    route: '/program',
  ),
  Choice(
    title: 'Sumbangan',
    icon: Icons.volunteer_activism, // Changed from bitcoin to a more general icon
    cardColor: Colors.yellow,
    iconColor: Color(0xFFFBBF24),
    route: '/derma',
  ),
  Choice(
    title: 'Semak Status',
    icon: Icons.check_circle_outline,
    cardColor: Colors.yellow,
    iconColor: Color(0xFF10B981),
    route: '/semak',
  ),
  Choice(
    title: 'Al-Quran',
    icon: Icons.menu_book_outlined,
    cardColor: Colors.yellow,
    iconColor: Color(0xFF8B5CF6),
    route: '/qurban', // Note: Original had '/quran', corrected for consistency if it was a typo
  ),
  Choice(
    title: 'Hadis 40',
    icon: Icons.note_outlined,
    cardColor: Colors.yellow,
    iconColor: Color(0xFF14B8A6),
    route: '/hadis',
  ),
  Choice(
    title: 'Doa Harian',
    icon: Icons.description_outlined,
    cardColor: Colors.yellow,
    iconColor: Color(0xFFEC4899), // Changed color for variety
    route: '/doa',
  ),
];

// Placeholder for CustomNavBar if it's in widgets.dart
// class CustomNavBar extends StatelessWidget {
//   const CustomNavBar({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(items: const [
//       BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//       BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
//     ]);
//   }
// }