import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ymix_messenger/models/message_model.dart';

class MessageService {
  static const String baseUrl = 'http://10.194.18.37:8080/api';

  // Отправить сообщение
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String messageType = 'TEXT',
  }) async {
    try {
      print('=== ОТПРАВКА СООБЩЕНИЯ ===');
      print('ChatId: $chatId');
      print('SenderId: $senderId');
      print('Content: $content');

      // Проверяем UUID
      if (!_isValidUUID(chatId) || !_isValidUUID(senderId)) {
        return {
          'success': false,
          'message': 'Некорректные ID',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chatId': chatId,
          'senderId': senderId,
          'content': content,
          'messageType': messageType,
        }),
      );

      print('Send message status: ${response.statusCode}');
      print('Send message body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          // Пробуем разные пути к данным
          dynamic messageData = data['data'] ?? data['message'];
          if (messageData != null) {
            final message = Message.fromJson(messageData);
            print('Сообщение успешно создано: ${message.id}');
            return {
              'success': true,
              'message': message,
              'responseMessage': data['message'] ?? 'Сообщение отправлено',
            };
          } else {
            return {
              'success': false,
              'message': 'Данные сообщения не получены от сервера',
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Ошибка отправки сообщения',
          };
        }
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, data),
        };
      }
    } catch (e) {
      print('Ошибка отправки сообщения: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения: $e',
      };
    }
  }

  // Получить сообщения чата
  static Future<List<Message>> getChatMessages(String chatId, {int limit = 50}) async {
    try {
      print('=== ЗАГРУЗКА СООБЩЕНИЙ ===');
      print('ChatId: $chatId');
      
      if (!_isValidUUID(chatId)) {
        print('Некорректный UUID чата: $chatId');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/messages/chat/$chatId?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Get messages status: ${response.statusCode}');
      print('Get messages body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> messagesData = data['data'] ?? [];
          print('Получено ${messagesData.length} сообщений');
          
          // Переворачиваем список, чтобы новые сообщения были внизу
          final messages = messagesData.reversed.map((messageData) => Message.fromJson(messageData)).toList();
          
          // Логируем первое сообщение для проверки
          if (messages.isNotEmpty) {
            print('Первое сообщение: ${messages.first.text}');
          }
          
          return messages;
        } else {
          print('Сервер вернул success: false');
          return [];
        }
      } else {
        print('Ошибка HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Ошибка получения сообщений: $e');
      print('StackTrace: ${e.toString()}');
      return [];
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
      case 500:
        return 'Внутренняя ошибка сервера';
      default:
        return data['message'] ?? 'Ошибка сервера: $statusCode';
    }
  }

  // Проверка валидности UUID
  static bool _isValidUUID(String uuid) {
    if (uuid.isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(uuid);
  }
}