import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/post_location_options.dart';
import '../theme/home_feed_tokens.dart';
import 'post_picker_search_field.dart';

/// Draggable location picker — Figma 2019:2715.
/// Starts at ~1/3 screen; expands to ~88% when scrolled/dragged.
class ChooseLocationSheet extends StatefulWidget {
  const ChooseLocationSheet({
    super.key,
    required this.selectedIds,
    required this.onLocationSelected,
  });

  final Set<String> selectedIds;
  final ValueChanged<PostLocationOption> onLocationSelected;

  static Future<void> show(
    BuildContext context, {
    required Set<String> selectedIds,
    required ValueChanged<PostLocationOption> onLocationSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ChooseLocationSheet(
        selectedIds: selectedIds,
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  State<ChooseLocationSheet> createState() => _ChooseLocationSheetState();
}

class _ChooseLocationSheetState extends State<ChooseLocationSheet> {
  static const _sheetBg = Color(0xFF231F1B);
  static const _handleColor = Color(0xFF4A4843);

  static const _initialSize = 0.33;
  static const _maxSize = 0.88;

  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PostLocationOption> get _filtered {
    if (_query.isEmpty) return PostLocationOptions.all;
    final q = _query.toLowerCase();
    return PostLocationOptions.all
        .where(
          (loc) =>
              loc.name.toLowerCase().contains(q) ||
              loc.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _initialSize,
      minChildSize: _initialSize,
      maxChildSize: _maxSize,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: _sheetBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 82,
                height: 4,
                decoration: BoxDecoration(
                  color: _handleColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add location',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HomeFeedTokens.textInverse,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                child: PostPickerSearchField(
                  controller: _searchController,
                  hintText: 'Search locations',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 24),
                  itemCount: _filtered.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    final location = _filtered[index];
                    final selected = widget.selectedIds.contains(location.id);
                    return _LocationListTile(
                      location: location,
                      selected: selected,
                      onTap: () {
                        widget.onLocationSelected(location);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationListTile extends StatelessWidget {
  const _LocationListTile({
    required this.location,
    required this.selected,
    required this.onTap,
  });

  static const _textSecondary = Color(0xFF8C8880);

  final PostLocationOption location;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: HomeFeedTokens.textInverse,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
