import 'piece_summary.dart';

class UserProfile {
  const UserProfile({
    required this.username,
    required this.name,
    this.email,
    this.bio,
    this.location,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.role,
    this.onboardingComplete = false,
    this.sellerEnabled = false,
    this.canChangeUsername = true,
    this.followingCount = 0,
    this.followersCount = 0,
    this.piecesCount = 0,
    this.collectedCount = 0,
    this.savesCount = 0,
    this.isFollowing = false,
    this.tastePreferences,
    this.savedPieces = const [],
  });

  final String username;
  final String name;
  final String? email;
  final String? bio;
  final String? location;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final String? role;
  final bool onboardingComplete;
  final bool sellerEnabled;
  final bool canChangeUsername;
  final int followingCount;
  final int followersCount;
  final int piecesCount;
  final int collectedCount;
  final int savesCount;
  final bool isFollowing;
  final Map<String, dynamic>? tastePreferences;
  final List<PieceSummary> savedPieces;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      role: json['role'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      sellerEnabled: json['sellerEnabled'] as bool? ??
          json['isSeller'] as bool? ??
          false,
      canChangeUsername: json['canChangeUsername'] as bool? ?? true,
      followingCount: _intFrom(json['followingCount'] ?? json['following']),
      followersCount: _intFrom(json['followersCount'] ?? json['followers']),
      piecesCount: _intFrom(json['piecesCount'] ?? json['pieces']),
      collectedCount: _intFrom(json['collectedCount'] ?? json['collected']),
      savesCount: _intFrom(json['savesCount'] ?? json['saves']),
      isFollowing: json['isFollowing'] as bool? ?? false,
      tastePreferences: json['tastePreferences'] as Map<String, dynamic>?,
      savedPieces: _parseSavedPieces(json),
    );
  }

  static int _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static List<PieceSummary> _parseSavedPieces(Map<String, dynamic> json) {
    final candidates = [
      json['savedPieces'],
      json['collectedPieces'],
      json['saved'],
    ];
    for (final list in candidates) {
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(PieceSummary.fromJson)
            .toList();
      }
    }
    return const [];
  }

  String get handle => '@$username';

  String get followingFollowers =>
      '$followingCount following · $followersCount followers';
}

class SellerStatus {
  const SellerStatus({
    required this.enabled,
    this.location,
  });

  final bool enabled;
  final String? location;

  factory SellerStatus.fromJson(Map<String, dynamic> json) {
    return SellerStatus(
      enabled: json['enabled'] as bool? ??
          json['sellerEnabled'] as bool? ??
          json['isSeller'] as bool? ??
          false,
      location: json['location'] as String? ?? json['sellerLocation'] as String?,
    );
  }
}

class SellerAnalytics {
  const SellerAnalytics({
    this.savesCount,
    this.likesCount,
    this.inquiriesCount,
    this.salesCount,
    this.period,
  });

  final int? savesCount;
  final int? likesCount;
  final int? inquiriesCount;
  final int? salesCount;
  final String? period;

  factory SellerAnalytics.fromJson(Map<String, dynamic> json) {
    return SellerAnalytics(
      savesCount: json['savesCount'] as int?,
      likesCount: json['likesCount'] as int?,
      inquiriesCount: json['inquiriesCount'] as int?,
      salesCount: json['salesCount'] as int?,
      period: json['period'] as String?,
    );
  }
}
