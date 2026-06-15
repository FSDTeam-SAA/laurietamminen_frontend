import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class ApiService {
  // Live server URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://2.24.103.56:5000/api',
  );

  // Local server URL (Android Emulator)
  // static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Local server URL (Physical Device)
  // static const String baseUrl = 'http://10.10.26.118:5000/api';

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
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'test': 'data'}),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint("Test status: ${response.statusCode}");
      debugPrint("Test body: ${response.body}");
    } catch (e) {
      debugPrint("Test connectivity failed: $e");
    }
  }

  // Save tokens
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
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

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  // Refresh Access Token
  static Future<bool> refreshAccessToken() async {
    if (_isRefreshing) {
      debugPrint("Token refresh already in progress, waiting...");
      return _refreshCompleter?.future ?? Future.value(false);
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      _isRefreshing = false;
      _refreshCompleter!.complete(false);
      return false;
    }

    try {
      debugPrint("Refreshing access token...");
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final String newAccess = data['data']['access_token'].toString();
          final String newRefresh = data['data']['refresh_token'].toString();

          if (newAccess != "null" && newAccess.isNotEmpty) {
            await saveTokens(newAccess, newRefresh);
            debugPrint("Token refreshed successfully.");
            _refreshCompleter!.complete(true);
            return true;
          }
        }
      }
      debugPrint("Token refresh failed with status: ${response.statusCode}");
    } catch (e) {
      debugPrint("Token refresh failed with error: $e");
    }

    _refreshCompleter!.complete(false);
    _isRefreshing = false;
    _refreshCompleter = null;
    return false;
  }

  // Generic Authenticated Request with Auto-Refresh
  static Future<Map<String, dynamic>> _authenticatedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    String? token = await getAccessToken();

    // Check if token is invalid or the string "null"
    if (token == null ||
        token.isEmpty ||
        token == "null" ||
        token.length < 10) {
      debugPrint(
        "Invalid token detected for $path: $token. Triggering expiry.",
      );
      return {
        'success': false,
        'message': 'Invalid session.',
        'error_type': 'session_expired',
      };
    }

    Future<http.Response> makeRequest(String? currentToken) async {
      final url = Uri.parse('$baseUrl$path');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentToken',
      };

      final duration = const Duration(seconds: 30);

      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(url, headers: headers).timeout(duration);
        case 'POST':
          return await http
              .post(
                url,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(duration);
        case 'PATCH':
          return await http
              .patch(
                url,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(duration);
        case 'DELETE':
          return await http.delete(url, headers: headers).timeout(duration);
        default:
          throw Exception("Unsupported HTTP method: $method");
      }
    }

    try {
      var response = await makeRequest(token);

      // Handle common token errors (401 Unauthorized or 400 with "jwt malformed")
      bool isTokenError = response.statusCode == 401;

      // Some backends return 400 for malformed JWTs
      if (response.statusCode == 400) {
        final bodyStr = response.body.toLowerCase();
        if (bodyStr.contains("jwt") ||
            bodyStr.contains("token") ||
            bodyStr.contains("malformed")) {
          isTokenError = true;
        }
      }

      if (isTokenError) {
        debugPrint(
          "Token error (${response.statusCode}) for $path, attempting refresh...",
        );
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          token = await getAccessToken();
          response = await makeRequest(token);
        } else {
          debugPrint("Refresh failed for $path, clearing session.");
          await clearSession();
          return {
            'success': false,
            'message': 'Session expired. Please login again.',
            'error_type': 'session_expired',
          };
        }
      }

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Authenticated request error for $path: $e");
      return {
        'success': false,
        'message': 'Network error or server unreachable',
        'error': e.toString(),
      };
    }
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
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Generate a unique ID to satisfy the backend's unique client_id index
    final String uniqueClientId = "ID_${DateTime.now().millisecondsSinceEpoch}";
    final String hiddenPhoneNumber =
        "01${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}";

    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'full_name': fullName,
            'phone_number': hiddenPhoneNumber,
            'email': email.trim(),
            'password': password,
            'confirm_password': confirmPassword,
            'client_id': uniqueClientId,
          }),
        )
        .timeout(const Duration(seconds: 60));
    return jsonDecode(response.body);
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');
    debugPrint("Hitting URL: $url");
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'Flutter/solidsteps_frontend',
          },
          body: jsonEncode({'email': email.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 60));

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final String access = data['data']['access_token'].toString();
      final String refresh = data['data']['refresh_token'].toString();

      debugPrint("Saving tokens. Access length: ${access.length}");
      await saveTokens(access, refresh);
      await saveUserRole(data['data']['user']['role'].toString());
    }
    return data;
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');
    debugPrint("Hitting URL: $url");
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Connection': 'keep-alive',
            },
            body: jsonEncode({'email': email.trim()}),
          )
          .timeout(const Duration(seconds: 60));
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
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email.trim(), 'otp': otp.trim()}),
        )
        .timeout(const Duration(seconds: 60));
    return jsonDecode(response.body);
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.trim(),
            'new_password': newPassword,
            'confirm_password': confirmPassword,
          }),
        )
        .timeout(const Duration(seconds: 60));
    return jsonDecode(response.body);
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    final result = await _authenticatedRequest('POST', '/auth/logout');
    await clearSession(); // Always clear locally
    return result;
  }

  // Get Profile
  static Future<Map<String, dynamic>> getProfile() async {
    return await _authenticatedRequest('GET', '/users/profile');
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
    Future<http.Response> makeRequest() async {
      final token = await getAccessToken();
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/users/profile'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      if (fullName != null) request.fields['full_name'] = fullName;
      if (email != null) request.fields['email'] = email;
      if (dob != null) request.fields['date_of_birth'] = dob;
      if (height != null) request.fields['height'] = height.toString();
      if (weight != null) request.fields['weight'] = weight.toString();

      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture',
            imagePath,
            contentType: MediaType('image', imagePath.split('.').last),
          ),
        );
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    var response = await makeRequest();

    if (response.statusCode == 401) {
      debugPrint(
        "Token expired during multipart request, attempting refresh...",
      );
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await makeRequest();
      } else {
        await clearSession();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }
    }

    try {
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Invalid response from server'};
    }
  }

  // Update Step Goal
  static Future<Map<String, dynamic>> updateStepGoal(int stepGoal) async {
    return await _authenticatedRequest(
      'PATCH',
      '/users/step-goal',
      body: {'step_goal': stepGoal},
    );
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return await _authenticatedRequest(
      'PATCH',
      '/users/change-password',
      body: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }

  // Confirm Steps
  static Future<Map<String, dynamic>> confirmSteps(dynamic steps) async {
    return await _authenticatedRequest(
      'POST',
      '/steps/confirm',
      body: {'steps': steps},
    );
  }

  // Get Today's Steps
  static Future<Map<String, dynamic>> getTodaySteps() async {
    return await _authenticatedRequest('GET', '/steps/today');
  }

  // Get Weekly Steps
  static Future<Map<String, dynamic>> getWeeklySteps() async {
    return await _authenticatedRequest('GET', '/steps/weekly');
  }

  // Get Admin Alerts (For Notifications Screen)
  static Future<Map<String, dynamic>> getAdminAlerts({
    String filter = 'all',
    int page = 1,
    int limit = 10,
  }) async {
    return await _authenticatedRequest(
      'GET',
      '/admin/alerts?filter=${filter.toLowerCase()}&page=$page&limit=$limit',
    );
  }

  // Update Alert Status
  static Future<Map<String, dynamic>> updateAlertStatus(
    String alertId,
    String status,
  ) async {
    return await _authenticatedRequest(
      'PATCH',
      '/admin/alerts/$alertId/status',
      body: {'status': status.toLowerCase()},
    );
  }

  // Get Single Alert Detail (For Admin Detail Screen)
  static Future<Map<String, dynamic>> getAlertDetail(String alertId) async {
    return await _authenticatedRequest('GET', '/admin/alerts/$alertId');
  }

  // Helper to fetch current coordinates and reverse-geocode to get the actual street address
  static Future<Map<String, dynamic>> getCurrentLocationData() async {
    final hasPermission = await LocationService.handleLocationPermission();
    if (!hasPermission) {
      throw Exception(
        "Location permission is required to trigger alert. Please enable location services.",
      );
    }

    try {
      // Step 1: Try cached/last known position first (instant, no GPS radio needed)
      Position? position = await Geolocator.getLastKnownPosition();

      // Step 2: If no cached position, get fresh position with medium accuracy for speed
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 8));

      final double lat = position.latitude;
      final double lng = position.longitude;
      final int accuracy = position.accuracy.round();
      String streetAddress =
          "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";

      // Step 3: Reverse geocode via OSM Nominatim (non-blocking, failure is OK)
      try {
        final response = await http
            .get(
              Uri.parse(
                'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
              ),
              headers: {
                'User-Agent': 'SolidSteps/1.0 (contact@solidsteps.com)',
              },
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['display_name'] != null) {
            streetAddress = data['display_name'].toString();
          }
        }
      } catch (e) {
        debugPrint(
          "Reverse geocoding error (using coordinates as address): $e",
        );
      }

      return {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'streetAddress': streetAddress,
      };
    } catch (e) {
      throw Exception(
        "Failed to get GPS location. Please ensure GPS is enabled and try again.",
      );
    }
  }

  // Trigger Alert
  static Future<Map<String, dynamic>> triggerAlert({
    required String triggerToken,
    required String dateOfBirth,
    required double lat,
    required double lng,
    required int accuracy,
    required String streetAddress,
    String signalStrength = "strong",
    String connectionState = "4g",
    String deviceId = "device-001",
  }) async {
    return await _authenticatedRequest(
      'POST',
      '/alerts/trigger',
      body: {
        'trigger_token': triggerToken,
        'date_of_birth': dateOfBirth,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'street_address': streetAddress,
        'signal_strength': signalStrength,
        'connection_state': connectionState,
        'device_id': deviceId,
      },
    );
  }

  // Update Alert Location
  static Future<Map<String, dynamic>> updateAlertLocation({
    required String alertId,
    required double lat,
    required double lng,
    required int accuracy,
    required String streetAddress,
    String signalStrength = "medium",
    String connectionState = "wifi",
    String deviceId = "device-001",
  }) async {
    return await _authenticatedRequest(
      'PATCH',
      '/alerts/$alertId/location-update',
      body: {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'street_address': streetAddress,
        'signal_strength': signalStrength,
        'connection_state': connectionState,
        'device_id': deviceId,
      },
    );
  }

  // Get Activities
  static Future<Map<String, dynamic>> getActivities() async {
    return await _authenticatedRequest('GET', '/activities');
  }

  // Create Activity
  static Future<Map<String, dynamic>> createActivity({
    required String category,
    required double steps,
    String? notes,
    String? entryTime,
  }) async {
    return await _authenticatedRequest(
      'POST',
      '/activities',
      body: {
        'category': category,
        'steps': steps,
        'notes': notes ?? '',
        'entry_time': entryTime ?? DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  // Delete User Account
  static Future<Map<String, dynamic>> deleteAccount() async {
    final result = await _authenticatedRequest('DELETE', '/users/profile');
    if (result['success'] == true) {
      await clearSession();
    }
    return result;
  }
}
