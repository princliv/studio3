import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/home_feed_dummy.dart';
import '../../../theme/home_feed_tokens.dart';
import '../models/profile_series_data.dart';
import '../profile_constants.dart';

class ProfileSeriesGrid extends StatelessWidget {
  const ProfileSeriesGrid({super.key, required this.items});

  final List<ProfileSeriesData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
        child: Center(
          child: Text(
            'Series with more than one piece will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: kProfileTextMuted,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    final left = <ProfileSeriesData>[];
    final right = <ProfileSeriesData>[];
    for (var i = 0; i < items.length; i++) {
      if (i.isEven) {
        left.add(items[i]);
      } else {
        right.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _SeriesColumn(series: left)),
        const SizedBox(width: kProfileGutter),
        Expanded(child: _SeriesColumn(series: right)),
      ],
    );
  }
}

class _SeriesColumn extends StatelessWidget {
  const _SeriesColumn({required this.series});

  final List<ProfileSeriesData> series;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < series.length; i++) ...[
          if (i > 0) const SizedBox(height: 18),
          _SeriesGridCard(data: series[i]),
        ],
      ],
    );
  }
}

class _SeriesGridCard extends StatelessWidget {
  const _SeriesGridCard({required this.data});

  final ProfileSeriesData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StackedSeriesCovers(data: data, maxWidth: constraints.maxWidth),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${data.name} · ${data.pieceCount}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: HomeFeedTokens.textPrimary,
                  height: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StackedSeriesCovers extends StatelessWidget {
  const _StackedSeriesCovers({
    required this.data,
    required this.maxWidth,
  });

  final ProfileSeriesData data;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final seeds = data.stackSeeds;
    final n = seeds.length;
    final w = maxWidth.isFinite && maxWidth > 0 ? maxWidth : 180.0;
    final side = w * kSeriesCardSideFraction;
    final stackHeight = side + (n >= 2 ? 8.0 : 4.0);

    if (n == 0) {
      return SizedBox(
        width: w,
        height: side,
        child: const ColoredBox(color: Color(0xFFE8E6E1)),
      );
    }

    final radius = BorderRadius.circular(HomeFeedTokens.cardRadius);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final imgPx = (side * dpr).round().clamp(120, 900);

    final cards = <Widget>[];
    if (n == 1) {
      cards.add(
        Positioned(
          left: 0,
          top: 0,
          width: side,
          height: side,
          child: _SeriesPaletteCard(
            seed: seeds[0],
            borderRadius: radius,
            imagePx: imgPx,
            dropShadow: false,
          ),
        ),
      );
    } else {
      final step = (w - side) / (n - 1);
      for (var i = n - 1; i >= 0; i--) {
        cards.add(
          Positioned(
            left: i * step,
            top: 0,
            width: side,
            height: side,
            child: _SeriesPaletteCard(
              seed: seeds[i],
              borderRadius: radius,
              imagePx: imgPx,
              dropShadow: i != 0,
            ),
          ),
        );
      }
    }

    return SizedBox(
      width: w,
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: cards,
      ),
    );
  }
}

class _SeriesPaletteCard extends StatelessWidget {
  const _SeriesPaletteCard({
    required this.seed,
    required this.borderRadius,
    required this.imagePx,
    this.dropShadow = false,
  });

  final int seed;
  final BorderRadius borderRadius;
  final int imagePx;
  final bool dropShadow;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        picsumUrl(seed, imagePx, imagePx),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: Colors.grey.shade300,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HomeFeedTokens.textPrimary.withValues(alpha: 0.35),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: Colors.grey.shade300,
          child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
        ),
      ),
    );

    if (!dropShadow) return image;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            offset: const Offset(5, 2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: image,
    );
  }
}
