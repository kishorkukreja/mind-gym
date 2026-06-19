# Issue 001: Fix Text Encoding Across Challenge Flow

## Context

GitHub issue: #1, "Fix broken text across a complete challenge flow"

Parent PRD: `docs/prd-mind-gym-product-improvements.md`

The app currently shows mojibake in the local-first training loop, including encoded emoji, em dashes, bullets, arrows, middots, and pound symbols. These strings appear in challenge prompts, hints, AI fallback/error copy, screen labels, progress copy, and settings details.

## Goal

A user can register, open a challenge, debate, request a hint, complete the challenge, and view progress/settings without broken encoded characters in user-facing text.

## Acceptance Criteria

- Registration/login, home, debate, hints, completion, progress, and settings screens do not show obvious mojibake.
- Challenge content uses clean punctuation, ASCII alternatives, or valid symbols that render correctly.
- AI fallback/error messages render cleanly.
- A lightweight regression test catches obvious mojibake patterns before they reach the UI.
- Local-first behavior remains unchanged: user data, challenge assignment, hints, completion, and progress continue to use local storage and existing provider flows.

## Scope

In scope:

- Replace corrupted text literals in `lib/`.
- Add a focused regression test for obvious mojibake markers.
- Keep behavior and data contracts unchanged.

Out of scope:

- Rewriting challenge content for tone or pedagogy.
- Changing the XP algorithm.
- Changing authentication/storage behavior.
- Adding network-first or server-backed flows.

## Implementation Notes

Prefer clean ASCII where symbols are decorative or risk font/encoding issues:

- Replace encoded emoji with existing Material icons or ASCII text.
- Replace corrupted em dashes/arrows/middots with `-`, `->`, or `-`.
- Replace corrupted bullet glyphs with simple dots or existing dot widgets.
- Replace corrupted pound signs with `GBP`.

Do not sanitize user-generated conversation text at render time; this issue is about app-authored strings and bundled challenge content.
