import 'package:flutter/material.dart';
import '../Custom_Bottom_Nevigation_Bar/custom_bottom_nevigaiton.dart';

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
    const SafeArea(child: Center(child: Text('Progress Page Content', style: TextStyle(fontSize: 20)))),
    const SafeArea(child: Center(child: Text('Add Steps Page Content', style: TextStyle(fontSize: 20)))),
    const SafeArea(child: Center(child: Text('Settings Page Content', style: TextStyle(fontSize: 20)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEAEF),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Hi!, Laurie Schamber",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B0A16),
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Daily Streak Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B0A16),
                        ),
                      ),
                      Image.asset('assets/images/App_features/fire_icon.png', height: 24),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index < 4 ? const Color(0xFF800B39) : const Color(0xFFD3E1DD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "4 days tracking consistently! Keep it up.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8A606A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Middle Circle Image
            Center(
              child: Image.asset(
                'assets/images/App_features/middle_circle_image.png.png',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Daily Momentum
            const Text(
              "Daily Momentum",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B0A16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You're 82% of the way to your daily goal.\nKeep the flow going, Laurie Schamber.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8A606A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3E1DD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.82,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF800B39),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
