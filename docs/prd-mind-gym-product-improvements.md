# PRD: Mind Gym Product Improvements

## Problem Statement

Mind Gym is a promising Flutter prototype for training critical thinking through scheduled philosophy and cognitive-bias challenges, but the current app still feels like an early MVP. The core product idea is strong, yet several areas weaken trust and retention: local PIN-only auth, broken text encoding, a basic XP algorithm, a limited hardcoded challenge bank, a debate engine without structured evaluation, sparse onboarding, and progress mechanics that do not yet explain what the user is improving.

From the user's perspective, Mind Gym should feel like a serious thinking coach: easy to enter, clear about what to do next, challenging during debate, transparent about scoring, and rewarding in a way that reflects actual reasoning quality rather than simple message count.

## Solution

Improve Mind Gym in staged product increments, starting with foundational quality fixes and then strengthening the learning loop.

The first improvement track should make the app reliable and understandable: fix broken strings, clean up assets, document setup, improve onboarding, and make challenge states clearer. The second track should improve the learning loop: a better AI debate rubric, richer XP scoring, streaks, countdowns, completion feedback, and a larger challenge bank. The third track should prepare for real accounts: Google auth, Firebase-backed persistence, and multi-user support later.

The near-term goal is not to rebuild the app around a backend. The near-term goal is to make the existing local-first Flutter app feel coherent, polished, and product-ready enough to validate the core Mind Gym habit loop.

## User Stories

1. As a new user, I want to understand what Mind Gym does within the first minute, so that I know why I should create an account.
2. As a new user, I want to try one starter challenge immediately, so that I do not have to wait for a schedule before seeing the value.
3. As a new user, I want to register without friction, so that I can start training quickly.
4. As a returning user, I want to sign in with Google, so that I do not have to remember a local PIN.
5. As a returning user, I want my progress to be preserved, so that I can trust the app with my training history.
6. As a guest user, I want to try the app before signing in, so that I can evaluate the experience before committing.
7. As a user, I want clean, readable text throughout the app, so that broken characters do not distract from the challenge content.
8. As a user, I want challenge copy to render quotes, punctuation, currency, and symbols correctly, so that philosophical prompts remain clear.
9. As a user, I want a clear home screen, so that I immediately know which challenge is ready, locked, completed, or skipped.
10. As a user, I want countdowns to the next challenge, so that I know when to return.
11. As a user, I want reminders when a challenge opens, so that I do not forget my training schedule.
12. As a user, I want a visible warning when a streak is at risk, so that I can decide whether to complete a challenge.
13. As a user, I want challenge cards to preview the topic and difficulty, so that I know what kind of thinking session I am entering.
14. As a user, I want philosophy and cognitive-bias challenges to be visually distinct, so that I can scan my weekly training quickly.
15. As a user, I want the app to give me a balanced schedule of challenges, so that I practice different kinds of reasoning.
16. As a user, I want difficulty to progress gradually, so that I am not overwhelmed too early.
17. As a user, I want harder challenges after I improve, so that the app keeps stretching me.
18. As a user, I want a larger challenge bank, so that the app does not become repetitive.
19. As a user, I want challenge variants, so that repeated concepts still feel fresh.
20. As a user, I want challenge categories and tags, so that my training feels organized.
21. As a user, I want hints that reveal progressively more, so that I can keep thinking without being handed the answer.
22. As a user, I want the debate AI to challenge my reasoning, so that I cannot get away with shallow answers.
23. As a user, I want the debate AI to ask targeted follow-up questions, so that I can refine my argument.
24. As a user, I want the debate AI to adapt to my level, so that the debate is neither too easy nor too technical.
25. As a user, I want the debate AI to recognize when I contradict myself, so that I can improve my reasoning.
26. As a user, I want the debate AI to help me consider counterarguments, so that I build stronger positions.
27. As a user, I want the debate AI to stay constructive, so that tough feedback does not become discouraging.
28. As a user without an API key, I want an offline fallback mode, so that the app still works with built-in prompts and hints.
29. As a user with an API key, I want clear API key setup instructions, so that I can enable AI debate confidently.
30. As a user, I want the app to protect sensitive API key input, so that I do not accidentally expose it.
31. As a user, I want to know why I earned a certain XP score, so that the scoring feels fair.
32. As a user, I want XP to reflect reasoning quality, so that thoughtful answers matter more than message volume.
33. As a user, I want the app to discourage XP farming, so that progress represents real learning.
34. As a user, I want a completion summary after each challenge, so that I can see what I did well and what to improve.
35. As a user, I want a quality score for each debate, so that I can track depth of reasoning over time.
36. As a user, I want streaks that distinguish daily activity from weekly completion, so that the app rewards different forms of consistency.
37. As a user, I want perfect-week recognition, so that completing all assigned challenges feels meaningful.
38. As a user, I want skipped challenges to affect my progress transparently, so that penalties do not feel arbitrary.
39. As a user, I want a weekly report, so that I can reflect on my effort and improvement.
40. As a user, I want progress charts, so that I can see trends in XP, completion, streaks, and reasoning quality.
41. As a user, I want a personal bias profile, so that I can see which cognitive biases I struggle with most.
42. As a user, I want to revisit old debates, so that I can compare past and current thinking.
43. As a user, I want to save insights after a debate, so that important realizations are not lost.
44. As a user, I want custom challenges eventually, so that I can test my own beliefs and dilemmas.
45. As a user, I want the UI typography to feel calm and serious, so that long challenge text is pleasant to read.
46. As a user, I want a polished dark mode, so that I can debate and read comfortably at night.
47. As a user, I want fewer generic Flutter-feeling screens, so that the app feels like a deliberate product.
48. As a developer, I want challenge content outside of Dart source code, so that content can be edited without rebuilding app logic.
49. As a developer, I want test coverage around scheduling and XP, so that product mechanics do not regress.
50. As a developer, I want the debate scoring rubric separated from UI code, so that it can evolve without changing screens.
51. As a developer, I want documented setup instructions, so that future contributors can run and validate the app quickly.
52. As a product owner, I want the improvement work split into phases, so that we can ship visible quality improvements before backend work.

