import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:e_masjid/providers/user.provider.dart';
import '../services/firestore_service.dart';
import 'package:e_masjid/widgets/widgets.dart';
import 'package:e_masjid/providers/user_role_provider.dart';
import 'package:e_masjid/mixins/role_checker_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, RoleCheckerMixin {
  String username = "";
  bool isLoading = true;
  
  // Reduced to single animation controller for main content
  late AnimationController _mainAnimationController;
  late Animation<double> _fadeAnimation;

  final FireStoreService fireStoreService = FireStoreService();

  // --- State for highlighting and scrolling prayer times ---

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    // Single animation controller for all content
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800), 
      vsync: this
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController, 
        curve: Curves.easeInOut
      )
    );
  }

  Future<void> _initializeData() async {
    await initializeUserRole(context);
    try {
      var value = await fireStoreService.getdata();
      if (mounted) {
        setState(() {
          username = value.data()?["name"] ?? "Guest";
          isLoading = false;
        });
      }
      _mainAnimationController.forward();
    } catch (e) {
      if (mounted) setState(() => username = "Guest");
      print('Error loading user data: $e');
      _mainAnimationController.forward();
      isLoading = false;
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        if (roleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final appUser = Provider.of<AppUser>(context);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const CustomAppBar(
            title: 'Home',
            showBackButton: false,
          ),
          body: Stack(
            children: [
              const GradientBackground(
                showDecorativeCircles: true,
                child: SizedBox.expand(),
              ),
              SafeArea(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        HomeHeaderWidget(username: username, appUser: appUser),
                        const PrayerTimeWidget(),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F9FA), 
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30), 
                                topRight: Radius.circular(30)
                              )
                            ),
                            child: ServiceGridWidget(
                              choices: isPetugas(context) ? petugasChoices : choices,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                    )
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

const List<Choice> choices = [
  Choice(
    title: 'Tanya Imam',
    icon: Icons.man_outlined,
    route: '/tanya-imam',
    color: Colors.blue,
  ),
  Choice(
    title: 'Sewa Aula',
    icon: Icons.meeting_room_outlined,
    route: '/sewa-aula',
    color: Colors.green,
  ),
  Choice(
    title: 'Jadwal Program',
    icon: Icons.calendar_month_outlined,
    route: '/program',
    color: Colors.orange,
  ),
  Choice(
    title: 'Sumbangan',
    icon: Icons.payments_outlined,
    route: '/derma',
    color: Colors.red,
  ),
  Choice(
    title: 'Lihat Status',
    icon: Icons.check_circle_outline_outlined,
    route: '/semak',
    color: Colors.purple,
  ),
  Choice(
    title: 'Al-Quran',
    icon: Icons.menu_book_outlined,
    route: '/quran',
    color: Colors.teal,
  ),
  Choice(
    title: 'Hadis 40',
    icon: Icons.note_outlined,
    route: '/hadis',
    color: Colors.indigo,
  ),
  Choice(
    title: 'Doa Harian',
    icon: Icons.favorite_outlined,
    route: '/doa',
    color: Colors.pink,
  ),
];

const List<Choice> petugasChoices = [
  Choice(
    title: 'Program',
    icon: Icons.verified_user_outlined,
    route: '/program',
    color: Colors.blueGrey,
  ),
  Choice(
    title: 'Permohonan',
    icon: Icons.list_alt_outlined,
    route: '/semak',
    color: Colors.deepOrange,
  ),
  // Tambahkan sesuai kebutuhan
];
