# Issue 012: External Challenge Content

## Context

GitHub issue #12 asks for challenge definitions to move out of Dart source into structured local content files while preserving the current weekly assignment, home, debate, hints, and completion flows.

Issue #12 is marked blocked by #11. Issue #11 is still open and asks for richer challenge metadata, so this work keeps the existing model fields stable and uses a schema that can later grow with tags, estimated time, variants, and additional metadata without changing screens again.

The PRD driver is developer story 48: challenge content should live outside Dart source so content can be edited without rebuilding app logic. The relevant testing direction is to add coverage at the challenge library/content repository boundary.

## Goals

- Store the existing challenge bank in structured local JSON content.
- Load challenge content through a repository/service boundary during app startup.
- Keep existing static challenge lookup methods available to scheduling and screens.
- Fail clearly when content is malformed, incomplete, duplicated, or empty.
- Cover valid loading plus at least one error/fallback behavior with tests.

## Non-Goals

- Expand the challenge bank with new issue #11 content.
- Add remote CMS loading.
- Change weekly assignment timing, XP calculation, debate prompts, or completion gating.
- Add the future #11 metadata fields to app surfaces.

## Content Schema

The local asset is `assets/content/challenges.json`:

```json
{
  "version": 1,
  "challenges": [
    {
      "id": "phi_001",
      "title": "...",
      "question": "...",
      "type": "philosophy",
      "sourceName": "...",
      "sourceDescription": "...",
      "hintTiers": ["...", "...", "..."],
      "category": "...",
      "difficulty": 2,
      "thinkingAngles": ["..."]
    }
  ]
}
```

Validation rules:

- `version` must be present.
- `challenges` must be a non-empty list.
- `id`, `title`, `question`, `sourceName`, `sourceDescription`, and `category` must be non-empty strings.
- `type` must be `philosophy` or `cognitiveBias`.
- `difficulty` must be between 1 and 5.
- `hintTiers` must contain at least 3 non-empty strings because debate prompts reference the first three tiers.
- `thinkingAngles` must contain at least one non-empty string.
- Challenge IDs must be unique.

## Plan

1. Add repository tests for JSON parsing, invalid content errors, duplicate IDs, library lookup, weekly type selection, and recent-ID fallback.
2. Add `Challenge.fromJson` validation and a `ChallengeContentException`.
3. Add `ChallengeContentRepository`, `AssetChallengeContentRepository`, and an in-memory repository for tests.
4. Change `ChallengeLibrary` from a hardcoded list to a loaded cache with the same lookup and selection API.
5. Load challenge content from `AppProvider.init()` before user/session challenge loading.
6. Generate `assets/content/challenges.json` from the existing hardcoded bank and remove hardcoded challenge objects from Dart.
7. Register `assets/content/` in `pubspec.yaml`.
8. Run focused tests plus full Flutter tests/analyzer where the local SDK allows it.
