import '../models/feed_item.dart';

/// A request to jump the already-mounted Reels tab to a specific video.
class ReelsJumpRequest {
  const ReelsJumpRequest({required this.items, required this.index});

  final List<FeedItem> items;
  final int index;
}

/// Bridges "open this video" call sites (Explore, Home, Profile, piece
/// detail, Saved — see `lib/utils/reels_route.dart`) to `MainShell`'s own
/// Reels tab, so opening a video switches tabs in place (keeping the bottom
/// nav bar visible) instead of pushing a full-screen route on top of it.
///
/// A plain singleton rather than an `InheritedWidget` because `Navigator.push`
/// inserts routes as siblings in the same Navigator, not descendants of
/// `MainShell`'s widget subtree — a pushed page several routes deep (e.g. a
/// piece detail page) couldn't look one up via `context` regardless of
/// nesting, matching this app's existing `AuthSession.instance`/
/// `SocialService.instance` singleton-service convention.
class ReelsTabService {
  ReelsTabService._();
  static final instance = ReelsTabService._();

  void Function(List<FeedItem> items, int index)? _handler;

  void register(void Function(List<FeedItem> items, int index) handler) {
    _handler = handler;
  }

  void unregister() {
    _handler = null;
  }

  /// Returns true if a mounted `MainShell` handled the request in-place;
  /// false if none is mounted, so the caller should fall back to pushing a
  /// standalone `ReelsPage` route.
  bool tryOpen(List<FeedItem> items, int index) {
    final handler = _handler;
    if (handler == null) return false;
    handler(items, index);
    return true;
  }
}
