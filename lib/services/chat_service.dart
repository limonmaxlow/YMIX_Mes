import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ymix_messenger/models/chat_model.dart';
import 'package:ymix_messenger/models/user.dart';

class ChatService {
  static const String baseUrl = 'http://10.194.18.37:8080/api';

  // Получить все чаты пользователя
  static Future<List<Chat>> getUserChats(String userId) async {
    try {
      // Проверяем, что userId является корректным UUID
      if (!_isValidUUID(userId)) {
        print('Некорректный UUID пользователя: $userId');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/chats/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Get chats status: ${response.statusCode}');
      print('Get chats body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> chatsData = data['data'];
          return chatsData.map((chatData) => Chat.fromJson(chatData)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Ошибка получения чатов: $e');
      return [];
    }
  }

  // Создать приватный чат - ИСПРАВЛЕННЫЙ ВАРИАНТ
  static Future<Map<String, dynamic>> createPrivateChat(String creatorId, String targetUserPhone) async {
    try {
      // Проверяем UUID
      if (!_isValidUUID(creatorId)) {
        return {
          'success': false,
          'message': 'Некорректный ID пользователя',
        };
      }

      final cleanPhone = targetUserPhone.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chats/private?creatorId=$creatorId&targetUserPhone=$cleanPhone'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Create private chat status: ${response.statusCode}');
      print('Create private chat body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          return {
            'success': true,
            'chat': Chat.fromJson(data['data']),
            'message': data['message'] ?? 'Приватный чат создан',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Ошибка создания чата',
          };
        }
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, data),
        };
      }
    } catch (e) {
      print('Ошибка создания приватного чата: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения: $e',
      };
    }
  }

  // Создать групповой чат - ИСПРАВЛЕННЫЙ ВАРИАНТ
  static Future<Map<String, dynamic>> createGroupChat(String chatName, String creatorId, List<String> memberIds) async {
    try {
      // Проверяем UUID
      if (!_isValidUUID(creatorId)) {
        return {
          'success': false,
          'message': 'Некорректный ID пользователя',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/group?chatName=${Uri.encodeComponent(chatName)}&creatorId=$creatorId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Create group chat status: ${response.statusCode}');
      print('Create group chat body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          return {
            'success': true,
            'chat': Chat.fromJson(data['data']),
            'message': data['message'] ?? 'Групповой чат создан',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Ошибка создания группы',
          };
        }
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, data),
        };
      }
    } catch (e) {
      print('Ошибка создания группового чата: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения: $e',
      };
    }
  }

  // Создать канал - ИСПРАВЛЕННЫЙ ВАРИАНТ
  static Future<Map<String, dynamic>> createChannel(String channelName, String creatorId) async {
    try {
      // Проверяем UUID
      if (!_isValidUUID(creatorId)) {
        return {
          'success': false,
          'message': 'Некорректный ID пользователя',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/channel?channelName=${Uri.encodeComponent(channelName)}&creatorId=$creatorId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Create channel status: ${response.statusCode}');
      print('Create channel body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          return {
            'success': true,
            'chat': Chat.fromJson(data['data']),
            'message': data['message'] ?? 'Канал создан',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Ошибка создания канала',
          };
        }
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, data),
        };
      }
    } catch (e) {
      print('Ошибка создания канала: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения: $e',
      };
    }
  }

  // Вспомогательный метод для получения понятных сообщений об ошибках
  static String _getErrorMessage(int statusCode, Map<String, dynamic> data) {
    switch (statusCode) {
      case 400:
        return data['message'] ?? 'Неверный запрос. Проверьте введенные данные';
      case 401:
        return 'Неавторизованный доступ';
      case 403:
        return 'Доступ запрещен';
      case 404:
        return 'Ресурс не найден';
      case 409:
        return data['message'] ?? 'Конфликт: чат уже существует';
      case 500:
        return 'Внутренняя ошибка сервера';
      default:
        return data['message'] ?? 'Ошибка сервера: $statusCode';
    }
  }

  // Проверка валидности UUID
  static bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(uuid);
  }

  // Удалить пользователя из чата (удалить чат для пользователя)
  static Future<Map<String, dynamic>> removeUserFromChat(String chatId, String userId) async {
    try {
      // Проверяем UUID
      if (!_isValidUUID(chatId) || !_isValidUUID(userId)) {
        return {
          'success': false,
          'message': 'Некорректные ID',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/chats/$chatId/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Remove user from chat status: ${response.statusCode}');
      print('Remove user from chat body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Чат удален',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Ошибка удаления чата',
          };
        }
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, data),
        };
      }
    } catch (e) {
      print('Ошибка удаления чата: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения: $e',
      };
    }
  }

  // Поиск пользователей по номеру телефона
  static Future<List<User>> searchUsersByPhone(String phoneQuery) async {
    try {
      final cleanPhone = phoneQuery.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?phone=$cleanPhone'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> usersData = data['data'];
          return usersData.map((userData) => User.fromJson(userData)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Ошибка поиска пользователей: $e');
      return [];
    }
  }

// Удалить чат полностью из БД
static Future<Map<String, dynamic>> deleteChat(String chatId) async {
  try {
    // Проверяем UUID
    if (!_isValidUUID(chatId)) {
      return {
        'success': false,
        'message': 'Некорректный ID чата',
      };
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/chats/$chatId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Delete chat status: ${response.statusCode}');
    print('Delete chat body: ${response.body}');

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Чат удален',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка удаления чата',
        };
      }
    } else {
      return {
        'success': false,
        'message': _getErrorMessage(response.statusCode, data),
      };
    }
  } catch (e) {
    print('Ошибка удаления чата: $e');
    return {
      'success': false,
      'message': 'Ошибка соединения: $e',
    };
  }
}

}