class PieceSummary {
  const PieceSummary({
    required this.id,
    required this.title,
    this.mediaUrl,
    this.mediaType,
    this.caption,
    this.medium,
    this.isForSale = false,
    this.priceCents,
    this.dimensions,
    this.shippingRegion,
    this.likeCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.authorUsername,
    this.authorName,
  });

  final String id;
  final String title;
  final String? mediaUrl;
  final String? mediaType;
  final String? caption;
  final String? medium;
  final bool isForSale;
  final int? priceCents;
  final String? dimensions;
  final String? shippingRegion;
  final int likeCount;
  final bool isLiked;
  final bool isSaved;
  final String? authorUsername;
  final String? authorName;

  factory PieceSummary.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    return PieceSummary(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      caption: json['caption'] as String?,
      medium: json['medium'] as String?,
      isForSale: json['isForSale'] as bool? ?? false,
      priceCents: json['priceCents'] as int?,
      dimensions: json['dimensions'] as String?,
      shippingRegion: json['shippingRegion'] as String?,
      likeCount: _intFrom(json['likeCount'] ?? json['likes']),
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      authorUsername: author?['username'] as String? ??
          user?['username'] as String? ??
          json['authorUsername'] as String?,
      authorName: author?['name'] as String? ??
          user?['name'] as String? ??
          json['authorName'] as String?,
    );
  }

  static int _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  String? get priceDisplay {
    if (priceCents == null) return null;
    return '\$${(priceCents! / 100).toStringAsFixed(0)}';
  }
}
