import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../services/archive_service.dart';
import '../../widgets/chat/chat_item.dart';

class ArchivedChatsScreen extends StatefulWidget {
  const ArchivedChatsScreen({super.key});

  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen> {
  final ArchiveService _archiveService = ArchiveService();
  late List<Chat> _archivedChats;

  @override
  void initState() {
    super.initState();
    _archivedChats = _archiveService.getArchivedChats();
  }

  void _unarchiveChat(Chat chat) {
    setState(() {
      _archiveService.unarchiveChat(chat.id);
      _archivedChats = _archiveService.getArchivedChats();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Чат с ${chat.name} возвращен из архива'),
        backgroundColor: Colors.green,
      ),
    );
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
          'Архивные чаты',
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
      body: _archivedChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Архив пуст',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Здесь будут ваши архивные чаты',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: _archivedChats.length,
              itemBuilder: (context, index) {
                final chat = _archivedChats[index];
                return Dismissible(
                  key: Key(chat.id),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.unarchive, color: Colors.white),
                  ),
                  onDismissed: (direction) => _unarchiveChat(chat),
                  child: ChatItem(
                    chat: chat,
                    onTap: () => _openChat(chat),
                  ),
                );
              },
            ),
    );
  }
}