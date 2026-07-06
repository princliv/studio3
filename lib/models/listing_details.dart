import 'dart:convert';

/// Listing-specific fields collected in the listing details step.
class ListingDetails {
  const ListingDetails({
    this.priceUsd,
    this.width,
    this.height,
    this.depth,
    this.dimensionUnit = 'in',
    this.nonStandardFormat = false,
    this.nonStandardDescription,
    this.framingMounting,
    this.location,
    this.provenance,
    this.yearCreated,
    this.handlingNotes,
  });

  final double? priceUsd;
  final double? width;
  final double? height;
  final double? depth;
  final String dimensionUnit;
  final bool nonStandardFormat;
  final String? nonStandardDescription;
  final String? framingMounting;
  final String? location;
  final String? provenance;
  final int? yearCreated;
  final String? handlingNotes;

  int? get priceCents =>
      priceUsd == null ? null : (priceUsd! * 100).round();

  String? get dimensionsString {
    if (nonStandardFormat) {
      return nonStandardDescription?.trim().isNotEmpty == true
          ? 'non-standard: ${nonStandardDescription!.trim()}'
          : 'non-standard';
    }
    if (width == null && height == null && depth == null) return null;
    final w = width?.toString() ?? '?';
    final h = height?.toString() ?? '?';
    final d = depth?.toString() ?? '?';
    return '${w}x${h}x$d $dimensionUnit';
  }

  /// Extra listing metadata serialized into caption until backend adds fields.
  String buildCaptionExtras({String? baseCaption}) {
    final extras = <String, dynamic>{
      if (framingMounting?.trim().isNotEmpty == true)
        'framingMounting': framingMounting!.trim(),
      if (provenance?.trim().isNotEmpty == true)
        'provenance': provenance!.trim(),
      if (yearCreated != null) 'yearCreated': yearCreated,
      if (handlingNotes?.trim().isNotEmpty == true)
        'handlingNotes': handlingNotes!.trim(),
      if (nonStandardFormat) 'nonStandardFormat': true,
    };
    if (extras.isEmpty) return baseCaption ?? '';
    final block = '---listing---\n${jsonEncode(extras)}';
    if (baseCaption == null || baseCaption.trim().isEmpty) return block;
    return '${baseCaption.trim()}\n\n$block';
  }
}
