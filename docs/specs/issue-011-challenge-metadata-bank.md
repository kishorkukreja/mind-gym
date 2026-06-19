# Issue 011 Challenge Metadata Bank Spec

## Source Context

- GitHub issue: #11, "Add more challenge content with metadata"
- Parent PRD: `docs/prd-mind-gym-product-improvements.md`
- Blocker context: #1 is still open and covers broken user-facing text. This issue should not introduce new mojibake or symbol-heavy copy.

## Goal

Expand the local challenge bank into a richer, metadata-aware content slice while preserving the current two-challenge weekly training loop.

## Requirements

- `Challenge` exposes category, tags, difficulty, estimated time, type, and optional variants.
- Challenge content covers philosophy, cognitive bias, logic, decision theory, statistics, rhetoric, and media literacy.
- Weekly assignment still returns two challenges, preferring one philosophy-style challenge and one cognitive-bias-style challenge when available.
- Selection uses metadata to rotate categories and avoid recently assigned IDs and near-duplicate variants.
- Home and debate screens show useful metadata without adding clutter.
- Tests cover metadata availability and weekly selection behavior.

## Product Decisions

- Keep content in Dart for this issue because the PRD says externalized content should happen after the model stabilizes.
- Keep `ChallengeType.philosophy` and `ChallengeType.cognitiveBias` as schedule lanes for compatibility, and add broader challenge types for expanded domains.
- Treat `category` as the user-visible domain label and `tags` as lightweight searchable/selection metadata.
- Treat variants as alternate prompt framings under a parent challenge. Variant IDs must be distinct from parent IDs so recent assignment checks can avoid repeats.
- Show metadata as compact chips: type/category, difficulty, estimated time, and up to two tags.

## Out Of Scope

- Moving challenge content out of Dart source.
- Reworking challenge scheduling persistence.
- Closing or fixing all of #1's existing broken strings.
- Backend, analytics, adaptive difficulty, or a full content authoring tool.

## Acceptance Checklist

- Challenge model supports the required metadata fields.
- The bank includes at least one challenge in every listed domain.
- Weekly selection is metadata-aware and preserves philosophy/bias balance where possible.
- Home and debate screens display compact metadata.
- Tests cover metadata completeness, domain coverage, variants, and weekly selection.
