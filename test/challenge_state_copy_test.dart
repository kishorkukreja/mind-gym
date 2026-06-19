import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/utils/challenge_state_copy.dart';

void main() {
  test('provides user-visible labels for every weekly challenge state', () {
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.pending).badge,
      'Pending',
    );
    expect(ChallengeStateCopy.forStatus(ChallengeStatus.ready).badge, 'Ready');
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.inProgress).badge,
      'In progress',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.completed).badge,
      'Completed',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.skipped).badge,
      'Skipped',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.expired).badge,
      'Expired',
    );
  });

  test('matches home card actions to state behavior', () {
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.pending).homeAction,
      'Opens later',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.ready).homeAction,
      'Start debate',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.inProgress).homeAction,
      'Resume debate',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.completed).homeAction,
      'Completed',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.skipped).homeAction,
      'Skipped',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.expired).homeAction,
      'Expired',
    );
  });

  test('provides debate terminal copy for blocked states', () {
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.pending).debateBlockedMessage,
      'This challenge is still pending.',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.skipped).debateBlockedMessage,
      'This challenge was skipped.',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.expired).debateBlockedMessage,
      'This challenge expired before it was completed.',
    );
    expect(
      ChallengeStateCopy.forStatus(ChallengeStatus.ready).debateBlockedMessage,
      isNull,
    );
  });
}
