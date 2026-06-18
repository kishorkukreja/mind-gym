# Issue 013: Firebase Auth and Firestore Architecture

## Status

- Issue: #13, "Prepare Firebase auth and Firestore architecture"
- Parent PRD: `docs/prd-mind-gym-product-improvements.md`
- Blocker context: #2, "Make the project runnable and documented"
- Decision state: accepted for implementation planning
- Backend direction: Firebase Authentication plus Cloud Firestore

Issue #13 is marked blocked by #2 because the repository still needs baseline
README/setup cleanup. This architecture does not depend on those cleanup changes
being merged, but implementation agents should expect the current app to remain
local-first until the first Firebase slice is intentionally introduced.

## Decision

Mind Gym will use Firebase Authentication as the account identity layer and
Cloud Firestore as the production persistence layer.

Google Sign-In is the confirmed primary account path. Each signed-in account is
represented by the Firebase Auth `uid`; Firestore documents use that `uid` as
the stable user document id. The existing username/PIN model remains a local
prototype-only entry path until replaced by Google Sign-In and optional guest
trial mode.

Firestore will store user profile data, schedule/settings, challenge
assignments, debate history, XP, streaks, weekly summaries, and saved insights.
The first Firebase implementation should preserve the current local-first
training loop and migrate local state only after a user signs in.

## Goals

- Replace production account identity with Firebase Auth and Google Sign-In.
- Preserve a low-friction guest/local trial before sign-in.
- Define Firestore documents for all current local data and near-term PRD data.
- Make local-to-Firebase migration deterministic and recoverable.
- Support offline reads and queued writes through Firestore local persistence.
- Avoid storing sensitive OpenRouter API keys in Firestore.

## Non-Goals

- Do not implement Firebase in this issue.
- Do not add account switching beyond Firebase Auth's current signed-in user.
- Do not build an admin CMS for challenge content.
- Do not move OpenRouter secrets to shared Firestore documents.
- Do not define payments, leaderboards, social graphs, or analytics.

## Current Local Model

Current persistence lives in `SharedPreferences` through
`lib/services/storage_service.dart`.

Existing local keys:

| Local key | Meaning | Firebase destination |
| --- | --- | --- |
| `mg_users` | List of local `UserModel` records, including PIN hash, XP, streaks, schedule, and OpenRouter key | `users/{uid}` plus `users/{uid}/settings/app` plus local secure storage for secrets |
| `mg_current_user` | Current local user id | Firebase Auth current user; guest id while unsigned |
| `mg_challenges_{userId}` | User challenge instances and debate messages | `users/{uid}/assignments/{assignmentId}` and `users/{uid}/debates/{debateId}` |
| `mg_weekly_assignments_{userId}` | Current week assignment ids and recent challenge ids | `users/{uid}/assignmentWeeks/{weekKey}` |

Current models that must map cleanly:

- `UserModel`: profile, XP, level, completion counts, skipped counts, streaks,
  weekly stats, schedule preferences, created date.
- `UserChallenge`: assigned challenge instance, status, schedule/open/complete
  timestamps, hints used, XP earned, response count, conversation, self
  assessment, quality score.
- `ChallengeMessage`: role, content, timestamp.
- `Challenge`: content metadata currently hardcoded in Dart.

## Identity Model

### Signed-In Users

- Firebase Auth provider: Google.
- Firestore user id: Firebase Auth `uid`.
- Firestore document path: `users/{uid}`.
- Email and display name come from Firebase Auth provider claims and are copied
  into the profile document for display only.
- Firestore rules must never trust copied profile email for authorization; rules
  check `request.auth.uid`.

### Guest Trial Users

Guest trial mode remains local-only by default.

- Guest users can start one starter challenge without signing in.
- Guest ids use a local prefix such as `guest_{uuid}` and must never be used as
  Firestore document ids.
- Guest challenge data is stored locally until the user signs in.
- After Google Sign-In, the app offers to attach the guest trial data to the
  signed-in Firebase account.
- If the user declines migration, guest data stays local and can be cleared from
  the device.

