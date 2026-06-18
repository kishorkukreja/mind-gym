import '../models/challenge_model.dart';

class ChallengeLibrary {
  static final List<Challenge> allChallenges = [
    // =================== PHILOSOPHY CHALLENGES ===================
    Challenge(
      id: 'phi_001',
      title: 'The Trolley Problem',
      question:
          'A runaway trolley is speeding down the tracks toward five people who are tied up and unable to move. You are standing next to a lever that can divert the trolley to a side track where only ONE person is tied. If you pull the lever, you save five but directly cause the death of one. If you do nothing, five die but you did not act.\n\nDo you pull the lever? And more importantly — WHY? Is there a morally correct answer here, or is this a trap?',
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Classic utilitarian vs deontological ethics dilemma',
      category: 'Trolley Problem',
      difficulty: 2,
      hintTiers: [
        'Think about the difference between DOING harm and ALLOWING harm to happen. Are they morally equivalent?',
        'Consider: Utilitarian ethics says maximize good outcomes. Deontological ethics says some actions are wrong regardless of outcome. Which framework are you using — and why that one?',
        'Ask yourself: If pulling the lever is acceptable, what stops you from pushing a fat man off a bridge to stop the trolley with his body? The math is the same. Why does it feel different?',
      ],
      thinkingAngles: [
        'intention vs consequence',
        'doctrine of double effect',
        'utilitarian calculus',
        'deontological constraints',
        'personal vs impersonal morality',
        'the difference between killing and letting die',
      ],
    ),
    Challenge(
      id: 'phi_002',
      title: "The Ship of Theseus",
      question:
          "Theseus had a famous ship. Over centuries, every single plank, rope, and nail was gradually replaced as they wore out. Eventually, not one original piece remained — yet sailors still called it 'The Ship of Theseus.'\n\nIs it still the same ship? Now imagine someone collected all the original parts and reassembled them into a second ship. Which one is the REAL Ship of Theseus?\n\nNow apply this to yourself: Every cell in your body is replaced every 7 years. Are you the same person you were at age 10?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Identity, persistence, and what makes something "the same thing"',
      category: 'Identity & Persistence',
      difficulty: 3,
      hintTiers: [
        'Think about WHAT makes something the same thing over time. Is it physical material? Pattern? Memory? Continuity? Function?',
        'Consider the difference between numeric identity (this exact thing) and qualitative identity (looks/acts exactly like it). Which matters for personal identity?',
        'Your memories connect your past and present self — but memories can be false, altered, or forgotten. If you lost all memory of your childhood, would that person still be "you"?',
      ],
      thinkingAngles: [
        'material continuity vs functional continuity',
        'psychological continuity theory',
        'four-dimensionalism',
        'what personal identity means legally vs philosophically',
        'implications for responsibility and punishment',
      ],
    ),
    Challenge(
      id: 'phi_003',
      title: "The Experience Machine",
      question:
          "Philosopher Robert Nozick asks you to imagine a machine that can give you ANY experience you want — perfect happiness, achievement, love, adventure — all indistinguishable from reality. Once you plug in, you'll believe you're living a real, rich life. You'll never know the difference.\n\nWould you plug in forever?\n\nMost people say NO. But if happiness and positive experience are the only things that matter (as hedonists claim), then plugging in is OBVIOUSLY the right choice. So why does it feel wrong? What does your hesitation reveal about what you truly value?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Hedonism, authenticity, and the value of real experience',
      category: 'Hedonism vs Reality',
      difficulty: 3,
      hintTiers: [
        'Think about WHAT you want from life. Is it the feeling of achievement, or actual achievement? Is happiness the only thing that matters, or do you want things to be REAL?',
        'Consider: We care about things beyond our own feelings — that our loved ones actually love us (not just believing they do), that our accomplishments are real. What does this say about hedonism?',
        "If you reject the machine, you're saying reality has intrinsic value beyond how it feels. But then ask: how is your daily life different from a less perfect version of the machine?",
      ],
      thinkingAngles: [
        'hedonism vs desire satisfaction theory',
        'objective list theories of wellbeing',
        'authenticity and meaning',
        'the value of contact with reality',
        'implications for virtual reality and AI',
      ],
    ),
    Challenge(
      id: 'phi_004',
      title: "The Chinese Room",
      question:
          "Imagine you're locked in a room. Through a slot, Chinese symbols are passed to you. You have a giant rulebook that tells you exactly which symbols to send back in response — all in Chinese. To people outside, you appear to be holding an intelligent Chinese conversation. But you understand NOTHING. You're just following rules.\n\nJohn Searle argues this is exactly what computers do. They manipulate symbols without understanding them. Therefore, no computer — no matter how sophisticated — can ever be truly conscious or intelligent.\n\nDo you agree? And if not — where exactly does understanding come from?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Consciousness, artificial intelligence, and what understanding means',
      category: 'Mind & Consciousness',
      difficulty: 4,
      hintTiers: [
        "Think about the SYSTEM as a whole, not just you in the room. You don't understand Chinese, but does the system (you + rulebook + room) understand it? What's the difference?",
        'Consider: How do YOU understand anything? Your neurons are just electrochemical signals following rules. How is that fundamentally different from the room?',
        'Ask yourself: What would it even MEAN to prove something is conscious? Is consciousness detectable from the outside at all — or is it only knowable from the inside?',
      ],
      thinkingAngles: [
        'syntax vs semantics',
        'the systems reply',
        'functionalism vs biological naturalism',
        'the hard problem of consciousness',
        'philosophical zombies',
        'implications for AI rights',
      ],
    ),
    Challenge(
      id: 'phi_005',
      title: "The Violinist",
      question:
          "You wake up in a hospital, connected by tubes to a famous unconscious violinist. A society of music lovers has kidnapped you — the violinist has a fatal kidney ailment and only your blood type can help. The doctor says: 'If we disconnect you, he will die. But in nine months he will have recovered and can be safely disconnected.'\n\nDo you have a moral obligation to stay connected for nine months? Philosopher Judith Jarvis Thomson uses this as an analogy for abortion. Even IF we grant that a fetus has full personhood — does that AUTOMATICALLY mean a woman is obligated to sustain its life?\n\nWhat's your position — and can you defend it without using the word 'obvious'?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Bodily autonomy, rights, and obligations',
      category: 'Rights & Obligations',
      difficulty: 5,
      hintTiers: [
        "Separate TWO questions: (1) Does the fetus have a right to life? (2) Does a right to life include the right to use another person's body? These are different questions.",
        'Think about CONSENT and RESPONSIBILITY. Does it matter how the pregnancy began? Thomson actually argues it might — think about why consent to one thing might not mean consent to all consequences.',
        "Consider: We don't legally require people to donate organs, blood, or bone marrow even to save lives. Why not? And is the pregnant body situation relevantly similar or different?",
      ],
      thinkingAngles: [
        'positive vs negative rights',
        'bodily autonomy',
        'the good samaritan problem',
        'consent and responsibility',
        'the killing vs letting die distinction',
        'minimally decent samaritanism',
      ],
    ),
    Challenge(
      id: 'phi_006',
      title: "The Simulation Argument",
      question:
          "Philosopher Nick Bostrom argues that at least one of these must be true:\n1. Almost all civilizations go extinct before reaching technological maturity.\n2. Almost all technologically mature civilizations choose NOT to run simulated realities.\n3. We are almost certainly living in a computer simulation right now.\n\nThe logic: if civilizations survive AND choose to run simulations, the number of simulated minds would astronomically outnumber real ones. Therefore, statistically, you're almost certainly simulated.\n\nWhich of the three options do you think is true — and what evidence could even in principle resolve this question?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Reality, consciousness, and the nature of existence',
      category: 'Metaphysics & Reality',
      difficulty: 4,
      hintTiers: [
        "Think carefully about the LOGIC: the argument doesn't prove we're simulated — it says IF options 1 and 2 are false, then option 3 follows. So which premise do you actually dispute?",
        "If you're in a simulation, what would change? Would morality still apply? Would your experiences still be \"real\"? Does it matter?",
        'Consider: What would count as EVIDENCE for or against being simulated? Could you ever design an experiment to test it? If not, what does that say about the claim scientifically?',
      ],
      thinkingAngles: [
        'anthropic reasoning and probability',
        'the trilemma structure of the argument',
        'unfalsifiability and scientific merit',
        'implications for ethics and meaning',
        'computational theory of mind',
      ],
    ),
    Challenge(
      id: 'phi_007',
      title: "The Teleporter",
      question:
          "A teleporter scans your body completely, disintegrates you, and reconstructs a perfect copy at the destination — same atoms, same memories, same personality. You step in on Earth, and 'you' step out on Mars.\n\nBut here's the twist: A malfunction leaves the original you alive on Earth while the copy exists on Mars. Now there are two of you, both claiming to be the real person. The Earth copy is then destroyed.\n\nDid the Mars person survive the teleportation? And the harder question: would YOU use the teleporter, knowing this is what's happening?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Personal identity, survival, and what makes YOU you',
      category: 'Identity & Persistence',
      difficulty: 3,
      hintTiers: [
        'Ask: what is it that SURVIVES death or teleportation? Physical continuity of brain matter? Psychological continuity of memories and personality? Something else entirely?',
        "Consider: the copy has all your memories and feels they are continuous with your past. From the INSIDE, there's no difference. Does subjective experience settle the identity question?",
        "Think about the BRANCHING problem: if the original isn't destroyed, you'd say there are now TWO people who are both \"you.\" But two things can't be identical. So what happens to identity when the original IS destroyed?",
      ],
      thinkingAngles: [
        'physical continuity theory',
        'psychological continuity theory',
        "Derek Parfit's reductionism",
        'what matters in survival vs identity',
        'the fission problem',
      ],
    ),
    Challenge(
      id: 'phi_008',
      title: "The Invisible Gardener",
      question:
          "Two explorers find a clearing in a jungle with beautiful flowers and tidy paths. One says: 'A gardener tends this.' They camp and watch — no gardener appears. 'Perhaps an invisible gardener.' They set up electric fences, bloodhounds — nothing. Yet the believer keeps adjusting: 'He must be intangible, has no scent, makes no sound.' \n\nThe skeptic asks: 'Just what is the difference between an invisible, intangible, indetectable gardener and NO gardener at all?'\n\nThis is Anthony Flew's challenge to religious belief. What distinguishes a meaningful claim from a non-falsifiable one? And does unfalsifiability automatically make a belief irrational?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Falsifiability, religious belief, and meaning of claims',
      category: 'Philosophy of Religion',
      difficulty: 4,
      hintTiers: [
        'Think about what makes a claim MEANINGFUL vs meaningless. Karl Popper argued a claim must be falsifiable to be scientific. But does scientific = meaningful?',
        "Consider: many things we believe in (love, consciousness, mathematical truths) aren't falsifiable in a simple way. Does that make them meaningless?",
        'Ask: is the believer being irrational, or just using a DIFFERENT kind of reasoning — personal experience, testimony, philosophical argument — rather than empirical testing?',
      ],
      thinkingAngles: [
        'falsificationism vs verificationism',
        'the death by a thousand qualifications',
        'types of evidence beyond empirical',
        'pragmatic vs epistemic rationality',
        'faith and evidence',
      ],
    ),
    Challenge(
      id: 'phi_009',
      title: "Mary's Room",
      question:
          "Mary is a brilliant neuroscientist who has lived her entire life in a black-and-white room. She knows EVERYTHING physical there is to know about color vision — every wavelength, every neural firing pattern, every brain response when people see red.\n\nThen one day she leaves the room and sees red for the first time.\n\nDoes she learn anything new?\n\nPhilosopher Frank Jackson argues YES — she learns what it's LIKE to see red. This supposedly proves that physical knowledge is incomplete — that there are non-physical facts about consciousness. Do you agree? And if not, what exactly is she learning?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Qualia, consciousness, and the limits of physical explanations',
      category: 'Mind & Consciousness',
      difficulty: 5,
      hintTiers: [
        'Think carefully about what KIND of knowledge Mary gains. Is it propositional knowledge (knowing THAT something is true) or ability knowledge (knowing HOW to do/recognize something)? Are these different?',
        "Consider the \"ability hypothesis\": Mary doesn't learn a new FACT — she gains a new ABILITY to recognize, remember, and imagine red experiences. This would defeat Jackson's argument. Does it work?",
        'Ask: if Mary already knew everything physical, what exactly is this new "non-physical fact"? Where does it live? How does it interact with the physical world? What is it made of?',
      ],
      thinkingAngles: [
        'qualia and phenomenal consciousness',
        'physicalism vs dualism',
        'the ability hypothesis',
        'the knowledge argument',
        'explanatory gap',
      ],
    ),
    Challenge(
      id: 'phi_010',
      title: "The Drowning Child",
      question:
          "You're walking past a shallow pond and see a small child drowning. You could easily save them, but ruining your expensive new shoes and being late to an important meeting. Obviously you save the child.\n\nNow: philosopher Peter Singer argues there's NO morally relevant difference between this case and donating money to save a child dying from preventable disease on the other side of the world. Distance doesn't matter morally. You can save a life for ~£100 via effective charities.\n\nIf you're not donating money you don't need for necessities, you are — by Singer's logic — letting children die. Are you morally obligated to give until it hurts? Where does the obligation end?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Effective altruism, obligation, and the demands of morality',
      category: 'Ethics & Obligation',
      difficulty: 3,
      hintTiers: [
        "Singer's argument: (1) Suffering and death are bad. (2) If you can prevent something bad without sacrificing anything of comparable moral worth, you should. (3) You can prevent deaths cheaply. Conclusion: you should. Where does the logic FAIL, if it does?",
        "Consider the DEMANDINGNESS objection: Singer's conclusion requires giving until you're as poor as those you're helping. Is a moral theory that demands too much actually wrong? Or are we just uncomfortable with its demands?",
        'Think about SPECIAL OBLIGATIONS: we have stronger duties to those close to us. Does this override universal obligations? Can it, without being a form of arbitrary bias?',
      ],
      thinkingAngles: [
        'impartialism vs partiality',
        'the demandingness objection',
        'positive vs negative duties',
        'special obligations to family and community',
        'effective altruism critique',
        'moral psychology vs moral theory',
      ],
    ),
    // =================== COGNITIVE BIAS CHALLENGES ===================
    Challenge(
      id: 'cog_001',
      title: 'Confirmation Bias in Your Own Life',
      question:
          "You hold a strong belief — political, personal, scientific, or about someone you know. You encounter new information every day.\n\nHere's the trap: Confirmation bias means you unconsciously SEEK information that confirms what you already believe, and DISMISS information that challenges it — often without noticing.\n\nChallenge: Think of your single strongest held belief. Now honestly answer — what is the strongest EVIDENCE AGAINST that belief? If you struggle to name it quickly, that's confirmation bias at work RIGHT NOW.\n\nBonus: How would you even KNOW if your belief is wrong?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Tendency to search for and favor information confirming existing beliefs',
      category: 'Confirmation Bias',
      difficulty: 3,
      hintTiers: [
        "Think about your news consumption, social media feed, and the people you discuss ideas with. Do they mostly AGREE with you? That's not coincidence — it's bias in action.",
        'Consider: what would it take to CHANGE your mind on this belief? If no evidence could change it, is it truly a belief or just an identity statement?',
        "Ask yourself: have you ever genuinely SOUGHT OUT the best arguments AGAINST your position and tried to steelman them? If not, you don't really know your own belief yet.",
      ],
      thinkingAngles: [
        'motivated reasoning',
        'echo chambers and filter bubbles',
        'falsificationism applied to personal beliefs',
        'steelmanning vs strawmanning',
        'the difference between belief and identity',
      ],
    ),
    Challenge(
      id: 'cog_002',
      title: 'The Sunk Cost Trap',
      question:
          "You've been in a relationship for 3 years and it's making you miserable. But you think: 'I've invested 3 years — I can't just leave now.' \n\nYou're 80% through a terrible movie you hate. You stay to the end because you already spent 2 hours.\n\nYou've spent £50,000 on a business that's clearly failing. You keep investing because 'it would be a waste to stop now.'\n\nThis is the Sunk Cost Fallacy. The past investment is GONE — it cannot be recovered. Rational decision-making should only consider FUTURE costs and benefits.\n\nBut here's the real question: Is it EVER rational to consider sunk costs? Or is there something valuable about commitment and not being a quitter that pure rational calculation misses?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'How past investments irrationally influence future decisions',
      category: 'Sunk Cost Fallacy',
      difficulty: 2,
      hintTiers: [
        'Think about WHY we fall for sunk costs. Loss aversion (losses feel twice as bad as equivalent gains) plays a role. So does identity — quitting feels like admitting you were WRONG.',
        "Consider the counterargument: sometimes past investment DOES contain useful signal. If you've been in a relationship 3 years, you have 3 years of data. Is IGNORING that truly rational?",
        'Ask: is there a difference between being influenced by sunk costs and valuing COMMITMENT as a character trait? A person who quits everything easily might be ignoring future costs too.',
      ],
      thinkingAngles: [
        'loss aversion and prospect theory',
        'when commitment has intrinsic value',
        'the opportunity cost of staying',
        'identity, consistency, and the desire to not be wrong',
        'when to pivot vs persist',
      ],
    ),
    Challenge(
      id: 'cog_003',
      title: 'The Availability Heuristic & Fear',
      question:
          "After 9/11, millions of Americans switched from flying to driving. They perceived flying as too dangerous. Result: an estimated 1,500 additional road deaths in the year following — because driving is statistically FAR more dangerous than flying.\n\nThe Availability Heuristic: We judge the probability of events by how easily examples come to mind. Dramatic, vivid, recent events (plane crashes, shark attacks, terrorist attacks) get OVERWEIGHTED. Mundane common risks (car accidents, heart disease) get ignored.\n\nChallenge: Name three things you are genuinely afraid of. Now look up the actual statistical probability. Are your fears calibrated to reality — or to memorable news stories?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Judging probability by how easily examples come to mind',
      category: 'Availability Heuristic',
      difficulty: 2,
      hintTiers: [
        'Think about your media diet. News by definition covers UNUSUAL events. So a brain trained on news will systematically overestimate unusual dangers and underestimate common ones.',
        'Consider: is it irrational to be more afraid of vivid, dramatic risks even if statistically small? Perhaps it reflects something about the TYPE of death (loss of control, randomness) rather than probability alone.',
        'Ask yourself: how SHOULD we calibrate our fears? Pure statistical probability? But we also care about controllability, fairness, and who bears the risk. Is fear ever tracking something beyond statistics?',
      ],
      thinkingAngles: [
        'statistical thinking vs narrative thinking',
        'the role of media in shaping perceived risk',
        'psychometric dimensions of risk beyond probability',
        'when heuristics serve us well',
        'emotional vs analytical risk assessment',
      ],
    ),
    Challenge(
      id: 'cog_004',
      title: 'The Dunning-Kruger Trap',
      question:
          "Research by David Dunning and Justin Kruger showed: people with LOW competence in a domain consistently OVERESTIMATE their ability. People with HIGH competence consistently UNDERESTIMATE it.\n\nThe brutal implication: The less you know, the more confident you are. The more you know, the more you realize how much you don't know.\n\nHere's your challenge: Pick a domain where you consider yourself expert or highly knowledgeable. Now answer these: What is the single hardest UNSOLVED problem in that domain? What is the most serious CHALLENGE to your main view? What do top experts in the field DISAGREE about?\n\nIf you can't answer these fluently, recalibrate.",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Why incompetent people overestimate and experts underestimate',
      category: 'Dunning-Kruger Effect',
      difficulty: 3,
      hintTiers: [
        "Think about WHY this happens. Low competence means you lack the very skills needed to RECOGNIZE your lack of competence. It's not stupidity — it's a structural feature of early learning.",
        "Consider the flip side: experts suffer from the Curse of Knowledge — they've forgotten what it's like NOT to know, so they assume others understand more than they do. Both ends of the curve are miscalibrated.",
        'Ask: how do you BUILD accurate self-assessment? Seeking feedback from people who will be honest (not just supportive), testing yourself under real conditions, comparing yourself to the best in the field — not the average.',
      ],
      thinkingAngles: [
        'metacognition and self-awareness',
        'the curse of knowledge',
        'calibration in beliefs',
        'how to get honest feedback',
        'the Mount Stupid phase of learning',
      ],
    ),
    Challenge(
      id: 'cog_005',
      title: 'Anchoring: The First Number Wins',
      question:
          "Experiment: Two groups are asked whether Gandhi died before or after age 9 (Group A) or age 140 (Group B). Both numbers are clearly ridiculous. But then both groups are asked: 'How old WAS Gandhi when he died?'\n\nGroup A consistently guesses younger. Group B consistently guesses older. An irrelevant, obviously wrong number ANCHORED their estimate.\n\nThis affects salary negotiations, judicial sentences, medical diagnoses, and every major decision you make.\n\nChallenge: In your last 3 significant decisions (purchase, negotiation, evaluation of someone), what was the ANCHOR? Did you adjust enough from it? And the meta-question: now that you KNOW about anchoring, does knowing protect you from it?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'The first piece of information disproportionately influences judgments',
      category: 'Anchoring Effect',
      difficulty: 2,
      hintTiers: [
        "Think about salary negotiation. Research consistently shows whoever makes the first offer gains an advantage — their number becomes the anchor. Even if you \"negotiate down,\" you're playing on their terms.",
        "Consider: anchoring works even when the anchor is RANDOM (a dice roll before price estimates). This suggests it's not just that we think the anchor contains information — it's a deeper cognitive pull.",
        'Ask the critical question: mere knowledge of a bias does NOT protect you from it in most cases. What strategies actually work? (Hint: consider strategies that force you to generate your OWN number first, independently.)',
      ],
      thinkingAngles: [
        'insufficient adjustment from anchor',
        'anchoring in negotiations',
        'anchoring in legal sentencing',
        'de-biasing strategies that actually work',
        'the limits of knowing your biases',
      ],
    ),
    Challenge(
      id: 'cog_006',
      title: 'The Fundamental Attribution Error',
      question:
          "A waiter is rude to you. Your immediate thought: 'What a jerk.' But the waiter just received devastating personal news an hour ago.\n\nYou cut someone off in traffic because you're rushing to a hospital. Others think: 'Terrible driver.'\n\nThe Fundamental Attribution Error: We over-attribute others' behavior to their CHARACTER (dispositional), while under-weighting SITUATIONAL factors. For ourselves, we do the opposite — we blame our bad behavior on the situation.\n\nThe deeper challenge: If most human behavior is situationally driven, what does this mean for how we hold people morally responsible? Does the situation ever fully excuse the behavior?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Over-attributing others behavior to character, underweighting situations',
      category: 'Fundamental Attribution Error',
      difficulty: 3,
      hintTiers: [
        'Think about the ACTOR-OBSERVER asymmetry: as an actor in your own life, you see the full situational context. As an observer of others, you only see their behavior — so character feels like the natural explanation.',
        "Consider Milgram's obedience experiments: ordinary people gave what they believed were lethal electric shocks when ordered to by an authority figure. Most people's prediction? \"I wouldn't do that.\" They were wrong. What does this say about character vs. situation?",
        'Ask the hard question: if situations dominate behavior, does this undermine moral responsibility? Or can we hold people responsible for being in certain situations, or for building certain character traits over time?',
      ],
      thinkingAngles: [
        'situationism vs. virtue ethics',
        'Milgram and Stanford Prison Experiment implications',
        'moral luck and responsibility',
        'why self-serving bias mirrors FAE',
        'how institutions shape behavior',
      ],
    ),
    Challenge(
      id: 'cog_007',
      title: 'Survivorship Bias: The Missing Bullet Holes',
      question:
          "During WWII, the Allies analyzed bullet holes in planes returning from missions to determine where to add extra armor. The data showed hits concentrated on the fuselage and wings. The obvious conclusion: reinforce those areas.\n\nStatistician Abraham Wald said: WRONG. Reinforce the engines and cockpit. Why? Because the planes that were HIT THERE didn't RETURN. You're only studying survivors.\n\nSurvivorship bias affects everything: 'Successful entrepreneurs dropped out of college' (ignoring the thousands who dropped out and failed), 'Old buildings are better quality' (the bad ones fell down), 'This investment strategy worked' (ignoring all the funds that used it and went bust).\n\nWhere in YOUR life are you studying only the planes that came back?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Focusing on survivors while ignoring those who did not make it',
      category: 'Survivorship Bias',
      difficulty: 3,
      hintTiers: [
        "Think about how you gather evidence for beliefs. When you read about successful people's habits, you're reading a book written by someone who survived. What would the book look like if written by all the people who did the same things and FAILED?",
        'Consider: scientific research has a publication bias — positive results get published, negative results sit in drawers. So the "scientific consensus" you read is already survivorship-biased toward positive findings.',
        "Ask: what would you need to know to correct for survivorship bias? You'd need to find and study the NON-survivors — which is precisely what we never naturally do. How might you build this habit?",
      ],
      thinkingAngles: [
        'base rates and reference classes',
        'publication bias in science',
        'selection effects in data',
        'how to think about absent evidence',
        'the silent graveyard of failures',
      ],
    ),
    Challenge(
      id: 'cog_008',
      title: 'The Framing Effect',
      question:
          "Two doctors describe the same surgery:\nDoctor A: 'This surgery has a 90% survival rate.'\nDoctor B: 'This surgery has a 10% mortality rate.'\n\nIdentical information. But people consistently rate Doctor A's surgery as preferable and are more likely to consent.\n\nThe Framing Effect: how information is PRESENTED changes our decisions, independent of the actual content. Marketers, politicians, and lawyers exploit this constantly.\n\nYour challenge: Take a decision you've made recently. Now reframe the key information in the OPPOSITE frame (losses as gains, gains as losses). Does the decision still feel right? What does this tell you about YOUR reasoning process?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'How presentation of identical information changes decisions',
      category: 'Framing Effect',
      difficulty: 2,
      hintTiers: [
        'Think about why loss frames hit harder (loss aversion: losses feel ~2x as powerful as equivalent gains). Is this irrational? Or does it reflect something real about how bad loss is?',
        "Consider: politicians use frames constantly. \"Estate tax\" vs \"death tax.\" \"Pro-choice\" vs \"pro-abortion.\" \"Enhanced interrogation\" vs \"torture.\" The frame doesn't change the reality — but it changes who you're on the side of before you even start thinking.",
        'Ask: what would frame-independent thinking actually look like? One strategy: always translate to a NEUTRAL frame (raw numbers, base rates) before deciding. Is this achievable, or will some frame always leak through?',
      ],
      thinkingAngles: [
        'loss aversion and prospect theory',
        'political framing and propaganda',
        'how to make frame-resistant decisions',
        'whether any frame is ever truly neutral',
        'media literacy and framing',
      ],
    ),
    Challenge(
      id: 'cog_009',
      title: 'In-Group Bias and Tribalism',
      question:
          "Experiments show that randomly dividing people into two groups — even by coin flip or which abstract painting they prefer — is enough to make them favor members of their own group and discriminate against the other. No conflict, no history, no real difference. Just a label.\n\nThis is In-Group Bias. Now apply it seriously: Your political party, nationality, religion, football club, university, social class. You likely believe YOUR group is more reasonable, more moral, more correct than the other side.\n\nHere's the brutal question: If you were born into the other group, you would BELIEVE EXACTLY WHAT THEY BELIEVE with the same certainty you now hold your own views. What does that do to your confidence in your group's correctness?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Favoring members of ones own group over outsiders',
      category: 'In-Group Bias',
      difficulty: 4,
      hintTiers: [
        "Think about the EPISTEMIC implications: if your beliefs are largely determined by which group you were born into or adopted, they're not the result of independent reasoning — they're tribal signals. Does that make them less valid?",
        "Consider: in-group bias serves real evolutionary functions. Groups that cooperate internally outcompete those that don't. Does having an evolutionary explanation make a bias more or less forgivable?",
        "Ask: what would it take to genuinely evaluate your group's beliefs from outside? \"Outsider test for faith\" — imagine you were raised in the opposing tribe. Would their arguments seem as obviously wrong as they do from inside?",
      ],
      thinkingAngles: [
        'minimal group paradigm',
        'epistemic implications of tribal belief formation',
        'the outsider test',
        'how to distinguish genuine conviction from tribal loyalty',
        'when group membership is epistemically relevant',
      ],
    ),
    Challenge(
      id: 'cog_010',
      title: 'The Planning Fallacy',
      question:
          "Research consistently shows humans are terrible at predicting how long tasks will take. Students estimate essays will take 3 days — average actual time: 10 days. Building projects, software launches, government initiatives — almost all overrun their initial estimates, often by 100-300%.\n\nDaniel Kahneman calls this the Planning Fallacy: we plan based on best-case scenarios (inside view) while ignoring base rates of similar projects (outside view).\n\nBut here's the twist: even KNOWING this, we still do it. And there's a paradox — if everyone builds in extra time, nothing gets done efficiently. Is there a rational case for optimistic planning? Or is it pure bias all the way down?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Underestimating time and costs while overestimating benefits of plans',
      category: 'Planning Fallacy',
      difficulty: 3,
      hintTiers: [
        'Think about the INSIDE vs OUTSIDE view: inside view = "how will THIS specific project go?" Outside view = "how do projects like this TYPICALLY go?" Research shows outside view is far more accurate. Why do we ignore it?',
        "Consider: optimism might be strategically useful. Teams that believe they'll succeed persist longer and work harder. Maybe the planning fallacy is a feature, not a bug — it gets projects started that would never begin if we were fully realistic.",
        "Ask: what's the REFERENCE CLASS fallacy at play? To use the outside view, you need to pick the right comparison group. Is this building \"like major government infrastructure projects\" or \"like simple renovations\"? The choice of reference class changes everything.",
      ],
      thinkingAngles: [
        'inside view vs outside view',
        'reference class forecasting',
        'motivated optimism',
        'pre-mortem analysis as correction',
        'when optimism has strategic value',
      ],
    ),
    // More challenges
    Challenge(
      id: 'cog_011',
      title: 'The Bystander Effect',
      question:
          "In 1964, Kitty Genovese was murdered outside her New York apartment while (reportedly) 38 witnesses watched and did nothing. This launched research into the Bystander Effect: the more people present in an emergency, the LESS likely any individual is to help.\n\nTwo mechanisms: (1) Diffusion of responsibility — 'someone else will handle it.' (2) Pluralistic ignorance — everyone looks at others for cues, sees no one acting, concludes it must not be an emergency.\n\nThe disturbing implication: you are statistically less safe collapsing in Times Square than on a quiet country road. What does this say about collective moral responsibility? And does knowing this change how YOU would act?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Individuals are less likely to help when others are present',
      category: 'Bystander Effect',
      difficulty: 3,
      hintTiers: [
        'Think about the INTERVENTION: research shows that simply naming a specific person ("YOU in the red jacket — call 911!") breaks the diffusion of responsibility. Why does specificity override the effect?',
        "Consider: pluralistic ignorance works because we look to others to interpret ambiguous situations. But in doing so, everyone is looking at everyone else — who are ALL also deferring. It's cascading uncertainty. What would break the cascade?",
        'Ask: can you BUILD IN a commitment to act in emergencies? Some research suggests making a deliberate, explicit prior commitment ("I will always be the first to call for help") actually changes behavior. Is this a meaningful strategy or wishful thinking?',
      ],
      thinkingAngles: [
        'diffusion of responsibility',
        'pluralistic ignorance',
        'how to override bystander effect',
        'collective vs individual moral obligation',
        'ambiguity and social proof in emergencies',
      ],
    ),
    Challenge(
      id: 'phi_011',
      title: "Newcomb's Problem",
      question:
          "A predictor with an extraordinary track record places two boxes before you:\n- Box A: Transparent, contains £1,000\n- Box B: Opaque — contains £1,000,000 if the predictor predicted you would take ONLY Box B, or empty if they predicted you'd take BOTH.\n\nThe predictor has been right 99.9% of the time. The prediction is already made — you cannot change it.\n\nDo you take both boxes (guaranteed £1,000 + whatever is in B) or only Box B?\n\nTwo brilliant principles give opposite answers:\n- DOMINANCE: Taking both boxes always gets you more (regardless of what's in B, two boxes > one box)\n- EXPECTED VALUE: Taking only Box B has vastly higher expected value given the predictor's accuracy\n\nWhich principle do you trust — and why?",
      type: ChallengeType.philosophy,
      sourceName: 'Philosophy Experiments',
      sourceDescription: 'Decision theory, free will, and causation vs. correlation',
      category: 'Decision Theory',
      difficulty: 5,
      hintTiers: [
        "Think about CAUSAL vs EVIDENTIAL decision theory. Causal: choose what causes the best outcome. Evidential: choose what is the best EVIDENCE you're the kind of person who gets the best outcome. These give different answers here.",
        "Consider: \"The box is already set — my choice can't change what's in it.\" This seems right. But 99.9% of one-boxers are millionaires. If you two-box, you're almost certainly in the group that has only £1,000. Does this matter?",
        "Ask: what does this problem reveal about FREE WILL? If the predictor can predict your choice nearly perfectly, in what sense are you freely choosing? And if you're free to confound the prediction, why can't you simply predict that you'll take B and then take both?",
      ],
      thinkingAngles: [
        'causal vs evidential decision theory',
        'dominance principle vs expected value',
        'implications for free will and determinism',
        'the role of prediction in decision making',
        'self-fulfilling and self-defeating predictions',
      ],
    ),
    Challenge(
      id: 'cog_012',
      title: "The Gambler's Fallacy",
      question:
          "A fair coin has landed heads 8 times in a row. What's the probability it lands heads on the 9th flip?\n\nMost people feel strongly it 'must' be tails now — the universe owes a correction. This is the Gambler's Fallacy: believing independent random events are connected and 'balance out' over time.\n\nThe coin doesn't remember its history. P(heads) = 0.5 every single time.\n\nBut here's the twist: after 8 consecutive heads, a RATIONAL person should actually update their belief that the coin might be BIASED toward heads. So the error isn't just the gambler's fallacy — it's treating a potentially non-random system as random.\n\nWhen is it rational to believe in 'runs' vs independent events?",
      type: ChallengeType.cognitiveBias,
      sourceName: 'The Decision Lab',
      sourceDescription: 'Believing past random events affect future independent outcomes',
      category: "Gambler's Fallacy",
      difficulty: 3,
      hintTiers: [
        "Think about the HOT HAND debate: for decades, economists said basketball players' \"hot streaks\" were the gambler's fallacy in reverse. Recent research suggests hot hands may be REAL. The question is always: is this system truly random?",
        "Consider the INVERSE error: the opposite of gambler's fallacy is assuming every streak indicates skill or bias. But most streaks in financial markets, sports, and business are random noise. How do you tell the difference?",
        'Ask: what sample size would you need before 8 heads in a row should update your belief that a coin is biased? This is Bayesian reasoning — and it shows that the "right" answer depends entirely on your prior probability of the coin being fair.',
      ],
      thinkingAngles: [
        'independence of random events',
        'Bayesian updating on observed patterns',
        'hot hand fallacy and its recent vindication',
        'when pattern recognition serves vs misleads us',
        'the base rate of biased coins',
      ],
    ),
  ];

  static List<Challenge> getPhilosophyChallenges() =>
      allChallenges.where((c) => c.type == ChallengeType.philosophy).toList();

  static List<Challenge> getCognitiveBiasChallenges() =>
      allChallenges.where((c) => c.type == ChallengeType.cognitiveBias).toList();

  static Challenge? getById(String id) {
    try {
      return allChallenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Picks two challenges for the week: one philosophy, one cognitive bias
  /// Avoids recently used challenges
  static List<Challenge> pickWeeklyChallenges(List<String> recentIds) {
    var philo = getPhilosophyChallenges()
        .where((c) => !recentIds.contains(c.id))
        .toList();
    var cogn = getCognitiveBiasChallenges()
        .where((c) => !recentIds.contains(c.id))
        .toList();

    // Fallback to full list if all have been used
    if (philo.isEmpty) {
      philo = getPhilosophyChallenges();
    }
    if (cogn.isEmpty) {
      cogn = getCognitiveBiasChallenges();
    }

    philo.shuffle();
    cogn.shuffle();

    return [philo.first, cogn.first];
  }
}
