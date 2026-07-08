import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/collect_shipping_address.dart';
import '../../theme/collect_detail_tokens.dart';

/// Shipping address form — Figma 2371-1692.
class CollectShippingSheet extends StatefulWidget {
  const CollectShippingSheet({
    super.key,
    this.initial,
  });

  final CollectShippingAddress? initial;

  static Future<CollectShippingAddress?> show(
    BuildContext context, {
    CollectShippingAddress? initial,
  }) {
    return showModalBottomSheet<CollectShippingAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) => CollectShippingSheet(initial: initial),
    );
  }

  @override
  State<CollectShippingSheet> createState() => _CollectShippingSheetState();
}

class _CollectShippingSheetState extends State<CollectShippingSheet> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _street;
  late final TextEditingController _apt;
  late final TextEditingController _city;
  late final TextEditingController _zip;
  late final TextEditingController _phone;
  String? _state;
  String? _error;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _firstName = TextEditingController(text: i?.firstName);
    _lastName = TextEditingController(text: i?.lastName);
    _street = TextEditingController(text: i?.street);
    _apt = TextEditingController(text: i?.apt);
    _city = TextEditingController(text: i?.city);
    _zip = TextEditingController(text: i?.zip);
    _phone = TextEditingController(text: i?.phone);
    _state = i?.state;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _street.dispose();
    _apt.dispose();
    _city.dispose();
    _zip.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _canSave {
    return _firstName.text.trim().isNotEmpty &&
        _lastName.text.trim().isNotEmpty &&
        _street.text.trim().isNotEmpty &&
        _city.text.trim().isNotEmpty &&
        (_state != null && _state!.isNotEmpty) &&
        _zip.text.trim().isNotEmpty;
  }

  void _save() {
    if (!_canSave) {
      setState(() => _error = 'Please fill in all required fields');
      return;
    }
    final apt = _apt.text.trim();
    final phone = _phone.text.trim();
    Navigator.pop(
      context,
      CollectShippingAddress(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        street: _street.text.trim(),
        apt: apt.isEmpty ? null : apt,
        city: _city.text.trim(),
        state: _state!,
        zip: _zip.text.trim(),
        phone: phone.isEmpty ? null : phone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.96;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: CollectDetailTokens.sheetBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.only(bottom: keyboard),
            child: Column(
              children: [
                _ShippingHeader(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: CollectDetailTokens.sheetCardFill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _LabeledField(
                                      label: 'First Name',
                                      hint: 'Required',
                                      controller: _firstName,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _LabeledField(
                                      label: 'Last Name',
                                      hint: 'Required',
                                      controller: _lastName,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Street address',
                                hint: 'Required',
                                controller: _street,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Apt, suite, etc (optional)',
                                hint: 'Optional',
                                controller: _apt,
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'City',
                                hint: 'Required',
                                controller: _city,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _StateField(
                                      value: _state,
                                      onChanged: (v) =>
                                          setState(() => _state = v),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _LabeledField(
                                      label: 'Zip Code',
                                      hint: 'Required',
                                      controller: _zip,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Phone number',
                                hint: 'Optional',
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: CollectDetailTokens.collectButtonHeight,
                        width: double.infinity,
                        child: Material(
                          color: _canSave
                              ? CollectDetailTokens.ctaFill
                              : CollectDetailTokens.ctaFill
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            CollectDetailTokens.collectButtonRadius,
                          ),
                          child: InkWell(
                            onTap: _save,
                            borderRadius: BorderRadius.circular(
                              CollectDetailTokens.collectButtonRadius,
                            ),
                            child: Center(
                              child: Text(
                                'Save and continue',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: CollectDetailTokens.textInverse,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: CollectDetailTokens.sheetCardFill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shipping method',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: CollectDetailTokens.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Shipping methods and rates vary based on location',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: CollectDetailTokens.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShippingHeader extends StatelessWidget {
  const _ShippingHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: SizedBox(
        height: 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: CollectDetailTokens.textPrimary,
                  ),
                ),
              ),
            ),
            Text(
              'Shipping',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CollectDetailTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: CollectDetailTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: CollectDetailTokens.textPrimary,
            ),
            cursorColor: CollectDetailTokens.textPrimary,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: CollectDetailTokens.textDisabled,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              filled: true,
              fillColor: CollectDetailTokens.sheetBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: CollectDetailTokens.textSecondary,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: CollectDetailTokens.textSecondary,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: CollectDetailTokens.textPrimary,
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StateField extends StatelessWidget {
  const _StateField({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: CollectDetailTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CollectDetailTokens.sheetBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CollectDetailTokens.textSecondary,
                width: 0.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Required',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: CollectDetailTokens.textDisabled,
                    ),
                  ),
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: CollectDetailTokens.textSecondary,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: CollectDetailTokens.textPrimary,
                ),
                dropdownColor: CollectDetailTokens.sheetBackground,
                borderRadius: BorderRadius.circular(8),
                items: [
                  for (final s in kUsStates)
                    DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: onChanged,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
