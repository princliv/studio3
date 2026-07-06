import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/social_service.dart';
import '../theme/home_feed_tokens.dart';

/// Detail view for a piece or post from feeds.
class ArtworkDetailPage extends StatefulWidget {
  const ArtworkDetailPage({
    super.key,
    required this.imageUrl,
    this.artistName,
    this.medium,
    this.pieceId,
    this.postId,
    this.title,
    this.forSale = false,
    this.price,
  });

  final String imageUrl;
  final String? artistName;
  final String? medium;
  final String? pieceId;
  final String? postId;
  final String? title;
  final bool forSale;
  final String? price;

  @override
  State<ArtworkDetailPage> createState() => _ArtworkDetailPageState();
}

class _ArtworkDetailPageState extends State<ArtworkDetailPage> {
  final _commentController = TextEditingController();
  bool _liked = false;
  bool _saved = false;
  bool _busy = false;

  bool get _isPiece => widget.pieceId != null;

  Future<void> _toggleLike() async {
    if (_busy || (!_isPiece && widget.postId == null)) return;
    setState(() => _busy = true);
    try {
      if (_isPiece) {
        if (_liked) {
          await SocialService.instance.unlikePiece(widget.pieceId!);
        } else {
          await SocialService.instance.likePiece(widget.pieceId!);
        }
      } else {
        if (_liked) {
          await SocialService.instance.unlikePost(widget.postId!);
        } else {
          await SocialService.instance.likePost(widget.postId!);
        }
      }
      if (mounted) setState(() => _liked = !_liked);
    } catch (_) {}
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _toggleSave() async {
    if (_busy || (!_isPiece && widget.postId == null)) return;
    setState(() => _busy = true);
    try {
      if (_isPiece) {
        if (_saved) {
          await SocialService.instance.unsavePiece(widget.pieceId!);
        } else {
          await SocialService.instance.savePiece(widget.pieceId!);
        }
      } else {
        if (_saved) {
          await SocialService.instance.unsavePost(widget.postId!);
        } else {
          await SocialService.instance.savePost(widget.postId!);
        }
      }
      if (mounted) setState(() => _saved = !_saved);
    } catch (_) {}
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _postComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _busy) return;
    if (!_isPiece && widget.postId == null) return;
    setState(() => _busy = true);
    try {
      if (_isPiece) {
        await SocialService.instance.commentOnPiece(widget.pieceId!, body);
      } else {
        await SocialService.instance.commentOnPost(widget.postId!, body);
      }
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Comment posted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      appBar: AppBar(
        backgroundColor: HomeFeedTokens.background,
        foregroundColor: HomeFeedTokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleLike,
          ),
          IconButton(
            icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              ),
            ),
            if (widget.title != null && widget.title!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.title!,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ],
            if (widget.artistName != null || widget.medium != null) ...[
              const SizedBox(height: 8),
              if (widget.artistName != null)
                Text(
                  widget.artistName!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HomeFeedTokens.textPrimary,
                  ),
                ),
              if (widget.medium != null)
                Text(
                  widget.medium!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: HomeFeedTokens.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
            ],
            if (widget.forSale && widget.price != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.price!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
