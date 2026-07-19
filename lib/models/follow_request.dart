/// One pending follow request to the current user, from
/// `GET /api/users/follow-requests`.
class FollowRequest {
  const FollowRequest({
    required this.username,
    required this.name,
    this.profilePhotoUrl,
    required this.requestedAt,
  });

  final String username;
  final String name;
  final String? profilePhotoUrl;
  final DateTime requestedAt;

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      requestedAt: DateTime.tryParse(json['requestedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
