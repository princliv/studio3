import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_feed_tokens.dart';
import '../utils/scrolls_to_top_on_double_tap.dart';

/// Events tab placeholder — content ships later.
class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with ScrollsToTopOnDoubleTap<EventPage> {
  @override
  void scrollToTopAndRefresh() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        child: Center(
          child: Text(
            'Coming Soon',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: HomeFeedTokens.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
