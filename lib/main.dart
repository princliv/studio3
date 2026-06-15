import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart' show BottomNav, BottomNavIndex;
import 'services/auth_session.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/welcome_page.dart';
import 'screens/profile_settings_page.dart';
import 'screens/home_feed_page.dart';
import 'screens/discover_page.dart';
import 'screens/chat_page.dart';
import 'screens/profile_page.dart';
import 'screens/post_page.dart';
import 'screens/notifications_page.dart';
import 'models/auth_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSession.instance.initialize();
  runApp(const Studio3App());
}

class Studio3App extends StatelessWidget {
  const Studio3App({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = AuthSession.instance.isLoggedIn;

    return MaterialApp(
      title: 'Studio 3 Discover',
      theme: AppTheme.light,
      initialRoute: loggedIn ? '/' : '/login',
      routes: {
        '/': (context) => const MainShell(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/welcome': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as AuthUser?;
          return WelcomePage(user: user ?? const AuthUser(username: '', name: 'Artist', email: ''));
        },
        '/profile-settings': (context) => const ProfileSettingsPage(),
        '/post': (context) => const PostPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// 0=home, 1=discover, 2=chat, 3=profile
  int _currentScreenIndex = 0;

  int get _selectedNavIndex {
    switch (_currentScreenIndex) {
      case 0:
        return BottomNavIndex.home;
      case 1:
        return BottomNavIndex.discover;
      case 2:
        return BottomNavIndex.bookmark;
      case 3:
        return BottomNavIndex.profile;
      default:
        return BottomNavIndex.home;
    }
  }

  void _onNavTap(int navIndex) {
    switch (navIndex) {
      case BottomNavIndex.more:
        break;
      case BottomNavIndex.home:
        setState(() => _currentScreenIndex = 0);
        break;
      case BottomNavIndex.discover:
        setState(() => _currentScreenIndex = 1);
        break;
      case BottomNavIndex.post:
        Navigator.pushNamed(context, '/post');
        break;
      case BottomNavIndex.bookmark:
        setState(() => _currentScreenIndex = 2);
        break;
      case BottomNavIndex.bell:
        Navigator.pushNamed(context, '/notifications');
        break;
      case BottomNavIndex.profile:
        setState(() => _currentScreenIndex = 3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeFeedPage(),
      const DiscoverPage(),
      const ChatPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          screens[_currentScreenIndex],
          BottomNav(
            selectedNavIndex: _selectedNavIndex,
            onNavTap: _onNavTap,
          ),
        ],
      ),
    );
  }
}
