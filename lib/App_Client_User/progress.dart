import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../welcome_onbording.dart';

class ClientProgressPage extends StatefulWidget {
  const ClientProgressPage({super.key});

  @override
  State<ClientProgressPage> createState() => _ClientProgressPageState();
}

class _ClientProgressPageState extends State<ClientProgressPage> {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color bgColor = const Color(0xFFFEEAEF);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);

  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isSubmitting = false;
  String? _triggerToken;

  void _handleSessionExpired() {
    if (!mounted) return;
    ApiService.clearSession();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeOnboarding()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session expired. Please login again.")),
    );
  }

  Future<void> _handleConfirm() async {
    final stepsInput = _stepsController.text.trim();
    if (stepsInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter steps")));
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);
    try {
      final result = await ApiService.confirmSteps(stepsInput);

      if (!mounted) return;
      if (result['trigger'] == true) {
        _triggerToken = result['trigger_token'];
        _showDOBDialog(context);
      } else if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Steps confirmed successfully")),
        );
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Error confirming steps")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDOBConfirm() async {
    final dob = _dobController.text.trim();
    if (dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter date of birth")),
      );
      return;
    }

    if (_triggerToken == null) return;

    Navigator.pop(context); // Close dialog
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.triggerAlert(
        triggerToken: _triggerToken!,
        dateOfBirth: dob,
        lat: 23.8103,
        lng: 90.4125,
        accuracy: 12,
        streetAddress: "123 Demo Street, Dhaka",
        signalStrength: "strong",
        connectionState: "4g",
        deviceId: "device-001",
      );

      if (!mounted) return;
      if (result['success'] == true || result['data'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for conforming your Birth of Date")),
        );
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Birth of Date Dosent Match")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onRefresh() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: primaryDarkRed,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  Text(
                    "Add your Today Goal",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                   "Please add your step goal for today and \n click set goal to confirm",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: greyText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Input Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFC).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF0D5DD), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PLEASE ENTER YOUR STEPS FOR TODAY",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _stepsController,
                    decoration: InputDecoration(
                      hintText: "Enter steps...",
                      hintStyle: TextStyle(color: greyText.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: Color(0xFFF0D5DD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: primaryDarkRed),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "if you missed a day, you may add them to today's total",
                    style: TextStyle(fontSize: 12, color: greyText),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDarkRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Confirm",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status Card
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFFFFBFC).withOpacity(0.5),
            //     borderRadius: BorderRadius.circular(24),
            //     border: Border.all(color: const Color(0xFFF0D5DD), width: 1.5),
            //   ),
            //   child: Stack(
            //     children: [
            //       Positioned(
            //         right: 20,
            //         top: 20,
            //         child: Opacity(
            //           opacity: 0.1,
            //           child: Image.asset(
            //             'assets/images/bottom_nev_image/step.png',
            //             height: 80,
            //             color: primaryDarkRed,
            //           ),
            //         ),
            //       ),
            //       Container(
            //         width: double.infinity,
            //         padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            //         child: Column(
            //           children: [
            //             Text(
            //               "TOTAL STEPS TODAY",
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w600,
            //                 color: darkText,
            //                 letterSpacing: 0.8,
            //               ),
            //             ),
            //             const SizedBox(height: 8),
            //             RichText(
            //               text: TextSpan(
            //                 children: [
            //                   TextSpan(
            //                     text: "100",
            //                     style: TextStyle(
            //                       fontSize: 68,
            //                       fontWeight: FontWeight.bold,
            //                       color: primaryDarkRed,
            //                     ),
            //                   ),
            //                   TextSpan(
            //                     text: "/10,000",
            //                     style: TextStyle(
            //                       fontSize: 36,
            //                       fontWeight: FontWeight.bold,
            //                       color: primaryDarkRed,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             const SizedBox(height: 20),
            //             Container(
            //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //               decoration: BoxDecoration(
            //                 color: const Color(0xFFF0D5DD).withOpacity(0.5),
            //                 borderRadius: BorderRadius.circular(24),
            //               ),
            //               child: Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   Icon(Icons.check_circle_rounded, color: primaryDarkRed, size: 18),
            //                   const SizedBox(width: 8),
            //                   Text(
            //                     "High Intensity",
            //                     style: TextStyle(
            //                       color: primaryDarkRed,
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 16,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 70),

            // Weekly Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Weekly Activity",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                Text(
                  "Last 7 Days",
                  style: TextStyle(color: greyText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 10),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 4,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              'MON',
                              'TUE',
                              'WED',
                              'THU',
                              'FRI',
                              'SAT',
                              'SUN',
                            ];
                            int index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return SideTitleWidget(
                                meta: meta,
                                space: 10,
                                child: Text(
                                  days[index],
                                  style: TextStyle(
                                    color: index == 4
                                        ? primaryDarkRed
                                        : greyText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 0.8),
                          FlSpot(1, 1.4),
                          FlSpot(2, 1.1),
                          FlSpot(3, 1.6),
                          FlSpot(4, 3.2),
                          FlSpot(5, 2.0),
                          FlSpot(6, 2.1),
                        ],
                        isCurved: true,
                        curveSmoothness: 0.5,
                        color: primaryDarkRed,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            if (index == 4) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: primaryDarkRed,
                                strokeWidth: 3,
                                strokeColor: Colors.white,
                              );
                            }
                            return FlDotCirclePainter(radius: 0);
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              primaryDarkRed.withOpacity(0.2),
                              primaryDarkRed.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      getTouchedSpotIndicator:
                          (LineChartBarData barData, List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                FlLine(color: primaryDarkRed, strokeWidth: 2),
                                FlDotData(show: false),
                              );
                            }).toList();
                          },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => primaryDarkRed,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((touchedSpot) {
                            return LineTooltipItem(
                              '505 Steps',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryDarkRed,
              onPrimary: Colors.white,
              onSurface: darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showDOBDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x337F0B34),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "PLEASE CONFIRM DATE OF BIRTH",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              _dobController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Select Date of Birth",
                          hintStyle: TextStyle(
                            color: greyText.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: primaryDarkRed,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(
                              color: Color(0xFFF0D5DD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(color: primaryDarkRed),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleDOBConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryDarkRed, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: primaryDarkRed,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
