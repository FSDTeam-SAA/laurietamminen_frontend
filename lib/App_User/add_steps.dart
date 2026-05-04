import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddStepsPage extends StatefulWidget {
  const AddStepsPage({super.key});

  @override
  State<AddStepsPage> createState() => _AddStepsPageState();
}

class _AddStepsPageState extends State<AddStepsPage> {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color bgColor = const Color(0xFFFEEAEF);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);
  
  final TextEditingController _stepsController = TextEditingController();
  bool isWalking = true;
  bool _isLoading = true;
  bool _isSaving = false;
  int todaySteps = 0;
  int stepGoal = 0;
  String? lastEntryTime;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchProfile(),
      _fetchTodaySteps(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await ApiService.getProfile();
      if (mounted && result['success'] == true) {
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
      if (mounted && result['success'] == true) {
        setState(() {
          todaySteps = result['data']?['steps'] ?? 0;
          // Optionally set lastEntryTime if available in backend
          // lastEntryTime = result['data']['last_entry']; 
        });
      }
    } catch (e) {
      debugPrint("Error fetching steps: $e");
    }
  }

  Future<void> _confirmSteps() async {
    if (_stepsController.text.isEmpty) return;
    
    final inputSteps = int.tryParse(_stepsController.text);
    if (inputSteps == null || inputSteps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of steps')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Logic: Add new steps to existing today's steps
      final newTotal = todaySteps + inputSteps;
      final result = await ApiService.confirmSteps(newTotal);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Steps added successfully!')),
          );
          _stepsController.clear();
          _fetchInitialData(); // Refresh data to show new total
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to add steps')),
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

    return Scaffold(
      backgroundColor: Colors.transparent, // Parent provides background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchInitialData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: darkText, size: 28),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Add Activity",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for balance
                  ],
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
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$todaySteps",
                            style: TextStyle(
                              fontSize: 64,
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
                    Text(
                      "STEPS",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryDarkRed,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Activity Category Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFC).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF0D5DD), width: 1.5),
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
                                  color: isWalking ? const Color(0xFF2B0A16) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isWalking ? Colors.transparent : const Color(0xFF2B0A16),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      color: isWalking ? Colors.white : darkText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Walking",
                                      style: TextStyle(
                                        color: isWalking ? Colors.white : darkText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
                                  color: !isWalking ? const Color(0xFF2B0A16) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: !isWalking ? Colors.transparent : const Color(0xFF2B0A16),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_run,
                                      color: !isWalking ? Colors.white : darkText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Running",
                                      style: TextStyle(
                                        color: !isWalking ? Colors.white : darkText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
                
                // Input Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFC).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF0D5DD), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Track Steps Toward Your Goals",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _stepsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter steps...",
                          hintStyle: TextStyle(color: greyText.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                            elevation: 0,
                          ),
                          child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFC).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFF0D5DD), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF0D5DD)),
                        ),
                        child: Icon(Icons.access_time, color: darkText),
                      ),
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
                            lastEntryTime ?? "Not added today",
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
