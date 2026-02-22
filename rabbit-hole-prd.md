# Rabbit Hole

**A progressive deep-learning app that turns curiosity into expertise, one layer at a time.**

Pick any question. Go from knowing nothing to knowing everything, one day at a time, through articles, quizzes, discussions, and challenges that level up as you do.

## Problem statement

Most people consume knowledge in fragments. You watch a 60-second video about black holes, scroll past it, and never go deeper. Social media rewards breadth over depth.

Meanwhile, if you want to learn something properly, your options are limited. Online courses feel like homework. YouTube and Wikipedia rabbit holes have no structure. Traditional educational content treats you like a student, not a curious adult.

There's a gap between "casually curious" and "formally studying." People who want more than surface-level content but aren't ready to enroll in a course have no good tool designed for them.

**Rabbit Hole fills this gap.** It gives curious people a structured yet engaging way to deeply explore any topic through varied content types that progressively increase in complexity.

## Target user

Curious adults who want to deeply understand topics they care about, but find courses too rigid and social media too shallow. Self-directed learners who enjoy going deep on one subject at a time and prefer active engagement (quizzes, discussions, challenges) over passive reading.

## Project scope

This document describes an **iOS app prototype** with on-device AI content generation.

**What this prototype includes:**

- Fully designed and interactive UI screens
- Pre-prepared mock content for the primary demo question (Stoicism)
- On-device AI article generation for custom topics using Apple Foundation Models
- Follow-up question generation to guide progressive exploration
- Content feed with 4 distinct content types, each with working detail views
- SwiftData persistence across app launches

**What this prototype does NOT include:**

- Backend infrastructure, databases, or external API integrations
- User authentication or account management
- Level progression system (planned, not yet built)
- Tab bar navigation (planned, not yet built)
- Monetization features

For technical specifications, refer to: **`rabbit-hole-technical-requirements.md`**


## Core concepts

### Question as the anchor

Everything revolves around a single question the user has chosen. The content feed, progression tracking, and UI theming are all oriented around this one question. Rather than exploring "Stoicism" broadly, the user is investigating "Were the Stoics right that most of your problems are imaginary?"

The question serves as both the entry point and the narrative thread. As the user goes deeper, the question's scope naturally expands, but it always stays grounded in the original provocation.

### Two paths to a question

The welcome screen offers two ways to start exploring:

**Custom prompt.** A text input at the top of the welcome screen where the user types their own question in their own words. This is the primary path for users who arrive with a specific curiosity. When submitted, this creates a new Topic in SwiftData with the "Custom" subject area and opens the content feed. The on-device AI generates an initial article, followed by follow-up questions for continued exploration.

**Curated picks.** Below the prompt input, the app presents a set of pre-written questions across various subject areas. These are editorially crafted to be maximally engaging and serve two purposes: they give undecided users an immediate on-ramp, and they showcase the kind of question framing the app encourages. The Stoicism question has full mock content; others trigger AI generation.

The curated questions also subtly teach the user what a good question looks like, so when they do type their own, they're more likely to write something specific and engaging rather than broad.

### Content question guidelines

The curated questions are the single most important piece of content in the experience. They are the hook. Every proposed question must follow these principles:

**Specific, not broad.** Zoom in on a concrete angle, not an entire field.

| Bad (too broad) | Good (specific and engaging) |
|-----------------|------------------------------|
| What is Stoicism? | Were the Stoics right that most of your problems are imaginary? |
| What is design thinking? | How did Airbnb use design thinking to avoid going bankrupt? |
| Tell me about black holes | What happens to time when you fall into a black hole? |

**Catching and engaging.** Should trigger surprise, disagreement, curiosity, or a "wait, really?" moment.

**Conversational and concise.** Under 15 words. No academic phrasing, no jargon.

**Opinionated or provocative when possible.** "Is travelling really that good?" beats "What are the benefits of travelling?"

**Not definitional.** No "What is X?" questions. Definitions get woven into content naturally.

**Variety in tone.** Mix of "how", "why", "is it true that", "what happens when", and "who/what changed" questions.

### Progressive depth (the leveling system)

Content is organized into 5 progressive levels:

| Level | Label | Description |
|-------|-------|-------------|
| 1 | **Newcomer** | Absolute basics, grounding the question in context |
| 2 | **Explorer** | Key concepts and figures behind the question |
| 3 | **Student** | Deeper principles, nuance, and counterarguments |
| 4 | **Practitioner** | Real-world application and critical thinking |
| 5 | **Expert** | Advanced discourse, synthesis, and original thinking |

**Unlocking mechanism:** Either 24-hour time gate with minimum engagement, or challenge fast-track (pass a quiz at 80%+).

*Not yet implemented in prototype. Currently only Level 1 content is seeded and displayed.*

### Content variety

The feed uses 4 text-based content types:

| Content type | Format | Purpose |
|-------------|--------|---------|
| **Article** | Under 200 word text | Core learning content, conversational tone |
| **Quiz** | Multiple choice, 3-5 questions | Test understanding |
| **Discussion** | Socratic Q&A thread | Active thinking |
| **Challenge** | Task or exercise | Application of knowledge |

Articles are the primary content type and the only type currently generated by AI. Quiz, discussion, and challenge content uses pre-built mock data for the Stoicism topic.

