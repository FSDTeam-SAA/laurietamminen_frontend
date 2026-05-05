import 'package:flutter/material.dart';
import 'Authentication/login.dart';
import 'Authentication/signup.dart';

class WelcomeOnboarding extends StatefulWidget {
  const WelcomeOnboarding({super.key});

  @override
  State<WelcomeOnboarding> createState() => _WelcomeOnboardingState();
}

class _WelcomeOnboardingState extends State<WelcomeOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color bgColor = const Color(0xFFFEEAEF);
  final Color greyText = const Color(0xFF8A606A);
  final Color darkText = const Color(0xFF2B0A16);
  final Color inactiveDot = const Color(0xFFBCCBC6);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 16 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryDarkRed : inactiveDot,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                  _buildPage4(),
                ],
              ),
            ),
            if (_currentPage < 3) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildDot(index)),
              ),
              const SizedBox(height: 30),
              _buildNextButton(),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/splash_screen/onbording_image1.png.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Stay active and monitor your daily and weekly steps. Add steps here from your choice of step tracker.",
            textAlign: TextAlign.center,
            style: TextStyle(color: greyText, fontSize: 16, height: 1.5),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/splash_screen/onbording_image2.png.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        const SizedBox(height: 30),
        Text(
          "Understand Your Activity",
          style: TextStyle(
            color: darkText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Simple insights into your daily and\nweekly step goals",
            textAlign: TextAlign.center,
            style: TextStyle(color: greyText, fontSize: 16, height: 1.5),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPage3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/splash_screen/onbording_image3.png.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        const SizedBox(height: 30),
        Text(
          "Your Data, Your Control",
          style: TextStyle(
            color: darkText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "We respect your privacy and keep your\ndata secure.",
            textAlign: TextAlign.center,
            style: TextStyle(color: greyText, fontSize: 16, height: 1.5),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPage4() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Image.asset(
          'assets/images/splash_screen/logo.png.png',
          height: 300,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 30),
        Text(
          "Start your Steps\nJourney",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: darkText,
            fontSize: 38,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const Spacer(flex: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDarkRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Log in",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryDarkRed, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: primaryDarkRed,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDarkRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Next",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
