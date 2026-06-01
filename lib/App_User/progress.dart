import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../welcome_onbording.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color bgColor = const Color(0xFFFEEAEF);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);

  final TextEditingController _stepsController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  int todaySteps = 0;
  int stepGoal = 0;
  List<double> weeklySteps = [0, 0, 0, 0, 0, 0, 0];
  List<String> dayLabels = ["", "", "", "", "", "", ""];
  double maxWeeklySteps = 10000;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

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

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchProfile(),
        _fetchTodaySteps(),
        _fetchWeeklySteps(),
      ]);
    } catch (e) {
      debugPrint("Error in _fetchInitialData: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await ApiService.getProfile();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          stepGoal = result['data']['step_goal'] ?? 0;
        });
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<void> _fetchTodaySteps() async {
    try {
      final result = await ApiService.getTodaySteps();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          todaySteps = result['data']?['steps'] ?? 0;
        });
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      }
    } catch (e) {
      debugPrint("Error fetching today steps: $e");
    }
  }

  Future<void> _fetchWeeklySteps() async {
    try {
      final result = await ApiService.getWeeklySteps();
      if (!mounted) return;
      if (result['success'] == true) {
        final List<dynamic> data = result['data']?['weekly_activity'] ?? [];
        List<double> steps = [0, 0, 0, 0, 0, 0, 0];
        List<String> labels = ["", "", "", "", "", "", ""];
        double currentMax = 5000;

        for (int i = 0; i < data.length && i < 7; i++) {
          steps[i] = (data[i]['steps'] ?? 0).toDouble();
          if (steps[i] > currentMax) currentMax = steps[i];
          
          if (data[i]['date'] != null) {
            final date = DateTime.parse(data[i]['date']);
            labels[i] = _getDayName(date.weekday);
          }
        }

        setState(() {
          weeklySteps = steps;
          dayLabels = labels;
          maxWeeklySteps = currentMax * 1.2;
        });
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      }
    } catch (e) {
      debugPrint("Error fetching weekly steps: $e");
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Mon";
      case 2: return "Tue";
      case 3: return "Wed";
      case 4: return "Thu";
      case 5: return "Fri";
      case 6: return "Sat";
      case 7: return "Sun";
      default: return "";
    }
  }

  Future<void> _updateGoal() async {
    if (_stepsController.text.isEmpty) return;
    
    final inputGoal = int.tryParse(_stepsController.text);
    if (inputGoal == null || inputGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid step goal')),
      );
      return;
    }

    final newGoal = stepGoal + inputGoal;

    setState(() => _isSaving = true);
    try {
      final result = await ApiService.updateStepGoal(newGoal);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Step goal updated successfully!')),
          );
          _stepsController.clear();
          _fetchInitialData(); // Refresh data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to update goal')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchInitialData,
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
                    "Add Step Goals",
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
            const SizedBox(height: 30),
            
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
                    "PLEASE SET YOUR DAILY STEP GOAL",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _stepsController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Enter goal (e.g. 10000)",
                      hintStyle: TextStyle(color: greyText.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    "setting a goal helps you stay motivated!",
                    style: TextStyle(fontSize: 12, color: greyText),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDarkRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Set Goal",
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFC).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF0D5DD), width: 1.5),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/bottom_nev_image/step.png',
                        height: 100,
                        color: primaryDarkRed,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          "TOTAL STEPS TODAY",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${stepGoal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: primaryDarkRed,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "/$todaySteps",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: primaryDarkRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0D5DD).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: primaryDarkRed, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                todaySteps >= stepGoal ? "Goal Reached" : "In Progress",
                                style: TextStyle(
                                  color: primaryDarkRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
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
                    maxY: maxWeeklySteps,
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                            int index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return SideTitleWidget(
                                meta: meta,
                                space: 10,
                                child: Text(
                                  dayLabels[index],
                                  style: TextStyle(
                                    color: greyText,
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
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(7, (i) => FlSpot(i.toDouble(), weeklySteps[i])),
                        isCurved: true,
                        curveSmoothness: 0.5,
                        color: primaryDarkRed,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: primaryDarkRed,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
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
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
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
                              '${touchedSpot.y.toInt()} Steps',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
}
