import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/post_media_assets.dart';
import '../models/listing_details.dart';
import '../services/api_exception.dart';
import '../services/post_publish_service.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/choose_location_sheet.dart';

/// Listing details step — final step for seller listing posts.
class ListingDetailsPage extends StatefulWidget {
  const ListingDetailsPage({super.key, required this.draft});

  final PostDraft draft;

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  static const _textSecondary = Color(0xFF8C8880);
  static const _neutral700 = Color(0xFF4A4843);
  static const _neutral300 = Color(0xFFC8C5BC);

  final _priceController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _depthController = TextEditingController();
  final _nonStandardController = TextEditingController();
  final _framingController = TextEditingController();
  final _provenanceController = TextEditingController();
  final _yearController = TextEditingController();
  final _handlingController = TextEditingController();

  String _dimensionUnit = 'in';
  bool _nonStandardFormat = false;
  String? _location;
  bool _publishing = false;

  @override
  void dispose() {
    _priceController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _depthController.dispose();
    _nonStandardController.dispose();
    _framingController.dispose();
    _provenanceController.dispose();
    _yearController.dispose();
    _handlingController.dispose();
    super.dispose();
  }

  ListingDetails _buildListingDetails() {
    return ListingDetails(
      priceUsd: double.tryParse(_priceController.text.trim()),
      width: double.tryParse(_widthController.text.trim()),
      height: double.tryParse(_heightController.text.trim()),
      depth: double.tryParse(_depthController.text.trim()),
      dimensionUnit: _dimensionUnit,
      nonStandardFormat: _nonStandardFormat,
      nonStandardDescription: _nonStandardController.text,
      framingMounting: _framingController.text,
      location: _location,
      provenance: _provenanceController.text,
      yearCreated: int.tryParse(_yearController.text.trim()),
      handlingNotes: _handlingController.text,
    );
  }

  Future<void> _createListing() async {
    setState(() => _publishing = true);
    try {
      final listing = _buildListingDetails();
      final draft = widget.draft.copyWith(
        postType: 'listing',
        listingDetails: listing,
      );
      await PostPublishService.instance.publish(draft);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing created successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _openLocationPicker() {
    ChooseLocationSheet.show(
      context,
      selectedIds: const {},
      onLocationSelected: (loc) {
        setState(() => _location = loc.name);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _Banner(topInset: topInset, onClose: () => Navigator.pop(context)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Listing details',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: HomeFeedTokens.textInverse,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Price (USD)'),
                  _TextField(
                    controller: _priceController,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Dimensions'),
                  Row(
                    children: [
                      Expanded(child: _TextField(controller: _widthController, hint: 'W')),
                      const SizedBox(width: 8),
                      Expanded(child: _TextField(controller: _heightController, hint: 'H')),
                      const SizedBox(width: 8),
                      Expanded(child: _TextField(controller: _depthController, hint: 'D')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _UnitChip(
                        label: 'in',
                        selected: _dimensionUnit == 'in',
                        onTap: () => setState(() => _dimensionUnit = 'in'),
                      ),
                      const SizedBox(width: 8),
                      _UnitChip(
                        label: 'cm',
                        selected: _dimensionUnit == 'cm',
                        onTap: () => setState(() => _dimensionUnit = 'cm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Non-standard format',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: HomeFeedTokens.textInverse,
                      ),
                    ),
                    value: _nonStandardFormat,
                    onChanged: (v) => setState(() => _nonStandardFormat = v),
                  ),
                  if (_nonStandardFormat) ...[
                    _TextField(
                      controller: _nonStandardController,
                      hint: 'Describe non-standard dimensions',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _FieldLabel('Framing/mounting'),
                  _TextField(controller: _framingController, hint: 'Optional'),
                  const SizedBox(height: 16),
                  _MetadataRow(
                    label: 'Location',
                    trailing: _location,
                    onTap: _openLocationPicker,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Provenance'),
                  _TextField(
                    controller: _provenanceController,
                    hint: 'Ownership history',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Year created'),
                  _TextField(
                    controller: _yearController,
                    hint: 'YYYY',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Handling notes'),
                  _TextField(
                    controller: _handlingController,
                    hint: 'Shipping and care instructions',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: Material(
                color: _neutral300,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _publishing ? null : _createListing,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: _publishing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Save and create listing',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: HomeFeedTokens.textPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.topInset, required this.onClose});

  final double topInset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
                Expanded(
                  child: Text(
                    'Listing details',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HomeFeedTokens.textInverse,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFC8C5BC),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: HomeFeedTokens.textInverse),
      cursorColor: HomeFeedTokens.textInverse,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8C8880)),
        filled: true,
        fillColor: const Color(0xFF4A4843),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? HomeFeedTokens.textInverse : const Color(0xFF4A4843),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? HomeFeedTokens.textPrimary : const Color(0xFF8C8880),
          ),
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: HomeFeedTokens.textInverse,
              ),
            ),
            const Spacer(),
            if (trailing != null)
              Text(
                trailing!,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8C8880)),
              ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              PostMediaAssets.createChevronRight,
              width: 8,
              height: 13,
            ),
          ],
        ),
      ),
    );
  }
}
