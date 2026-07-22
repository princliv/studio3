import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/feed_item.dart';
import '../../services/saved_content_store.dart';
import '../../services/social_service.dart';
import '../../utils/profile_navigation.dart';
import '../profile_avatar.dart';
import 'scene_video_comment_sheet.dart';

class ReelOverlay extends StatefulWidget {
  const ReelOverlay({
    super.key,
    required this.item,
    this.bottomPadding = 96,
  });

  final FeedItem item;
  final double bottomPadding;

  @override
  State<ReelOverlay> createState() => _ReelOverlayState();
}

class _ReelOverlayState extends State<ReelOverlay> {
  late bool _liked;
  late bool _saved;
  late int _likeCount;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    final post = widget.item.post;
    final postId = post?.id;
    _liked = post?.isLiked ?? false;
    _saved = postId != null
        ? SavedContentStore.instance.isSaved(postId) ||
            (post?.isSaved ?? false)
        : false;
    _likeCount = post?.likeCount ?? 0;
    _commentCount = 0;
  }

  Future<void> _toggleLike() async {
    final postId = widget.item.post?.id;
    if (postId == null) return;
    final nextLiked = !_liked;
    setState(() {
      _liked = nextLiked;
      _likeCount += nextLiked ? 1 : -1;
    });
    try {
      if (nextLiked) {
        await SocialService.instance.likePost(postId);
      } else {
        await SocialService.instance.unlikePost(postId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _liked = !nextLiked;
        _likeCount += nextLiked ? -1 : 1;
      });
    }
  }

  Future<void> _openComments() async {
    final postId = widget.item.post?.id;
    if (postId == null) return;
    final posted = await SceneVideoCommentSheet.show(
      context,
      postId: postId,
      authorName: widget.item.authorName ?? 'Artist',
    );
    if (!mounted || posted != true) return;
    setState(() => _commentCount += 1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment posted')),
    );
  }

  Future<void> _shareScene() async {
    final post = widget.item.post;
    final author = widget.item.authorName ?? 'an artist';
    final caption = post?.caption?.trim();
    final mediaUrl = widget.item.mediaUrl;
    final lines = <String>[
      'Scene by $author on Studio',
      if (caption != null && caption.isNotEmpty) caption,
      if (mediaUrl != null && mediaUrl.isNotEmpty) mediaUrl,
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scene link copied')),
    );
  }

  Future<void> _toggleSave() async {
    final postId = widget.item.post?.id;
    if (postId == null) return;
    final nextSaved = !_saved;
    setState(() => _saved = nextSaved);
    if (nextSaved) {
      SavedContentStore.instance.saveFeedItem(widget.item);
    } else {
      SavedContentStore.instance.unsave(postId);
    }
    try {
      if (nextSaved) {
        await SocialService.instance.savePost(postId);
      } else {
        await SocialService.instance.unsavePost(postId);
      }
    } catch (_) {
      // Keep local saved state for scene videos when API is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.item.post;
    final authorName = widget.item.authorName ?? 'Artist';
    final authorUsername = widget.item.authorUsername;
    final caption = post?.caption ?? widget.item.title ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 12, widget.bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: authorUsername != null
                          ? () => openUserProfile(context, authorUsername)
                          : null,
                      behavior: authorUsername != null
                          ? HitTestBehavior.opaque
                          : HitTestBehavior.deferToChild,
                      child: ProfileAvatar(
                        url: null,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: authorUsername != null
                            ? () => openUserProfile(context, authorUsername)
                            : null,
                        behavior: authorUsername != null
                            ? HitTestBehavior.opaque
                            : HitTestBehavior.deferToChild,
                        child: Text(
                          authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (caption.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LikeActionButton(
                liked: _liked,
                label: _likeCount > 0 ? '$_likeCount' : 'Like',
                onTap: _toggleLike,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Colors.white,
                label: _commentCount > 0 ? '$_commentCount' : 'Comment',
                onTap: _openComments,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.ios_share_rounded,
                iconColor: Colors.white,
                label: 'Share',
                onTap: _shareScene,
              ),
              const SizedBox(height: 18),
              _SaveActionButton(
                saved: _saved,
                onTap: _toggleSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LikeActionButton extends StatelessWidget {
  const _LikeActionButton({
    required this.liked,
    required this.label,
    required this.onTap,
  });

  static const _likeRed = Color(0xFFFF3040);

  final bool liked;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(
            liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? _likeRed : Colors.white,
            size: 30,
            fill: liked ? 1 : 0,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveActionButton extends StatelessWidget {
  const _SaveActionButton({
    required this.saved,
    required this.onTap,
  });

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(
            saved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            size: 30,
            fill: saved ? 1 : 0,
          ),
          const SizedBox(height: 4),
          Text(
            'Save',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
