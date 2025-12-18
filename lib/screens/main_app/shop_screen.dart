import 'package:flutter/material.dart';
import 'package:ymix_messenger/models/user.dart';
import 'package:ymix_messenger/models/shop_item.dart';

class ShopScreen extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdate;

  const ShopScreen({Key? key, required this.user, required this.onUserUpdate}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late User _currentUser;
  final List<ShopItem> _shopItems = [];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _initializeShopItems();
  }

  void _initializeShopItems() {
    // Шапки профиля
    _shopItems.addAll([
      ShopItem(
        id: '4',
        name: 'Город ночью',
        description: 'Ночной город с огнями',
        price: 600,
        image: '🌃',
        type: ShopItemType.profileCover,
        previewImage: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=400',
      ),
      ShopItem(
        id: '5',
        name: 'Горы',
        description: 'Живописный горный пейзаж',
        price: 550,
        image: '⛰️',
        type: ShopItemType.profileCover,
        previewImage: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      ),
      ShopItem(
        id: '6',
        name: 'Космос',
        description: 'Глубокий космос с туманностями',
        price: 700,
        image: '🌌',
        type: ShopItemType.profileCover,
        previewImage: 'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=400',
      ),
    ]);

    // Темы чатов
    _shopItems.addAll([
      ShopItem(
        id: '1',
        name: 'Космическая тема',
        description: 'Тёмная тема с звёздами и планетами',
        price: 500,
        image: '🚀',
        type: ShopItemType.chatTheme,
        previewImage: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=400',
      ),
      ShopItem(
        id: '2',
        name: 'Неоновая тема',
        description: 'Яркие неоновые цвета для чатов',
        price: 300,
        image: '💡',
        type: ShopItemType.chatTheme,
        previewImage: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400',
      ),
    ]);

    // Фоны
    _shopItems.addAll([
      ShopItem(
        id: '7',
        name: 'Абстракция',
        description: 'Абстрактный градиентный фон',
        price: 250,
        image: '🎨',
        type: ShopItemType.background,
        previewImage: 'https://images.unsplash.com/photo-1579546929662-711aa81148cf?w=400',
      ),
      ShopItem(
        id: '8',
        name: 'Минимализм',
        description: 'Чистый минималистичный фон',
        price: 200,
        image: '⚪',
        type: ShopItemType.background,
        previewImage: 'https://images.unsplash.com/photo-1557683316-973673baf926?w=400',
      ),
    ]);
  }

  List<ShopItem> get _filteredItems {
    if (_selectedCategory == 0) return _shopItems;
    final type = ShopItemType.values[_selectedCategory - 1];
    return _shopItems.where((item) => item.type == type).toList();
  }

  bool _isItemPurchased(ShopItem item) {
    return _currentUser.inventory.contains(item.id);
  }

  void _purchaseItem(ShopItem item) {
    if (_currentUser.points >= item.price) {
      setState(() {
        _currentUser = _currentUser.copyWith(
          points: _currentUser.points - item.price,
          inventory: [..._currentUser.inventory, item.id],
        );
      });
      
      widget.onUserUpdate(_currentUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} куплен!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Недостаточно очков! Нужно ещё ${item.price - _currentUser.points} очков.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _equipItem(ShopItem item) {
    if (!_isItemPurchased(item)) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} применен!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Магазин', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                SizedBox(width: 5),
                Text(
                  '${_currentUser.points}',
                  style: TextStyle(color: Colors.amber, fontSize: 16),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Информация о системе очков
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[900]?.withOpacity(0.3),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Получайте 1 очко за каждое отправленное сообщение!',
                    style: TextStyle(color: Colors.blue[100], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Категории
          Container(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 16),
                _CategoryChip(
                  title: 'Все',
                  isSelected: _selectedCategory == 0,
                  onTap: () => setState(() => _selectedCategory = 0),
                ),
                _CategoryChip(
                  title: 'Шапки',
                  isSelected: _selectedCategory == 1,
                  onTap: () => setState(() => _selectedCategory = 1),
                ),
                _CategoryChip(
                  title: 'Темы чатов',
                  isSelected: _selectedCategory == 2,
                  onTap: () => setState(() => _selectedCategory = 2),
                ),
                _CategoryChip(
                  title: 'Фоны',
                  isSelected: _selectedCategory == 3,
                  onTap: () => setState(() => _selectedCategory = 3),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          Divider(color: Colors.grey[700]),
          
          // Список товаров
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'Товары не найдены',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isPurchased = _isItemPurchased(item);
                      
                      return _ShopItemCard(
                        item: item,
                        isPurchased: isPurchased,
                        onPurchase: () => _purchaseItem(item),
                        onEquip: () => _equipItem(item),
                        userPoints: _currentUser.points,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(title, style: TextStyle(color: Colors.white)),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[800],
        selectedColor: Colors.blue,
        checkmarkColor: Colors.white,
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool isPurchased;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;
  final int userPoints;

  const _ShopItemCard({
    required this.item,
    required this.isPurchased,
    required this.onPurchase,
    required this.onEquip,
    required this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.previewImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.previewImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.image,
                                  style: TextStyle(fontSize: 30),
                                ),
                                Text(
                                  'Ошибка загрузки',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        item.image,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
            ),
            SizedBox(height: 8),
            
            // Название и описание
            Text(
              item.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(color: Colors.grey, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            
            // Цена и кнопки
            Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '${item.price}',
                  style: TextStyle(color: Colors.amber, fontSize: 14),
                ),
                Spacer(),
                if (isPurchased)
                  ElevatedButton(
                    onPressed: onEquip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Выбрать',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: userPoints >= item.price ? onPurchase : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userPoints >= item.price ? Colors.blue : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Купить',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}