import '../models/challenge_model.dart';

class ChallengeStateCopy {
  final String badge;
  final String homeAction;
  final String? debateBlockedMessage;

  const ChallengeStateCopy({
    required this.badge,
    required this.homeAction,
    this.debateBlockedMessage,
  });

  static ChallengeStateCopy forStatus(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.pending:
        return const ChallengeStateCopy(
          badge: 'Pending',
          homeAction: 'Opens later',
          debateBlockedMessage: 'This challenge is still pending.',
        );
      case ChallengeStatus.ready:
        return const ChallengeStateCopy(
          badge: 'Ready',
          homeAction: 'Start debate',
        );
      case ChallengeStatus.inProgress:
        return const ChallengeStateCopy(
          badge: 'In progress',
          homeAction: 'Resume debate',
        );
      case ChallengeStatus.completed:
        return const ChallengeStateCopy(
          badge: 'Completed',
          homeAction: 'Completed',
          debateBlockedMessage: 'This challenge is already completed.',
        );
      case ChallengeStatus.skipped:
        return const ChallengeStateCopy(
          badge: 'Skipped',
          homeAction: 'Skipped',
          debateBlockedMessage: 'This challenge was skipped.',
        );
      case ChallengeStatus.expired:
        return const ChallengeStateCopy(
          badge: 'Expired',
          homeAction: 'Expired',
          debateBlockedMessage:
              'This challenge expired before it was completed.',
        );
    }
  }

  static String mutationBlockedMessage(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.pending:
        return 'Challenge is pending.';
      case ChallengeStatus.completed:
        return 'Challenge is already completed.';
      case ChallengeStatus.skipped:
        return 'Challenge is skipped.';
      case ChallengeStatus.expired:
        return 'Challenge is expired.';
      case ChallengeStatus.ready:
      case ChallengeStatus.inProgress:
        return '';
    }
  }
}
