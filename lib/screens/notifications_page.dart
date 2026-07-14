import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/glass_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _items = [
    (type: 'save', name: 'Alex Chen', text: "saved your piece 'Coastal Forms #3'", time: '2h', thumb: true, sale: false),
    (type: 'follow', name: 'Riley W.', text: 'started following you', time: '5h', thumb: false, sale: false),
    (type: 'inquiry', name: 'Jordan Lee', text: 'sent an inquiry about Untitled #12', time: '1d', thumb: true, sale: false),
    (type: 'purchase', name: 'Sam Rivera', text: "purchased 'Coastal Forms #3'", time: '2d', thumb: true, sale: true),
  ];

  @override
  Widget build(BuildContext context) {
    final today = _items.where((a) => a.time.endsWith('h')).toList();
    final week = _items.where((a) => a.time.endsWith('d')).toList();

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Activity',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'No activity yet',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.slate400,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        if (today.isNotEmpty) ...[
                          _SectionLabel('Today'),
                          ...today.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ActivityCard(item: item),
                              )),
                          const SizedBox(height: 8),
                        ],
                        if (week.isNotEmpty) ...[
                          _SectionLabel('This Week'),
                          ...week.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ActivityCard(item: item),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.slate400,
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final ({String type, String name, String text, String time, bool thumb, bool sale}) item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 18, backgroundColor: AppColors.slate200),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${item.name} ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
                Text(
                  item.text,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate700),
                ),
                if (item.type == 'inquiry') ...[
                  const SizedBox(width: 6),
                  _Pill(label: 'Inquiry', background: AppColors.slate100, textColor: AppColors.slate600),
                ],
                if (item.sale) ...[
                  const SizedBox(width: 6),
                  _Pill(label: 'Sale', background: AppColors.slate900, textColor: AppColors.white, bold: true),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.time,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
              ),
              if (item.thumb) ...[
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(AppDims.radiusSm),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.textColor,
    this.bold = false,
  });

  final String label;
  final Color background;
  final Color textColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}
