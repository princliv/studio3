import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../services/auth_session.dart';
import '../services/user_service.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/profile_photo_upload.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_cover_image.dart';
import '../widgets/studio_loading.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _canChangeUsername = true;
  String? _usernameError;
  String? _profilePhotoUrl;
  String? _coverPhotoUrl;
  Timer? _usernameDebounce;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _usernameController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserService.instance.getMe();
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.name;
        _bioController.text = profile.bio ?? '';
        _locationController.text = profile.location ?? '';
        _usernameController.text = profile.username;
        _profilePhotoUrl = profile.profilePhotoUrl;
        _coverPhotoUrl = profile.coverPhotoUrl;
        _canChangeUsername = profile.canChangeUsername;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().length < 3) return;
      try {
        final result = await AuthService.instance.checkUsername(
          value,
          forCurrentUser: true,
        );
        if (!mounted) return;
        setState(() {
          _usernameError = result.available ? null : (result.message ?? 'Username taken');
        });
      } catch (_) {}
    });
  }

  Future<String?> _uploadPhoto(String purpose) {
    return pickAndUploadPhoto(context, purpose);
  }

  Future<void> _save() async {
    if (_usernameError != null) return;
    setState(() => _saving = true);
    try {
      final sessionUser = AuthSession.instance.user;
      if (sessionUser != null &&
          _usernameController.text.trim() != sessionUser.username &&
          _canChangeUsername) {
        await UserService.instance.changeUsername(_usernameController.text.trim());
      }
      await UserService.instance.updateMe(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        profilePhotoUrl: _profilePhotoUrl,
        coverPhotoUrl: _coverPhotoUrl,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudioLoadingGate(
      loading: _loading || _saving,
      child: Scaffold(
        backgroundColor: HomeFeedTokens.background,
        appBar: AppBar(
          backgroundColor: HomeFeedTokens.background,
          elevation: 0,
          title: Text(
            'Edit profile',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HomeFeedTokens.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _saving || _loading ? null : _save,
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProfileCoverImage(
                url: _coverPhotoUrl,
                width: MediaQuery.sizeOf(context).width - 40,
                height: 120,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () async {
                  final url = await _uploadPhoto('cover');
                  if (url != null) setState(() => _coverPhotoUrl = url);
                },
                child: const Text('Change cover'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final url = await _uploadPhoto('profile');
                    if (url != null) setState(() => _profilePhotoUrl = url);
                  },
                  child: ProfileAvatar(
                    url: _profilePhotoUrl,
                    seed: 902,
                    size: 72,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _profilePhotoUrl == null
                        ? 'Tap photo to add profile picture'
                        : 'Tap photo to change',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: HomeFeedTokens.textPrimary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
                _Field(label: 'Name', controller: _nameController),
                const SizedBox(height: 16),
                _Field(
                  label: 'Username',
                  controller: _usernameController,
                  enabled: _canChangeUsername,
                  onChanged: _onUsernameChanged,
                  error: _usernameError,
                ),
                const SizedBox(height: 16),
                _Field(label: 'Bio', controller: _bioController, maxLines: 3),
                const SizedBox(height: 16),
                _Field(label: 'Location', controller: _locationController),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: HomeFeedTokens.textPrimary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            errorText: error,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
