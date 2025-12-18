class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final String senderId;
  final String chatId;
  final String messageType;
  final bool isMe;
  final String senderName;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.senderId,
    required this.chatId,
    this.messageType = 'TEXT',
    this.isMe = false,
    this.senderName = '',
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      text: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      senderId: json['senderId'] ?? '',
      chatId: json['chatId'] ?? '',
      messageType: json['messageType'] ?? 'TEXT',
      senderName: json['senderName'] ?? '',
    );
  }

  // ДОБАВЬ ЭТОТ МЕТОД:
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': text,
      'timestamp': timestamp.toIso8601String(),
      'senderId': senderId,
      'chatId': chatId,
      'messageType': messageType,
      'senderName': senderName,
    };
  }

  Message copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    String? senderId,
    String? chatId,
    String? messageType,
    bool? isMe,
    String? senderName,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      messageType: messageType ?? this.messageType,
      isMe: isMe ?? this.isMe,
      senderName: senderName ?? this.senderName,
    );
  }
}