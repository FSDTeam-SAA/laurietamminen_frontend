import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../Authentication/login.dart';

class ClientsDetailsScreen extends StatefulWidget {
  final String alertId;
  const ClientsDetailsScreen({super.key, required this.alertId});

  @override
  State<ClientsDetailsScreen> createState() => _ClientsDetailsScreenState();
}

class _ClientsDetailsScreenState extends State<ClientsDetailsScreen> {
  Map<String, dynamic>? _alertData;
  bool _isLoading = true;
  Timer? _locationTimer;
  LatLng _currentLocation = const LatLng(38.897, -77.036);

  @override
  void initState() {
    super.initState();
    _fetchInitialDetails();
    // Set up a timer to update location every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateLocation();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialDetails() async {
    try {
      final result = await ApiService.getAlertDetail(widget.alertId);
      if (mounted && result['success'] == true) {
        setState(() {
          _alertData = result['data'];
          final coords = _alertData?['coordinates'];
          if (coords != null) {
            _currentLocation = LatLng(coords['lat'].toDouble(), coords['lng'].toDouble());
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching alert details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation() async {
    try {
      final result = await ApiService.getAlertDetail(widget.alertId);
      if (mounted && result['success'] == true) {
        setState(() {
          _alertData = result['data'];
          final coords = _alertData?['coordinates'];
          if (coords != null) {
            _currentLocation = LatLng(coords['lat'].toDouble(), coords['lng'].toDouble());
          }
        });
      }
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  Future<void> _makeCall() async {
    String? phoneNumber = _alertData?['phone_number']?.toString();
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Remove spaces or parentheses that might break the URI
      phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      
      try {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch dialer: $e")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone number not found")),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    String? phoneNumber = _alertData?['phone_number']?.toString();
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
      );
      
      try {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch messages app: $e")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone number not found")),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color bgColor = Color(0xFFFDF5F7);
    const Color softPink = Color(0xFFFDE6ED);
    const Color darkText = Color(0xFF2B0A16);
    const Color greyText = Color(0xFF8A606A);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryDarkRed)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: darkText, size: 28),
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              "Client Detail",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: primaryDarkRed,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   width: 44,
                    //   height: 44,
                    //   decoration: const BoxDecoration(
                    //     color: softPink,
                    //     shape: BoxShape.circle,
                    //   ),
                    //   // child: IconButton(
                    //   //   icon: const Icon(Icons.more_vert, color: darkText, size: 24),
                    //   //   onPressed: () {},
                    //   // ),
                    // ),
                  ],
                ),
              ),

              // Map Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: _currentLocation,
                            initialZoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.laurietamminen_frontend',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation,
                                  width: 48,
                                  height: 48,
                                  child: const Icon(Icons.location_on, color: primaryDarkRed, size: 48),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // User Location Box
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _buildOverlayBox(
                            title: "USER LOCATION",
                            content: "${_currentLocation.latitude.toStringAsFixed(4)}° N,\n${_currentLocation.longitude.toStringAsFixed(4)}° W",
                            icon: Icons.my_location,
                          ),
                        ),
                        // Accuracy Box
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _buildOverlayBox(
                            title: "STATUS",
                            content: _alertData?['status'] ?? "PENDING",
                            isCenter: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: "Call",
                        icon: Icons.phone,
                        bgColor: primaryDarkRed,
                        textColor: Colors.white,
                        onTap: _makeCall,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        label: "Message",
                        icon: Icons.chat_bubble_outline,
                        bgColor: softPink,
                        textColor: primaryDarkRed,
                        onTap: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Client Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CLIENT ID",
                        style: TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _alertData?['full_name'] ?? _alertData?['client_id'] ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryDarkRed,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: softPink,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: primaryDarkRed, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Status: ${_alertData?['status'] ?? 'PENDING'}",
                              style: const TextStyle(color: primaryDarkRed, fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Street address",
                        style: TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _alertData?['street_address'] ?? "Unknown Address",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                            child: const Icon(Icons.location_on, color: darkText, size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Operational Status
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "OPERATIONAL STATUS",
                  style: TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildStatusButton("Mark In Progress", () {}),
                    const SizedBox(height: 16),
                    _buildStatusButton("Resolve", () {}),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Stats
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard("LAST SYNC", "Just Now")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("ALERT ID", widget.alertId.substring(widget.alertId.length - 6))),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Logout Option
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: GestureDetector(
                  onTap: _handleLogout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDE6ED)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: primaryDarkRed, size: 28),
                        const SizedBox(width: 20),
                        const Text(
                          "Log Out",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                        ),
                      ],
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

  Widget _buildOverlayBox({required String title, required String content, IconData? icon, bool isCenter = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE6ED).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF800B39), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2B0A16), letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF800B39))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color bgColor, required Color textColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFFDE6ED),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF800B39), fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF800B39), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B0A16))),
        ],
      ),
    );
  }
}