### Follow-up questions

At the end of each topic's feed, the app generates 3-5 follow-up questions using the on-device AI. These questions explore specific angles, causes, consequences, or real-world examples that help reveal the answer to the main topic question. When the user selects a follow-up, a new article is generated and appended to the feed, followed by a new set of follow-up questions. This creates an open-ended exploration loop driven by the user's curiosity.


## User flows

### Flow 1: First launch and question selection (implemented)

```
App opens
  → Welcome screen: "What are you curious about?"
  → Text input at top for typing a custom question
  → Below: "Or pick one to explore" with curated question cards
  → User either types and submits, or taps a curated question
  → Content feed appears, starting at Level 1
```

### Flow 2: Content feed browsing (implemented)

```
User is on the content feed
  → Vertical scroll of mixed content types
  → Each card is visually distinct by type (badge, layout, color)
  → Tapping opens detail view (sheet or full-screen)
  → Level pill in nav bar shows current level
  → Back button returns to welcome screen
```

### Flow 3: AI article generation (implemented)

```
User creates a custom topic or selects a topic with no content
  → Feed shows skeleton card with shimmer animation
  → On-device model generates article (streamed progressively)
  → Completed article persists to SwiftData
  → Follow-up questions generate and appear below the article
  → User taps a follow-up question
  → New skeleton card appears, new article generates
  → New follow-up questions appear
  → Cycle repeats
```

### Flow 4: Engaging with content (implemented)

Each type has its own detail view:

- **Article:** Full reading view with body text, "Mark as Read"
- **Quiz:** Step-by-step questions, green/red feedback, explanation, results screen
- **Discussion:** Chat-like UI, user types responses, AI replies appear with delay
- **Challenge:** Task instructions, text input, "Complete Challenge" with success banner

### Flow 5: Level progression (not yet implemented)

```
Progress bar fills as user completes content
  → 24-hour time gate OR challenge fast-track to unlock next level
  → Level-up celebration screen
  → New content feed at next level
```

### Flow 6: Switching questions (not yet implemented)

```
Tab bar with Feed / Progress / Explore
  → Explore tab shows active + past questions
  → Tap to switch, progress saved
```


## App structure and navigation

### Current screen map

```
├── Welcome / Question Selection Screen (implemented)
│     Custom question input + curated question cards
│
├── Content Feed (implemented)
│     Vertical feed with level pill in nav bar
│     ├── Article Detail View ✓
│     ├── Quiz Flow ✓
│     ├── Discussion Thread View ✓
│     ├── Challenge Detail View ✓
│     ├── Article Skeleton Card (AI generation) ✓
│     └── Follow-Up Questions (AI generated) ✓
│
├── Level Progress Screen (planned)
├── Question Management / Explore Screen (planned)
└── Tab Bar Navigation (planned)
```

### Planned navigation pattern

Three-tab bar: Feed, Progress, Explore.


## UI and visual direction

### Overall aesthetic

Dark, immersive, modern. Achieved through `preferredColorScheme(.dark)` and system background tiers. The metaphor of going deeper is reinforced visually.

### Color system

System colors only. Accent colors assigned per topic's subject area (orange for Philosophy, blue for Astrophysics, etc.). User-created topics cycle through cyan, mint, teal, indigo, yellow. Content types each have a distinct color (blue for article, orange for quiz, purple for discussion, pink for challenge).

### Components

Shared `TypeBadge` view for consistent content type labeling across all cards. `CardStyle` enum centralizes corner radius, padding, and spacing.


## Mock data

### Current state

**5 seeded questions** on the welcome screen:

| Question | Subject area | Has content |
|----------|-------------|-------------|
| Were the Stoics right that most of your problems are imaginary? | Philosophy | Level 1 (6 items) |
| What happens to time when you fall into a black hole? | Astrophysics | No (AI generates on selection) |
| How did Airbnb use design thinking to avoid going bankrupt? | Design | No (AI generates on selection) |
| Is eating local actually better for the planet? | Environment | No (AI generates on selection) |
| Can you actually rewire your brain by changing your habits? | Neuroscience | No (AI generates on selection) |

**Level 1 Stoicism content** (6 items): 3 articles (full body text), 1 quiz (3 questions with explanations), 1 discussion (4 exchanges), 1 challenge.

**User-created questions** are persisted in SwiftData with "Custom" subject area. AI generates an initial article on creation.

### Planned

Seed Levels 2-5 for the Stoicism question. Extend AI generation to quiz, discussion, and challenge content types.


## Success criteria

- **Core loop is clear.** Question selection → content consumption → follow-up exploration feels intuitive
- **Content variety feels engaging.** Visual distinction between types is immediate
- **AI generation feels seamless.** Skeleton cards and streaming create a smooth experience
- **Question selection is compelling.** Custom input + curated picks give every user an entry point
- **Visual design feels premium.** Dark, content-first, not gamified


## Future considerations (out of scope)

- **Extended AI generation:** On-device generation for quizzes, discussions, and challenges
- **Backend and persistence:** User accounts, cloud sync, cross-device progress
- **Adaptive difficulty:** AI adjusts complexity based on quiz performance
- **Community features:** Shared discussions, leaderboards
- **Content bookmarking and review**
- **Notifications and streaks**
- **Monetization**
