# Configurable Timer Settings Design

## Summary

Add two configurable timing preferences to the app settings:

- Study card auto-advance interval
- Quiz duration

Both preferences must have persisted defaults so the app keeps the current behavior for users who do not change anything.

## Goals

- Let families adjust the study pace from the settings screen.
- Keep the experience simple and predictable for children.
- Preserve the current defaults on fresh installs and existing devices.
- Reuse the app's current `SharedPreferences` pattern for persistence.

## Non-Goals

- Per-profile timer customization
- Free-form numeric inputs
- Slider-based configuration
- Changes to quiz scoring, number of questions, or study card content

## UX Decision

Use fixed options instead of sliders.

### Study auto-advance

- Options: `3s`, `5s`, `8s`
- Default: `5s`

### Quiz duration

- Options: `30s`, `50s`, `60s`
- Default: `50s`

### Settings presentation

Add a new settings section for practice timing with:

- One tappable row for the study auto-advance interval
- One tappable row for the quiz duration
- One row action to restore default values

Each tappable row should open a simple selection dialog with the allowed options and the current value selected.

## Architecture

### Persistence

Add new preference keys in `AppPrefs`:

- `studyAutoSwipeSeconds`
- `quizDurationSeconds`

Create a small service or config-backed helper responsible for:

- reading each setting from `SharedPreferences`
- returning the default value when the preference is missing
- writing updated values back to `SharedPreferences`

This keeps timing behavior out of the settings UI and makes it reusable from quiz and study flows.

### Default values

Keep app defaults centralized in `lib/configs/settings.dart`.

Add:

- default study auto-swipe seconds
- default quiz duration seconds
- fixed option lists for both settings

## Screen Integration

### Study screen

Replace the hardcoded `5` second interval in `StudyTableScreen` with the persisted setting value.

Expected behavior:

- countdown uses the configured interval
- auto-swipe uses the same configured interval
- toggling auto mode off and on again reuses the configured value

### Quiz flow

Replace the hardcoded `50` second value in `QuizNotifier` with the persisted setting value.

Expected behavior:

- initial countdown uses the configured duration
- quiz reset uses the configured duration
- saved quiz attempt duration is calculated from the configured duration instead of a hardcoded constant

## Error Handling

- If preferences are missing, use defaults.
- If a saved value is invalid or unsupported, fall back to defaults.
- Restore defaults should update storage and refresh the visible values immediately.

## Testing

Add or update tests to cover:

- settings screen shows the timing section
- selecting a study interval persists the chosen option
- selecting a quiz duration persists the chosen option
- restore defaults resets both values
- quiz notifier uses the persisted quiz duration

## Risks

- If quiz duration remains partially hardcoded, saved attempt durations will become inconsistent.
- If study countdown and swipe timers read different values, the UI countdown will drift from the actual swipe behavior.

## Implementation Notes

- Keep the UI simple and text-based; avoid adding complex controls.
- Follow the current localization pattern for any new labels.
- Preserve existing behavior for sound and vibration settings.
