import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/auth_session.dart';
import '../theme/home_feed_tokens.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthSession.instance.user;

    return Scaffold(
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: HomeFeedTokens.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user != null) ...[
            Text(
              user.name,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: HomeFeedTokens.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: GoogleFonts.inter(fontSize: 14, color: HomeFeedTokens.textPrimary.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: GoogleFonts.inter(fontSize: 13, color: HomeFeedTokens.textPrimary.withValues(alpha: 0.45)),
            ),
            const SizedBox(height: 28),
          ],
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            label: 'Edit profile',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Password & security',
            onTap: () => Navigator.pushNamed(context, '/forgot-password'),
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
    final color = destructive ? const Color(0xFFE05252) : HomeFeedTokens.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color.withValues(alpha: destructive ? 1 : 0.75)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: color),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
