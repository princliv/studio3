import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/auth_session.dart';
import 'services/cache_service.dart';
import 'services/connectivity_service.dart';
import 'services/device_service.dart';
import 'services/permission_service.dart';
import 'services/saved_content_store.dart';
import 'services/user_service.dart';
import 'utils/app_routes.dart';
import 'utils/app_state_store.dart';
import 'utils/profile_navigation.dart';
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
import 'screens/chat_page.dart';
import 'screens/onboarding/onboarding_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/manage_series_page.dart';
import 'screens/address_list_page.dart';
import 'screens/my_orders_page.dart';
import 'screens/my_sales_page.dart';
import 'screens/change_password_page.dart';
import 'screens/change_email_page.dart';
import 'screens/notification_preferences_page.dart';
import 'screens/follow_requests_page.dart';
import 'screens/blocked_users_page.dart';
import 'screens/privacy_settings_page.dart';
import 'models/auth_user.dart';
import 'theme/home_feed_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: HomeFeedTokens.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await AuthSession.instance.initialize();
  await CacheService.instance.init();
  await AppStateStore.instance.initialize();
  await SavedContentStore.instance.load();
  await ConnectivityService.instance.init();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase unavailable (no config yet?): $e');
  }
  runApp(const Studio3App());
}

class Studio3App extends StatelessWidget {
  const Studio3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio 3 Discover',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: resolveInitialRoute(),
      navigatorObservers: [routeObserver],
      routes: {
        '/': (context) => const AuthGate(
              child: MainShell(),
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
        '/manage-series': (context) => const ManageSeriesPage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/addresses': (context) => const AddressListPage(),
        '/orders': (context) => const MyOrdersPage(),
        '/sales': (context) => const MySalesPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/change-email': (context) => const ChangeEmailPage(),
        '/notification-preferences': (context) => const NotificationPreferencesPage(),
        '/privacy-settings': (context) => const PrivacySettingsPage(),
        '/follow-requests': (context) => const FollowRequestsPage(),
        '/blocked-users': (context) => const BlockedUsersPage(),
        '/profile': (context) {
          final args = parseProfileRouteArgs(
            ModalRoute.of(context)?.settings.arguments,
          );
          if (args == null) return const ProfilePage();
          return ProfilePage(
            username: args.username,
            viewerMode: args.viewerMode,
          );
        },
        '/post': (context) => const PostPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/chat': (context) => const ChatPage(),
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
  bool _deviceRegistered = false;

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
    if (session.isLoggedIn && !_deviceRegistered) {
      _deviceRegistered = true;
      DeviceService.instance.registerCurrentDevice();
      PermissionService.instance.requestNotifications();
    }
    if (!session.isLoggedIn) {
      _deviceRegistered = false;
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
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  late int _selectedNavIndex = AppStateStore.instance.lastNavIndex;

  List<Widget> _buildTabs() => [
        const HomeFeedPage(),
        const ExplorePage(),
        ReelsPage(active: _selectedNavIndex == BottomNavIndex.reels),
        const SavedPage(),
        const ProfilePage(),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthSession.instance.addListener(_onSessionChanged);
    _loadProfilePhoto();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthSession.instance.removeListener(_onSessionChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AppStateStore.instance.saveNavIndex(_selectedNavIndex);
    }
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
    AppStateStore.instance.saveNavIndex(navIndex);
    if (navIndex == BottomNavIndex.profile) {
      _loadProfilePhoto();
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
          IndexedStack(
            index: _selectedNavIndex,
            children: _buildTabs(),
          ),
          BottomNav(
            selectedNavIndex: _selectedNavIndex,
            onNavTap: _onNavTap,
            avatarUrl: AuthSession.instance.user?.profilePhotoUrl,
          ),
        ],
      ),
    );
  }
}
