import 'package:flutter/material.dart';
import 'package:ymix_messenger/models/chat_model.dart';
import 'package:ymix_messenger/services/chat_service.dart';
import 'package:ymix_messenger/services/auth_service.dart';
import 'package:ymix_messenger/widgets/chat/chat_item.dart';
import 'package:ymix_messenger/screens/main_app/chat_screen.dart'; // Импортируем отдельный ChatScreen

// УДАЛЯЕМ весь локальный класс ChatScreen и Message отсюда

// Основной класс ChatListScreen
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late AnimationController _starController;
  late Animation<double> _starScaleAnimation;
  late Animation<double> _starRotationAnimation;
  late Animation<double> _starGlowAnimation;
  late AnimationController _panelController;
  late Animation<double> _panelWidthAnimation;
  
  bool _showSearch = false;
  bool _showPanel = false;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  List<Chat> _chats = [];
  bool _isLoading = true;
  String? _currentUserId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserDataAndChats();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _starScaleAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );

    _starRotationAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );

    _starGlowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );

    _panelWidthAnimation = Tween<double>(begin: 15.0, end: 180.0).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Логика появления поиска при скролле вниз
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showSearch) {
        setState(() {
          _showSearch = true;
        });
      } else if (_scrollController.offset <= 100 && _showSearch) {
        setState(() {
          _showSearch = false;
        });
      }
    });
  }

  Future<void> _loadUserDataAndChats() async {
    try {
      // Получаем ID пользователя из AuthService
      final userId = await AuthService.getUserId();
      
      if (userId == null || !_isValidUUID(userId)) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Необходимо войти в систему';
        });
        return;
      }

      _currentUserId = userId;
      await _loadUserChats();
      
    } catch (e) {
      print('Ошибка загрузки данных пользователя: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки данных';
      });
    }
  }

  Future<void> _loadUserChats() async {
    if (_currentUserId == null) return;
    
    try {
      final chats = await ChatService.getUserChats(_currentUserId!);
      setState(() {
        _chats = chats;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      print('Ошибка загрузки чатов: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки чатов';
      });
    }
  }

  bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(uuid);
  }

  // Отфильтрованные чаты для поиска
  List<Chat> get _filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) => 
      chat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: chat), // Теперь используем импортированный ChatScreen
      ),
    );
  }

  Future<void> _deleteChat(Chat chat) async {
    try {
      final result = await ChatService.deleteChat(chat.id);
      
      if (result['success'] == true) {
        setState(() {
          _chats.removeWhere((c) => c.id == chat.id);
        });
        _showSuccess(result['message'] ?? 'Чат удален');
      } else {
        _showError(result['message'] ?? 'Ошибка удаления чата');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  void _togglePanel() {
    setState(() {
      _showPanel = !_showPanel;
      if (_showPanel) {
        _panelController.forward();
      } else {
        _panelController.reverse();
      }
    });
  }

  void _createNewChat() {
    if (_currentUserId == null) {
      _showError('Необходимо войти в систему');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать новый чат'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Приватный чат'),
              subtitle: const Text('Чат с одним пользователем'),
              onTap: () {
                Navigator.pop(context);
                _showNewPrivateChatDialog();
              },
            ),
            /*ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Групповой чат'),
              subtitle: const Text('Чат с несколькими участниками'),
              onTap: () {
                Navigator.pop(context);
                _showNewGroupDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Канал'),
              subtitle: const Text('Публичный канал для широкой аудитории'),
              onTap: () {
                Navigator.pop(context);
                _showNewChannelDialog();
              },
            ),*/
          ],
        ),
      ),
    );
  }

  void _showNewPrivateChatDialog() {
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый приватный чат'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите номер телефона пользователя:'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                hintText: 'Например: 9123456789',
                border: OutlineInputBorder(),
                prefixText: '+7 ',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.length == 10) {
                Navigator.pop(context);
                await _createPrivateChat(phone);
              } else {
                _showError('Введите корректный номер телефона (10 цифр)');
              }
            },
            child: const Text('Создать чат'),
          ),
        ],
      ),
    );
  }

  void _showNewGroupDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать группу'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Название группы',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Группа будет создана с вами как администратором. Вы сможете добавить участников позже.',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                await _createGroupChat(name);
              } else {
                _showError('Введите название группы');
              }
            },
            child: const Text('Создать группу'),
          ),
        ],
      ),
    );
  }

  void _showNewChannelDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать канал'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Название канала',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Канал - это публичный чат для широкой аудитории. Сообщения могут отправлять только администраторы.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                await _createChannel(name);
              } else {
                _showError('Введите название канала');
              }
            },
            child: const Text('Создать канал'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPrivateChat(String phone) async {
    if (_currentUserId == null) {
      _showError('Необходимо войти в систему');
      return;
    }

    try {
      final result = await ChatService.createPrivateChat(_currentUserId!, phone);
      
      if (result['success'] == true) {
        final Chat chat = result['chat'];
        setState(() {
          _chats.insert(0, chat);
        });
        _showSuccess(result['message'] ?? 'Приватный чат создан');
      } else {
        _showError(result['message'] ?? 'Ошибка создания чата');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  Future<void> _createGroupChat(String name) async {
    if (_currentUserId == null) {
      _showError('Необходимо войти в систему');
      return;
    }

    try {
      final result = await ChatService.createGroupChat(name, _currentUserId!, []);
      
      if (result['success'] == true) {
        final Chat chat = result['chat'];
        setState(() {
          _chats.insert(0, chat);
        });
        _showSuccess(result['message'] ?? 'Групповой чат создан');
      } else {
        _showError(result['message'] ?? 'Ошибка создания группы');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  Future<void> _createChannel(String name) async {
    if (_currentUserId == null) {
      _showError('Необходимо войти в систему');
      return;
    }

    try {
      final result = await ChatService.createChannel(name, _currentUserId!);
      
      if (result['success'] == true) {
        final Chat chat = result['chat'];
        setState(() {
          _chats.insert(0, chat);
        });
        _showSuccess(result['message'] ?? 'Канал создан');
      } else {
        _showError(result['message'] ?? 'Ошибка создания канала');
      }
    } catch (e) {
      _showError('Ошибка: $e');
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

  void _openProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _openMarketplace() {
    Navigator.pushNamed(context, '/shop');
  }

  void _openPets() {
    Navigator.pushNamed(context, '/pets');
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  Future<void> _refreshChats() async {
    if (_currentUserId == null) {
      await _loadUserDataAndChats();
    } else {
      setState(() {
        _isLoading = true;
      });
      await _loadUserChats();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _starController.dispose();
    _panelController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          );
        },
        child: Stack(
          children: [
            // Основной контент
            Column(
              children: [
                // Шапка профиля
                Container(
                  height: 120,
                  color: const Color(0xFF1C2840),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      children: [
                        // Логотип Ymix на одной строке
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Буква Y с градиентом
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF4F74B9),
                                    Color(0xFF9747FF),
                                    Color(0xFFCDDBF0),
                                  ],
                                  stops: [0.22, 0.6, 1.0],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Y',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Буквы "mix" белые
                            const Text(
                              'mix',
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Круг со звездой - круг неподвижный, звезда сияет
                        /*Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x33FFFFFF),
                          ),
                          child: AnimatedBuilder(
                            animation: _starController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Эффект сияния
                                  Container(
                                    width: 30 * _starGlowAnimation.value,
                                    height: 30 * _starGlowAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromRGBO(255, 255, 255, (0.1 * _starGlowAnimation.value)),
                                    ),
                                  ),
                                  // Вытянутая звезда
                                  Transform.rotate(
                                    angle: _starRotationAnimation.value,
                                    child: Transform.scale(
                                      scale: _starScaleAnimation.value,
                                      child: Icon(
                                        Icons.star,
                                        color: Color.fromRGBO(255, 255, 255, _starGlowAnimation.value),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
                
                // Секция с кругом создания + выдвигающаяся кнопка справа
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Круг для создания слева
                      GestureDetector(
                        onTap: _createNewChat,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF424242),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Выдвигающаяся кнопка справа
                      AnimatedBuilder(
                        animation: _panelController,
                        builder: (context, child) {
                          return GestureDetector(
                            onTap: _togglePanel,
                            child: Container(
                              width: _panelWidthAnimation.value,
                              height: 70,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF111E35),
                                    Color(0xFF05348A),
                                  ],
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _panelWidthAnimation.value > 50 
                                  ? _buildExpandedPanelContent()
                                  : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Список чатов
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _refreshChats(),
                    child: _buildChatListContent(),
                  ),
                ),
              ],
            ),
            
            // Поисковая строка (появляется снизу при скролле)
            if (_showSearch)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: _buildSimpleSearchBar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToLogin,
              child: const Text('Войти в систему'),
            ),
          ],
        ),
      );
    }

    if (_filteredChats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нет чатов',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Создайте новый чат',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) {
        final chat = _filteredChats[index];
        return ChatItem(
          chat: chat,
          onTap: () => _openChat(chat),
          onDelete: () => _deleteChat(chat),
        );
      },
    );
  }

  Widget _buildExpandedPanelContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //_buildPanelIcon(Icons.pets, 'Питомцы', Colors.orange, _openPets),
          _buildPanelIcon(Icons.person, 'Профиль', Colors.blue, _openProfile),
          //_buildPanelIcon(Icons.shopping_bag, 'Магазин', Colors.green, _openMarketplace),
        ],
      ),
    );
  }

  Widget _buildPanelIcon(IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          onTap();
          _togglePanel();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleSearchBar() {
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
          const SizedBox(width: 12),
          // Поле поиска
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
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