import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/brain_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  final _usernameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  bool _obscurePin = true;
  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _usernameCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
    _usernameCtrl.clear();
    _pinCtrl.clear();
    _confirmPinCtrl.clear();
  }

  Future<void> _submit() async {
    final provider = context.read<AppProvider>();
    final username = _usernameCtrl.text.trim();
    final pin = _pinCtrl.text.trim();
    provider.clearError();

    if (_isLogin) {
      final success = await provider.login(username, pin);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Login failed'),
          backgroundColor: AppTheme.errorColor,
        ));
      }
    } else {
      if (_pinCtrl.text != _confirmPinCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('PINs do not match'),
          backgroundColor: AppTheme.errorColor,
        ));
        return;
      }
      final err = await provider.register(
        username,
        pin,
        apiKey: _apiKeyCtrl.text.trim().isNotEmpty
            ? _apiKeyCtrl.text.trim()
            : null,
      );
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppTheme.errorColor,
        ));
      }
    }
  }

  Future<void> _startGuest() async {
    await context.read<AppProvider>().startGuestSession();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final users = provider.getAllUsers();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: AnimatedBuilder(
            animation: _slideAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, 30 * (1 - _slideAnim.value)),
              child: Opacity(opacity: _slideAnim.value, child: child),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Brain Logo
                const BrainLogo(size: 90),
                const SizedBox(height: 16),
                Text('MIND GYM',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.primary,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                        )),
                Text('Sharpen Your Thinking',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.5,
                        )),
                const SizedBox(height: 24),
                _buildOnboardingCard(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: provider.isLoading ? null : _startGuest,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Try Starter Challenge as Guest'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User switcher if users exist
                if (users.isNotEmpty && _isLogin) ...[
                  _buildUserSwitcher(users),
                  const SizedBox(height: 20),
                  _buildDivider('or enter manually'),
                  const SizedBox(height: 20),
                ],

                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildField(
                        controller: _usernameCtrl,
                        label: 'Username',
                        icon: Icons.person_outline,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9_]'),
                          ),
                          LengthLimitingTextInputFormatter(20),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _pinCtrl,
                        label: 'PIN (4+ digits)',
                        icon: Icons.lock_outline,
                        isPin: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _confirmPinCtrl,
                          label: 'Confirm PIN',
                          icon: Icons.lock_outline,
                          isPin: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _apiKeyCtrl,
                          label: 'OpenRouter API Key (optional)',
                          icon: Icons.vpn_key_outlined,
                          hint: 'sk-or-...',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You can add/update your API key later in Settings',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _isLogin ? 'Enter the Gym' : 'Begin Training',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLogin
                        ? 'New user? Create an account'
                        : 'Already have an account? Login',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSwitcher(users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Login',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                letterSpacing: 1)),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final u = users[i];
              return GestureDetector(
                onTap: () => _usernameCtrl.text = u.username,
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppTheme.primary.withValues(alpha: 0.2),
                        child: Text(
                          u.username[0].toUpperCase(),
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u.username,
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 10,
                          ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingCard() {
    final items = [
      (Icons.event_available_outlined, 'Scheduled weekly challenges'),
      (Icons.forum_outlined, 'Debate your reasoning'),
      (Icons.bolt_outlined, 'Earn XP for completing sessions'),
      (Icons.insights_outlined, 'Track progress over time'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Train with one challenge now. New weekly drills unlock on your schedule.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(item.$1, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPin = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPin ? _obscurePin : false,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.5),
        ),
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        suffixIcon: isPin
            ? IconButton(
                icon: Icon(
                  _obscurePin
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              )
            : null,
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDivider(String label) {
    return Row(children: [
      Expanded(child: Divider(color: AppTheme.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ),
      Expanded(child: Divider(color: AppTheme.border)),
    ]);
  }
}
