import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildNavItem(int index, String iconPath, String label) {
    bool isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top active indicator
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 12),
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF7F0B34),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'assets/images/bottom_nev_image/home.png', 'Home'),
            _buildNavItem(1, 'assets/images/bottom_nev_image/trend.png', 'Progress'),
            _buildNavItem(2, 'assets/images/bottom_nev_image/step.png', 'Add Steps'),
            _buildNavItem(3, 'assets/images/bottom_nev_image/settings.png', 'Settings'),
          ],
        ),
      ),
    );
  }
}