Firebase anonymous auth is intentionally deferred. It can be introduced later if
we need cross-device anonymous continuity, but the first slice should avoid
creating backend accounts for every trial user.

### Legacy Local PIN Users

Existing PIN users are local identities, not production accounts.

- PIN hash is not migrated to Firestore.
- Username can be migrated as `profile.displayNameCandidate` if the user has no
  Google display name.
- Local users migrate only after explicit Google Sign-In.
- Multiple local users on the same device require a picker before migration.

## Firestore Layout

All user-owned documents live under `users/{uid}` unless explicitly marked as
global content.

```text
users/{uid}
users/{uid}/settings/app
users/{uid}/assignmentWeeks/{weekKey}
users/{uid}/assignments/{assignmentId}
users/{uid}/debates/{debateId}
users/{uid}/debates/{debateId}/messages/{messageId}
users/{uid}/xpEvents/{eventId}
users/{uid}/streakEvents/{eventId}
users/{uid}/savedInsights/{insightId}
challenges/{challengeId}
migrations/{uid}
```

### `users/{uid}`

Owns profile and aggregate progress. Keep this document small enough to load on
app start.

```json
{
  "uid": "firebase-auth-uid",
  "schemaVersion": 1,
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "lastActiveAt": "2026-06-18T20:30:00.000Z",
  "auth": {
    "primaryProvider": "google.com",
    "providerIds": ["google.com"],
    "emailVerified": true
  },
  "profile": {
    "displayName": "Kish",
    "displayNameCandidate": "localUsername",
    "photoUrl": "https://lh3.googleusercontent.com/a/example-user-photo",
    "locale": "en-GB"
  },
  "progress": {
    "xp": 320,
    "level": 3,
    "totalChallengesCompleted": 4,
    "totalChallengesSkipped": 1,
    "completedAssignmentIds": ["assignment_123"],
    "skippedAssignmentIds": ["assignment_456"]
  },
  "streaks": {
    "activity": {
      "current": 3,
      "best": 8,
      "lastActiveDate": "2026-06-18"
    },
    "weeklyCompletion": {
      "current": 2,
      "best": 5,
      "lastCompletedWeek": "2026-W25"
    },
    "perfectWeek": {
      "current": 1,
      "best": 2,
      "lastPerfectWeek": "2026-W25"
    }
  },
  "migration": {
    "source": "local-shared-preferences",
    "completedAt": "2026-06-18T20:31:00.000Z",
    "localUserId": "legacy-local-uuid"
  }
}
```

Implementation notes:

- `progress.completedAssignmentIds` and `progress.skippedAssignmentIds` are
  convenience snapshots only. The source of truth is `assignments`.
- If the arrays grow too large, replace them with counts and recent ids only.
- Use transactions or batched writes when updating progress totals with
  assignment completion.

### `users/{uid}/settings/app`

Stores user preferences and non-secret configuration.

```json
{
  "schemaVersion": 1,
  "updatedAt": "serverTimestamp",
  "schedule": {
    "weekdayChallengeDay": 3,
    "weekdayHour": 22,
    "weekendChallengeDay": 6,
    "weekendHour": 17,
    "timezone": "Europe/London"
  },
  "notifications": {
    "challengeRemindersEnabled": false,
    "streakRiskWarningsEnabled": true
  },
  "debate": {
    "tone": "constructive-ruthless",
    "difficultyAdaptationEnabled": true
  },
  "privacy": {
    "saveDebateHistory": true,
    "saveInsights": true
  },
  "integrations": {
    "openRouterKeyStorage": "local-secure-storage"
  }
}
```

OpenRouter API keys must remain in device secure storage or a later server-side
secret store. Do not write raw API keys to Firestore.

### `users/{uid}/assignmentWeeks/{weekKey}`

Represents deterministic weekly assignment selection.

```json
{
  "schemaVersion": 1,
  "weekKey": "2026-W25",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "assignmentIds": ["assignment_weekday_2026_w25", "assignment_weekend_2026_w25"],
  "challengeIds": ["trolley_problem", "confirmation_bias"],
  "recentChallengeIds": [
    "sunk_cost",
    "plato_cave",
    "trolley_problem",
    "confirmation_bias"
  ],
  "timezone": "Europe/London",
  "selectionVersion": "local-v1"
}
```

