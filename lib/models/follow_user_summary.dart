/// One row from `GET /api/users/:username/followers` or `.../following`.
class FollowUserSummary {
  const FollowUserSummary({
    required this.username,
    required this.name,
    this.profilePhotoUrl,
  });

  final String username;
  final String name;
  final String? profilePhotoUrl;

  factory FollowUserSummary.fromJson(Map<String, dynamic> json) {
    return FollowUserSummary(
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}

/// Cursor-paginated followers/following list.
class FollowUserPage {
  const FollowUserPage({
    required this.items,
    this.nextCursor,
  });

  final List<FollowUserSummary> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
