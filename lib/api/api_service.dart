import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // CHANGE THIS to your Laravel API URL
  static const String baseUrl =
      'http://10.23.15.111:8000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator
  // static const String baseUrl = 'https://your-api.com/api'; // Production

  // Get stored Sanctum token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sanctum_token');
  }

  // Save Sanctum token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sanctum_token', token);
  }

  // Clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sanctum_token');
  }

  // Firebase Signup
  Future<Map<String, dynamic>> firebaseSignup({
    required String firstname,
    required String lastname,
    required String email,
    required String contact,
    required String dob,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/firebase/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'contact': contact,
          'dob': dob,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        // Save Sanctum token
        await _saveToken(data['data']['sanctum_token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Firebase Login
  Future<Map<String, dynamic>> firebaseLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/firebase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await _saveToken(data['data']['sanctum_token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User Update the profile
  Future<Map<String, dynamic>> updateProfile({
    required String textLabel,
    required String updateData,
    required String updated,
    required id,
  }) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('No authentication token');
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'Column': textLabel,
            'Previous_data': updateData,
            'New_Data': updated,
            'id': id,
            'token': token,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 201 && data['success']) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Profile Update Failed');
        }
      } catch (e) {
        throw Exception('Network Error: $e');
      }
    }
  }

  // Social Login (Google, Facebook, etc.)
  Future<Map<String, dynamic>> socialLogin({
    required String firebaseToken,
    required String provider,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/firebase/social-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_token': firebaseToken,
          'provider': provider,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await _saveToken(data['data']['sanctum_token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Social login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get User Info
  Future<Map<String, dynamic>> getUser() async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/firebase/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await _getToken();

      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/firebase/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      await clearToken();
    } catch (e) {
      // Even if API call fails, clear local token
      await clearToken();
    }
  }

  //Saving Other information to the database
  Future<Map<String, dynamic>> saveReportWithUser({
    required String reportTime,
    required String date,
    required String location,
    required String incident,
    required String contact,
  }) async {
    try {
      //Check this Url in the laravel project
      final response = await http.post(
        Uri.parse('$baseUrl/report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reportTime': reportTime,
          'date': date,
          'location': location,
          'incident': incident,
          'contact': contact,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        // Save Sanctum token
        return data;
      } else {
        throw Exception(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
