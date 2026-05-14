import 'package:flutter/material.dart';
import 'welcome_onbording.dart';
import 'services/api_service.dart';
import 'App_Admin/admin_dashboard.dart' as admin;
import 'App_Client_User/user_dashboard.dart' as client;
import 'App_User/user_dashboard.dart' as user;
import 'services/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solid Steps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800B39)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Add a small delay to let the emulator/system stabilize
      await Future.delayed(const Duration(milliseconds: 500));
      await LocationService.handleLocationPermission();
      await _checkAuth();
    } catch (e) {
      debugPrint("Initialization error: $e");
      // Still try to check auth even if location fails
      await _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    debugPrint("Auth check started...");
    final token = await ApiService.getAccessToken();
    final role = await ApiService.getUserRole();
    debugPrint("Token found: ${token != null}, Role: $role");

    if (mounted) {
      if (token != null && role != null) {
        debugPrint("Verifying session with getProfile()...");
        try {
          final result = await ApiService.getProfile();
          debugPrint("getProfile result: ${result['success']}");
          
          if (mounted) {
            if (result['success'] == false) {
              final errorMsg = result['message']?.toString().toLowerCase() ?? "";
              debugPrint("Session invalid: ${result['error_type']}, Message: $errorMsg");

              if (result['error_type'] == 'session_expired' || errorMsg.contains('jwt')) {
                debugPrint("Redirecting to WelcomeOnboarding due to token issue.");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeOnboarding()),
                );
                return;
              }
            }

            debugPrint("Proceeding to dashboard for role: $role");
            Widget dashboard;
            if (role == 'admin') {
              dashboard = const admin.AdminDashboardScreen();
            } else if (role == 'client') {
              dashboard = const client.ClientUserDashboardScreen();
            } else {
              dashboard = const user.UserDashboardScreen();
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboard),
            );
          }
        } catch (e) {
          debugPrint("Error during getProfile: $e");
          // Fallback if needed
          if (mounted) {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeOnboarding()),
            );
          }
        }
      } else {
        debugPrint("No token or role, redirecting to onboarding.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeOnboarding()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF800B39)),
      ),
    );
  }
}
