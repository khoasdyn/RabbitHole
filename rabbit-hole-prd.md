# Rabbit Hole

**A progressive deep-learning app that turns curiosity into expertise, one layer at a time.**

Pick any topic. Go from knowing nothing to knowing everything, one day at a time, through AI-generated videos, articles, quizzes, and discussions that level up as you do.

## Problem statement

Most people today consume knowledge in fragments. You watch a 60-second video about black holes, scroll past it, and never go deeper. Social media rewards breadth over depth, so you end up knowing a little about everything and a lot about nothing.

Meanwhile, if you actually want to learn something properly, your options are limited. Online courses feel like homework with rigid structures and slow pacing. YouTube and Wikipedia rabbit holes have no structure at all, so you wander aimlessly and retain very little. Traditional educational content treats you like a student, not a curious adult.

There's a gap between "casually curious" and "formally studying." People who are genuinely curious about a topic, who want more than surface-level content but aren't ready to enroll in a course, have no good tool designed for them. They want depth, variety, and progression without the weight of a classroom.

**Rabbit Hole fills this gap.** It gives curious people a structured yet engaging way to deeply explore any topic through varied content types that progressively increase in complexity, making the experience feel like a natural deepening of understanding rather than a course or a feed.

## Target user

Curious adults who want to deeply understand topics they care about, but find courses too rigid and social media too shallow. They are self-directed learners who enjoy going deep on one subject at a time and prefer active engagement (quizzes, discussions, challenges) over passive reading.

## Project scope

This document describes a **UI/UX prototype** of an iOS app. The goal at this stage is to nail the interface, user flow, and overall feel of the experience.

**What this prototype includes:**

- Fully designed and interactive UI screens
- Pre-prepared mock content for demonstration purposes
- Simulated topic input, content feed, and progression system
- All core user flows functional with mock data

**What this prototype does NOT include:**

- Real AI content generation (all content is pre-built mock data)
- Backend infrastructure, databases, or API integrations
- User authentication or account management
- Real-time data persistence across sessions (local state only)
- Monetization features

These deferred elements are noted throughout this document for future reference but are explicitly out of scope for the prototype build.


For all technical specifications, architecture, and coding standards, refer to the companion document: **`rabbit-hole-technical-requirements.md`**


## Core concepts

### Topic as the anchor

Everything in Rabbit Hole revolves around a single topic the user has chosen. The entire app experience, including the content feed, progression tracking, and UI theming, is oriented around this one subject. The user can switch topics at any time, but the app encourages focused, sustained exploration of one topic before moving on.

### Freeform topic input

Rather than browsing a curated catalog, users type what they want to learn in their own words. Examples: "Stoicism," "How nuclear reactors work," "Cognitive biases," "The history of jazz." The app interprets this input and builds a content experience around it.

For the prototype, this is simulated by mapping keyword inputs to pre-built mock content sets. The UI presents it as a freeform text input with no visible catalog or category restrictions.

### Progressive depth (the leveling system)

Content is organized into progressive levels that represent the user's depth of understanding:

| Level | Label | Description | Example (topic: Stoicism) |
|-------|-------|-------------|---------------------------|
| 1 | **Newcomer** | Absolute basics, definitions, "what is this?" | What is Stoicism? Who were the Stoics? |
| 2 | **Explorer** | Key concepts, major figures, foundational ideas | The four virtues, Marcus Aurelius, Seneca |
| 3 | **Student** | Deeper principles, nuance, historical context | Stoic logic, the discipline of assent, Stoicism vs Epicureanism |
| 4 | **Practitioner** | Application, real-world relevance, critical thinking | Applying Stoic principles to modern life, critiques of Stoicism |
| 5 | **Expert** | Advanced discourse, edge cases, original thinking | Academic debates, Stoicism's influence on CBT, synthesizing your own Stoic framework |

