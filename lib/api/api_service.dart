import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // CHANGE THIS to your Laravel API URL
  static const String baseUrl =
      'http://10.23.15.101:8000/api'; // Android Emulator
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

  //save user
  Future<Map<String, dynamic>> save_user({
    required String firstname,
    required String lastname,
    required String email,
    required String provider,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'provider': provider,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await _saveToken(data['data']['sactum_token']);
        return data;
      } else {
        throw Exception("Data not received");
      }
    } catch ($e) {
      throw Exception($e.toString());
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

  //Saving the user location

  Future<Map<String, dynamic>> saveReportWithUser({
    required String uid,
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
          'uid': uid,
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

  Future<Map<String, dynamic>> obtain_report(String uid) async {
    try {
      //Check this Url in the laravel project
      final response = await http.get(
        Uri.parse('$baseUrl/obtain_report/$uid'),
        headers: {'Content-Type': 'application/json'},
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

  Future<Map<String, dynamic>> delete_report(int reportId, String uid) async {
    try {
      final token = await _getToken();

      if (token == null) throw Exception('No authentication token');

      final response = await http.delete(
        Uri.parse('$baseUrl/delete_report/$reportId, $uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete contact');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // emergency contacts

  //Adding the emergency contacts
  // ignore: non_constant_identifier_names
  Future<Map<String, dynamic>> add_emergency_contacts({
    required String user_id,
    required String contactName,
    required String contactNumber,
  }) async {
    try {
      //Check this Url in the laravel project
      final response = await http.post(
        Uri.parse('$baseUrl/add_emergency_contacts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user_id,
          'contactName': contactName,
          'contactNumber': contactNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Save Sanctum token
        return data;
      } else {
        throw Exception(data['message'] ?? 'Repor received');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  //Obtain Emergency contacts

  Future<Map<String, dynamic>> obtain_emergencyContacts(String uid) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/obtain_emergency_contacts/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(
          data['message'] ?? 'Failed to obtain emergency contacts',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  //Deleting the emergency contact
  Future<Map<String, dynamic>> delete_emergencyContact(
    int contactId,
    String uid,
  ) async {
    try {
      final token = await _getToken();

      if (token == null) throw Exception('No authentication token');

      final response = await http.delete(
        Uri.parse('$baseUrl/delete_emergency_contact/$contactId, $uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete contact');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  //Obtaining counsellors
  Future<Map<String, dynamic>> obtain_counsellors() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/obtain_counsellors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to obtain counsellors');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> create_counsellor_appointment({
    required String user_id,
    required int counsellor_id,
    required DateTime appointmentDate,
    required DateTime appointmentTime,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ("No Authentication Token");
      }
      //Check this Url in the laravel project
      final response = await http.post(
        Uri.parse('$baseUrl/add_appointment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user_id,
          'counsellor_id': counsellor_id,
          'appointment_date': appointmentDate.toIso8601String(),
          'appointment_time': appointmentTime.toIso8601String(),
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
      throw Exception('Failed to create counsellor appointment $e');
    }
  }

  Future<Map<String, dynamic>> obtain_appointments(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ("No Authentication Token");
      }
      final response = await http.get(
        Uri.parse('$baseUrl/obtain_appointments/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to obtain appointments');
      }
    } catch (e) {
      throw Exception('Failed to obtain appointments $e');
    }
  }

  Future<Map<String, dynamic>> delete_appointments(
    int userId,
    String appointment_id,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ("No Authentication Token");
      }
      final response = await http.delete(
        Uri.parse('$baseUrl/delete_appointment/$userId/$appointment_id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete appointment');
      }
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  Future<Map<String, dynamic>> obtain_support() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ("No Authentication Token");
      }
      final response = await http.get(
        Uri.parse('$baseUrl/obtain_all_support'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(
          data['message'] ?? 'Failed to obtain the support information',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> obtain_single_support(String supportid) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ("No Authentication Token");
      }
      final response = await http.get(
        Uri.parse('$baseUrl/obtain_support/$supportid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(
          data['message'] ?? 'Failed to obtain the support information',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  ///Future<Map<String, dynamic>> save_Appointment() async{}
}
