# Rabbit Hole

**A progressive deep-learning app that turns curiosity into expertise, one layer at a time.**

Pick any question. Go from knowing nothing to knowing everything, one day at a time, through AI-generated videos, articles, quizzes, and discussions that level up as you do.

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
- Simulated question selection, content feed, and progression system
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

### Question as the anchor

Everything in Rabbit Hole revolves around a single question the user has chosen. The entire app experience, including the content feed, progression tracking, and UI theming, is oriented around this one question and the subject area it opens up. The user can switch questions at any time, but the app encourages focused, sustained exploration of one question before moving on.

The question serves as both the entry point and the narrative thread. Rather than exploring "Stoicism" broadly, the user is investigating "Were the Stoics right that most of your problems are imaginary?" This framing keeps the content focused, opinionated, and engaging at every level. As the user goes deeper, the question's scope naturally expands to encompass the broader subject, but it always stays grounded in the original provocation.

### Question-driven exploration

Rather than typing a broad topic or browsing a catalog, users choose from a curated set of proposed questions. The app presents engaging, specific questions that spark curiosity and pull the user into a subject through a compelling angle rather than a dry definition.

This is a deliberate design choice. Broad topics like "Stoicism" or "Design thinking" lead to generic, encyclopedia-style content. A specific, opinionated question like "Were the Stoics right that most of your problems are imaginary?" immediately frames the exploration around a provocative idea, gives the content a narrative direction, and makes the user feel like they're investigating something rather than studying a subject.

For the prototype, the app displays a selection of pre-written questions across various subject areas. The user picks one, and the app builds the content journey around it.

### Content question guidelines

The questions the app proposes are the single most important piece of content in the entire experience. They are the hook. If the questions feel like textbook chapter titles, users will scroll past them. Every proposed question must follow these principles:

**Specific, not broad.** The question should zoom in on a concrete angle, scenario, or claim rather than asking about an entire field. It should feel like the start of an interesting conversation, not a Wikipedia search query.

| Bad (too broad) | Good (specific and engaging) |
|-----------------|------------------------------|
| What is Stoicism? | Were the Stoics right that most of your problems are imaginary? |
| What is design thinking? | How did Airbnb use design thinking to avoid going bankrupt? |
| Tell me about black holes | What happens to time when you fall into a black hole? |
| What is climate change? | Is eating local actually better for the planet? |
| History of jazz | Why did jazz musicians start breaking all the rules in the 1940s? |

**Catching and engaging.** The question should trigger an emotional or intellectual reaction: surprise, disagreement, curiosity, or a "wait, really?" moment. It should feel like a question you'd want to hear the answer to at a dinner party.

**Conversational and concise.** Questions should read like something a curious person would actually ask out loud. Keep them short, ideally under 15 words. No academic phrasing, no jargon, no filler.

**Opinionated or provocative when possible.** Questions that imply a stance, challenge a common belief, or present a counterintuitive angle tend to perform best. "Is travelling really that good?" is more engaging than "What are the benefits of travelling?" because it makes the user want to find out the answer.

**Not definitional.** Avoid "What is X?" or "Define X" style questions. The app is not an encyclopedia. If the user needs a definition, it can be woven into the content naturally. The entry point should always be a question that makes the user think, not one that makes them expect a textbook answer.

**Variety in tone and angle.** Across the set of proposed questions, there should be a healthy mix of "how" questions (process, mechanism), "why" questions (cause, motivation), "is it true that" questions (myth-busting, challenging assumptions), "what happens when" questions (consequences, scenarios), and "who/what changed" questions (pivotal moments, key figures in action).

### Progressive depth (the leveling system)

Content is organized into progressive levels that represent the user's depth of understanding:

| Level | Label | Description | Example (question: "Were the Stoics right that most of your problems are imaginary?") |
|-------|-------|-------------|---------------------------|
| 1 | **Newcomer** | Absolute basics, grounding the question in context | What did the Stoics actually believe? What do they mean by "imaginary" problems? |
| 2 | **Explorer** | Key concepts and figures behind the question | The dichotomy of control, Marcus Aurelius's journal, Epictetus on perception |
| 3 | **Student** | Deeper principles, nuance, and counterarguments | Stoic logic of impressions, how this compares to Buddhist detachment, valid critiques |
| 4 | **Practitioner** | Real-world application and critical thinking | Testing Stoic reframing on modern anxiety, when Stoicism fails, practical exercises |
| 5 | **Expert** | Advanced discourse, synthesis, and original thinking | Stoicism's influence on CBT, academic debates on emotional suppression, building your own framework |

**Unlocking mechanism (Duolingo-inspired):** Users unlock the next level by either spending 24 hours engaging with content at their current level, or completing challenge sets (a series of quizzes/exercises) to skip ahead early. This creates a natural pacing that prevents surface-level skimming while rewarding active engagement.

