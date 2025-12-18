import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';

class WebSocketService {
  static StompClient? _stompClient;
  static final WebSocketService _instance = WebSocketService._internal();
  
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Коллбэки
  Function(String, dynamic)? onMessage;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(dynamic)? onError;

  // Подключение к WebSocket
  void connect(String userId) {
    try {
      print('🤖 === ПОДКЛЮЧЕНИЕ К WEBSOCKET STOMP ===');
      print('🤖 User ID: $userId');
      
      _stompClient = StompClient(
        config: StompConfig(
          url: 'ws://10.194.18.37:8080/ws',
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          stompConnectHeaders: {'userId': userId},
          reconnectDelay: const Duration(seconds: 3),
        ),
      );
      
      _stompClient!.activate();
      
    } catch (e) {
      print('❌ Ошибка подключения WebSocket: $e');
      onError?.call(e);
    }
  }

  void _onConnect(StompFrame frame) {
    print('✅ WebSocket подключен');
    print('✅ Frame: ${frame.body}');
    onConnected?.call();
  }

  void _onDisconnect(StompFrame frame) {
    print('🔴 WebSocket отключен');
    onDisconnected?.call();
  }

  void _onStompError(StompFrame frame) {
    print('❌ STOMP ошибка: ${frame.body}');
    onError?.call(frame.body);
  }

  void _onWebSocketError(dynamic error) {
    print('❌ WebSocket ошибка: $error');
    onError?.call(error);
  }

  // Подписка на чат
  void subscribeToChat(String chatId) {
    if (_stompClient?.connected == true) {
      final destination = '/topic/chat/$chatId';
      print('📡 Подписываюсь на чат: $destination');
      
      _stompClient!.subscribe(
        destination: destination,
        callback: (frame) {
          print('📨 Получено WebSocket сообщение: ${frame.body}');
          
          if (frame.body != null) {
            try {
              final message = jsonDecode(frame.body!);
              final type = message['type'];
              final data = message['data'];
              
              print('📨 Тип: $type');
              print('📨 Данные: $data');
              
              onMessage?.call(type, data);
            } catch (e) {
              print('❌ Ошибка парсинга WebSocket сообщения: $e');
            }
          }
        },
      );
    } else {
      print('❌ WebSocket не подключен, не могу подписаться на чат $chatId');
    }
  }

  // Отправка сообщения через WebSocket
  void sendMessage(String chatId, Map<String, dynamic> messageData) {
    if (_stompClient?.connected == true) {
      final destination = '/app/chat/$chatId/send';
      print('📤 Отправка WebSocket сообщения: $destination');
      print('📤 Данные: $messageData');
      
      _stompClient!.send(
        destination: destination,
        body: jsonEncode(messageData),
      );
    } else {
      print('❌ WebSocket не подключен, не могу отправить сообщение');
    }
  }

  // Статус "печатает"
  void sendTypingStatus(String chatId, String userId, bool isTyping) {
    if (_stompClient?.connected == true) {
      _stompClient!.send(
        destination: '/app/chat/$chatId/typing',
        body: jsonEncode({
          'userId': userId,
          'chatId': chatId,
          'isTyping': isTyping,
        }),
      );
    }
  }

  // Отключение
  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    print('🔴 WebSocket отключен вручную');
  }

  bool get isConnected => _stompClient?.connected == true;
}