import 'package:flutter/material.dart';
import '../Custom_Bottom_Nevigation_Bar/custom_bottom_nevigaiton.dart';
import 'progress.dart'; // Imports ClientProgressPage from the same folder
import 'add_steps.dart'; // Imports ClientAddStepsPage from the same folder
import 'settings.dart'; // Imports ClientSettingsPage from the same folder

class ClientUserDashboardScreen extends StatefulWidget {
  const ClientUserDashboardScreen({super.key});

  @override
  State<ClientUserDashboardScreen> createState() => _ClientUserDashboardScreenState();
}

class _ClientUserDashboardScreenState extends State<ClientUserDashboardScreen> {
  int _currentIndex = 0;

  // Pages for each tab
  List<Widget> get _pages => [
    const _ClientHomeContent(),
    const ClientProgressPage(),
    const ClientAddStepsPage(),
    const ClientSettingsPage(),
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

class _ClientHomeContent extends StatelessWidget {
  const _ClientHomeContent();

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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B0A16),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.grey, size: 30),
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
                          color: index < 4 ? const Color(0xFF800B39) : const Color(0xFFD3E1DD),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "4 days tracking consistently! Keep it up.",
                    style: TextStyle(
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
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "100",
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF800B39),
                              ),
                            ),
                            TextSpan(
                              text: "/10,000",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF800B39),
                              ),
                            ),
                          ],
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
            const Text(
              "You're 82% of the way to your daily goal.\nKeep the flow going, Laurie Schamber.",
              style: TextStyle(
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
                  widthFactor: 0.82,
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
    );
  }
}
