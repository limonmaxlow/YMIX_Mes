import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFolderTap;

  const SearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onFolderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onFolderTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.filter_list,
                color: Color(0xFF808080),
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Поиск...',
                hintStyle: TextStyle(color: Color(0xFF808080)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}