import 'package:flutter/material.dart';

class ClientsDetailsScreen extends StatelessWidget {
  const ClientsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color bgColor = Color(0xFFFFF0F5);
    const Color cardColor = Colors.white;
    const Color softPink = Color(0xFFFDE6ED);
    const Color darkText = Color(0xFF2B0A16);
    const Color greyText = Color(0xFF8A606A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: darkText),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Client Detail",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryDarkRed,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: softPink,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, color: darkText),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              // Map Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: NetworkImage("https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-77.036,38.897,14,0/600x600?access_token=pk.eyJ1IjoiZGVtbyIsImEiOiJjaXpvaHExZ20wMDBqMzJvM2ZqM2ZqM2ZqIn0"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // User Location Box
                      Positioned(
                        top: 16,
                        left: 16,
                        child: _buildOverlayBox(
                          title: "USER LOCATION",
                          content: "37.7749° N,\n122.4194° W",
                          icon: Icons.my_location,
                        ),
                      ),
                      // Accuracy Box
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildOverlayBox(
                          title: "ACCURACY",
                          content: "± 4.2 Meters",
                          isCenter: true,
                        ),
                      ),
                      // Marker
                      const Center(
                        child: Icon(Icons.location_on, color: primaryDarkRed, size: 40),
                      ),
                    ],
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        label: "Message",
                        icon: Icons.chat_bubble_outline,
                        bgColor: softPink,
                        textColor: primaryDarkRed,
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CLIENT ID",
                        style: TextStyle(color: greyText, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Client-20260418-01",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryDarkRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: softPink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: primaryDarkRed, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Active for 4m 12s",
                              style: TextStyle(color: primaryDarkRed, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Street address",
                        style: TextStyle(color: greyText, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "9528 25 Hwy",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                          ),
                          const Icon(Icons.location_on, color: darkText),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Operational Status
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "OPERATIONAL STATUS",
                  style: TextStyle(color: greyText, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildStatusButton("Mark In Progress"),
                    const SizedBox(height: 12),
                    _buildStatusButton("Resolve"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard("LAST SYNC", "2s ago")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("DEVICE ID", "DW-0992")),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayBox({required String title, required String content, IconData? icon, bool isCenter = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE6ED).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF800B39), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2B0A16))),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF800B39))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color bgColor, required Color textColor}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFDE6ED),
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF800B39), fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF800B39), fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B0A16))),
        ],
      ),
    );
  }
}
