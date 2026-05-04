import 'package:flutter/material.dart';
import '../App_User/user_dashboard.dart';
import '../App_Client_User/user_dashboard.dart';
import '../App_Admin/admin_dashboard.dart';

class UserRoleScreen extends StatefulWidget {
  const UserRoleScreen({super.key});

  @override
  State<UserRoleScreen> createState() => _UserRoleScreenState();
}

class _UserRoleScreenState extends State<UserRoleScreen> {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);
  
  String? selectedRole; // 'user' or 'client'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEAEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Choose Your Role",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Select how you would like to join our platform to customize your experience.",
                style: TextStyle(
                  fontSize: 16,
                  color: greyText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Role Cards
              _buildRoleCard(
                roleId: 'user',
                title: "Regular User",
                subtitle: "Track your steps, set goals, and monitor your daily progress.",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                roleId: 'client',
                title: "Client User",
                subtitle: "Access advanced client features and manage specialized activities.",
                icon: Icons.business_center_outlined,
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                roleId: 'admin',
                title: "Admin",
                subtitle: "Full system access to manage users, roles, and platform settings.",
                icon: Icons.admin_panel_settings_outlined,
              ),
              
              const Spacer(),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRole == null ? null : () {
                    if (selectedRole == 'user') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const UserDashboardScreen()),
                      );
                    } else if (selectedRole == 'client') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ClientUserDashboardScreen()),
                      );
                    } else if (selectedRole == 'admin') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDarkRed,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = selectedRole == roleId;
    
    return GestureDetector(
      onTap: () => setState(() => selectedRole = roleId),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryDarkRed : const Color(0xFFF0D5DD),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: primaryDarkRed.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? primaryDarkRed : const Color(0xFFFEEAEF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : primaryDarkRed,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: greyText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryDarkRed, size: 24),
          ],
        ),
      ),
    );
  }
}
