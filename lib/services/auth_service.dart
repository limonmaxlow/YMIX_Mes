import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ymix_messenger/models/user.dart';

class AuthService {
  static const String baseUrl = 'http://10.194.18.37:8080/api';

  // Проверка существования номера телефона
  static Future<bool> checkPhoneNumber(String phone) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/check-phone/$cleanPhone'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true && data['data'] == true;
      }
      return false;
    } catch (e) {
      print('Ошибка проверки номера: $e');
      return false;
    }
  }

  // Регистрация нового пользователя
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'phoneNumber': cleanPhone,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['data']);
        
        // Сохраняем реальный ID пользователя
        await _saveUserId(user.id);
        
        return {
          'success': true,
          'user': user,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка регистрации',
        };
      }
    } catch (e) {
      print('Ошибка регистрации: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения: $e',
      };
    }
  }

  // Логин пользователя по паролю
  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': cleanPhone,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['data']);
        
        // Сохраняем реальный ID пользователя
        await _saveUserId(user.id);
        
        return {
          'success': true,
          'user': user,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка входа',
        };
      }
    } catch (e) {
      print('Ошибка входа: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения: $e',
      };
    }
  }

  // Сохранение ID пользователя
  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // Получение ID пользователя
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Выход из системы
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  // Проверка авторизации
  static Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null && _isValidUUID(userId);
  }

  // Проверка валидности UUID
  static bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(uuid);
  }
}