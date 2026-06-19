# Issue 008: AI Debate Evaluation Contract

Status: Accepted for implementation

Issue: https://github.com/kishorkukreja/mind-gym/issues/8
Parent PRD: `docs/prd-mind-gym-product-improvements.md`

## Decision

Mind Gym debate replies must be split into two products of the same AI turn:

1. A user-facing Socratic reply shown in the chat.
2. Hidden structured evaluation metadata used for completion readiness, XP, and the post-challenge completion summary.

The evaluation metadata is not shown raw to the user. It is persisted with the user challenge once runtime storage is implemented for this contract, and the UI presents only derived labels, XP breakdown, and summary copy.

## Schema Version

Current schema version:

```text
mind_gym.ai_debate_evaluation.v1
```

Implementation agents must reject unknown schema versions and use fallback behavior rather than guessing.

## Required Payload

The AI response parser should extract a JSON object with this shape:

```json
{
  "reply": "User-facing Socratic reply, under 200 words, ending with a targeted question.",
  "evaluation": {
    "schemaVersion": "mind_gym.ai_debate_evaluation.v1",
    "reasoningDepth": 3,
    "clarity": 3,
    "counterarguments": 2,
    "selfCorrection": 1,
    "specificity": 3,
    "originality": 2,
    "intellectualHonesty": 3,
    "completionReadiness": 70,
    "completionRecommended": true,
    "strengths": ["Names the core tradeoff clearly."],
    "improvementAreas": ["Test the claim against the strongest objection."],
    "completionSummary": "You made a clear argument, but it still needs stronger counterargument handling."
  }
}
```

For the lightweight Dart contract in `lib/models/debate_evaluation_contract.dart`, `reply` remains outside the typed evaluation object. Debate service implementation should parse the full provider response, display `reply`, and pass `evaluation` through the contract validator.

## Score Ranges

All rubric dimensions are required integers from `0` to `4`.

`0` means absent or counterproductive.

`1` means present but shallow.

`2` means adequate for a novice session.

`3` means strong and specific.

`4` means excellent, rigorous, and sustained.

### Reasoning Depth

Measures whether the user goes beyond assertion into causes, tradeoffs, assumptions, implications, or principles.

Score `0`: Bare opinion, refusal, copied prompt text, or unrelated response.

Score `2`: Gives at least one reason and recognizes the central tension.

Score `4`: Builds a layered argument with assumptions, consequences, and limits.

### Clarity

Measures whether the user's position can be understood and evaluated.

Score `0`: Incoherent, ambiguous, or too fragmentary to assess.

Score `2`: Main claim is understandable but may be loosely organized.

Score `4`: Claim, reasons, and qualifications are easy to follow.

### Counterarguments

Measures whether the user engages opposing views or alternative explanations.

Score `0`: Ignores objections or treats disagreement as irrelevant.

Score `2`: Mentions at least one plausible objection.

Score `4`: States a strong opposing case and answers it fairly.

### Self-Correction

Measures whether the user updates, narrows, or improves their position during the debate.

Score `0`: Repeats the same position despite challenges.

Score `2`: Acknowledges a weakness or clarifies a claim after challenge.

Score `4`: Revises the argument in a way that materially improves it.

### Specificity

Measures concrete examples, terms, distinctions, and direct contact with the challenge.

Score `0`: Generic statements that could apply to any challenge.

Score `2`: Uses at least one relevant example or distinction.

Score `4`: Uses precise examples and challenge-specific details throughout.

### Originality

Measures non-formulaic thinking and personal synthesis.

Score `0`: Empty platitudes, obvious slogans, or parroting hints.

Score `2`: Adds a modest personal angle or non-obvious connection.

Score `4`: Produces a fresh framing, analogy, or synthesis that deepens the debate.

### Intellectual Honesty

Measures fair treatment of uncertainty, evidence limits, and uncomfortable implications.

Score `0`: Dodges tradeoffs, overclaims, or argues in bad faith.

Score `2`: Admits at least one uncertainty, assumption, or limitation.

Score `4`: Actively distinguishes confidence from uncertainty and gives opposing views their due.

## Completion Readiness

`completionReadiness` is a required integer from `0` to `100`.

It answers: "Has the user genuinely wrestled with the core tension enough to complete this challenge?"

Recommended bands:

| Range | Meaning | UI behavior |
| --- | --- | --- |
| `0-24` | Not assessable or no substantive engagement | Hide completion action or keep it disabled. |
| `25-49` | Early engagement | Encourage another response. |
| `50-69` | Basic completion possible | Allow completion only if deterministic minimums pass. |
| `70-84` | Ready | Show completion action and explain remaining improvement area. |
| `85-100` | Strongly ready | Show completion action with high-quality summary language. |

`completionRecommended` is a required boolean. It must be `true` only when:

- `completionReadiness >= 70`.
- The user has at least two substantive user responses.
- No core rubric dimension is `0` except originality.
- The AI can name at least one strength and one improvement area.

