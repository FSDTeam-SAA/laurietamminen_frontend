import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import '../welcome_onbording.dart';

class ClientAddStepsPage extends StatefulWidget {
  const ClientAddStepsPage({super.key});

  @override
  State<ClientAddStepsPage> createState() => _ClientAddStepsPageState();
}

class _ClientAddStepsPageState extends State<ClientAddStepsPage> {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color bgColor = const Color(0xFFFEEAEF);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);

  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool isWalking = true;
  bool _isLoading = true;
  bool _isSaving = false;
  int todaySteps = 0;
  int stepGoal = 0;
  String? lastEntryTime;
  String? _triggerToken;

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
        _fetchLatestActivity(),
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
      }
    } catch (e) {
      debugPrint("Error fetching steps: $e");
    }
  }

  Future<void> _fetchLatestActivity() async {
    try {
      final result = await ApiService.getActivities();
      if (!mounted) return;
      if (result['success'] == true) {
        final List activities = result['data'] ?? [];
        if (activities.isNotEmpty) {
          final latest = activities.first;
          final DateTime entryTime = DateTime.parse(
            latest['entry_time'],
          ).toLocal();
          setState(() {
            lastEntryTime = DateFormat('MMM d, h:mm a').format(entryTime);
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching activities: $e");
    }
  }

  // NOW: This performs the Secret Trigger logic (formerly in progress.dart)
  Future<void> _confirmSteps() async {
    final String input = _stepsController.text.trim();
    if (input.isEmpty) return;
    
    final inputSteps = double.tryParse(input);
    if (inputSteps != null && inputSteps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of steps')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);
    try {
      Map<String, dynamic> result;

      if (inputSteps == null) {
        // Assume it might be a secret trigger
        result = await ApiService.confirmSteps(input);
      } else {
        // Normal numeric input: create an activity
        final newTotal = todaySteps + inputSteps;
        result = await ApiService.createActivity(
          category: isWalking ? "walking" : "running",
          steps: newTotal,
        );
      }
      
      if (!mounted) return;
      if (result['trigger'] == true) {
        _triggerToken = result['trigger_token'];
        _showDOBDialog(context);
        _stepsController.clear();
        _fetchInitialData(); // Refresh data
      } else if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Steps added successfully!')),
        );
        _stepsController.clear();
        _fetchInitialData(); // Refresh data
      } else if (result['error_type'] == 'session_expired') {
        _handleSessionExpired();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to add steps')),
        );
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
    setState(() => _isSaving = true);

    try {
      // Step 1: Get actual GPS location first (separate from API call)
      final locData = await ApiService.getCurrentLocationData();

      if (!mounted) return;

      // Step 2: Trigger alert with actual coordinates
      final result = await ApiService.triggerAlert(
        triggerToken: _triggerToken!,
        dateOfBirth: dob,
        lat: locData['lat'],
        lng: locData['lng'],
        accuracy: locData['accuracy'],
        streetAddress: locData['streetAddress'],
      );

      if (!mounted) return;
      if (result['success'] == true || result['data'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thank you for confirming your Date of Birth"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Date of Birth Doesn't Match"),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkRed,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Add Activity",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Top Stats
                Column(
                  children: [
                    Text(
                      "TOTAL DAILY STEPS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: greyText.withOpacity(0.7),
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
                                text: todaySteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: primaryDarkRed,
                                ),
                              ),
                              TextSpan(
                                text: "/${stepGoal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: primaryDarkRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Activity Category Card (UI ONLY NOW)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFC).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF0D5DD),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ACTIVITY CATEGORY",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isWalking = true),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isWalking
                                      ? const Color(0xFF2B0A16)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF2B0A16),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      color: isWalking
                                          ? Colors.white
                                          : darkText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Walking",
                                      style: TextStyle(
                                        color: isWalking
                                            ? Colors.white
                                            : darkText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isWalking = false),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: !isWalking
                                      ? const Color(0xFF2B0A16)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF2B0A16),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_run,
                                      color: !isWalking
                                          ? Colors.white
                                          : darkText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Running",
                                      style: TextStyle(
                                        color: !isWalking
                                            ? Colors.white
                                            : darkText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Input Card (Logic swapped to Secret Trigger)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFC).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF0D5DD),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add your Daily Steps",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _stepsController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Enter steps...",
                          filled: true,
                          fillColor: Colors.white,
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
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _confirmSteps,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Confirm",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Last Entry Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFC).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFF0D5DD),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: darkText),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LAST ENTRY TIME",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: greyText.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastEntryTime ?? "No entries yet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDOBDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(
        0xFF800B39,
      ).withOpacity(0.4), // Premium dark red blur
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
                          if (picked != null)
                            setDialogState(
                              () => _dobController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",
                            );
                        },
                        decoration: InputDecoration(
                          hintText: "Select Date of Birth",
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: primaryDarkRed,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(
                              color: Color(0xFFF0D5DD),
                            ),
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
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: greyText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
