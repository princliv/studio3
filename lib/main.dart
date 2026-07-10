import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/auth_session.dart';
import 'services/user_service.dart';
import 'utils/app_routes.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart' show BottomNav, BottomNavIndex;
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/welcome_page.dart';
import 'screens/profile_settings_page.dart';
import 'screens/home_feed_page.dart';
import 'screens/explore_page.dart';
import 'screens/reels_page.dart';
import 'screens/saved_page.dart';
import 'screens/profile_page.dart';
import 'screens/post_page.dart';
import 'screens/notifications_page.dart';
import 'screens/onboarding/onboarding_page.dart';
import 'screens/edit_profile_page.dart';
import 'models/auth_user.dart';
import 'theme/home_feed_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: HomeFeedTokens.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await AuthSession.instance.initialize();
  runApp(const Studio3App());
}

class Studio3App extends StatefulWidget {
  const Studio3App({super.key});

  @override
  State<Studio3App> createState() => _Studio3AppState();
}

class _Studio3AppState extends State<Studio3App> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio 3 Discover',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      initialRoute: resolveInitialRoute(),
      routes: {
        '/': (context) => AuthGate(
              child: MainShell(onThemeToggle: _toggleTheme),
            ),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/welcome': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as AuthUser?;
          return WelcomePage(
            user: user ?? const AuthUser(username: '', name: 'Artist', email: ''),
          );
        },
        '/profile-settings': (context) => const ProfileSettingsPage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/post': (context) => const PostPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}

/// Redirects unauthenticated or non-onboarded users.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    AuthSession.instance.addListener(_onSessionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  @override
  void dispose() {
    AuthSession.instance.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() => _checkAuth();

  void _checkAuth() {
    if (!mounted) return;
    final session = AuthSession.instance;
    if (!session.isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }
    if (!session.isOnboarded) {
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _avatarSeed = 902;

  int _selectedNavIndex = BottomNavIndex.home;

  @override
  void initState() {
    super.initState();
    AuthSession.instance.addListener(_onSessionChanged);
    _loadProfilePhoto();
  }

  @override
  void dispose() {
    AuthSession.instance.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfilePhoto() async {
    try {
      await UserService.instance.getMe();
    } catch (_) {
      // Keep placeholder avatar when profile cannot be loaded.
    } finally {
      if (mounted) setState(() {});
    }
  }

  void _onNavTap(int navIndex) {
    setState(() => _selectedNavIndex = navIndex);
    if (navIndex == BottomNavIndex.profile) {
      _loadProfilePhoto();
    }
  }

  Widget _buildScreen() {
    switch (_selectedNavIndex) {
      case BottomNavIndex.home:
        return HomeFeedPage(onThemeToggle: widget.onThemeToggle);
      case BottomNavIndex.discover:
        return const ExplorePage(key: ValueKey('explore'));
      case BottomNavIndex.reels:
        return const ReelsPage(key: ValueKey('reels'));
      case BottomNavIndex.bookmark:
        return const SavedPage();
      case BottomNavIndex.profile:
        return const ProfilePage();
      default:
        return HomeFeedPage(onThemeToggle: widget.onThemeToggle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildScreen(),
          BottomNav(
            selectedNavIndex: _selectedNavIndex,
            onNavTap: _onNavTap,
            avatarUrl: AuthSession.instance.user?.profilePhotoUrl,
            avatarSeed: _avatarSeed,
          ),
        ],
      ),
    );
  }
}
