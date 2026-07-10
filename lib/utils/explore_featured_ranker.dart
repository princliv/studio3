import '../models/feed_item.dart';
import '../models/user_profile.dart';

class ExploreFeaturedRanker {
  static FeedItem? pickFeatured(
    List<FeedItem> items, {
    UserProfile? profile,
    String? excludeId,
  }) {
    final candidates = items
        .where((item) => excludeId == null || item.id != excludeId)
        .toList();
    if (candidates.isEmpty) return null;

    FeedItem? best;
    var bestScore = -1.0;

    for (final item in candidates) {
      final score = _score(item, profile);
      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }

    return best;
  }

  static double _score(FeedItem item, UserProfile? profile) {
    var score = 0.0;

    if (item.type == FeedItemType.piece && item.piece != null) {
      final piece = item.piece!;
      if (piece.isLiked) score += 40;
      if (piece.isSaved) score += 35;
      if (piece.isForSale) score += 5;

      final medium = piece.medium?.toLowerCase() ?? '';
      if (medium.isNotEmpty) {
        score += _preferenceMatch(medium, profile?.tastePreferences?['mediums']);
      }
    } else if (item.post != null) {
      final post = item.post!;
      if (post.isLiked) score += 40;
      if (post.isSaved) score += 35;
    }

    if (profile != null) {
      final author = item.authorName?.toLowerCase() ?? '';
      for (final saved in profile.savedPieces) {
        if (saved.authorName?.toLowerCase() == author && author.isNotEmpty) {
          score += 20;
          break;
        }
      }
    }

    score += item.id.hashCode.abs() % 7;
    return score;
  }

  static double _preferenceMatch(String value, dynamic prefs) {
    if (prefs is! List) return 0;
    for (final pref in prefs) {
      final p = pref.toString().toLowerCase();
      if (value.contains(p) || p.contains(value)) return 25;
    }
    return 0;
  }
}
