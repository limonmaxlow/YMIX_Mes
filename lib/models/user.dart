class User {
  final String id;
  final String name;
  final String username;
  final int points;
  final List<String> inventory;
  final String? profileImage;
  final bool isOnline;
  final String? email;
  final String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.points,
    required this.inventory,
    this.profileImage,
    this.isOnline = true,
    this.email,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['username'] ?? '', // Используем username как name
      username: json['username'] ?? '',
      points: json['points'] ?? 0,
      inventory: List<String>.from(json['inventory'] ?? []),
      profileImage: json['profileImage'],
      isOnline: json['isOnline'] ?? true,
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    int? points,
    List<String>? inventory,
    String? profileImage,
    bool? isOnline,
    String? email,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      points: points ?? this.points,
      inventory: inventory ?? this.inventory,
      profileImage: profileImage ?? this.profileImage,
      isOnline: isOnline ?? this.isOnline,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}