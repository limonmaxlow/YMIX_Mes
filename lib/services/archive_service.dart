import '../models/chat_model.dart';

class ArchiveService {
  static final ArchiveService _instance = ArchiveService._internal();
  factory ArchiveService() => _instance;
  ArchiveService._internal();

  // Временное локальное хранилище для архивных чатов
  final List<Chat> _archivedChats = [];

  // Получить все архивные чаты
  List<Chat> getArchivedChats() {
    return List.from(_archivedChats); // Возвращаем копию списка
  }

  // Архивировать чат
  void archiveChat(String chatId) {
    // Проверяем, не архивирован ли уже чат
    if (!_archivedChats.any((chat) => chat.id == chatId)) {
      // Создаем временный архивный чат
      final archivedChat = Chat(
        id: chatId,
        name: 'Архивный чат',
        lastMessage: 'Чат в архиве',
        time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        avatar: 'А',
        isArchived: true,
      );
      _archivedChats.add(archivedChat);
    }
  }

  // Разархивировать чат
  void unarchiveChat(String chatId) {
    _archivedChats.removeWhere((chat) => chat.id == chatId);
  }

  // Очистить архив
  void clearArchive() {
    _archivedChats.clear();
  }

  // Проверить, архивирован ли чат
  bool isChatArchived(String chatId) {
    return _archivedChats.any((chat) => chat.id == chatId);
  }

  // Получить количество архивных чатов
  int get archivedChatsCount => _archivedChats.length;
}