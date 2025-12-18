import 'package:flutter/material.dart';
import '../../models/chat_model.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onFavorite;
  final VoidCallback? onMore;

  const ChatItem({
    super.key,
    required this.chat,
    required this.onTap,
    this.onDelete,
    this.onArchive,
    this.onFavorite,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(chat.id),
      direction: DismissDirection.horizontal,
      background: _buildDeleteBackground(),
      secondaryBackground: _buildDeleteBackground(), // Одинаковый фон для обоих направлений
      confirmDismiss: (direction) async {
        // Для обоих направлений показываем подтверждение удаления
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: _buildAvatar(),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  chat.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (chat.isPinned)
                const Icon(Icons.push_pin, size: 14, color: Colors.orange),
              if (chat.isMuted)
                const Icon(Icons.volume_off, size: 14, color: Colors.grey),
            ],
          ),
          subtitle: Text(
            chat.lastMessage,
            style: TextStyle(
              color: const Color(0xFF718096),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _buildTrailing(),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red, // Красный фон
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.close, color: Colors.white, size: 24), // Крестик
          SizedBox(height: 4),
          Text(
            'Удалить',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: Text('Вы уверены, что хотите удалить чат "${chat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildAvatar() {
    final color = _getAvatarColor(chat.avatar);
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              chat.avatar,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
        if (chat.isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailing() {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: const TextStyle(
              color: Color(0xFFA0AEC0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String avatar) {
    final colors = [
      const Color(0xFF667EEA), // Мягкий синий
      const Color(0xFF764BA2), // Мягкий фиолетовый
      const Color(0xFFF093FB), // Мягкий розовый
      const Color(0xFF4ECDC4), // Мягкий бирюзовый
      const Color(0xFF43E97B), // Мягкий зеленый
      const Color(0xFFFA709A), // Мягкий коралловый
    ];
    final index = avatar.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}