**Unlocking mechanism (Duolingo-inspired):** Users unlock the next level by either spending 24 hours engaging with content at their current level, or completing challenge sets (a series of quizzes/exercises) to skip ahead early. This creates a natural pacing that prevents surface-level skimming while rewarding active engagement.

For the prototype, this system is visually represented and interactive with mock data, but does not require real progress tracking logic.

### Content variety

A core design principle of Rabbit Hole is that learning should never feel monotonous. The content feed mixes multiple content types to keep engagement high and cater to different learning preferences within the same user. Each content type serves a different cognitive purpose:

| Content type | Format | Purpose | Example |
|-------------|--------|---------|---------|
| **Short video** | 30-90 second video clip | Quick visual explanation, hook attention | Animated explainer on what Stoicism is |
| **Article** | 300-800 word text with images | Deeper reading, context and nuance | "The life of Marcus Aurelius and why it matters" |
| **Image card** | Single image with caption or overlay text | Visual concept, infographic, memorable snapshot | Infographic of the four Stoic virtues |
| **Quiz** | Multiple choice or short answer, 3-5 questions | Test understanding, reinforce retention | "Which Stoic philosopher said...?" |
| **Discussion** | AI-driven Socratic Q&A thread | Active thinking, articulating understanding | "Do you think Stoic emotional control is healthy or suppressive?" |
| **Survey/poll** | Single question with response options | Self-reflection, opinion formation | "Which Stoic virtue do you find hardest to practice?" |
| **Challenge** | Task or exercise to complete | Application of knowledge, level progression | "Write down 3 situations this week where you could apply the dichotomy of control" |

For the prototype, all content pieces are pre-written mock data. The feed should visually demonstrate variety by interspersing different content types rather than grouping them.

> **Future note:** In production, all content types will be AI-generated in real-time or through batch processing. Short videos and podcast episodes are the most resource-intensive to generate and may be phased in after text-based content types are validated. Discussions will use conversational AI (like Claude) for real-time Socratic dialogue.


## User flows

### Flow 1: First launch and topic selection

```
App opens
  → Welcome screen with app branding and a single compelling line:
    "What do you want to master?"
  → Large, centered text input field with placeholder text:
    e.g., "Stoicism, quantum physics, how bread is made..."
  → User types their topic and taps "Dive In"
  → Brief loading/transition animation
    (visually suggests the app is "building" their learning path)
  → Content feed appears, starting at Level 1: Newcomer
```

There is no sign-up, no onboarding tutorial, no category browsing. The user goes from launch to content in under 10 seconds. The first-time experience should feel immediate and exciting.

### Flow 2: Content feed browsing

```
User is on the content feed for their chosen topic
  → Feed displays a vertical scroll of mixed content types
  → Each content card is visually distinct by type:
    - Video cards show a thumbnail with a play button
    - Articles show a headline, preview text, and estimated read time
    - Image cards display the image prominently with overlay text
    - Quizzes show the question count and a "Start Quiz" button
    - Discussions show the prompt question with a "Join Discussion" button
    - Surveys show the question with tappable response options inline
    - Challenges show the task with a "Start Challenge" button
  → User scrolls vertically through content
  → Tapping a card opens it in a detail/full-screen view
  → After consuming a piece of content, user returns to the feed
  → The current level is always visible (e.g., a subtle top bar or badge)
```

The feed should feel like an infinite scroll within the current level. Content is ordered to maintain variety (never two articles in a row, never two quizzes in a row).

### Flow 3: Engaging with a content piece

Each content type has its own detail view:

**Short video:** Full-screen vertical video player with play/pause, progress bar, and a "Next" button. Below the video, a brief text summary of the key point is shown.

**Article:** Clean reading view with the title, body text, and inline images. Estimated read time shown at the top. A "Mark as Read" or completion indicator at the bottom.

**Image card:** Full-screen image with caption text overlaid or below. Swipe to dismiss.

**Quiz:** One question at a time, with tappable answer options. Immediate feedback after each answer (correct/incorrect with a brief explanation). Summary score at the end.

