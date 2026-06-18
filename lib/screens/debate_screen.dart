import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/challenge_model.dart';
import '../services/challenge_library.dart';
import '../utils/theme.dart';

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
    if (uc == null) return;
    final requiredResponses = provider.getCompletionResponseRequirement(uc);
    if (uc.responseCount < requiredResponses) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'This mode expects at least $requiredResponses substantive responses before completion.',
        ),
        backgroundColor: AppTheme.warningColor,
      ));
      return;
    }

    final xp = await provider.markChallengeComplete(widget.ucId);
    if (mounted) {
      _showCompletionDialog(xp);
    }
  }

  void _showCompletionDialog(int xp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text('Challenge Completed!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Your mind grew stronger today.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text('+$xp XP',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 24)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Training'),
            ),
          ),
        ],
      ),
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
    final activeDifficulty = provider.getActiveDebateDifficulty(uc);
    final requiredResponses = provider.getCompletionResponseRequirement(uc);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(challenge.title,
            style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
        actions: [
          if (!isCompleted && uc.responseCount >= requiredResponses)
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            '${activeDifficulty.label} debate',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
          _buildBottomBar(isCompleted, hintsLeft, typeColor, requiredResponses),
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

  Widget _buildBottomBar(
    bool isCompleted,
    int hintsLeft,
    Color typeColor,
    int requiredResponses,
  ) {
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
                  'Responses: ${context.watch<AppProvider>().getChallenge(widget.ucId)?.responseCount ?? 0}/$requiredResponses',
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
