import 'package:flutter/material.dart';
import 'clients_details.dart';

class ClientsNotificationScreen extends StatelessWidget {
  const ClientsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color bgColor = Color(0xFFFFF0F5);
    const Color cardColor = Colors.white;
    const Color buttonBg = Color(0xFFFDE6ED);
    const Color darkText = Color(0xFF2B0A16);
    const Color greyText = Color(0xFF8A606A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar replacement
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Clients Notification",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryDarkRed,
                    ),
                  ),
                  Row(
                    children: [
                      _buildHeaderButton("Filter"),
                      const SizedBox(width: 8),
                      _buildHeaderButton("Sort"),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  _buildNotificationCard(
                    context,
                    clientId: "Client-29402",
                    status: "PENDING",
                    statusColor: const Color(0xFFFFF4D6),
                    statusTextColor: const Color(0xFFB8860B),
                    location: "Prospect Park, Brooklyn",
                    time: "14:02 Today",
                    mapUrl: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-73.969,40.660,14,0/600x300?access_token=pk.eyJ1IjoiZGVtbyIsImEiOiJjaXpvaHExZ20wMDBqMzJvM2ZqM2ZqM2ZqIn0",
                    isDetailsActive: true,
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationCard(
                    context,
                    clientId: "Client-11804",
                    status: "IN PROGRESS",
                    statusColor: const Color(0xFFE3F2FD),
                    statusTextColor: const Color(0xFF1E88E5),
                    location: "Prospect Park, Brooklyn",
                    time: "14:02 Today",
                    mapUrl: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-73.971,40.665,14,0/600x300?access_token=pk.eyJ1IjoiZGVtbyIsImEiOiJjaXpvaHExZ20wMDBqMzJvM2ZqM2ZqM2ZqIn0",
                    isDetailsActive: false,
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationCard(
                    context,
                    clientId: "Client-09433",
                    status: "CLOSED",
                    statusColor: const Color(0xFFE8F5E9),
                    statusTextColor: const Color(0xFF43A047),
                    location: "Prospect Park, Brooklyn",
                    time: "14:02 Today",
                    mapUrl: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-73.975,40.670,14,0/600x300?access_token=pk.eyJ1IjoiZGVtbyIsImEiOiJjaXpvaHExZ20wMDBqMzJvM2ZqM2ZqM2ZqIn0",
                    isDetailsActive: false,
                    isClosed: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE6ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8A606A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String clientId,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required String location,
    required String time,
    required String mapUrl,
    bool isDetailsActive = false,
    bool isClosed = false,
  }) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color darkText = Color(0xFF2B0A16);
    const Color greyText = Color(0xFF8A606A);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              mapUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.map, size: 50, color: Colors.grey),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      clientId,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: greyText),
                    const SizedBox(width: 8),
                    Text(
                      location,
                      style: const TextStyle(color: greyText, fontSize: 14),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: greyText),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(color: greyText, fontSize: 14),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isClosed ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ClientsDetailsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDetailsActive ? primaryDarkRed : const Color(0xFFFDE6ED),
                      foregroundColor: isDetailsActive ? Colors.white : primaryDarkRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      isClosed ? "Closed" : "View Details",
                      style: const TextStyle(
                        fontSize: 16,
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