**Discussion (Socratic AI dialogue):** A conversational thread UI. The app presents a thought-provoking question related to the current topic and level. The user types a response. The AI responds with a follow-up question or challenges their reasoning. This continues for 3-5 exchanges. For the prototype, the AI responses are pre-scripted mock data following a branching or linear script.

**Survey/poll:** Inline on the feed, tappable options. After selecting, the user sees simulated aggregate results (e.g., "68% of learners agree with you"). This creates a sense of community even in a solo experience.

**Challenge:** Description of the task, a text input or checklist for completion, and a "Complete" button. Completing challenges contributes to level progression.

### Flow 4: Level progression

```
User has been engaging with Level 1 content
  → Progress indicator fills up as they consume content and complete activities
  → Two paths to unlock the next level:
    Path A: 24-hour time gate
      → After 24 hours of having the topic active AND minimum engagement
        (e.g., consumed at least 5 pieces of content),
        the next level unlocks automatically
    Path B: Challenge fast-track
      → User taps "Take the Challenge" on the level progress screen
      → Completes a set of 5-10 quiz/exercise questions testing current level knowledge
      → Passing (e.g., 80%+) unlocks the next level immediately
  → Level-up moment: celebratory animation/screen
    → Brief preview of what the next level covers
    → "Continue" button drops them into the new level's content feed
```

The level-up moment should feel rewarding and significant. It's one of the key dopamine loops that keeps users coming back.

### Flow 5: Switching topics

```
User is on any screen
  → Navigation includes a way to access topic management
    (e.g., a top-left menu or a dedicated tab)
  → Topic management screen shows:
    - Current active topic with its level and progress
    - Previously explored topics (with their saved progress)
    - "Explore something new" button → returns to the topic input screen
  → Tapping a previous topic reactivates it and resumes from saved progress
  → Tapping "Explore something new" opens the freeform topic input
  → Only one topic is active at a time in the content feed
```

This flow encourages depth (one topic at a time) while allowing the user to pivot whenever they want without losing progress on previous explorations.


## App structure and navigation

### Screen map

```
├── Welcome / Topic Input Screen
│     The entry point. "What do you want to master?"
│
├── Content Feed (main screen)
│     Vertical scrolling feed of mixed content for the active topic.
│     Shows current level indicator.
│     ├── Video Detail View
│     ├── Article Detail View
│     ├── Image Full-Screen View
│     ├── Quiz Flow (question → answer → result)
│     ├── Discussion Thread View
│     └── Challenge Detail View
│
├── Level Progress Screen
│     Shows current level, progress bar, XP or engagement stats,
│     and the option to take a challenge to unlock the next level.
│     Also previews what's coming in the next level.
│
├── Topic Management Screen
│     Lists active topic and past topics.
│     Option to start a new topic.
│
└── Settings Screen (minimal for prototype)
      Placeholder for future preferences, account, notifications.
```

### Navigation pattern

The app uses a **tab bar** at the bottom with three primary tabs:

| Tab | Icon concept | Destination |
|-----|-------------|-------------|
| **Feed** | Scroll/cards icon | Content feed for active topic |
| **Progress** | Layers/level icon | Level progress and challenge access |
| **Topics** | Compass/search icon | Topic management and new topic input |

A settings gear icon can be placed in the top-right corner of the Topics or Progress screen.


## UI and visual direction

### Overall aesthetic

The visual identity should feel **immersive, modern, and slightly dark**, drawing from the metaphor of going down a rabbit hole: deeper means darker, richer, more complex. The design should feel premium and focused, more like a curated knowledge app than a playful game.

### Design principles

**Depth as a visual metaphor.** The UI should subtly reinforce the concept of going deeper. As the user levels up, the visual theme can shift slightly: Level 1 feels lighter and more open, while Level 5 feels deeper, richer, and more complex. This can be achieved through color palette shifts, background textures, or typography weight.

**Content-first layout.** Every screen should prioritize the content itself. Minimal chrome, no unnecessary UI clutter. The content cards should feel like the primary surface, not buttons and navigation.

