import 'package:flutter/material.dart';

import '../services/auth_session.dart';

/// Arguments for navigating to a profile screen.
class ProfileRouteArgs {
  const ProfileRouteArgs({
    required this.username,
    this.viewerMode = false,
  });

  final String username;
  final bool viewerMode;
}

/// Opens a user's profile screen. [username] may include a leading `@`.
void openUserProfile(BuildContext context, String? username) {
  final handle = username?.replaceFirst('@', '').trim();
  if (handle == null || handle.isEmpty) return;
  Navigator.pushNamed(
    context,
    '/profile',
    arguments: ProfileRouteArgs(username: handle),
  );
}

/// Opens the signed-in user's profile as other viewers see it.
void openOwnProfileAsViewer(BuildContext context) {
  final username = AuthSession.instance.user?.username;
  if (username == null || username.isEmpty) return;
  Navigator.pushNamed(
    context,
    '/profile',
    arguments: ProfileRouteArgs(username: username, viewerMode: true),
  );
}

/// Parses `/profile` route [arguments] into a [ProfileRouteArgs], if possible.
ProfileRouteArgs? parseProfileRouteArgs(Object? arguments) {
  if (arguments is ProfileRouteArgs) return arguments;
  if (arguments is String) {
    final handle = arguments.replaceFirst('@', '').trim();
    if (handle.isEmpty) return null;
    return ProfileRouteArgs(username: handle);
  }
  return null;
}
