import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debate_difficulty.dart';
import '../services/app_provider.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyCtrl;
  bool _showApiKey = false;
  bool _saving = false;
  late int _weekdayHour;
  late int _weekendHour;
  late int _weekdayDay;
  late int _weekendDay;
  late DebateDifficultyPreference _debateDifficultyPreference;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser!;
    _apiKeyCtrl = TextEditingController(text: user.openRouterApiKey ?? '');
    _weekdayHour = user.weekdayHour;
    _weekendHour = user.weekendHour;
    _weekdayDay = user.weekdayChallengeDay;
    _weekendDay = user.weekendChallengeDay;
    _debateDifficultyPreference = user.debateDifficultyPreference;
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    setState(() => _saving = true);
    await context.read<AppProvider>().updateApiKey(_apiKeyCtrl.text.trim());
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('API key saved!'),
        backgroundColor: AppTheme.successColor,
      ));
    }
  }

  Future<void> _saveSchedule() async {
    await context.read<AppProvider>().updateSchedule(
          weekdayHour: _weekdayHour,
          weekendHour: _weekendHour,
          weekdayChallengeDay: _weekdayDay,
          weekendChallengeDay: _weekendDay,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Schedule saved! New challenges next week.'),
        backgroundColor: AppTheme.successColor,
      ));
    }
  }

  Future<void> _setDebateDifficulty(
    DebateDifficultyPreference preference,
  ) async {
    setState(() => _debateDifficultyPreference = preference);
    await context
        .read<AppProvider>()
        .updateDebateDifficultyPreference(preference);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Debate difficulty set to ${preference.label}.'),
        backgroundColor: AppTheme.successColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SETTINGS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card
              _buildSection(
                title: 'Profile',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _buildInfoRow('Username', user.username),
                    _buildInfoRow(
                      'Level',
                      '${user.level} — ${user.levelTitle}',
                    ),
                    _buildInfoRow('Total XP', '${user.xp}'),
                    _buildInfoRow('Member since',
                        _formatDate(user.createdAt)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // API Key
              _buildSection(
                title: 'OpenRouter API Key',
                icon: Icons.vpn_key_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Powers the Socratic debate engine. Get your key from openrouter.ai',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyCtrl,
                      obscureText: !_showApiKey,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'sk-or-...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(
                          Icons.key_outlined,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _showApiKey
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textSecondary,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _showApiKey = !_showApiKey),
                            ),
                          ],
                        ),
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
                          borderSide: BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveApiKey,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save API Key'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSection(
                title: 'Debate Difficulty',
                icon: Icons.tune_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose how hard the debate engine pushes, or inherit from each challenge.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          DebateDifficultyPreference.values.map((preference) {
                        final selected =
                            _debateDifficultyPreference == preference;
                        return ChoiceChip(
                          label: Text(preference.label),
                          selected: selected,
                          onSelected: (_) => _setDebateDifficulty(preference),
                          selectedColor: AppTheme.primary.withValues(
                            alpha: 0.16,
                          ),
                          backgroundColor: AppTheme.background,
                          checkmarkColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color:
                                selected ? AppTheme.primary : AppTheme.border,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _debateDifficultyPreference.description,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Schedule
              _buildSection(
                title: 'Challenge Schedule',
                icon: Icons.schedule_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekday Challenge',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Day',
                            value: _weekdayDay,
                            items: {
                              1: 'Monday',
                              2: 'Tuesday',
                              3: 'Wednesday',
                              4: 'Thursday',
                              5: 'Friday',
                            },
                            onChanged: (v) => setState(() => _weekdayDay = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Time',
                            value: _weekdayHour,
                            items: {
                              18: '6:00 PM',
                              19: '7:00 PM',
                              20: '8:00 PM',
                              21: '9:00 PM',
                              22: '10:00 PM',
                              23: '11:00 PM',
                            },
                            onChanged: (v) =>
                                setState(() => _weekdayHour = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Weekend Challenge',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Day',
                            value: _weekendDay,
                            items: {
                              6: 'Saturday',
                              7: 'Sunday',
                            },
                            onChanged: (v) => setState(() => _weekendDay = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Time',
                            value: _weekendHour,
                            items: {
                              14: '2:00 PM',
                              15: '3:00 PM',
                              16: '4:00 PM',
                              17: '5:00 PM',
                              18: '6:00 PM',
                              19: '7:00 PM',
                            },
                            onChanged: (v) =>
                                setState(() => _weekendHour = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                        ),
                        child: const Text('Save Schedule'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Logout & Danger Zone
              _buildSection(
                title: 'Account',
                icon: Icons.manage_accounts_outlined,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Log Out?'),
                              content: const Text(
                                'Your progress is saved locally. You can log back in anytime.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                  child: const Text('Log Out'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await context.read<AppProvider>().logout();
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Mind Gym v1.0.0\nKeep challenging yourself.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required Map<int, String> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        filled: true,
        fillColor: AppTheme.background,
      ),
      dropdownColor: AppTheme.surface,
      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      items: items.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
