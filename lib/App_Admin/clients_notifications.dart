import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'clients_details.dart';
import '../services/api_service.dart';

class ClientsNotificationScreen extends StatefulWidget {
  const ClientsNotificationScreen({super.key});

  @override
  State<ClientsNotificationScreen> createState() =>
      _ClientsNotificationScreenState();
}

class _ClientsNotificationScreenState extends State<ClientsNotificationScreen> {
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  String _currentFilter = 'all';
  String _currentSort = 'newest';

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAdminAlerts(filter: _currentFilter);
      debugPrint("Fetched alerts: $result");
      if (mounted && result['success'] == true) {
        final data = result['data'];
        setState(() {
          if (data is List) {
            _alerts = data;
          } else {
            debugPrint("Warning: Expected list in data but got ${data.runtimeType}");
            _alerts = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching alerts: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color bgColor = Color(0xFFFDF5F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar replacement
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Clients Notification",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryDarkRed,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      _buildHeaderButton("Filter", onFilterTap: _showFilterMenu),
                      const SizedBox(width: 10),
                      _buildHeaderButton("Sort", onFilterTap: _showSortMenu),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryDarkRed),
                    )
                  : _alerts.isEmpty
                  ? const Center(child: Text("No notifications found"))
                    : RefreshIndicator(
                        onRefresh: _fetchAlerts,
                        color: primaryDarkRed,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: _alerts.length,
                          itemBuilder: (context, index) {
                            final alert = _alerts[index];
                            if (alert is! Map) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                _buildNotificationCard(
                                  context,
                                  alertId: alert['alert_id']?.toString() ?? "",
                                  clientId: alert['full_name']?.toString() ?? "Unknown Client",
                                  status: alert['status']?.toString() ?? "pending",
                                  location: alert['street_address']?.toString() ?? "Unknown Location",
                                  time: "Just Now",
                                  lat: alert['coordinates']?['lat']?.toDouble() ?? 23.8103,
                                  lng: alert['coordinates']?['lng']?.toDouble() ?? 90.4125,
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter by Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("All"),
                onTap: () {
                  setState(() => _currentFilter = 'all');
                  _fetchAlerts();
                  Navigator.pop(context);
                },
                trailing: _currentFilter == 'all' ? const Icon(Icons.check, color: Color(0xFF800B39)) : null,
              ),
              ListTile(
                title: const Text("Pending"),
                onTap: () {
                  setState(() => _currentFilter = 'PENDING');
                  _fetchAlerts();
                  Navigator.pop(context);
                },
                trailing: _currentFilter == 'PENDING' ? const Icon(Icons.check, color: Color(0xFF800B39)) : null,
              ),
              ListTile(
                title: const Text("In Progress"),
                onTap: () {
                  setState(() => _currentFilter = 'IN_PROGRESS');
                  _fetchAlerts();
                  Navigator.pop(context);
                },
                trailing: _currentFilter == 'IN_PROGRESS' ? const Icon(Icons.check, color: Color(0xFF800B39)) : null,
              ),
              ListTile(
                title: const Text("Resolved"),
                onTap: () {
                  setState(() => _currentFilter = 'RESOLVED');
                  _fetchAlerts();
                  Navigator.pop(context);
                },
                trailing: _currentFilter == 'RESOLVED' ? const Icon(Icons.check, color: Color(0xFF800B39)) : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sort by Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("Newest First"),
                onTap: () {
                  setState(() {
                    _currentSort = 'newest';
                    _alerts.sort((a, b) {
                      final dateA = a['created_at'] != null ? DateTime.parse(a['created_at']) : DateTime(2000);
                      final dateB = b['created_at'] != null ? DateTime.parse(b['created_at']) : DateTime(2000);
                      return dateB.compareTo(dateA);
                    });
                  });
                  Navigator.pop(context);
                },
                trailing: _currentSort == 'newest' ? const Icon(Icons.check, color: Color(0xFF800B39)) : null,
              ),
              ListTile(
                title: const Text("Oldest First"),
                onTap: () {
                  setState(() {
                    _currentSort = 'oldest';
                    _alerts.sort((a, b) {
                      final dateA = a['created_at'] != null ? DateTime.parse(a['created_at']) : DateTime(2000);
                      final dateB = b['created_at'] != null ? DateTime.parse(b['created_at']) : DateTime(2000);
                      return dateA.compareTo(dateB);
                    });
                  });
                  Navigator.pop(context);
                },
                trailing: _currentSort == 'oldest' ? const Icon(Icons.check, color: Color(0xFF800B39)) : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton(String text, {VoidCallback? onFilterTap}) {
    return GestureDetector(
      onTap: onFilterTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE6ED),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8A606A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String alertId,
    required String clientId,
    required String status,
    required String location,
    required String time,
    required double lat,
    required double lng,
  }) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color darkText = Color(0xFF2B0A16);
    const Color greyText = Color(0xFF8A606A);

    Color statusColor = const Color(0xFFFFF3E0); // Light Orange
    Color statusTextColor = const Color(0xFFFF9800); // Orange

    String statusKey = status.toLowerCase();

    if (statusKey == "in_progress") {
      statusColor = const Color(0xFFFFEBEE); // Light Red/Pink
      statusTextColor = const Color(0xFFD32F2F); // Red
    } else if (statusKey == "resolved" || statusKey == "closed") {
      statusColor = const Color(0xFFE8F5E9); // Light Green
      statusTextColor = const Color(0xFF388E3C); // Green
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.laurietamminen_frontend',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: primaryDarkRed,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        clientId,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: greyText.withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: greyText.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: greyText.withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      time,
                      style: TextStyle(
                        color: greyText.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ClientsDetailsScreen(alertId: alertId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == "PENDING"
                          ? primaryDarkRed
                          : const Color(0xFFFDE6ED),
                      foregroundColor: status == "PENDING"
                          ? Colors.white
                          : primaryDarkRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
