import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _items = [
    (type: 'save', name: 'Alex Chen', text: "saved your piece **'Coastal Forms #3'**", time: '2h', thumb: true, sale: false),
    (type: 'follow', name: 'Riley W.', text: 'started following you', time: '5h', thumb: false, sale: false),
    (type: 'inquiry', name: 'Jordan Lee', text: 'sent an inquiry about **Untitled #12**', time: '1d', thumb: true, sale: false),
    (type: 'purchase', name: 'Sam Rivera', text: 'purchased **Coastal Forms #3**', time: '2d', thumb: true, sale: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Activity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.slate900)),
            ),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No activity yet', style: TextStyle(fontSize: 14, color: AppColors.slate400)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(radius: 18, backgroundColor: AppColors.slate200),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('${item.name} ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                                    Text(item.text.replaceAll('**', ''), style: const TextStyle(fontSize: 14, color: AppColors.slate700)),
                                    if (item.type == 'inquiry') ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.slate100,
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: const Text('Inquiry', style: TextStyle(fontSize: 11, color: AppColors.slate600)),
                                      ),
                                    ],
                                    if (item.sale) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.slate900,
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: const Text('Sale', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.white)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(item.time, style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
                                  if (item.thumb) const SizedBox(height: 4),
                                  if (item.thumb) Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(8)),
                                  ),
                                ],
                              ),
                            ],
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
