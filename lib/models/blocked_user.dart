/// One row from `GET /api/users/blocked`.
class BlockedUser {
  const BlockedUser({
    required this.username,
    required this.name,
    this.profilePhotoUrl,
  });

  final String username;
  final String name;
  final String? profilePhotoUrl;

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}