For the prototype, this system is visually represented and interactive with mock data, but does not require real progress tracking logic.

### Content variety

A core design principle of Rabbit Hole is that learning should never feel monotonous. The content feed mixes multiple content types to keep engagement high and cater to different learning preferences within the same user. Each content type serves a different cognitive purpose:

| Content type | Format | Purpose | Example |
|-------------|--------|---------|---------|
| **Short video** | 30-90 second video clip | Quick visual explanation, hook attention | Animated explainer: "What did the Stoics mean by 'it's all in your head'?" |
| **Article** | 300-800 word text with images | Deeper reading, context and nuance | "Marcus Aurelius wrote a journal no one was supposed to read. Here's what it says about your problems." |
| **Image card** | Single image with caption or overlay text | Visual concept, infographic, memorable snapshot | Infographic mapping the Stoic dichotomy of control to everyday situations |
| **Quiz** | Multiple choice or short answer, 3-5 questions | Test understanding, reinforce retention | "Epictetus was a slave. How did that shape his idea that suffering is a choice?" |
| **Discussion** | AI-driven Socratic Q&A thread | Active thinking, articulating understanding | "Your flight got cancelled and you're stuck overnight. A Stoic would say that's not actually a problem. Do you agree?" |
| **Survey/poll** | Single question with response options | Self-reflection, opinion formation | "When something goes wrong, is your first instinct to fix it or to stress about it?" |
| **Challenge** | Task or exercise to complete | Application of knowledge, level progression | "Pick one thing bothering you today. Write down what you can control about it and what you can't." |

For the prototype, all content pieces are pre-written mock data. The feed should visually demonstrate variety by interspersing different content types rather than grouping them.

> **Future note:** In production, all content types will be AI-generated in real-time or through batch processing. Short videos and podcast episodes are the most resource-intensive to generate and may be phased in after text-based content types are validated. Discussions will use conversational AI (like Claude) for real-time Socratic dialogue.


## User flows

### Flow 1: First launch and question selection

```
App opens
  → Welcome screen with app branding and a single compelling line:
    "What are you curious about?"
  → A curated grid or list of proposed questions, each presented as
    a tappable card. Questions span different subject areas to offer variety.
    e.g., "Were the Stoics right that most of your problems are imaginary?"
         "What happens to time when you fall into a black hole?"
         "Why did jazz musicians start breaking all the rules in the 1940s?"
         "Is eating local actually better for the planet?"
  → User taps a question that catches their interest
  → Brief loading/transition animation
    (visually suggests the app is "building" their learning path)
  → Content feed appears, starting at Level 1: Newcomer
```

There is no sign-up, no onboarding tutorial, no typing required. The user goes from launch to content in two taps. The first-time experience should feel immediate and exciting. The questions themselves should be compelling enough that users feel pulled to tap one.

### Flow 2: Content feed browsing

```
User is on the content feed for their chosen question
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

**Discussion (Socratic AI dialogue):** A conversational thread UI. The app presents a thought-provoking prompt related to the current question and level. The user types a response. The AI responds with a follow-up question or challenges their reasoning. This continues for 3-5 exchanges. For the prototype, the AI responses are pre-scripted mock data following a branching or linear script.

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

### Flow 5: Switching questions

```
User is on any screen
  → Navigation includes a way to access question management
    (e.g., a top-left menu or a dedicated tab)
  → Question management screen shows:
    - Current active question with its level and progress
    - Previously explored questions (with their saved progress)
    - "Explore something new" button → returns to the question selection screen
  → Tapping a previous question reactivates it and resumes from saved progress
  → Tapping "Explore something new" shows the curated question selection
  → Only one question is active at a time in the content feed
```

This flow encourages depth (one question at a time) while allowing the user to pivot whenever they want without losing progress on previous explorations.


## App structure and navigation

### Screen map

```
├── Welcome / Question Selection Screen
│     The entry point. "What are you curious about?"
│     Displays a curated set of engaging, specific questions to choose from.
│
├── Content Feed (main screen)
│     Vertical scrolling feed of mixed content for the active question.
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
├── Question Management Screen
│     Lists active question and past questions.
│     Option to explore a new question.
│
└── Settings Screen (minimal for prototype)
      Placeholder for future preferences, account, notifications.
