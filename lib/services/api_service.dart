import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://187.77.187.56:8018/api';

  // Check Server Health
  static Future<void> checkServerHealth() async {
    final url = Uri.parse('$baseUrl/health');
    debugPrint("Checking health at: $url");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      debugPrint("Health status: ${response.statusCode}");
      debugPrint("Health body: ${response.body}");
    } catch (e) {
      debugPrint("Health check failed: $e");
    }
  }

  // Test Connectivity
  static Future<void> testConnectivity() async {
    final url = Uri.parse('https://httpbin.org/post');
    debugPrint("Testing connectivity at: $url");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'test': 'data'}),
      ).timeout(const Duration(seconds: 10));
      debugPrint("Test status: ${response.statusCode}");
      debugPrint("Test body: ${response.body}");
    } catch (e) {
      debugPrint("Test connectivity failed: $e");
    }
  }

  // Save tokens
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Save user role
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  // Get tokens
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Clear session (Logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Generate a unique ID to satisfy the backend's unique client_id index
    final String uniqueClientId = "ID_${DateTime.now().millisecondsSinceEpoch}";

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email.trim(),
        'password': password,
        'confirm_password': confirmPassword,
        'client_id': uniqueClientId,
      }),
    ).timeout(const Duration(seconds: 60));
    return jsonDecode(response.body);
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    debugPrint("Hitting URL: $url");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Flutter/laurietamminen_frontend',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    ).timeout(const Duration(seconds: 60));
    
    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");
    
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      await saveTokens(data['data']['access_token'], data['data']['refresh_token']);
      await saveUserRole(data['data']['user']['role']);
    }
    return data;
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');
    debugPrint("Hitting URL: $url");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Connection': 'keep-alive',
        },
        body: jsonEncode({'email': email.trim()}),
      ).timeout(const Duration(seconds: 60));
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e, stack) {
      debugPrint("Error in forgotPassword: $e");
      debugPrint("Stack trace: $stack");
      rethrow;
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'otp': otp.trim()}),
    ).timeout(const Duration(seconds: 60));
    return jsonDecode(response.body);
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    ).timeout(const Duration(seconds: 60));
    return jsonDecode(response.body);
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    }
    return jsonDecode(response.body);
  }

  // Get Profile
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Update Profile with Image
  static Future<Map<String, dynamic>> updateProfileWithImage({
    String? fullName,
    String? email,
    String? dob,
    double? height,
    double? weight,
    String? imagePath,
  }) async {
    final token = await getAccessToken();
    var request = http.MultipartRequest('PATCH', Uri.parse('$baseUrl/users/profile'));
    
    request.headers['Authorization'] = 'Bearer $token';

    if (fullName != null) request.fields['full_name'] = fullName;
    if (email != null) request.fields['email'] = email;
    if (dob != null) request.fields['date_of_birth'] = dob;
    if (height != null) request.fields['height'] = height.toString();
    if (weight != null) request.fields['weight'] = weight.toString();

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        imagePath,
        contentType: MediaType('image', imagePath.split('.').last),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  // Update Step Goal
  static Future<Map<String, dynamic>> updateStepGoal(int stepGoal) async {
    final token = await getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/users/step-goal'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'step_goal': stepGoal}),
    );
    return jsonDecode(response.body);
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final token = await getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/users/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  // Confirm Steps
  static Future<Map<String, dynamic>> confirmSteps(dynamic steps) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/steps/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'steps': steps}),
    );
    return jsonDecode(response.body);
  }

  // Get Today's Steps
  static Future<Map<String, dynamic>> getTodaySteps() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/steps/today'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Get Weekly Steps
  static Future<Map<String, dynamic>> getWeeklySteps() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/steps/weekly'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Get Admin Alerts (For Notifications Screen)
  static Future<Map<String, dynamic>> getAdminAlerts({
    String filter = 'all',
    int page = 1,
    int limit = 10,
  }) async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/alerts?filter=${filter.toLowerCase()}&page=$page&limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Update Alert Status
  static Future<Map<String, dynamic>> updateAlertStatus(String alertId, String status) async {
    final token = await getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/alerts/$alertId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status.toLowerCase()}),
    );
    return jsonDecode(response.body);
  }

  // Get Single Alert Detail (For Admin Detail Screen)
  static Future<Map<String, dynamic>> getAlertDetail(String alertId) async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/alerts/$alertId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Trigger Alert
  static Future<Map<String, dynamic>> triggerAlert({
    required String triggerToken,
    required String dateOfBirth,
    double lat = 23.8103,
    double lng = 90.4125,
    int accuracy = 12,
    String streetAddress = "123 Demo Street, Dhaka",
    String signalStrength = "strong",
    String connectionState = "4g",
    String deviceId = "device-001",
  }) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/alerts/trigger'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'trigger_token': triggerToken,
        'date_of_birth': dateOfBirth,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'street_address': streetAddress,
        'signal_strength': signalStrength,
        'connection_state': connectionState,
        'device_id': deviceId,
      }),
    );
    return jsonDecode(response.body);
  }

  // Update Alert Location
  static Future<Map<String, dynamic>> updateAlertLocation({
    required String alertId,
    double lat = 23.8111,
    double lng = 90.4131,
    int accuracy = 8,
    String streetAddress = "Updated Demo Street, Dhaka",
    String signalStrength = "medium",
    String connectionState = "wifi",
    String deviceId = "device-001",
  }) async {
    final token = await getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/alerts/$alertId/location-update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'street_address': streetAddress,
        'signal_strength': signalStrength,
        'connection_state': connectionState,
        'device_id': deviceId,
      }),
    );
    return jsonDecode(response.body);
  }

  // Get Activities
  static Future<Map<String, dynamic>> getActivities() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/activities'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Create Activity
  static Future<Map<String, dynamic>> createActivity({
    required String category,
    required double steps,
    String? notes,
    String? entryTime,
  }) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/activities'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category': category,
        'steps': steps,
        'notes': notes ?? '',
        'entry_time': entryTime ?? DateTime.now().toUtc().toIso8601String(),
      }),
    );
    return jsonDecode(response.body);
  }
}
