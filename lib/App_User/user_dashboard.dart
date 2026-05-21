import 'package:flutter/material.dart';
import '../Custom_Bottom_Nevigation_Bar/custom_bottom_nevigaiton.dart';
import 'progress.dart';
import 'add_steps.dart';
import 'settings.dart';
import '../services/api_service.dart';
import '../welcome_onbording.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _currentIndex = 0;

  // Pages for each tab
  List<Widget> get _pages => [
    const _HomeContent(),
    const ProgressPage(),
    const AddStepsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEAEF),
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  Map<String, dynamic>? userProfile;
  int todaySteps = 0;
  int streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchProfile(),
        _fetchTodaySteps(),
        _fetchWeeklyData(),
      ]);
    } catch (e) {
      debugPrint("Error in _fetchInitialData: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSessionExpired() {
    if (!mounted) return;
    ApiService.clearSession();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeOnboarding()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session expired. Please login again.")),
    );
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await ApiService.getProfile();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          userProfile = result['data'];
        });
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<void> _fetchTodaySteps() async {
    try {
      final result = await ApiService.getTodaySteps();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          todaySteps = result['data']?['steps'] ?? 0;
        });
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      }
    } catch (e) {
      debugPrint("Error fetching steps: $e");
    }
  }

  Future<void> _fetchWeeklyData() async {
    try {
      final result = await ApiService.getWeeklySteps();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          streak = result['data']?['streak']?['current_streak'] ?? 0;
        });
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      }
    } catch (e) {
      debugPrint("Error fetching weekly data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String fullName = userProfile?['full_name'] ?? "User";
    final int stepGoal = userProfile?['step_goal'] ?? 0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Hi!, $fullName",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B0A16),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfilePage()),
                      );
                      _fetchInitialData(); // Refresh data when returning
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: userProfile?['profile_picture_url'] != null && userProfile?['profile_picture_url'] != ""
                            ? NetworkImage(userProfile!['profile_picture_url'])
                            : null,
                        child: userProfile?['profile_picture_url'] == null || userProfile?['profile_picture_url'] == ""
                            ? const Icon(Icons.person, color: Colors.grey, size: 30)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Daily Streak Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBFC).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF0D5DD), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Daily Streak",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B0A16),
                          ),
                        ),
                        Image.asset('assets/images/App_features/fire_icon.png', height: 24),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 5,
                          decoration: BoxDecoration(
                            color: index < streak ? const Color(0xFF800B39) : const Color(0xFFD3E1DD),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "$streak days tracking consistently! Keep it up.",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A606A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Middle Circle with Text overlay
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/App_features/middle_circle_image.png.png',
                      width: 320,
                      fit: BoxFit.contain,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 5), // Adjust based on image footprints
                        SizedBox(
                          width: 280, // Constrain width so it stays inside the circle
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "$todaySteps",
                                    style: const TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF800B39),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "/${stepGoal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF800B39),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          "STEPS TODAY",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A606A),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Daily Momentum
              const Text(
                "Daily Momentum",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B0A16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You're ${(todaySteps / stepGoal * 100).toStringAsFixed(0)}% of the way to your daily goal.\nKeep the flow going, $fullName.",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8A606A),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3E1DD),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (todaySteps / stepGoal).clamp(0.0, 1.0),
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF800B39),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
