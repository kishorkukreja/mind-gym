# Issue 010: Debate Difficulty Selection

## Context

GitHub issue: #10, "Add debate difficulty selection".

Parent PRD: `docs/prd-mind-gym-product-improvements.md`.

Blocker context: issue #10 is marked blocked by #9, "Use AI evaluation in one debate completion path". Issue #9 is open and adds structured evaluation metadata later. This implementation avoids depending on that metadata and keeps completion gating response-count based, with difficulty-specific thresholds that can be replaced by evaluation readiness once #9 lands.

## Goals

- Let users keep debate difficulty on `inherit` or explicitly choose `beginner`, `intermediate`, or `advanced`.
- Persist the selected preference in local user storage.
- Show the active debate difficulty in the debate screen.
- Adapt AI debate prompts by difficulty for tone, terminology, rigor, and completion expectations.
- Vary completion expectations by difficulty without requiring structured evaluation metadata.
- Cover prompt behavior and persisted preference with deterministic tests.

## Product Behavior

### Preference

The setting is stored on `UserModel` as a preference:

- `inherit`: derive the active mode from challenge difficulty.
- `beginner`: use accessible language and more scaffolding.
- `intermediate`: use balanced Socratic pressure and moderate rigor.
- `advanced`: use higher rigor, sharper counterarguments, and technical terminology.

### Inherited Mode

When the user preference is `inherit`, active difficulty is derived from the challenge difficulty:

- challenge difficulty 1-2 => beginner
- challenge difficulty 3 => intermediate
- challenge difficulty 4-5 => advanced

### Completion Expectations

Until issue #9 provides structured AI readiness metadata, completion requires a minimum number of user responses:

- beginner: 2
- intermediate: 3
- advanced: 4

These thresholds are intentionally simple and local. They preserve the existing fallback behavior and provide the hook for future AI readiness.

## Out Of Scope

- Structured AI evaluation metadata.
- Quality-score persistence changes.
- XP formula changes.
- Backend or account sync.
