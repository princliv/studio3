/// A location result for the create-post flow, sourced from live search
/// (see `LocationSearchService`) rather than a fixed list.
class PostLocationOption {
  const PostLocationOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.displayName,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String subtitle;

  /// Full human-readable place name — what's actually sent to the backend
  /// and shown on the piece/scene detail page.
  final String displayName;
  final double? lat;
  final double? lng;

  /// Parses a Nominatim `/search` or `/reverse` (jsonv2) result.
  factory PostLocationOption.fromNominatim(Map<String, dynamic> json) {
    final displayName = (json['display_name'] as String?)?.trim() ?? '';
    final parts = displayName
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final rawName = json['name'] as String?;
    final name = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (parts.isNotEmpty ? parts.first : 'Unknown location');
    final subtitle = parts.length > 1
        ? parts.sublist(1).join(', ')
        : displayName;
    return PostLocationOption(
      id: json['place_id']?.toString() ?? displayName,
      name: name,
      subtitle: subtitle,
      displayName: displayName.isNotEmpty ? displayName : name,
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      lng: double.tryParse(json['lon']?.toString() ?? ''),
    );
  }
}