Implementation notes:

- `weekKey` should match the local schedule service's Monday-based key until a
  better ISO week helper is introduced.
- Create or update this document in the same batch as the week's assignments.
- `recentChallengeIds` is a rotation hint, not user-visible history.

### `users/{uid}/assignments/{assignmentId}`

One scheduled challenge instance for one user.

```json
{
  "schemaVersion": 1,
  "assignmentId": "assignment_weekday_2026_w25",
  "challengeId": "trolley_problem",
  "debateId": "debate_assignment_weekday_2026_w25",
  "weekKey": "2026-W25",
  "slot": "weekday",
  "status": "inProgress",
  "scheduledFor": "2026-06-17T22:00:00.000+01:00",
  "openedAt": "2026-06-17T22:05:00.000+01:00",
  "completedAt": null,
  "skippedAt": null,
  "expiresAt": "2026-06-21T22:00:00.000+01:00",
  "hintsUsed": 1,
  "responseCount": 2,
  "xpEarned": 0,
  "qualityScore": null,
  "selfAssessmentNote": null,
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "lastClientWriteId": "device-uuid:write-uuid"
}
```

Allowed `status` values:

- `pending`: scheduled but not yet available.
- `open`: available and not started.
- `inProgress`: user opened or sent at least one debate message.
- `completed`: user completed the challenge and XP was awarded.
- `skipped`: expired or explicitly skipped.
- `expired`: optional future display state; the current implementation can map
  expired pending assignments to `skipped`.

Implementation notes:

- `assignmentId` should be stable for migrated local records; use the existing
  `UserChallenge.id` where available.
- Completion writes must update `assignments`, `debates`, `xpEvents`, and
  aggregate `users/{uid}.progress` together.
- Status transitions should be monotonic. Do not let a stale offline write move
  `completed` back to `inProgress`.

### `users/{uid}/debates/{debateId}`

Stores debate-level metadata and evaluation results.

