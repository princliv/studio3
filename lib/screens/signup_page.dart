import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_input.dart';
import '../widgets/primary_button.dart';
import '../widgets/pill_chip.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _step = 1;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  bool _obscurePassword = true;

  final List<String> _mediums = ['Oil', 'Watercolor', 'Digital', 'Photography', 'Sculpture', 'Mixed Media', 'Ceramics', 'Printmaking'];
  final List<String> _styles = ['Abstract', 'Figurative', 'Landscape', 'Portrait', 'Contemporary', 'Minimalist'];
  final List<String> _themes = ['Nature', 'Urban', 'Identity', 'Surreal', 'Geometric'];

  final Set<String> _selectedMediums = {};
  final Set<String> _selectedStyles = {};
  final Set<String> _selectedThemes = {};

  bool get _canFinish =>
      _selectedMediums.length >= 3 && _selectedStyles.length >= 3 && _selectedThemes.length >= 3;

  void _toggle(String id, Set<String> set) {
    setState(() {
      if (set.contains(id)) {
        set.remove(id);
      } else {
        set.add(id);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.slate50, AppColors.slate100, AppColors.slate200],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text('Studio 3', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.slate900)),
                const SizedBox(height: 4),
                const Text('Discover Art. Collect Stories.', style: TextStyle(fontSize: 13, color: AppColors.slate400)),
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [1, 2, 3].map((i) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _step == i ? AppColors.slate900 : AppColors.slate300,
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 24),
                      if (_step == 1) ...[
                        PillInput(controller: _nameController, placeholder: 'Full Name'),
                        const SizedBox(height: 16),
                        PillInput(controller: _emailController, placeholder: 'Email', keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        PillInput(
                          controller: _passwordController,
                          placeholder: 'Password',
                          obscureText: _obscurePassword,
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(value: 0.6, backgroundColor: AppColors.slate200, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.slate600)),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(label: 'Continue', onPressed: () => setState(() => _step = 2)),
                      ],
                      if (_step == 2) ...[
                        Container(
                          width: 72,
                          height: 72,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.slate300, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                            color: AppColors.slate50,
                          ),
                          child: const Center(child: Text('Avatar', style: TextStyle(fontSize: 12, color: AppColors.slate400))),
                        ),
                        TextField(
                          controller: _bioController,
                          maxLength: 300,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Bio',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            counterStyle: const TextStyle(fontSize: 11, color: AppColors.slate400),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PillInput(controller: _locationController, placeholder: 'Location (optional)'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: PrimaryButton(label: 'Continue', onPressed: () => setState(() => _step = 3))),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _step = 3),
                                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), side: const BorderSide(color: AppColors.slate300)),
                                child: const Text('Skip', style: TextStyle(color: AppColors.slate600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_step == 3) ...[
                        const Text('What moves you?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Select at least 3 to personalize your feed', style: TextStyle(fontSize: 13, color: AppColors.slate500)),
                        const SizedBox(height: 20),
                        const Text('Medium', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.slate600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _mediums.map((m) => PillChip(label: m, selected: _selectedMediums.contains(m), onTap: () => _toggle(m, _selectedMediums))).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Style', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.slate600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _styles.map((s) => PillChip(label: s, selected: _selectedStyles.contains(s), onTap: () => _toggle(s, _selectedStyles))).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Theme', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.slate600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _themes.map((t) => PillChip(label: t, selected: _selectedThemes.contains(t), onTap: () => _toggle(t, _selectedThemes))).toList(),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(label: 'Get Started', enabled: _canFinish, onPressed: _canFinish ? () => Navigator.pushReplacementNamed(context, '/') : null),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(fontSize: 14, color: AppColors.slate600)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
