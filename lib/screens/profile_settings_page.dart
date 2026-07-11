import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../services/auth_session.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/profile_navigation.dart';
import '../widgets/studio_loading.dart';
import 'profile/widgets/profile_seller_insights.dart';
import 'seller_analytics_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _sellerEnabled = false;
  bool _loadingSeller = true;
  bool _togglingSeller = false;
  String? _profileLocation;
  SellerAnalytics? _analytics;

  @override
  void initState() {
    super.initState();
    _loadSellerStatus();
  }

  Future<void> _loadSellerStatus() async {
    try {
      final results = await Future.wait([
        UserService.instance.getSellerStatus(),
        UserService.instance.getMe(),
      ]);
      final status = results[0] as SellerStatus;
      final profile = results[1] as UserProfile;
      if (!mounted) return;
      setState(() {
        _sellerEnabled = status.enabled;
        _profileLocation = profile.location;
        _loadingSeller = false;
      });
      if (status.enabled) _loadAnalytics();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sellerEnabled = AuthSession.instance.sellerEnabled;
        _loadingSeller = false;
      });
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await UserService.instance.getSellerAnalytics();
      if (!mounted) return;
      setState(() => _analytics = analytics);
    } catch (_) {
      // Seller mode still works if analytics fails to load.
    }
  }

  Future<void> _onSellerToggle(bool value) async {
    if (_togglingSeller) return;
    setState(() => _togglingSeller = true);
    final result = await toggleSellerMode(
      context: context,
      enable: value,
      profileLocation: _profileLocation,
    );
    if (!mounted) return;
    setState(() {
      _togglingSeller = false;
      if (result != null) _sellerEnabled = result;
    });
    if (result == true) _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final pageLoading = _loadingSeller || _togglingSeller;

    return StudioLoadingGate(
      loading: pageLoading,
      child: Scaffold(
        backgroundColor: HomeFeedTokens.background,
        appBar: AppBar(
          backgroundColor: HomeFeedTokens.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HomeFeedTokens.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: HomeFeedTokens.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SellerToggleTile(
              enabled: _sellerEnabled,
              onChanged: _onSellerToggle,
            ),
          if (_sellerEnabled) ...[
            _SettingsTile(
              icon: Icons.bar_chart_rounded,
              label: 'Seller analytics',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SellerAnalyticsPage(
                      savesCount: _analytics?.savesCount,
                      likesCount: _analytics?.likesCount,
                      inquiriesCount: _analytics?.inquiriesCount,
                      salesCount: _analytics?.salesCount,
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.collections_bookmark_outlined,
            label: 'Manage series',
            onTap: () async {
              await Navigator.pushNamed(context, '/manage-series');
              if (!context.mounted) return;
              // Parent profile reloads when settings is popped; no extra action here.
            },
          ),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            label: 'Edit profile',
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
          _SettingsTile(
            icon: Icons.visibility_outlined,
            label: 'See profile as viewer',
            onTap: () => openOwnProfileAsViewer(context),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Password & security',
            onTap: () => Navigator.pushNamed(context, '/forgot-password'),
          ),
          _SettingsTile(
            icon: Icons.devices_other_outlined,
            label: 'Log out of all devices',
            onTap: () async {
              await AuthService.instance.logoutAllDevices();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Log out',
            destructive: true,
            onTap: () async {
              await AuthService.instance.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
        ),
      ),
    );
  }
}

class _SellerToggleTile extends StatelessWidget {
  const _SellerToggleTile({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: HomeFeedTokens.textPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.storefront_outlined,
              size: 22, color: HomeFeedTokens.textPrimary.withValues(alpha: 0.75)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Seller account',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: HomeFeedTokens.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? const Color(0xFFE05252) : HomeFeedTokens.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon,
                  size: 22, color: color.withValues(alpha: destructive ? 1 : 0.75)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
