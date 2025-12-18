import 'package:flutter/material.dart';
import 'package:ymix_messenger/models/chat_model.dart';
import 'package:ymix_messenger/services/chat_service.dart';
import 'package:ymix_messenger/widgets/chat/chat_item.dart';

class FavoriteChatsScreen extends StatefulWidget {
  final String userId;

  const FavoriteChatsScreen({super.key, required this.userId});

  @override
  State<FavoriteChatsScreen> createState() => _FavoriteChatsScreenState();
}

class _FavoriteChatsScreenState extends State<FavoriteChatsScreen> {
  List<Chat> _favoriteChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteChats();
  }

  Future<void> _loadFavoriteChats() async {
    try {
      // Получаем все чаты и фильтруем избранные
      final allChats = await ChatService.getUserChats(widget.userId);
      setState(() {
        _favoriteChats = allChats.where((chat) => chat.isFavorite).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки избранных чатов: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openChat(Chat chat) {
    // Навигация к чату
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Избранные чаты',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A5568)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет избранных чатов',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Добавляйте чаты в избранное долгим нажатием',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: _favoriteChats.length,
                  itemBuilder: (context, index) {
                    final chat = _favoriteChats[index];
                    return ChatItem(
                      chat: chat,
                      onTap: () => _openChat(chat),
                    );
                  },
                ),
    );
  }
}