```

### Navigation pattern

The app uses a **tab bar** at the bottom with three primary tabs:

| Tab | Icon concept | Destination |
|-----|-------------|-------------|
| **Feed** | Scroll/cards icon | Content feed for active question |
| **Progress** | Layers/level icon | Level progress and challenge access |
| **Explore** | Compass/search icon | Question management and new question selection |

A settings gear icon can be placed in the top-right corner of the Explore or Progress screen.


## UI and visual direction

### Overall aesthetic

The visual identity should feel **immersive, modern, and slightly dark**, drawing from the metaphor of going down a rabbit hole: deeper means darker, richer, more complex. The design should feel premium and focused, more like a curated knowledge app than a playful game.

### Design principles

**Depth as a visual metaphor.** The UI should subtly reinforce the concept of going deeper. As the user levels up, the visual theme can shift slightly: Level 1 feels lighter and more open, while Level 5 feels deeper, richer, and more complex. This can be achieved through color palette shifts, background textures, or typography weight.

**Content-first layout.** Every screen should prioritize the content itself. Minimal chrome, no unnecessary UI clutter. The content cards should feel like the primary surface, not buttons and navigation.

**Distinct content type cards.** Each content type must be instantly recognizable at a glance through a combination of layout, iconography, and subtle color coding. The user should never have to read a label to know if something is a video, a quiz, or an article.

**Celebratory progression moments.** Level-up screens, challenge completions, and streak milestones should have satisfying animations and visual feedback. These moments are critical for retention.

### Color direction

A dark base palette with accent colors that shift by question or level. For example:

- Base background: deep charcoal or near-black
- Primary text: off-white
- Accent color: a signature color per question's subject area (e.g., deep blue for astrophysics questions, warm amber for philosophy questions, green for ecology questions) or per level (getting richer/more saturated as levels increase)
- Content cards: slightly elevated surfaces with subtle shadows or borders

### Typography

Clean, highly readable sans-serif. Two weights are sufficient: a bold weight for headings and a regular weight for body text. Generous line spacing, especially in article reading views, to ensure comfortable reading.


## Mock data requirements

To demonstrate the prototype effectively, the following mock data should be prepared:

### Mock questions (minimum 2 fully built out, plus additional selection options)

The welcome screen should display at least **8 to 10 proposed questions** across various subject areas to give users a compelling selection. Of these, two are fully built out with content across multiple levels.

**Proposed questions for the welcome screen (examples):**

| Question | Subject area |
|----------|-------------|
| Were the Stoics right that most of your problems are imaginary? | Philosophy |
| What happens to time when you fall into a black hole? | Astrophysics |
| Why did jazz musicians start breaking all the rules in the 1940s? | Music history |
| Is eating local actually better for the planet? | Environment |
| How did Airbnb use design thinking to avoid going bankrupt? | Design/Business |
| Can you actually rewire your brain by changing your habits? | Neuroscience |
| Why do we dream about falling and what does it mean? | Psychology |
| Did the ancient Romans have fast food? | History |
| Is remote work making us lonelier or freer? | Culture/Work |
| Why do some languages have no word for "blue"? | Linguistics |

These questions follow the content question guidelines defined in the core concepts section. Each question is specific, concise, conversational, and designed to provoke curiosity rather than define a subject.

**Primary demo question: "Were the Stoics right that most of your problems are imaginary?"**
This is the question used for the main walkthrough and demonstration. It should have complete mock content across all five levels. The content should explore Stoic philosophy through the lens of this specific question, progressively deepening from "what did the Stoics actually mean by this?" to advanced critiques and modern applications.

**Secondary demo question: "What happens to time when you fall into a black hole?"**
A second question to demonstrate question switching and to show the app works across different subject areas. This can have content for levels 1 through 3 only.

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

**The core loop is clear and compelling.** A new user picking up the app should understand within 10 seconds what the app does and how to use it. The flow from question selection to content consumption to progression should feel intuitive with no instruction needed.

**The content variety feels engaging.** Scrolling the feed should feel dynamic and interesting, not repetitive. The visual distinction between content types should be immediate and the transitions between them smooth.

**The progression system is motivating.** The level indicator, progress tracking, and level-up moments should create a clear sense of advancement. The user should feel pulled forward by curiosity about what the next level contains.

**Question switching is frictionless.** Moving between questions and returning to a previous question should feel easy and not disruptive to the experience.

**The question selection is compelling.** Users should see the proposed questions and immediately feel drawn to tap one. The questions should spark curiosity on their own, before any content is consumed.

**The visual design feels premium and immersive.** The app should not look like a generic education app or a gamified quiz app. It should feel like a carefully crafted experience that respects the user's intelligence and curiosity.


## Future considerations (out of scope for prototype)

These items are documented here for context and future planning. They are explicitly **not part of the prototype build**.

- **Real AI content generation:** Integration with LLMs (Claude) for text, quizzes, and discussions. Integration with image generation models for visual content. Integration with text-to-speech and video generation for audio/video content.
- **Backend and data persistence:** User accounts, cloud-saved progress, content caching, and syncing across devices.
- **Adaptive difficulty:** AI that adjusts content complexity based on quiz performance and engagement patterns, rather than fixed level gates.
- **Content bookmarking and review:** Ability to save, revisit, or share individual content pieces.
