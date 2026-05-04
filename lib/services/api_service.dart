import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Removed /v1 as per backend routes

  // Save tokens
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Get tokens
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
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
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'client_id': uniqueClientId,
      }),
    );
    return jsonDecode(response.body);
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      await saveTokens(data['data']['access_token'], data['data']['refresh_token']);
    }
    return data;
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
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
        'email': email,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );
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
  static Future<Map<String, dynamic>> confirmSteps(int steps) async {
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
}
