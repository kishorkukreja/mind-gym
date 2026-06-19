import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/challenge_model.dart';
import '../services/challenge_library.dart';
import '../utils/theme.dart';
import 'progress_screen.dart';

class DebateScreen extends StatefulWidget {
  final String ucId;

  const DebateScreen({super.key, required this.ucId});

  @override
  State<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends State<DebateScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showChallenge = true;
  bool _sendingMessage = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty || _sendingMessage) return;

    _controller.clear();
    setState(() {
      _sendingMessage = true;
      _showChallenge = false;
    });
    _scrollToBottom();

    final provider = context.read<AppProvider>();
    await provider.sendDebateMessage(widget.ucId, msg);

    if (mounted) setState(() => _sendingMessage = false);
    _scrollToBottom();
  }

  Future<void> _requestHint() async {
    final provider = context.read<AppProvider>();
    setState(() => _sendingMessage = true);
    await provider.requestHint(widget.ucId);
    if (mounted) setState(() => _sendingMessage = false);
    _scrollToBottom();
  }

  Future<void> _markComplete() async {
    final provider = context.read<AppProvider>();
    final uc = provider.getChallenge(widget.ucId);
    if (uc == null || uc.responseCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You need to engage more before completing. Keep thinking!'),
        backgroundColor: AppTheme.warningColor,
      ));
      return;
    }

    final summary = await provider.markChallengeComplete(widget.ucId);
    if (mounted && summary != null) {
      _showCompletionDialog(summary);
    }
  }

  void _showCompletionDialog(CompletionSummary summary) {
    final navigator = Navigator.of(context);
    DebateCompletionDialog.show(
      context,
      summary,
      onHome: () {
        navigator.pop();
        navigator.pop();
      },
      onProgress: () {
        navigator.pop();
        navigator.pop();
        navigator.push(
          MaterialPageRoute(builder: (_) => const ProgressScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final uc = provider.getChallenge(widget.ucId);

    if (uc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge')),
        body: const Center(child: Text('Challenge not found')),
      );
    }

    final challenge = ChallengeLibrary.getById(uc.challengeId);
    if (challenge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge')),
        body: const Center(child: Text('Challenge definition not found')),
      );
    }

    final isPhilo = challenge.type == ChallengeType.philosophy;
    final typeColor = isPhilo ? AppTheme.philosophyColor : AppTheme.biasColor;
    final isCompleted = uc.status == ChallengeStatus.completed;
    final hintsLeft = challenge.hintTiers.length - uc.hintsUsed;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(challenge.title,
            style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
        actions: [
          if (!isCompleted && uc.responseCount >= 2)
            TextButton.icon(
              onPressed: _markComplete,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Complete'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.successColor),
            ),
        ],
      ),
      body: Column(
        children: [
          // Challenge header
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            color: AppTheme.surface,
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _showChallenge = !_showChallenge),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(challenge.typeLabel,
                              style: TextStyle(
                                  color: typeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Difficulty: ${'●' * challenge.difficulty}${'○' * (5 - challenge.difficulty)}',
                          style: TextStyle(color: typeColor, fontSize: 12),
                        ),
                        const Spacer(),
                        Icon(
                          _showChallenge
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showChallenge
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(challenge.question,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                height: 1.7,
                                fontSize: 14,
                              )),
                    ),
                  ),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      '"${challenge.title}" — Tap to show full question',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.border),

          // Chat messages
          Expanded(
            child: uc.conversation.isEmpty
                ? _buildEmptyState(challenge.typeLabel, typeColor)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: uc.conversation.length + (provider.isDebating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == uc.conversation.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(uc.conversation[index], typeColor);
                    },
                  ),
          ),

          // Bottom bar
          _buildBottomBar(isCompleted, hintsLeft, typeColor),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String typeLabel, Color typeColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('The Challenge Awaits',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Read the challenge above carefully. Then share your initial thoughts — even if you\'re unsure. The debate begins with your first word.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Remember: I will NEVER give you the answer.\nI will only help you find it yourself.',
              style: TextStyle(
                  color: typeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChallengeMessage msg, Color typeColor) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 40 : 0,
          right: isUser ? 0 : 40,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? typeColor : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('Mind Gym AI',
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
              ),
            Text(
              msg.content,
              style: TextStyle(
                color: isUser ? Colors.white : AppTheme.textPrimary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.timestamp),
              style: TextStyle(
                color: isUser
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thinking',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isCompleted, int hintsLeft, Color typeColor) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            const SizedBox(width: 8),
            Text('Challenge Completed!',
                style: TextStyle(
                    color: AppTheme.successColor, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: AppTheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                if (hintsLeft > 0)
                  TextButton.icon(
                    onPressed: _sendingMessage ? null : _requestHint,
                    icon: const Icon(Icons.lightbulb_outline, size: 16),
                    label: Text('Hint ($hintsLeft left)',
                        style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.warningColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                if (hintsLeft == 0)
                  Text('No hints remaining',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                const Spacer(),
                Text(
                  'Responses: ${context.watch<AppProvider>().getChallenge(widget.ucId)?.responseCount ?? 0}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Share your thinking...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: typeColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    onPressed: _sendingMessage ? null : _sendMessage,
                    icon: _sendingMessage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }
}

class DebateCompletionDialog extends StatelessWidget {
  final CompletionSummary summary;
  final VoidCallback? onHome;
  final VoidCallback? onProgress;

  const DebateCompletionDialog({
    super.key,
    required this.summary,
    this.onHome,
    this.onProgress,
  });

  static Future<void> show(
    BuildContext context,
    CompletionSummary summary, {
    VoidCallback? onHome,
    VoidCallback? onProgress,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DebateCompletionDialog(
        summary: summary,
        onHome: onHome,
        onProgress: onProgress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.psychology, color: AppTheme.primary, size: 48),
            const SizedBox(height: 12),
            Text(
              'Completion Summary',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '+${summary.totalXp} XP',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ...summary.factors.map(_buildFactor),
            const SizedBox(height: 18),
            _buildSummaryText(
              context,
              icon: Icons.check_circle_outline,
              title: 'What went well',
              body: summary.feedback,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            _buildSummaryText(
              context,
              icon: Icons.trending_up,
              title: 'Next step',
              body: summary.nextStep,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onHome ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Home'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onProgress ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.psychology_outlined, size: 18),
                label: const Text('Progress'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFactor(XpFactor factor) {
    final isPositive = factor.points >= 0;
    final color = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    final prefix = factor.points > 0 ? '+' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor.label,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  factor.detail,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$prefix${factor.points} XP',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryText(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
