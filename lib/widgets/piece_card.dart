import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class PieceCard extends StatefulWidget {
  const PieceCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.storyPreview,
    required this.artistName,
    this.medium,
    this.forSale = false,
    this.price,
    this.isProcess = false,
  });

  final String? imageUrl;
  final String title;
  final String? storyPreview;
  final String artistName;
  final String? medium;
  final bool forSale;
  final String? price;
  final bool isProcess;

  @override
  State<PieceCard> createState() => _PieceCardState();
}

class _PieceCardState extends State<PieceCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: AppColors.slate100,
                  child: widget.imageUrl != null
                      ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                      : null,
                ),
              ),
              if (widget.isProcess)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'Process',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassDark(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.slate400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.artistName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            if (widget.medium != null)
                              Text(
                                widget.medium!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slate300,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _saved ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.white,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _saved = !_saved),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
                if (widget.storyPreview != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.storyPreview!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 20, color: AppColors.slate400),
                    const SizedBox(width: 12),
                    Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.slate400),
                    const Spacer(),
                    if (widget.forSale && widget.price != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.slate900,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '\$${widget.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
