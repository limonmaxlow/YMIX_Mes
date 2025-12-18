enum ShopItemType {
  profileCover,
  chatTheme,
  background,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String image;
  final ShopItemType type;
  final String? previewImage;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.type,
    this.previewImage,
  });
}