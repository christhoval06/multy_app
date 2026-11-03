# Multy Landing Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Match the supplied landing reference with responsive Flutter and focused SOLID responsibilities.
**Architecture:** Keep lib/landing/main.dart and web/. Compose feature sections from shared design primitives. Inject quiz state and external URL opening; immutable content is separate from rendering.
**Tech Stack:** Flutter Material, existing url_launcher, bundled fonts and screenshots.
**Spec:** docs/superpowers/specs/2026-11-03-multy-landing-design.md

## Global Constraints
- Canonical YAML tokens; Rubik and Plus Jakarta Sans.
- Local screenshot and icon assets, no reference CDN dependencies.
- Preserve existing mobile entry point and unrelated changes.
- Store URL: https://apps.apple.com/us/app/multy-multiplication-tables/id6759070074

## Review Focus
- 320px viewport and 2x text scale must not overflow.
- Repeated answers must not inflate score.
- Mobile menu and desktop navigation must reveal target sections below header.
- External launch failures need visible feedback.
- Assets, fonts and policy must be included in the release build.

### Task 1: Foundations and interactions
- [x] Bundle fonts, screenshots, icon and policy; centralize design tokens and asset names.
- [x] Define immutable QuizQuestion / QuizOption and QuizController submit/next API.
- [x] Add focused scoring/progression tests and run them RED then GREEN.
- [x] Define LandingLinkOpener.open(Uri) and a url_launcher adapter; keep actions injectable.

### Task 2: Page composition
- [x] Build shared SectionShell, SectionHeading, Badge, TactileButton and PhoneMockup widgets.
- [x] Implement responsive header/navigation and hero, steps, features, story, privacy, playground, download and footer.
- [x] Connect App Store, policy, contact and section actions; remove placeholder destinations.

### Task 3: Verification
- [x] Test phone/tablet/desktop layout, 2x text scale, navigation and quiz interactions.
- [x] Run targeted flutter analyze and landing tests, then flutter build web -t lib/landing/main.dart.
- [ ] Inspect browser at phone and desktop widths. Browser automation could not attach; visual browser review remains pending.
- [x] Review changed files and document remaining limits.

## Decisions
- Work in the current checkout because existing uncommitted landing scaffolding and user-supplied assets are needed here.
- Keep the current published policy as bundled text; do not invent legal assurances from the visual reference.
- Implement inline; no per-task agent delegation.

## Verification
- Landing tests: 10 passed.
- Targeted Dart analysis: no issues found.
- Release web build: passed; output in build/web.
- Netlify build command targets lib/landing/main.dart. Hosting must provide the Flutter SDK.
