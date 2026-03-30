import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/feed_row.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/feed_layout_generator.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import 'artwork_detail_page.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  static const int _initialBatch = 16;
  static const int _loadMoreCount = 10;
  static const double _loadMoreThreshold = 200;

  final FeedLayoutGenerator _generator = FeedLayoutGenerator();
  final ScrollController _scrollController = ScrollController();
  final List<FeedRowModel> _rows = [];
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _rows.addAll(_generator.nextBatch(_initialBatch));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore) return;
    final pos = _scrollController.position;
    if (!pos.hasPixels || !pos.hasViewportDimension) return;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() {
      _loadingMore = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _rows.addAll(_generator.nextBatch(_loadMoreCount));
        _loadingMore = false;
      });
    });
  }

  void _openDetail(String imageUrl, FeedCardData data) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ArtworkDetailPage(
          imageUrl: imageUrl,
          artistName: data.artist.name,
          medium: data.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 100;

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HomeFeedTokens.sideMargin,
                8,
                HomeFeedTokens.sideMargin,
                12,
              ),
              child: Row(
                children: [
                  const _Studio3BrandTitle(),
                  const Spacer(),
                  Material(
                    color: const Color(0xFF1A1A1A),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: HomeFeedTokens.textInverse,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: bottomInset),
                itemCount: _rows.length + (_loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _rows.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: HomeFeedTokens.rowGap),
                    child: FeedRowView(
                      model: _rows[index],
                      onImageTap: _openDetail,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Studio3BrandTitle extends StatelessWidget {
  const _Studio3BrandTitle();

  static const String _text = 'Studio 3';

  @override
  Widget build(BuildContext context) {
    final fillStyle = GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: HomeFeedTokens.textPrimary,
      height: 1.05,
      shadows: const [
        Shadow(
          offset: Offset(0, 4),
          blurRadius: 4,
          color: Color(0x40000000),
        ),
      ],
    );

    return Stack(
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.none,
      children: [
        Text(
          _text,
          style: fillStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = Colors.black,
          ),
        ),
        Text(_text, style: fillStyle),
      ],
    );
  }
}
