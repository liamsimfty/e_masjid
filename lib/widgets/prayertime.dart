import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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

class PrayerTimeWidget extends StatefulWidget {
  const PrayerTimeWidget({Key? key}) : super(key: key);

  @override
  State<PrayerTimeWidget> createState() => _PrayerTimeWidgetState();
}

class _PrayerTimeWidgetState extends State<PrayerTimeWidget> {
  PrayerTimes? _prayerTimes;
  bool _isLoadingPrayerTimes = true;
  String? _prayerTimesError;
  String? _highlightedPrayerName;
  int _highlightedPrayerIndex = -1;
  final ScrollController _prayerListScrollController = ScrollController();
  final List<Map<String, dynamic>> _prayerUIData = [];
  bool isLoading = true;

  // Constants for card dimensions
  static const double _prayerCardWidth = 75.0;
  static const double _prayerCardMarginHorizontal = 4.0;
  static const double _totalCardWidthWithMargins = _prayerCardWidth + (_prayerCardMarginHorizontal * 2);

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  @override
  void dispose() {
    _prayerListScrollController.dispose();
    super.dispose();
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
    int method = 4; // Umm al-Qura, Makkah
    final String url = 'https://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=$method&tune=0,0,0,0,0,0,0,0,0';

    try {
      final response = await http.get(Uri.parse(url));
      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['code'] == 200) {
            _prayerTimes = PrayerTimes.fromJson(data);
            _preparePrayerUIData();
            _isLoadingPrayerTimes = false;
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
        if(!_isLoadingPrayerTimes || _prayerTimesError != null) {
            isLoading = false;
            setState(() {});
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

        if (prayerDt.isAfter(now)) {
          if (prayerEntry['apiName'] != 'Sunrise') {
             if (closestFuturePrayerTime == null || prayerDt.isBefore(closestFuturePrayerTime)) {
                closestFuturePrayerTime = prayerDt;
                nextPrayerApiName = prayerEntry['apiName'] as String;
                nextPrayerIndex = i;
             }
          }
        }
      } catch (e) {
        print("Error parsing time for ${prayerEntry['name']}: $e");
      }
    }
    
    // If all prayers for today have passed, highlight Fajr (next day)
    if (nextPrayerApiName == null && _prayerUIData.isNotEmpty) {
        final ishaData = _prayerUIData.lastWhere((p) => p['apiName'] == 'Isha', orElse: () => {});
        if (ishaData.isNotEmpty) {
            final ishaTimeParts = (ishaData['time'] as String).split(':');
            if (ishaTimeParts.length == 2) {
                try {
                    DateTime ishaDt = DateTime(now.year, now.month, now.day,
                        int.parse(ishaTimeParts[0]), int.parse(ishaTimeParts[1]));
                    if (now.isAfter(ishaDt)) {
                        nextPrayerApiName = 'Fajr';
                        nextPrayerIndex = _prayerUIData.indexWhere((p) => p['apiName'] == 'Fajr');
                    } else {
                         nextPrayerApiName = 'Isha';
                         nextPrayerIndex = _prayerUIData.indexWhere((p) => p['apiName'] == 'Isha');
                    }
                } catch(e) {/* ignore */}
            }
        }
        if(nextPrayerApiName == null) {
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
        double targetScrollOffset = (_highlightedPrayerIndex * _totalCardWidthWithMargins) -
                                   (screenWidth / 2) +
                                   (_totalCardWidthWithMargins / 2);

        targetScrollOffset = targetScrollOffset.clamp(
          _prayerListScrollController.position.minScrollExtent,
          _prayerListScrollController.position.maxScrollExtent,
        );

        _prayerListScrollController.animateTo(
          targetScrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildPrayerTimesSection() {
    if (_isLoadingPrayerTimes && _prayerTimes == null) {
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
                borderRadius: BorderRadius.circular(8)
              )
            ),
            Container(
              width: 150, 
              height: 16, 
              margin: const EdgeInsets.only(left: 8.0, bottom: 10.0), 
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(6)
              )
            ),
            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, 
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  width: _prayerCardWidth, 
                  margin: const EdgeInsets.symmetric(horizontal: _prayerCardMarginHorizontal), 
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15), 
                    borderRadius: BorderRadius.circular(12.0)
                  )
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
          borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.yellow[300], size: 30),
            const SizedBox(height: 8),
            Text(
              _prayerTimesError!, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: Colors.white.withOpacity(0.9), 
                fontSize: 14
              )
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: kPrimaryColor, size: 18),
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

    if (_prayerTimes == null || _prayerUIData.isEmpty) return const SizedBox.shrink();

    String nextPrayerDisplay = "";
    if (_highlightedPrayerName != null) {
        final highlightedPrayerInfo = _prayerUIData.firstWhere(
          (p) => p['apiName'] == _highlightedPrayerName, 
          orElse: () => {}
        );
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
            child: Text(
              "Jadwal Shalat (${_prayerTimes!.dateReadable})", 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 17, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 10.0),
            child: Text(
              _prayerTimes!.hijriDateReadable + nextPrayerDisplay, 
              style: TextStyle(
                color: Colors.white.withOpacity(0.85), 
                fontSize: 13, 
                fontWeight: FontWeight.w500
              )
            ),
          ),
          SizedBox(
            height: 85,
            child: ListView.builder(
              controller: _prayerListScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _prayerUIData.length,
              itemBuilder: (context, index) {
                final prayerItem = _prayerUIData[index];
                bool isHighlighted = prayerItem['apiName'] == _highlightedPrayerName && 
                                   prayerItem['apiName'] != 'Sunrise';
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
    final cardWidth = isHighlighted ? _prayerCardWidth + 10 : _prayerCardWidth;
    final cardHeight = isHighlighted ? 85.0 : 75.0;
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
      margin: EdgeInsets.symmetric(
        horizontal: _prayerCardMarginHorizontal, 
        vertical: (85 - cardHeight)/2
      ),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isHighlighted
            ? [BoxShadow(
                color: kPrimaryColor.withOpacity(0.3), 
                blurRadius: 8, 
                spreadRadius: 1, 
                offset: const Offset(0, 2)
              )]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          SizedBox(height: isHighlighted ? 6 : 5),
          Text(
            name,
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.white.withOpacity(0.85), 
              fontSize: nameFontSize, 
              fontWeight: nameFontWeight
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              color: Colors.white, 
              fontSize: timeFontSize, 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPrayerTimesSection();
  }
}