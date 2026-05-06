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
    await LocationService.handleLocationPermission();
    await _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiService.getAccessToken();
    final role = await ApiService.getUserRole();

    if (mounted) {
      if (token != null && role != null) {
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
      } else {
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