The app may allow manual completion below `70` only through deterministic fallback rules, but the completion summary must make clear that the reasoning score is capped.

## Quality Score Derivation

The persisted user-facing quality score remains `1` to `5` for compatibility with `UserChallenge.qualityScore`.

Derive it from the seven rubric dimensions:

```text
qualityScore = round((average_dimension_score / 4) * 4 + 1)
```

Clamp the result to `1-5`.

Fallback evaluations must cap `qualityScore` at `2`.

## XP Integration

The PRD requires XP to reflect reasoning quality rather than message volume. Use this contract as the reasoning-quality input to the eventual XP service.

Recommended v1 XP inputs:

| Input | Source | Notes |
| --- | --- | --- |
| Difficulty base | `Challenge.difficulty` | Keep existing `difficulty * 40` style base. |
| Hint penalty | `UserChallenge.hintsUsed` | Keep visible in the XP breakdown. |
| On-time modifier | Schedule status | Keep the current on-time completion signal. |
| Quality modifier | `qualityScore` and dimensions | Replace response-count depth bonus. |
| Completion readiness gate | `completionReadiness` | Do not award high XP unless readiness is at least `70`. |

Recommended quality modifier:

```text
qualityBonus = qualityScore * 12
readinessBonus = completionReadiness >= 85 ? 20 : completionReadiness >= 70 ? 10 : 0
```

If fallback evaluation is used:

- Cap total XP at the lower of calculated XP and `120`.
- Do not award readiness bonus.
- Show "Evaluation fallback used" in developer logs or diagnostics.

## Completion Summary Integration

The completion dialog should eventually include:

- XP earned.
- Quality score label derived from `qualityScore`.
- One strongest dimension, if tied choose the first by this order: reasoning depth, clarity, counterarguments, self-correction, specificity, originality, intellectual honesty.
- One weakest dimension, same tie order.
- `completionSummary` rewritten only for tone or length, not for meaning.
- One next-step improvement from `improvementAreas`.

The raw hidden evaluation should not be presented as JSON.

Suggested labels:

| Quality score | Label |
| --- | --- |
| `1` | Emerging |
| `2` | Developing |
| `3` | Solid |
| `4` | Sharp |
| `5` | Rigorous |

## Fallback Behavior

Use fallback when any of these occur:

- Provider call fails.
- Provider returns plain text only.
- JSON extraction fails.
- `schemaVersion` is missing or unknown.
- Any required field is missing.
- Any score is outside its range.
- `completionSummary` is empty.
- `strengths` or `improvementAreas` is not an array of non-empty strings.

Fallback rules:

1. Preserve the Socratic reply if it is usable; otherwise show the existing connection or API-key error copy.
2. Create a conservative fallback evaluation using deterministic local signals.
3. Allow completion only when current local minimum engagement passes, currently `responseCount >= 2`.
4. Set `completionReadiness` to `50` when the local minimum passes, otherwise `25`.
5. Set `completionRecommended` to `false`; fallback can allow manual completion but must not claim AI-assessed readiness.
6. Cap `qualityScore` at `2`.
7. Do not award high-quality XP bonuses.
8. Use a generic completion summary explaining that structured evaluation was unavailable.
9. Log the parse failure reason for implementation debugging, but do not show technical parse details to the user.

## Prompting Requirements

The provider prompt should instruct the AI to:

- Return one valid JSON object and no surrounding prose.
- Keep `reply` direct, constructive, under 200 words, and ending in a targeted question.
- Score only the user's demonstrated reasoning, not the AI's own coaching quality.
- Penalize empty verbosity and repeated assertions.
- Avoid high scores when the user has not engaged counterarguments.
- Mark `completionRecommended` false if the user has not substantively engaged the core tension.

## Persistence Notes

When implementing storage, add fields to `UserChallenge` or a nested evaluation object for:

- `evaluationSchemaVersion`
- `reasoningDepth`
- `clarity`
- `counterarguments`
- `selfCorrection`
- `specificity`
- `originality`
- `intellectualHonesty`
- `completionReadiness`
- `completionRecommended`
- `evaluationSource`
- `strengths`
- `improvementAreas`
- `completionSummary`

Retain the existing `qualityScore` field as the derived `1-5` compatibility score.

## Out Of Scope

- Changing the provider from OpenRouter.
- Implementing full provider JSON-mode support.
- Rebuilding the debate UI.
- Replacing the XP service in this issue.
- Designing backend sync for evaluation history.

## Implementation Checklist

- Parse the full provider response into `reply` plus `evaluation`.
- Validate `evaluation` using `DebateEvaluationContract.tryParse`.
- Store valid evaluation metadata with the challenge.
- Store fallback metadata when validation fails.
- Use `completionReadiness` and `completionRecommended` for completion affordance.
- Replace response-count XP bonus with quality and readiness bonuses.
- Update completion dialog to show XP, quality label, summary, and next-step guidance.