## Implementation Decisions

- Keep the current Flutter app structure for the first improvement pass.
- Treat the current local-first app as the base MVP rather than introducing backend sync immediately.
- Prioritize a foundation pass before large feature work: string cleanup, asset cleanup, README, onboarding copy, challenge-state clarity, and basic tests.
- Replace broken encoded characters across user-facing strings with valid UTF-8 or plain ASCII equivalents.
- Introduce a product copy pass for the "ruthless mentor" tone so it remains challenging without becoming hostile.
- Keep PIN auth temporarily, but define Google Sign-In as the preferred future account model.
- Use Firebase as the required backend/database platform for production persistence.
- Treat Firebase Authentication and Cloud Firestore as the default architecture for account identity, user profile data, challenge assignments, debate history, XP, streaks, settings, and saved insights unless a later architecture decision explicitly changes this.
- Defer multi-user account switching until real account auth and persistence are designed.
- Preserve guest or local trial mode so users can experience a starter challenge before account setup.
- Design Google auth as an account layer backed by Firebase so user progress, challenge history, settings, streaks, and saved insights can sync across devices.
- Keep OpenRouter as the current AI provider for debate, but isolate provider-specific behavior behind an AI debate service boundary.
- Add a structured debate evaluation concept alongside natural language replies.
- Evaluate debate quality across clarity, counterargument handling, self-correction, specificity, originality, and intellectual honesty.
- Do not award high XP based only on response count.
- Make the XP algorithm explainable to the user after completion.
- Track at least four scoring inputs: difficulty, hints used, on-time completion, and reasoning quality.
- Add anti-farming constraints such as minimum substantive engagement, diminishing returns for message count, and AI-assessed completion readiness.
- Split streaks into clearer concepts: activity streak, weekly completion streak, and perfect-week streak.
- Improve countdown and challenge availability presentation before adding complex notification infrastructure.
- Expand challenge content beyond philosophy and cognitive bias over time to include logic, argument analysis, decision theory, statistics, rhetoric, media literacy, and self-reflection.
- Move challenge content out of hardcoded Dart source once the content model stabilizes.
- Add challenge metadata for category, tags, difficulty, estimated time, prerequisites, and variants.
- Make the first-run flow provide an immediately available starter challenge.
- Make challenge state transitions explicit: pending, ready, in progress, completed, skipped, and expired.
- Improve completion flow with XP breakdown, quality feedback, and next-step guidance.
- Improve typography by using a strong UI font and a readable long-form challenge font.
- Treat the current README as inadequate and replace it with a product-focused setup document.
- Leave backend, analytics, payment, social sharing, and public leaderboards out of the initial improvement pass.

## Testing Decisions

- Tests should verify user-visible behavior and product mechanics rather than private implementation details.
- Scheduling tests should verify that weekly assignments produce one philosophy challenge and one cognitive-bias challenge at the configured weekday and weekend times.
- Scheduling tests should verify that assignments remain stable within a week and rotate across weeks.
- Expiration tests should verify that stale pending challenges become skipped and update user progress correctly.
- XP tests should verify reward calculation for difficulty, hints used, response count or engagement, on-time completion, and quality score once introduced.
- Auth tests should verify local registration, duplicate usernames, PIN validation, login, logout, and current-user restoration.
- Storage tests should verify user, challenge, weekly assignment, and API key persistence behavior.
- Debate service tests should use a fake AI client to verify prompt construction, response handling, error handling, and structured evaluation parsing.
- UI widget tests should cover first-run auth/onboarding, home challenge states, debate message submission, hint request, completion gating, and progress summaries.
- Golden or screenshot-style tests can be added later for typography and major screen layout stability.
- The highest-value seams are the app provider, schedule service, storage service, XP/scoring service, challenge library/content repository, and AI debate service.
- New test seams should be introduced at service boundaries rather than inside individual widgets where possible.
- The first test pass should focus on deterministic local logic before testing provider network calls or platform auth.

## Out of Scope

- Multi-user account management beyond the existing local prototype behavior.
- Full Firebase backend sync implementation in the first foundation pass.
- Payment, subscriptions, or monetization.
- Public leaderboards or social comparison.
- Production analytics.
- Push notification infrastructure beyond documenting the intended reminder behavior.
- Migrating all challenge content to a remote CMS in the first pass.
- Replacing OpenRouter with a different provider.
- Building a web admin tool for challenge authors.
- Full accessibility audit, although obvious text contrast, keyboard, and screen-size issues should be fixed when encountered.

## Further Notes

- The current README is still the default Flutter README and should be replaced.
- The app currently stores user data and OpenRouter API keys in local preferences. This is acceptable for a prototype but should be revisited before production.
- The current challenge bank contains strong initial material but is hardcoded and includes visible encoding problems.
- The app already has a clear product spine: weekly challenges, Socratic debate, XP, streaks, and progress. The improvement work should strengthen that spine rather than dilute it with unrelated features.
- Suggested implementation order:
  1. Foundation cleanup: strings, assets, README, setup verification.
  2. First-run and flow polish: onboarding, starter challenge, clearer states.
  3. Scoring model: XP rubric, quality score, completion summary.
  4. Debate engine: structured evaluation, tone guardrails, difficulty adaptation.
  5. Challenge bank: content expansion, metadata, externalized storage.
  6. Auth evolution: Google Sign-In and Firebase-backed account model.
