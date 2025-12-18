import 'package:flutter/material.dart';
import 'package:ymix_messenger/models/chat_model.dart';
import 'package:ymix_messenger/models/message_model.dart';
import 'package:ymix_messenger/services/message_service.dart';
import 'package:ymix_messenger/services/auth_service.dart';
import 'package:ymix_messenger/services/websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final WebSocketService _webSocketService = WebSocketService();
  
  bool _isLoading = true;
  String? _currentUserId;
  bool _isSending = false;
  bool _isConnected = false;
  Map<String, bool> _typingUsers = {};

  @override
  void initState() {
    super.initState();
    _loadUserDataAndMessages();
    _setupWebSocket();
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  void _setupWebSocket() {
    _webSocketService.onMessage = (type, payload) {
      _handleWebSocketMessage(type, payload);
    };

    _webSocketService.onConnected = () {
      setState(() {
        _isConnected = true;
      });
      
      if (_currentUserId != null) {
        _webSocketService.subscribeToChat(widget.chat.id);
      }
    };

    _webSocketService.onDisconnected = () {
      setState(() {
        _isConnected = false;
      });
    };

    _webSocketService.onError = (error) {
      print('❌ WebSocket ошибка: $error');
    };
  }

  void _handleWebSocketMessage(String type, dynamic payload) {
    switch (type) {
      case 'NEW_MESSAGE':
        _handleNewMessage(payload);
        break;
      case 'USER_TYPING':
        _handleUserTyping(payload);
        break;
    }
  }

  void _handleNewMessage(dynamic payload) {
    try {
      final newMessage = Message.fromJson(payload);
      
      // Проверяем, нет ли уже такого сообщения
      final messageExists = _messages.any((m) => m.id == newMessage.id);
      
      if (!messageExists) {
        setState(() {
          _messages.add(newMessage.copyWith(
            isMe: newMessage.senderId == _currentUserId,
            senderName: newMessage.senderId == _currentUserId ? 'Вы' : widget.chat.name,
          ));
        });
        
        _scrollToBottom();
      }
      
    } catch (e) {
      print('❌ Ошибка обработки нового сообщения: $e');
    }
  }

  void _handleUserTyping(dynamic payload) {
    final userId = payload['userId'];
    final isTyping = payload['isTyping'];
    
    setState(() {
      if (isTyping) {
        _typingUsers[userId] = true;
      } else {
        _typingUsers.remove(userId);
      }
    });
  }

  Future<void> _loadUserDataAndMessages() async {
    try {
      final userId = await AuthService.getUserId();
      _currentUserId = userId;
      
      if (userId != null) {
        _webSocketService.connect(userId);
        await _loadMessages();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Необходимо войти в систему');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await MessageService.getChatMessages(widget.chat.id);
      
      final updatedMessages = messages.map((message) {
        return message.copyWith(
          isMe: message.senderId == _currentUserId,
          senderName: message.senderId == _currentUserId ? 'Вы' : widget.chat.name,
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(updatedMessages);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Ошибка загрузки сообщений');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && _currentUserId != null) {
      _webSocketService.sendTypingStatus(widget.chat.id, _currentUserId!, true);
    } else if (_currentUserId != null) {
      _webSocketService.sendTypingStatus(widget.chat.id, _currentUserId!, false);
    }
  }

  Future<void> _sendMessage() async {
    if (_isSending) return;
    
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    setState(() {
      _isSending = true;
    });

    // Прекращаем статус "печатает"
    if (_currentUserId != null) {
      _webSocketService.sendTypingStatus(widget.chat.id, _currentUserId!, false);
    }

    // Очищаем поле ввода сразу
    _messageController.clear();

    try {
      // ОТПРАВЛЯЕМ ТОЛЬКО ЧЕРЕЗ WEBSOCKET - больше ничего не делаем!
      final messageData = {
        'chatId': widget.chat.id,
        'senderId': _currentUserId,
        'content': text,
        'messageType': 'TEXT',
      };

      _webSocketService.sendMessage(widget.chat.id, messageData);

      // WebSocket сам разошлет сообщение всем участникам, включая отправителя
      // Не создаем временное сообщение и не дублируем через HTTP

    } catch (e) {
      _showError('Ошибка отправки сообщения');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF1C2840),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.chat.avatar,
                style: const TextStyle(
                  color: Color(0xFF1C2840),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusText(),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.grey,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Нет сообщений',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              'Начните общение первым',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          if (_typingUsers.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${widget.chat.name} печатает...',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return _buildMessageBubble(message);
                              },
                            ),
                          ),
                        ],
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    if (_typingUsers.isNotEmpty) {
      return const Text(
        'печатает...',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
        ),
      );
    }
    
    return Text(
      '${widget.chat.isOnline ? 'online' : 'offline'} ${_isConnected ? '🟢' : '🔴'}',
      style: TextStyle(
        color: widget.chat.isOnline ? Colors.green : Colors.grey,
        fontSize: 12,
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFF1C2840),
              radius: 16,
              child: Text(
                widget.chat.avatar,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!message.isMe)
                  Text(
                    message.senderName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isMe ? const Color(0xFF1C2840) : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: message.isMe ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: message.isMe ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Color(0xFF4F74B9),
              radius: 16,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1C2840)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isSending,
                      onChanged: _onTextChanged,
                      decoration: InputDecoration(
                        hintText: _isSending ? 'Отправка...' : 'Сообщение...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isSending ? Colors.grey : const Color(0xFF1C2840),
            ),
            child: IconButton(
              icon: _isSending 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}