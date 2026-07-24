import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/auth_session.dart';
import 'services/cache_service.dart';
import 'services/connectivity_service.dart';
import 'services/chat_socket_service.dart';
import 'services/deep_link_service.dart';
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
import 'screens/inbox_page.dart';
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
import 'screens/blocked_users_page.dart';
import 'screens/privacy_settings_page.dart';
import 'models/auth_user.dart';
import 'models/feed_preview_item.dart' show FeedAvailabilityFilter;
import 'theme/home_feed_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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
        '/chat': (context) => const ChatPage(),
        '/inbox': (context) {
          final tab = ModalRoute.of(context)?.settings.arguments as InboxTab?;
          return InboxPage(initialTab: tab ?? InboxTab.notifications);
        },
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
      DeepLinkService.instance.start(context);
    });
  }

  @override
  void dispose() {
    AuthSession.instance.removeListener(_onSessionChanged);
    DeepLinkService.instance.dispose();
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
      ChatSocketService.instance.connect();
      ConnectivityService.instance.addReconnectHook(() async {
        ChatSocketService.instance.connect();
      });
    }
    if (!session.isLoggedIn) {
      _deviceRegistered = false;
      ChatSocketService.instance.disconnect();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }
    if (!session.isOnboarded) {
      if (kDebugMode) {
        final u = session.user;
        debugPrint(
          '[AuthGate] Redirecting to /onboarding — '
          'user.onboardingComplete=${u?.onboardingComplete}, '
          'username=${u?.username}, isLoggedIn=${session.isLoggedIn}',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade900,
              duration: const Duration(seconds: 6),
              content: Text(
                'DEBUG: bounced to onboarding — '
                'onboardingComplete=${u?.onboardingComplete} '
                'for ${u?.username}',
              ),
            ),
          );
        });
      }
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
  // Slide indices for the single swipeable Home/Discover/Video/Saved
  // sequence. Home's "All" and "Available" are two adjacent slides in the
  // SAME PageView (rather than Home owning its own nested horizontal
  // PageView) so a left/right swipe flows continuously from Available all
  // the way through to Saved with no nested-gesture conflict. Profile is
  // deliberately NOT one of these slides — it's shown as a tap-only overlay
  // (see `_showProfile`) so it can never be swiped into or out of.
  static const _kHomeAllPage = 0;
  static const _kHomeAvailablePage = 1;
  static const _kDiscoverPage = 2;
  static const _kReelsPage = 3;
  static const _kSavedPage = 4;

  // Always start on the For You/Home tab, regardless of which tab was last
  // open — matching Instagram's "always opens to the main feed" behavior.
  // A ValueNotifier (rather than a plain int + setState) so nav-index
  // changes only rebuild the BottomNav subtree below, instead of the whole
  // MainShell (which would otherwise also re-run on every avatar reload /
  // auth-session change via the shared setState scope).
  final ValueNotifier<int> _selectedNavIndex =
      ValueNotifier(BottomNavIndex.home);
  late final ValueNotifier<bool> _reelsActive =
      ValueNotifier(_selectedNavIndex.value == BottomNavIndex.reels);
  final ValueNotifier<bool> _showProfile = ValueNotifier(false);

  late final PageController _pageController = PageController(
    initialPage: _kHomeAllPage,
  );
  final HomeFeedStore _homeFeedStore = HomeFeedStore();
  int _currentPage = _kHomeAllPage;
  int _lastHomeSlide = _kHomeAllPage;

  // Built once — every page widget is `const` where possible (ReelsPage
  // takes a ValueListenable instead of a constructor bool; the two
  // HomeFeedSlides share one HomeFeedStore) so this list never needs to be
  // reconstructed.
  late final List<Widget> _pages = [
    HomeFeedSlide(
      store: _homeFeedStore,
      showAvailable: false,
      onFilterTap: _onHomeFilterTap,
    ),
    HomeFeedSlide(
      store: _homeFeedStore,
      showAvailable: true,
      onFilterTap: _onHomeFilterTap,
    ),
    const ExplorePage(),
    ReelsPage(activeListenable: _reelsActive),
    const SavedPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthSession.instance.addListener(_onSessionChanged);
    _selectedNavIndex.addListener(_onNavIndexChanged);
    _loadProfilePhoto();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthSession.instance.removeListener(_onSessionChanged);
    _selectedNavIndex.removeListener(_onNavIndexChanged);
    _selectedNavIndex.dispose();
    _reelsActive.dispose();
    _showProfile.dispose();
    _pageController.dispose();
    _homeFeedStore.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AppStateStore.instance.saveNavIndex(_selectedNavIndex.value);
    }
  }

  void _onNavIndexChanged() {
    _reelsActive.value = _selectedNavIndex.value == BottomNavIndex.reels;
  }

  void _onSessionChanged() {
    // Only the avatar (read directly by BottomNav's ValueListenableBuilder
    // below) needs to react to session changes — no setState here avoids
    // rebuilding the whole shell (and therefore every const-canonicalized
    // page reference) for an avatar URL update.
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

  int _navIndexForPage(int page) {
    switch (page) {
      case _kHomeAllPage:
      case _kHomeAvailablePage:
        return BottomNavIndex.home;
      case _kDiscoverPage:
        return BottomNavIndex.discover;
      case _kReelsPage:
        return BottomNavIndex.reels;
      case _kSavedPage:
      default:
        return BottomNavIndex.bookmark;
    }
  }

  void _onPageChanged(int page) {
    _currentPage = page;
    if (page == _kHomeAllPage || page == _kHomeAvailablePage) {
      _lastHomeSlide = page;
    }
    final navIndex = _navIndexForPage(page);
    _selectedNavIndex.value = navIndex;
    AppStateStore.instance.saveNavIndex(navIndex);
  }

  /// Tapping "All"/"Available" in the Home header animates the shared
  /// PageView to the matching slide — `_onPageChanged` then updates
  /// `_selectedNavIndex`/`_lastHomeSlide` once it lands, same as a swipe.
  void _onHomeFilterTap(FeedAvailabilityFilter filter) {
    final page =
        filter == FeedAvailabilityFilter.all ? _kHomeAllPage : _kHomeAvailablePage;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onNavTap(int navIndex) {
    if (navIndex == BottomNavIndex.profile) {
      _showProfile.value = true;
      _selectedNavIndex.value = BottomNavIndex.profile;
      AppStateStore.instance.saveNavIndex(navIndex);
      _loadProfilePhoto();
      return;
    }
    _showProfile.value = false;
    final targetPage = switch (navIndex) {
      BottomNavIndex.home => _lastHomeSlide,
      BottomNavIndex.discover => _kDiscoverPage,
      BottomNavIndex.reels => _kReelsPage,
      BottomNavIndex.bookmark => _kSavedPage,
      _ => _currentPage,
    };
    _selectedNavIndex.value = navIndex;
    AppStateStore.instance.saveNavIndex(navIndex);
    if (targetPage != _currentPage) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
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
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),
          // Offstage (not a conditional widget swap) so ProfilePage stays
          // mounted the whole session — its own data/scroll state survives
          // being hidden, same as it did as an IndexedStack child before.
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: _showProfile,
              builder: (context, show, child) => Offstage(
                offstage: !show,
                child: child,
              ),
              child: const ProfilePage(),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _selectedNavIndex,
            builder: (context, index, _) => BottomNav(
              selectedNavIndex: index,
              onNavTap: _onNavTap,
              avatarUrl: AuthSession.instance.user?.profilePhotoUrl,
            ),
          ),
        ],
      ),
    );
  }
}
