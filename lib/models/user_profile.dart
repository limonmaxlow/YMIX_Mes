class UserProfile {
  final String name;
  final String username;
  final String bio;
  final int contacts;
  final int points;
  final int days;
  final bool isOnline;

  UserProfile({
    required this.name,
    required this.username,
    required this.bio,
    required this.contacts,
    required this.points,
    required this.days,
    required this.isOnline,
  });
}