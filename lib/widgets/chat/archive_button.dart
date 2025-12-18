import 'package:flutter/material.dart';

class ArchiveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isArchived;

  const ArchiveButton({
    super.key,
    required this.onPressed,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isArchived ? Icons.unarchive : Icons.archive_outlined,
        color: const Color(0xFF424242),
      ),
      onPressed: onPressed,
      tooltip: isArchived ? 'Вернуть из архива' : 'Архивировать',
    );
  }
}