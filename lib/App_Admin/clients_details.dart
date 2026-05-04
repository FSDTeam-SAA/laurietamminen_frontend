import 'package:flutter/material.dart';

class ClientsDetailsScreen extends StatelessWidget {
  const ClientsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color bgColor = Color(0xFFFDF5F7);
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
                padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: darkText, size: 28),
                          onPressed: () => Navigator.pop(context),
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: softPink,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, color: darkText, size: 24),
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
                        Image.network(
                          "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-77.036,38.897,14,0/600x600?access_token=pk.eyJ1IjoiZGVtbyIsImEiOiJjaXpvaHExZ20wMDBqMzJvM2ZqM2ZqM2ZqIn0",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                        ),
                        // User Location Box
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _buildOverlayBox(
                            title: "USER LOCATION",
                            content: "37.7749° N,\n122.4194° W",
                            icon: Icons.my_location,
                          ),
                        ),
                        // Accuracy Box
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _buildOverlayBox(
                            title: "ACCURACY",
                            content: "± 4.2 Meters",
                            isCenter: true,
                          ),
                        ),
                        // Marker
                        const Center(
                          child: Icon(Icons.location_on, color: primaryDarkRed, size: 48),
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
                      const Text(
                        "Client-20260418-01",
                        style: TextStyle(
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
                            const Text(
                              "Active for 4m 12s",
                              style: TextStyle(color: primaryDarkRed, fontSize: 13, fontWeight: FontWeight.w900),
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
                          const Text(
                            "9528 25 Hwy",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
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
                    _buildStatusButton("Mark In Progress"),
                    const SizedBox(height: 16),
                    _buildStatusButton("Resolve"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Stats
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard("LAST SYNC", "2s ago")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("DEVICE ID", "DW-0992")),
                  ],
                ),
              ),
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

  Widget _buildActionButton({required String label, required IconData icon, required Color bgColor, required Color textColor}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: bgColor == Colors.white ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label) {
    return Container(
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
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
