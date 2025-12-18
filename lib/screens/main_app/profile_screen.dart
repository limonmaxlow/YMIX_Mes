import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageUrl;
  bool _isOnline = true;
  Color _backgroundColor = Colors.white;
  String _backgroundImageUrl = '';

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImageUrl = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при выборе изображения: $e');
    }
  }

  Future<void> _pickBackgroundImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _backgroundImageUrl = pickedFile.path;
          _backgroundColor = Colors.transparent;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при выборе фонового изображения: $e');
    }
  }

  bool isWeb() {
    return identical(0, 0.0);
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  void _showSecuritySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Безопасность'),
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Активные сеансы'),
                  subtitle: Text('Управление устройствами'),
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Пароль'),
                  subtitle: Text('Изменить пароль'),
                ),
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Блокировки'),
                  subtitle: Text('Заблокированные пользователи'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Приватность'),
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('Видимость профиля'),
                  subtitle: Text('Кто может видеть ваш профиль'),
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Друзья'),
                  subtitle: Text('Настройки друзей'),
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Уведомления'),
                  subtitle: Text('Настройки уведомлений'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Уведомления'),
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Сообщения'),
                  subtitle: Text('Уведомления о сообщениях'),
                ),
                ListTile(
                  leading: Icon(Icons.thumb_up),
                  title: Text('Лайки'),
                  subtitle: Text('Уведомления о лайках'),
                ),
                ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Друзья'),
                  subtitle: Text('Запросы в друзья'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAppearanceSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Внешний вид',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Цвет фона:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildColorOption(Colors.white, 'Белый'),
                _buildColorOption(Colors.black, 'Черный'),
                _buildColorOption(Colors.blue.shade50, 'Голубой'),
                _buildColorOption(Colors.grey.shade100, 'Серый'),
                _buildColorOption(Colors.purple.shade50, 'Фиолетовый'),
                _buildColorOption(Colors.green.shade50, 'Зеленый'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Фоновое изображение:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickBackgroundImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Выбрать изображение'),
                  ),
                ),
              ],
            ),
            if (_backgroundImageUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Текущее фоновое изображение',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: isWeb()
                        ? NetworkImage(_backgroundImageUrl)
                        : FileImage(File(_backgroundImageUrl)) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _backgroundImageUrl = '';
                    _backgroundColor = Colors.white;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Удалить фоновое изображение'),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Готово'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, String label) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _backgroundColor = color;
              _backgroundImageUrl = '';
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _backgroundColor == color ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundImageUrl.isNotEmpty
          ? Colors.transparent
          : _backgroundColor,
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAppearanceSettings(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.settings, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        if (_backgroundImageUrl.isNotEmpty)
          Positioned.fill(
            child: Image(
              image: isWeb()
                  ? NetworkImage(_backgroundImageUrl)
                  : FileImage(File(_backgroundImageUrl)) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 16),
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildStatsRow(),
              const SizedBox(height: 32),
              _buildSettingsSection(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        'Профиль',
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_2, color: Colors.black),
          onPressed: () {
            // Функционал QR-кода
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: _profileImageUrl != null
                    ? ClipOval(
                        child: isWeb()
                            ? Image.network(
                                _profileImageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  );
                                },
                              )
                            : Image.file(
                                File(_profileImageUrl!),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: _toggleOnlineStatus,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Maksim Boev',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '@maks_bb',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'О себе: я крутой мальчик',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('247', 'Контакты'),
          _buildStatItem('1.2K', 'Очков'),
          _buildStatItem('86', 'Дней'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Настройки',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingBlock(
            title: 'Безопасность',
            subtitle: 'Активные сеансы, пароль, блокировки',
            onTap: () => _showSecuritySettings(context),
          ),
          const SizedBox(height: 12),
          _buildSettingBlock(
            title: 'Приватность',
            subtitle: 'Настройки видимости профиля',
            onTap: () => _showPrivacySettings(context),
          ),
          const SizedBox(height: 12),
          _buildSettingBlock(
            title: 'Уведомления',
            subtitle: 'Управления оповещениями',
            onTap: () => _showNotificationsSettings(context),
          ),
          const SizedBox(height: 12),
          _buildSettingBlock(
            title: 'Внешний вид',
            subtitle: 'Темы, шрифты, иконки, фон',
            onTap: () => _showAppearanceSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingBlock({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}