# Issue 004: Weekly Challenge States

## Source

- GitHub issue: #4, "Clarify weekly challenge state end to end"
- Parent PRD: `docs/prd-mind-gym-product-improvements.md`

## Problem

Weekly challenges currently have partially implicit states. A challenge can be
stored as `pending`, `open`, `inProgress`, `completed`, or `skipped`, while the
home screen derives "ready" from time and expiration is a transient computed
property. That makes user-visible behavior hard to verify: home cards can call
an expired pending challenge ready, debate entry can start challenges that
should be terminal, and restart behavior depends on whether transition logic
has run.

## Goals

- Represent `pending`, `ready`, `inProgress`, `completed`, `skipped`, and
  `expired` explicitly in the challenge model and persisted JSON.
- Keep weekly assignments local-first and stable across app restart.
- Promote due pending challenges to `ready` and stale pending/ready challenges
  to `expired` through one scheduling transition path.
- Make home cards, debate entry, debate controls, and progress reporting match
  the stored challenge state.
- Cover the main transitions and user-visible behavior with tests.

## State Definitions

| State | Meaning | Home behavior | Debate behavior | Progress behavior |
| --- | --- | --- | --- | --- |
| `pending` | Scheduled for a future time. | Locked card with "Pending" badge and countdown copy. | Entry is blocked. | Not counted as attempted. |
| `ready` | Scheduled time has arrived and the user has not started. | Highlighted card with "Ready" badge and start CTA. | Entry starts debate and persists `inProgress`. | Not counted as attempted. |
| `inProgress` | User opened or interacted with the debate. | Highlighted card with "In progress" badge and resume CTA. | Message, hint, and completion controls are enabled. | Not counted as complete until completed. |
| `completed` | User completed the debate and earned XP. | Terminal card with XP summary. | Read-only completion state. | Counts as completed. |
| `skipped` | User intentionally skipped a challenge. | Terminal skipped card. | Entry is blocked. | Counts as skipped. |
| `expired` | The available window elapsed before completion. | Terminal expired card. | Entry is blocked. | Counts as missed/skipped for progress totals. |

## Transition Rules

- Weekly assignment creation starts both challenges as `pending`.
- `pending` becomes `ready` when `now >= scheduledFor`.
- `pending` or `ready` becomes `expired` when `now > scheduledFor + 4 days`.
- `ready` becomes `inProgress` when the user enters debate.
- `inProgress` remains `inProgress` after hints and messages.
- `inProgress` becomes `completed` only through the completion action.
- `skipped`, `expired`, and `completed` are terminal for issue #4.
- Expiry is idempotent: progress counters and ID lists are updated only once.
- Legacy stored `open` JSON values are restored as `ready`.

## Implementation Notes

- Add helper methods on `UserChallenge` for availability, terminal state,
  expiry deadline, and transition decisions.
- Route schedule reconciliation through `ScheduleService.refreshChallengeStates`
  and call it before weekly challenges are shown or read after login/restart.
- Keep the existing local persistence shape but save transitioned challenges and
  user progress immediately.
- Add `expiredChallengeIds` to `UserModel` so expiration is durable and
  idempotent without conflating storage state with manual skip state.
- Count expired challenges in weekly and all-time missed totals while preserving
  a distinct `expired` state for UI and behavior.

## Out of Scope

- Fixing broad mojibake or copy tone from issue #1.
- Adding notifications, reminders, backend sync, or Firebase persistence.
- Implementing a manual skip action if no existing UI control is present.
- Changing the XP scoring algorithm beyond the existing expiry penalty behavior.

## Verification

- Model tests for JSON restoration of `ready`, `expired`, and legacy `open`.
- Schedule tests for `pending -> ready`, `pending/ready -> expired`, idempotent
  expiry progress accounting, and persisted restart restoration.
- Provider tests for blocked terminal entry and ready-to-in-progress persistence.
- Widget tests for visible home and debate state copy where the local test
  environment supports Flutter.
