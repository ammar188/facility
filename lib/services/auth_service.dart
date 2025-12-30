import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config/app_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  final ApiService _apiService;

  AuthService() : _apiService = ApiService(baseUrl: AppConfig.backendUrl);

  Future<void> initialize() async {
    // No initialization needed if using backend auth
    // Just check if we have a stored token
    final token = await getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  /// Sign in with email and password using your backend
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      final response = await _apiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      // Adjust these keys based on your backend response format
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        final userId = data['user']?['id'] ?? data['userId'] ?? data['user_id'];

        if (token != null) {
          await _saveToken(token as String);
          if (userId != null) {
            await _saveUserId(userId.toString());
          }
          _apiService.setAuthToken(token as String);
        }

        return response;
      } else {
        throw Exception(response['error'] ?? response['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with phone and password using your backend
  Future<Map<String, dynamic>> signInWithPhone(String phone, String password) async {
    try {
      final response = await _apiService.post('/api/auth/login', {
        'phone': phone,
        'password': password,
      });

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        final userId = data['user']?['id'] ?? data['userId'] ?? data['user_id'];

        if (token != null) {
          await _saveToken(token as String);
          if (userId != null) {
            await _saveUserId(userId.toString());
          }
          _apiService.setAuthToken(token as String);
        }

        return response;
      } else {
        throw Exception(response['error'] ?? response['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get current session token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get current user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Optionally call backend logout endpoint
      // await _apiService.post('/api/auth/logout', {});
    } catch (e) {
      // Ignore errors on logout
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      _apiService.setAuthToken(null);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }
}
