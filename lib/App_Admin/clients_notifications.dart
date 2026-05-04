import 'package:flutter/material.dart';
import 'clients_details.dart';

class ClientsNotificationScreen extends StatelessWidget {
  const ClientsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color bgColor = Color(0xFFFDF5F7);
    const Color darkText = Color(0xFF2B0A16);
    const Color greyText = Color(0xFF8A606A);

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
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryDarkRed,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      _buildHeaderButton("Filter"),
                      const SizedBox(width: 10),
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
                    statusColor: const Color(0xFFFDF5E1),
                    statusTextColor: const Color(0xFFD4A017),
                    location: "Prospect Park, Brooklyn",
                    time: "14:02 Today",
                    mapUrl: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-73.969,40.660,14,0/600x300?access_token=pk.eyJ1IjoiZGVtbyIsImEiOiJjaXpvaHExZ20wMDBqMzJvM2ZqM2ZqM2ZqIn0",
                    isDetailsActive: true,
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 40),
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
          // Map Image - Fixed with proper aspect ratio and fit
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                mapUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text("Map Preview", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  );
                },
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
                    Text(
                      clientId,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    Icon(Icons.location_on_outlined, size: 20, color: greyText.withOpacity(0.8)),
                    const SizedBox(width: 10),
                    Text(
                      location,
                      style: TextStyle(color: greyText.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: greyText.withOpacity(0.8)),
                    const SizedBox(width: 10),
                    Text(
                      time,
                      style: TextStyle(color: greyText.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 54,
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
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: Text(
                      isClosed ? "Closed" : "View Details",
                      style: const TextStyle(
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