**Distinct content type cards.** Each content type must be instantly recognizable at a glance through a combination of layout, iconography, and subtle color coding. The user should never have to read a label to know if something is a video, a quiz, or an article.

**Celebratory progression moments.** Level-up screens, challenge completions, and streak milestones should have satisfying animations and visual feedback. These moments are critical for retention.

### Color direction

A dark base palette with accent colors that shift by topic or level. For example:

- Base background: deep charcoal or near-black
- Primary text: off-white
- Accent color: a signature color per topic (e.g., deep blue for "Astrophysics," warm amber for "Stoicism," green for "Ecology") or per level (getting richer/more saturated as levels increase)
- Content cards: slightly elevated surfaces with subtle shadows or borders

### Typography

Clean, highly readable sans-serif. Two weights are sufficient: a bold weight for headings and a regular weight for body text. Generous line spacing, especially in article reading views, to ensure comfortable reading.


## Mock data requirements

To demonstrate the prototype effectively, the following mock data should be prepared:

### Mock topics (minimum 2 fully built out)

**Primary demo topic: Stoicism**
This is the topic used for the main walkthrough and demonstration. It should have complete mock content across all five levels.

**Secondary demo topic: Astrophysics**
A second topic to demonstrate topic switching and to show that the app works across different subject areas. This can have content for levels 1 through 3 only.

### Mock content per level (for the primary topic)

Each level should have approximately 8 to 12 pieces of mock content, distributed roughly as follows:

- 2 short video entries (thumbnail image + title + duration; actual video playback not required, a static player UI is sufficient)
- 2-3 articles (full text, 300 to 800 words each)
- 1-2 image cards (actual images with captions)
- 1-2 quizzes (3 to 5 questions each with correct answers and explanations)
- 1 discussion thread (pre-scripted 3 to 5 exchange conversation)
- 1 survey with mock aggregate results
- 1 challenge with a task description

This means approximately **40 to 60 pieces of mock content** for the primary topic across all five levels.

### Mock progression data

- A progress bar state for each level (e.g., Level 1 at 75% complete, Level 2 locked, etc.)
- A sample "challenge quiz" set for demonstrating the fast-track unlock mechanic
- A level-up transition state


## Success criteria for the prototype

The prototype is considered successful if the following are true:

**The core loop is clear and compelling.** A new user picking up the app should understand within 10 seconds what the app does and how to use it. The flow from topic input to content consumption to progression should feel intuitive with no instruction needed.

**The content variety feels engaging.** Scrolling the feed should feel dynamic and interesting, not repetitive. The visual distinction between content types should be immediate and the transitions between them smooth.

**The progression system is motivating.** The level indicator, progress tracking, and level-up moments should create a clear sense of advancement. The user should feel pulled forward by curiosity about what the next level contains.

**Topic switching is frictionless.** Moving between topics and returning to a previous topic should feel easy and not disruptive to the experience.

**The visual design feels premium and immersive.** The app should not look like a generic education app or a gamified quiz app. It should feel like a carefully crafted experience that respects the user's intelligence and curiosity.


## Future considerations (out of scope for prototype)

These items are documented here for context and future planning. They are explicitly **not part of the prototype build**.

- **Real AI content generation:** Integration with LLMs (Claude) for text, quizzes, and discussions. Integration with image generation models for visual content. Integration with text-to-speech and video generation for audio/video content.
- **Backend and data persistence:** User accounts, cloud-saved progress, content caching, and syncing across devices.
- **Adaptive difficulty:** AI that adjusts content complexity based on quiz performance and engagement patterns, rather than fixed level gates.
- **Community features:** Shared discussions, leaderboards, or collaborative challenges with other users exploring the same topic.
- **Content bookmarking and review:** Ability to save, revisit, or share individual content pieces.
- **Notifications and streaks:** Daily reminders, streak tracking, and push notifications to drive retention.
- **Monetization:** Subscription model, content gating, or premium topic access.
