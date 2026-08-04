# Study Table Refresh Design

## Summary

Refresh the study table experience with a more game-like visual direction while preserving the current timer, swipe, and study flow behavior.

The redesign should make the screen feel more intentional and energetic without becoming noisy or overly childish.

## Goals

- Make the study mode feel more like a focused mini-game.
- Improve the visual hierarchy of the timer, progress, and current multiplication card.
- Turn the multiplication card into the clear hero element of the screen.
- Give the fun fact area a more deliberate visual treatment.
- Keep the experience strong on both phone-sized and larger layouts.

## Non-Goals

- No changes to swipe rules or timer behavior.
- No changes to route flow or study logic.
- No new gameplay rules, scoring, or rewards.
- No per-table custom themes.

## UX Direction

Use a `game-like` presentation.

### Overall tone

- Energetic but clean
- More visual depth and contrast
- Friendly for kids without looking overly toy-like

### Layout

Structure the screen into three clear layers:

1. Top status area
2. Main hero card area
3. Bottom supporting fact area

## Screen Design

### Background

- Replace the plain background with a soft green-blue gradient.
- Add subtle decorative shapes or glow accents behind the content.
- Keep contrast high enough so the card remains the focal point.

### Top status area

Promote the study progress and timer into a dedicated in-body status header.

Include:

- Table title or compact table label
- Current progress such as `4 of 12`
- More expressive progress indicator than simple gray dots
- Timer badge that is easy to scan
- More intentional play/pause control

This area should feel like a compact game HUD instead of default app chrome.

### App bar

Keep the app bar minimal so it does not compete with the study content.

Expected treatment:

- Preserve navigation/back behavior
- Reduce visual weight compared to the main content

## Multiplication Card Design

The multiplication card should be the strongest visual element on the screen.

### Card treatment

- Larger corner radius
- Stronger but cleaner shadow
- Brighter surface treatment with layered highlights
- Optional accent badge that references the active table, such as `x7`

### Content hierarchy

- Multiplication expression near the top
- Divider or visual separator around the equals section
- Result centered and very prominent
- Better spacing between the expression, symbol, and answer

### Responsiveness

- Preserve readability on small phones
- Avoid overflow with large results
- Keep the result visually dominant without clipping

## Progress Indicator Design

Replace the current plain dot row with a more expressive indicator.

Preferred approach:

- Rounded capsules or mini steps
- Clear active state
- Softer inactive state
- Sizing that remains readable across all 12 items

## Fun Fact Design

Turn the current fact line into a small supporting card.

Expected treatment:

- Rounded container
- Slight background tint or glass-like effect
- Icon kept, but integrated more cleanly
- Enough height and padding to feel intentional

The fun fact should support the main card instead of feeling like a leftover footer.

## Motion

Add only lightweight motion where it improves clarity.

Good candidates:

- Smooth transitions when the active study card changes
- Small animated emphasis on the active progress item
- Subtle state shift for play/pause

Avoid excessive animation that distracts from reading the multiplication result.

## Accessibility

- Maintain strong contrast for text over gradients
- Ensure timer and progress remain readable at a glance
- Keep tap targets comfortable for play/pause interactions
- Preserve current text scaling behavior as much as possible

## Implementation Shape

Primary files expected to change:

- `lib/screens/study_table_screen.dart`
- `lib/widgets/study_table/multiplication_card.dart`
- `lib/widgets/study_table/progress_indicator_widget.dart`
- `lib/widgets/study_table/fun_fact_widget.dart`

Potential supporting additions:

- Small helper widgets private to the study screen
- Small styling constants if needed, kept local unless broadly reusable

## Testing

Add or update widget tests to verify:

- Study screen still renders the persisted timer value
- Main study UI renders successfully after the visual refresh
- Progress indicator still updates correctly for the active card

## Risks

- The visual refresh could reduce readability if gradients or shadows become too strong.
- The hero card could overflow on smaller devices if typography scales too aggressively.
- Too much decorative UI could compete with the multiplication result.

## Recommendation

Implement the refresh as a presentation-only redesign over the current study flow, keeping behavior intact and using the card as the visual anchor of the whole screen.
