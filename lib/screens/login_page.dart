import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../services/auth_session.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _submitted = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final remembered = AuthSession.instance.rememberedUsername;
    if (remembered != null) {
      _usernameController.text = remembered;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? get _usernameError =>
      _submitted ? AuthValidators.username(_usernameController.text) : null;

  String? get _passwordError =>
      _submitted && _passwordController.text.isEmpty ? 'Password is required' : null;

  bool get _canSubmit =>
      AuthValidators.username(_usernameController.text) == null &&
      _passwordController.text.isNotEmpty;

  Future<void> _signIn() async {
    setState(() => _submitted = true);
    if (!_canSubmit) return;

    setState(() => _loading = true);
    try {
      await AuthService.instance.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (_rememberMe) {
        await AuthSession.instance.saveRememberedUsername(_usernameController.text.trim());
      } else {
        await AuthSession.instance.clearRememberedUsername();
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (mounted) showAuthError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    final uri = Uri.parse(ApiConfig.googleAuthUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) showAuthSnackBar(context, 'Could not open Google sign-in', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      compact: true,
      child: AuthFormBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthPageTitle(title: 'Login'),
            const SizedBox(height: 28),
            AuthIconInput(
              controller: _usernameController,
              placeholder: 'Username',
              prefixIcon: Icons.person_outline_rounded,
              errorText: _usernameError,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            AuthIconInput(
              controller: _passwordController,
              placeholder: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              errorText: _passwordError,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _signIn(),
              onChanged: (_) => setState(() {}),
              onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 14),
            AuthRememberRow(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v),
              onForgot: () => Navigator.pushNamed(context, '/forgot-password'),
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(label: 'Login', enabled: _canSubmit, loading: _loading, onPressed: _signIn),
            const SizedBox(height: 20),
            GoogleAuthButton(onPressed: _googleSignIn),
            const SizedBox(height: 20),
            AuthLinkFooter(
              prompt: "Don't have an account? ",
              actionLabel: 'Sign Up',
              onTap: () => Navigator.pushNamed(context, '/signup'),
            ),
          ],
        ),
      ),
    );
  }
}
