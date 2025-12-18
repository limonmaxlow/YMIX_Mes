class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;
  final bool isOnline;
  final bool isPinned;
  final int unreadCount;
  final bool isMuted;
  final bool isArchived;
  final bool isFavorite;
  final String? folderId;
  final String type; // PRIVATE, GROUP, CHANNEL

  const Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    this.isOnline = false,
    this.isPinned = false,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isArchived = false,
    this.isFavorite = false,
    this.folderId,
    this.type = 'PRIVATE',
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    // Форматируем время
    String formatTime(String? dateTimeString) {
      if (dateTimeString == null) return '--:--';
      
      try {
        final dateTime = DateTime.parse(dateTimeString);
        final now = DateTime.now();
        final difference = now.difference(dateTime);
        
        if (difference.inDays == 0) {
          // Сегодня - показываем время
          return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        } else if (difference.inDays == 1) {
          // Вчера
          return 'Вчера';
        } else if (difference.inDays < 7) {
          // На этой неделе
          final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
          return days[dateTime.weekday - 1];
        } else {
          // Более недели назад
          return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        return '--:--';
      }
    }

    return Chat(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Без названия',
      lastMessage: json['lastMessage'] ?? 'Нет сообщений',
      time: formatTime(json['lastMessageTime']?.toString()),
      avatar: json['avatar'] ?? _getDefaultAvatar(json['name'] ?? '?'),
      isOnline: json['online'] ?? false,
      isPinned: false,
      unreadCount: json['unreadCount'] ?? 0,
      isMuted: false,
      isArchived: false,
      isFavorite: false,
      type: json['type'] ?? 'PRIVATE',
    );
  }

  static String _getDefaultAvatar(String name) {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  Chat copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? time,
    String? avatar,
    bool? isOnline,
    bool? isPinned,
    int? unreadCount,
    bool? isMuted,
    bool? isArchived,
    bool? isFavorite,
    String? folderId,
    String? type,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId ?? this.folderId,
      type: type ?? this.type,
    );
  }
}