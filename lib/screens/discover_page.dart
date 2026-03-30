import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String _filter = 'All';
  final _filters = ['All', 'Painting', 'Sculpture', 'Photography', 'Digital', 'Available'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 20, color: AppColors.slate500),
                            const SizedBox(width: 8),
                            Text('Search', style: TextStyle(fontSize: 14, color: AppColors.slate500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.tune), onPressed: () {}, color: AppColors.slate700),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final active = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f),
                        selected: active,
                        onSelected: (_) => setState(() => _filter = f),
                        backgroundColor: AppColors.slate100,
                        selectedColor: AppColors.slate900,
                        labelStyle: TextStyle(color: active ? AppColors.white : AppColors.slate600, fontSize: 13),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Studio 3 Picks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                    TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(fontSize: 13, color: AppColors.slate500))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  itemBuilder: (context, i) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.slate900.withOpacity(0.55),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                              ),
                              child: Text('Piece ${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Process Spotlight', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.slate900)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  childCount: 4,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Voices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                    Text('See all', style: TextStyle(fontSize: 13, color: AppColors.slate500)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: ['Maya K.', 'James T.', 'Riley W.'].asMap().entries.map((e) {
                    final following = e.key == 0;
                    return SizedBox(
                      width: 200,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: following ? AppColors.slate900 : AppColors.slate200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          CircleAvatar(radius: 18, backgroundColor: AppColors.slate300),
                          const SizedBox(width: 10),
                          Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: following ? AppColors.slate900 : Colors.transparent,
                              foregroundColor: following ? AppColors.white : AppColors.slate700,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(following ? 'Following' : 'Follow'),
                          ),
                        ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