```json
{
  "schemaVersion": 1,
  "debateId": "debate_assignment_weekday_2026_w25",
  "assignmentId": "assignment_weekday_2026_w25",
  "challengeId": "trolley_problem",
  "startedAt": "2026-06-17T22:05:00.000+01:00",
  "lastMessageAt": "2026-06-17T22:18:00.000+01:00",
  "completedAt": null,
  "messageCount": 5,
  "userMessageCount": 2,
  "assistantMessageCount": 3,
  "hintsUsed": 1,
  "evaluation": {
    "qualityScore": null,
    "clarity": null,
    "counterargumentHandling": null,
    "selfCorrection": null,
    "specificity": null,
    "originality": null,
    "intellectualHonesty": null,
    "summary": null
  },
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

### `users/{uid}/debates/{debateId}/messages/{messageId}`

Messages are a subcollection so long debate histories do not inflate assignment
documents.

```json
{
  "schemaVersion": 1,
  "messageId": "01JY4YKZ7P63W8F9W6AQ0A5BDR",
  "displaySequence": 3,
  "role": "assistant",
  "content": "What assumption are you making about harm here?",
  "createdAt": "2026-06-17T22:12:00.000+01:00",
  "clientCreatedAt": "2026-06-17T22:12:00.000+01:00",
  "kind": "debate",
  "metadata": {
    "isHint": false,
    "hintTier": null,
    "aiProvider": "openrouter",
    "model": "configured-client-model"
  },
  "lastClientWriteId": "device-uuid:write-uuid"
}
```

Message ids must be collision-resistant. Use Firestore auto ids, ULIDs, or a
deterministic hash of `lastClientWriteId`; do not use only sequential ids such
as `msg_000003` as document ids. If the UI needs a stable transcript order,
store a separate `displaySequence` and sort by `createdAt`, then
`displaySequence`, then `messageId`.

Allowed `role` values:

- `user`
- `assistant`
- `system`

Allowed `kind` values:

- `debate`
- `hint`
- `completionSummary`
- `systemNotice`

### `users/{uid}/xpEvents/{eventId}`

Append-only ledger of XP changes.

```json
{
  "schemaVersion": 1,
  "eventId": "xp_assignment_weekday_2026_w25_complete",
  "assignmentId": "assignment_weekday_2026_w25",
  "challengeId": "trolley_problem",
  "type": "challengeCompleted",
  "delta": 145,
  "balanceAfter": 320,
  "breakdown": {
    "difficultyBase": 120,
    "hintPenalty": -10,
    "engagementBonus": 15,
    "onTimeBonus": 20,
    "qualityBonus": 0
  },
  "createdAt": "serverTimestamp"
}
```

Allowed `type` values:

- `challengeCompleted`
- `challengeSkipped`
- `manualAdjustment`
- `migrationImport`

Implementation notes:

- XP totals in `users/{uid}.progress.xp` are aggregate snapshots.
- The ledger is useful for auditability and user-facing "why did I earn this"
  explanations.

### `users/{uid}/streakEvents/{eventId}`

Append-only ledger for streak-affecting activity.

```json
{
  "schemaVersion": 1,
  "eventId": "streak_2026_06_18_activity",
  "assignmentId": "assignment_weekday_2026_w25",
  "type": "activity",
  "date": "2026-06-18",
  "weekKey": "2026-W25",
  "delta": 1,
  "currentAfter": 3,
  "bestAfter": 8,
  "createdAt": "serverTimestamp"
}
```

Allowed `type` values:

- `activity`
- `weeklyCompletion`
- `perfectWeek`
- `streakReset`

### `users/{uid}/savedInsights/{insightId}`

Stores user-saved reflections from debates.

```json
{
  "schemaVersion": 1,
  "insightId": "insight_2026_06_18_001",
  "assignmentId": "assignment_weekday_2026_w25",
  "debateId": "debate_assignment_weekday_2026_w25",
  "challengeId": "trolley_problem",
  "title": "I confuse harm avoided with harm caused",
  "body": "My argument assumed inaction is morally neutral.",
  "tags": ["trolley_problem", "omission_bias"],
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "sourceMessageIds": ["msg_000004", "msg_000005"],
  "isArchived": false
}
```

### `challenges/{challengeId}`

Global challenge content can remain hardcoded during the first Firebase slice,
but this is the target shape once content moves out of Dart source.

```json
{
  "schemaVersion": 1,
  "challengeId": "trolley_problem",
  "title": "The Trolley Problem",
  "question": "A runaway trolley is headed toward five people. You can pull a lever to divert it onto a track with one person. What should you do, and why?",
  "type": "philosophy",
  "sourceName": "Philippa Foot",
  "sourceDescription": "A classic dilemma in moral philosophy.",
  "hintTiers": [
    "Separate consequences from intentions.",
    "Compare action with inaction.",
    "Ask whether using a person as a means changes the moral math."
  ],
  "category": "moral_reasoning",
  "tags": ["ethics", "consequentialism", "deontology"],
  "difficulty": 3,
  "estimatedMinutes": 12,
  "thinkingAngles": [
    "What counts as causing harm?",
    "Are duties different from outcomes?"
  ],
  "isActive": true,
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

## Local-to-Firebase Migration

Migration starts only after successful Google Sign-In.

### Migration States

`migrations/{uid}` tracks device migration attempts.

```json
{
  "schemaVersion": 1,
  "uid": "firebase-auth-uid",
  "state": "completed",
  "source": "shared_preferences",
  "localUserId": "legacy-local-uuid",
  "startedAt": "2026-06-18T20:30:00.000Z",
  "completedAt": "2026-06-18T20:31:00.000Z",
  "counts": {
    "users": 1,
    "assignments": 12,
    "debates": 8,
    "messages": 64,
    "xpEvents": 1,
    "savedInsights": 0
  },
  "errors": []
}
```

Allowed states:

- `notStarted`
- `localScanComplete`
- `userConfirmed`
- `uploading`
- `completed`
- `failed`
- `declined`

### Migration Flow

1. On app start, detect local users from `mg_users`.
2. If no Firebase user exists, continue local or guest mode.
3. After Google Sign-In, load or create `users/{uid}`.
4. If local users exist and `migrations/{uid}.state` is neither `completed` nor
   `declined`, show a migration prompt. `declined` suppresses automatic prompts
   and remains manually retryable from settings.
5. If exactly one local user exists, offer to migrate that user.
6. If multiple local users exist, require the user to choose one local profile.
7. Build a migration preview: username, XP, level, completed count, skipped
   count, active assignments, debate count.
8. After confirmation, write `migrations/{uid}` as `uploading`.
9. Write the user profile, settings, assignment weeks, assignments, debates,
   messages, XP import event, and streak import event in idempotent chunks.
   Firestore batched writes are limited to 500 operations, so use chunks of 400
   writes or fewer and store chunk progress in `migrations/{uid}.chunks`.
10. Re-read or count the uploaded target documents and compare them with the
   migration preview counts.
11. Mark `migrations/{uid}` as `completed` only after all chunks are committed
   and count verification passes.
12. Mark local data as migrated with the target `uid`.
13. Keep local data for rollback until one successful post-migration app start.

### Merge Rules

If the Firebase account already has data:

- Keep the Firebase profile identity from Google.
- Add local XP as a `migrationImport` XP event only once.
- Do not duplicate assignments with the same migrated assignment id.
- For current-week assignment conflicts, prefer the Firebase assignment if it is
  `completed` or `inProgress`; otherwise prefer the newer `updatedAt`.
- Merge saved insights by generated `insightId`; if ids conflict, preserve both
  by suffixing the local id with `_local_{shortHash}`.
- Never migrate PIN hashes.
- Never migrate raw OpenRouter API keys into Firestore.

### Rollback and Retry

- All migration writes should be idempotent.
- Each migrated document should include `migration.localUserId` and
  `migration.sourceDocumentId` where useful.
- Chunk ids should be deterministic, for example `profile`, `settings`,
  `assignments_000`, `messages_000`, and `events_000`, so retries can resume
  without duplicating writes.
- If migration fails before completion, retry from `migrations/{uid}`.
- If migration completes but local cleanup fails, do not re-upload duplicates on
  next launch.

## Offline and Sync Behavior

Firestore offline persistence should be enabled for supported Flutter targets.

### Offline Reads

- On signed-in app start, show cached Firestore data if available.
- If no cache exists and the device is offline, fall back to local guest mode or
  show a signed-in offline empty state.
- Hardcoded challenge content remains available offline until challenge content
  is moved to Firestore.

### Offline Writes

Allow offline queued writes for:

- opening a challenge,
- sending user debate messages,
- recording hint usage,
- saving insights,
- updating non-secret settings,
- marking a challenge complete when enough local data exists to compute XP.

Avoid offline writes for:

- first-time migration upload,
- Google Sign-In itself,
- server-only integrity repair,
- remote challenge content publishing.

### Conflict Assumptions

Mind Gym is primarily single-user and single-active-device for the first
Firebase slice. Firestore may still receive writes from multiple devices, so the
data model uses conservative conflict rules:

- `updatedAt` is used for simple settings last-write-wins.
- Assignment status is monotonic:
  `pending -> open -> inProgress -> completed|skipped`.
- `completed` and `skipped` are terminal unless a future repair tool changes
  them.
- Debate messages are append-only and ordered by `createdAt` plus `messageId`.
- XP and streak changes use append-only ledgers plus aggregate snapshots.
- Repeated completion attempts must be idempotent by deterministic `eventId`.
- Every client write should include `lastClientWriteId` for duplicate detection
  during retries.

## Security Rules Expectations

Rules should enforce owner-only access for user data:

```text
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

This broad owner rule is a starting boundary, not sufficient final validation.
Implementation agents must replace it with path-specific create/update rules
before production release.

Path-specific expectations:

- `users/{uid}`: clients may create their own profile document only when
  `request.resource.data.uid == request.auth.uid`. `uid`, `createdAt`, and
  `migration.completedAt` are immutable after creation. Copied auth metadata
  must be display-only and may not grant privileges.
- `users/{uid}/settings/app`: clients may write schedule, notification, debate,
  and privacy settings. Reject any field that looks like a raw API key, token,
  or provider secret.
- `users/{uid}/assignments/{assignmentId}`: clients may move status forward
  only through allowed transitions and may not change `challengeId`, `weekKey`,
  or `scheduledFor` after creation.
- `users/{uid}/debates/{debateId}/messages/{messageId}`: clients may create
  append-only messages with allowed `role` and `kind` values. Updates and
  deletes should be rejected in the first slice.
- `users/{uid}/xpEvents/{eventId}`: clients may create deterministic
  `challengeCompleted`, `challengeSkipped`, and `migrationImport` events.
  Clients may not create `manualAdjustment` events.
- `users/{uid}/streakEvents/{eventId}`: clients may create deterministic
  streak events tied to assignment completion, skip, or migration. Updates and
  deletes should be rejected.
- Aggregate XP and streak fields in `users/{uid}` must be written through a
  repository transaction that creates deterministic ledger event ids first.
  Repeated writes with the same event id must be idempotent.

Global challenge content should be readable by signed-in users and writable only
by admin tooling:

```text
match /challenges/{challengeId} {
  allow read: if request.auth != null;
  allow write: if false;
}
```

Migration documents are user-owned control records:

```text
match /migrations/{uid} {
  allow read, create, update: if request.auth != null && request.auth.uid == uid;
  allow delete: if false;
}
```

Migration rule validation should require `uid == request.auth.uid`, allowed
state values only, monotonic state transitions, deterministic chunk ids, and no
raw PIN hashes or OpenRouter API keys in `errors`, `counts`, or chunk metadata.

Additional validation to add during implementation:

- `users/{uid}.uid` must equal `request.auth.uid`.
- `settings/app.integrations.openRouterKeyStorage` must not contain secret
  values.
- Assignment status must be one of the allowed status values.
- Debate message `role` and `kind` must be one of the allowed values.
- User-owned subcollection writes must not target another user's `uid`.
- `manualAdjustment` XP events require trusted admin infrastructure and are not
  accepted from mobile clients.

## Index Expectations

Initial query patterns:

- Current assignments for a week:
  `users/{uid}/assignments where weekKey == ? orderBy scheduledFor`
- Assignment history:
  `users/{uid}/assignments orderBy scheduledFor desc limit 50`
- Debate history:
  `users/{uid}/debates orderBy lastMessageAt desc limit 50`
- Saved insights:
  `users/{uid}/savedInsights where isArchived == false orderBy createdAt desc`
- XP ledger:
  `users/{uid}/xpEvents orderBy createdAt desc limit 50`

Firestore will prompt for composite indexes if a query requires them. The first
implementation should keep queries simple and collection-scoped under a single
user to avoid premature global indexes.

## First Firebase Implementation Slice

Implementation agents should build in this order:

1. Add Firebase project configuration and Flutter Firebase packages.
2. Add an auth service boundary that exposes current Firebase user, Google
   Sign-In, sign-out, and auth state stream.
3. Add a Firestore user repository for `users/{uid}` and `settings/app`.
4. Keep existing `StorageService` as the local source while wiring read-only
   signed-in profile creation.
5. Add migration preview logic from current `SharedPreferences` data.
6. Add migration upload for profile, settings, assignment weeks, assignments,
   debates, and messages.
7. Switch signed-in users to Firestore-backed assignments and debate history.
8. Add saved insights after debate persistence is stable.
9. Add XP and streak event ledgers around completion and skip flows.
10. Add security rules and emulator-backed tests for owner-only data access.

## Acceptance Checklist

- Firebase Auth with Google Sign-In is the confirmed account identity path.
- Firestore shapes are defined for profiles and aggregate progress.
- Firestore shapes are defined for settings.
- Firestore shapes are defined for challenge assignments and weekly assignment
  selection.
- Firestore shapes are defined for debate history and messages.
- Firestore shapes are defined for XP and streaks.
- Firestore shapes are defined for saved insights.
- Local-first migration behavior is documented for existing users.
- Guest/local trial behavior is defined.
- Offline and sync-conflict assumptions are documented.
- Security, indexing, and implementation sequencing are specified for future
  implementation agents.
