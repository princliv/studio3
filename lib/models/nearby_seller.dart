class NearbySeller {
  const NearbySeller({
    required this.username,
    this.name,
    this.profilePhotoUrl,
    this.location,
    required this.distanceKm,
  });

  final String username;
  final String? name;
  final String? profilePhotoUrl;
  final String? location;
  final double distanceKm;

  factory NearbySeller.fromJson(Map<String, dynamic> json) {
    return NearbySeller(
      username: json['username'] as String? ?? '',
      name: json['name'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      location: json['location'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    );
  }

  String get displayName =>
      (name != null && name!.isNotEmpty) ? name! : username;

  String get distanceDisplay => '${distanceKm.toStringAsFixed(1)} km away';
}
