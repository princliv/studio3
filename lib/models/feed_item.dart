import 'piece_summary.dart';
import 'post_summary.dart';

/// Unified feed row from following/explore/for-you endpoints.
class FeedItem {
  const FeedItem.piece(this.piece) : post = null, type = FeedItemType.piece;

  const FeedItem.post(this.post) : piece = null, type = FeedItemType.post;

  final FeedItemType type;
  final PieceSummary? piece;
  final PostSummary? post;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final kind = json['type'] as String? ?? json['contentType'] as String?;
    if (kind == 'post' || json.containsKey('pieceId')) {
      return FeedItem.post(PostSummary.fromJson(json));
    }
    return FeedItem.piece(PieceSummary.fromJson(json));
  }

  String get id => type == FeedItemType.piece ? piece!.id : post!.id;

  String? get mediaUrl =>
      type == FeedItemType.piece ? piece!.mediaUrl : post!.mediaUrl;

  String? get title =>
      type == FeedItemType.piece ? piece!.title : post!.caption;

  String? get authorName =>
      type == FeedItemType.piece ? piece!.authorName : post!.authorName;

  bool get isForSale =>
      type == FeedItemType.piece ? (piece?.isForSale ?? false) : false;

  String? get priceDisplay =>
      type == FeedItemType.piece ? piece?.priceDisplay : null;
}

enum FeedItemType { piece, post }

class CommentSummary {
  const CommentSummary({
    required this.id,
    required this.body,
    this.authorUsername,
    this.authorName,
    this.createdAt,
  });

  final String id;
  final String body;
  final String? authorUsername;
  final String? authorName;
  final String? createdAt;

  factory CommentSummary.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    return CommentSummary(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      authorUsername: author?['username'] as String? ??
          user?['username'] as String?,
      authorName:
          author?['name'] as String? ?? user?['name'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
