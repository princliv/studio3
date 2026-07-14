import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/glass_card.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inquiries = [
    (pieceTitle: 'Coastal Forms #3', subject: 'Purchase inquiry', preview: "Hi, I'm interested in this piece...", time: '2h', unread: true),
    (pieceTitle: 'Untitled (Series 12)', subject: 'Commission', preview: 'Would you consider a similar...', time: '1d', unread: false),
  ];
  int? _selectedIndex;
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Inquiries',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: _inquiries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mail_outline, size: 48, color: AppColors.slate200),
                          const SizedBox(height: AppDims.spaceMd),
                          Text(
                            'No inquiries yet',
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _inquiries.length,
                      itemBuilder: (context, i) {
                        final inq = _inquiries[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDims.spaceSm),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _selectedIndex = i),
                              borderRadius: BorderRadius.circular(AppDims.radiusMd),
                              child: GlassCard(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.slate100,
                                        borderRadius: BorderRadius.circular(AppDims.radiusSm),
                                      ),
                                    ),
                                    const SizedBox(width: AppDims.spaceSm + 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            inq.pieceTitle,
                                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900),
                                          ),
                                          Text(
                                            '${inq.subject} — ${inq.preview}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          inq.time,
                                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
                                        ),
                                        if (inq.unread) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.slate900),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomSheet: _selectedIndex != null
          ? _InquiryBottomSheet(
              inquiry: _inquiries[_selectedIndex!],
              replyController: _replyController,
              onClose: () => setState(() => _selectedIndex = null),
            )
          : null,
    );
  }
}

class _InquiryBottomSheet extends StatelessWidget {
  const _InquiryBottomSheet({
    required this.inquiry,
    required this.replyController,
    required this.onClose,
  });

  final ({String pieceTitle, String subject, String preview, String time, bool unread}) inquiry;
  final TextEditingController replyController;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDims.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDims.radiusXl)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(AppDims.radiusSm),
                ),
              ),
              const SizedBox(width: AppDims.spaceSm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.pieceTitle,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(9999)),
                      child: Text(
                        inquiry.subject,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate600),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: AppDims.spaceMd),
          Text(
            inquiry.preview,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate700),
          ),
          const SizedBox(height: AppDims.spaceMd),
          TextField(
            controller: replyController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate900),
            decoration: InputDecoration(
              hintText: 'Reply...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDims.radiusMd)),
            ),
          ),
          const SizedBox(height: AppDims.spaceSm + 4),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.slate900,
              minimumSize: const Size.fromHeight(AppDims.primaryButtonHeight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }
}
