# Offline Multi-Instrument Tuner Product Plan

This is the implementation plan for turning the current Flutter prototype into
a dependable, polished, fully offline tuner. The shorter
[`PRODUCT_GAP_REPORT.md`](PRODUCT_GAP_REPORT.md) remains the product-level gap
summary; this document defines delivery order, scope, and completion criteria.

## Product outcome

A user must be able to install the app, remain offline, create an instrument
with any number of tuning targets, and tune reliably without an account. The UI
must offer two levels of control:

1. **Standard mode** — select an instrument/tuning and a Fast, Balanced, or
   Precise response preset. An **Auto** detector supplies safe defaults.
2. **Expert mode** — configure detector (Auto, HPS, autocorrelation, cepstrum,
   or zero crossing), frequency range, window/FFT size, smoothing, confidence,
   noise gate, reference pitch, and temperament per instrument profile.

Standard and Expert modes must use the same underlying profile and tuning
engine. Standard mode is a simplified view, not a separate implementation.

## Current state

### Available now

- On-device microphone capture and live frequency/note displays.
- Cepstrum, HPS, autocorrelation, and zero-crossing detectors.
- Basic confidence, energy-gate, and frequency-smoothing logic.
- Guitar and ukulele presets.
- Local custom tunings containing any number of manually named frequencies.
- Diagnostic screens, generated tones, sample-audio tools, and performance
  data.

### Important gaps

- There is no Auto detector or user-friendly technical preset system.
- A custom tuning stores only a name and notes; detector/calibration parameters
  are not part of a reusable instrument profile.
- Custom configurations cannot yet be fully edited, reordered, duplicated,
  deleted, imported, or exported.
- A4/reference pitch and equal temperament are effectively fixed assumptions.
- Several visible settings are placeholders and are not saved.
- Harmonic rejection, stable note locking, and “no usable signal” behavior need
  completion and device validation.
- Tests do not yet validate DSP, note mapping, persistence, or actual app flows;
  the remaining starter widget test does not describe the current UI.
- Airplane-mode startup, audio interruptions, accessibility, and the stated
  accuracy/latency targets have not been verified across devices.

## Implementation principles

- Keep audio capture, pure-Dart pitch analysis, profile persistence, and UI
  separate so detection can be tested without a microphone.
- Store user intent in profiles; translate Fast/Balanced/Precise presets into
  validated engine parameters at one boundary.
- Keep all tuning and help data on-device. No account, network request,
  telemetry, or cloud dependency is required for core operation.
- Prefer small, reviewable increments. Do not redesign the UI before the engine
  has deterministic correctness tests.
- Hide experimental diagnostics from the normal journey while keeping them
  available in a clearly marked developer/advanced area.

## Delivery roadmap

### Phase 1 — Prove accuracy and establish a baseline

**Goal:** make correctness measurable before expanding the product model.

**Deliverables**

- Extract detector inputs/outputs behind a pure-Dart interface that accepts PCM
  samples, runtime sample rate, and an immutable parameter object.
- Replace compressed MP3-as-PCM testing with generated tones and decoded PCM/WAV
  fixtures for low notes, common guitar notes, silence, noise, and harmonics.
- Add deterministic tests for PCM decoding, frequency-bin mapping, cents, note
  mapping, each detector, confidence gating, and smoothing.
- Finish noise rejection, fundamental/harmonic selection, and explicit
  “no usable signal” output.
- Measure current latency, jitter, octave errors, and CPU cost; record results by
  detector and frequency range.
- Complete real-device checks for actual sample rate, buffer size, permissions,
  pause/resume, and microphone reconnect behavior.

**Exit criteria**

- Clean generated tones are within ±3 cents after 500 ms across the supported
  range; guitar/bass device trials are within ±5 cents after one second.
- Sustained tones settle to less than ±2 cents jitter, silence produces no note,
  and pitch changes settle within 500 ms.
- Automated tests cover every detector and the full PCM-to-tuning-result path.
- Device results and any detector-specific limits are documented.

### Phase 2 — Build the instrument/profile model

**Goal:** represent arbitrary instruments and all settings needed to reproduce a
tuning session.

**Deliverables**

- Introduce versioned `InstrumentProfile`, `TuningTarget`, and
  `DetectionSettings` models, with migration from existing saved tunings.
- Support any number of ordered targets, including one-note instruments and
  paired/coursed strings.
- Allow target entry by note plus octave, exact frequency, or cents offset, with
  sharp/flat display preference and custom labels.
- Add create, edit, reorder, duplicate, rename, delete, favorite, and validation
  workflows. Protect built-in profiles by copying before editing.
- Add chromatic and target/string modes with automatic or manual target
  selection.
- Persist the active profile, selected mode, reference pitch, temperament, and
  detection settings locally.
- Add human-readable offline import/export and safe recovery for unsupported or
  corrupted profile data.

**Exit criteria**

- A user can create and later edit profiles with 1, 4, 6, 7, 8, 12, or more
  targets without special cases.
- Profiles round-trip through persistence and export/import without data loss.
- Existing custom tunings migrate without being deleted or silently changed.
- Model, migration, validation, and CRUD flows have automated tests.

### Phase 3 — Add Standard and Expert control levels

**Goal:** make strong defaults effortless while keeping technical control
available.

**Deliverables**

- Add an Auto detector that selects or combines proven detectors by range and
  confidence, with a documented fallback when confidence is low.
- Define Fast, Balanced, and Precise presets for latency/accuracy trade-offs.
- Build Standard settings for profile, tuning mode, response preset, reference
  pitch, note naming, and confirmation feedback.
- Build Expert settings for detector, detection range, window/FFT size,
  smoothing, confidence threshold, noise gate, and temperament.
- Validate parameter combinations and offer “reset to recommended” per profile.
- Replace or remove every placeholder settings row and persist every setting
  that remains visible.

**Exit criteria**

- A first-time user can tune without understanding detector terminology.
- Expert values survive restart and affect the engine through one typed settings
  object; invalid combinations cannot start a session.
- Auto meets Phase 1 accuracy targets for guitar, bass, ukulele, and generated
  test ranges and falls back cleanly instead of showing an unstable note.
- Preset mappings and Expert-setting persistence are covered by tests.

### Phase 4 — Polish the tuning journey

**Goal:** provide a clear, fast, and accessible everyday experience.

**Deliverables**

- Focus the primary view on target/detected note, cents deviation, direction,
  signal/confidence, and an unmistakable in-tune or no-signal state.
- Add one-tap target selection, confidence-based note lock, optional automatic
  target progression, and optional sound/vibration confirmation.
- Add first-run microphone permission guidance, input-level checks, and a quick
  accuracy check.
- Complete responsive phone/tablet layouts, dark/light themes, large text,
  screen-reader labels, color-blind-safe feedback, and non-color indicators.
- Provide friendly empty, invalid-profile, permission-denied, interrupted-audio,
  and unsupported-device states.
- Package concise offline help for calibration, target selection, presets, and
  Expert settings.

**Exit criteria**

- Core tuning, profile selection, and recovery paths are usable with a screen
  reader and increased text size and never depend on color alone.
- Sustained notes do not visibly jump between harmonics; UI animation does not
  change the engine result or add noticeable latency.
- Widget/integration tests cover onboarding, profile selection, tuning states,
  permission denial, and recovery states.

### Phase 5 — Verify offline operation and release readiness

**Goal:** make the completed experience trustworthy on supported devices.

**Deliverables**

- Verify first launch, normal use, bundled help, profile editing, backup/restore,
  and restart in airplane mode.
- Publish an in-app privacy statement: audio stays on-device, recordings are
  opt-in, and core use requires no account, analytics, telemetry, or network.
- Test representative low/mid/high-end devices, tablets, built-in microphones,
  and supported external microphones.
- Exercise permission changes, audio focus/calls, background/foreground,
  microphone disconnects, corrupt storage, and interrupted imports.
- Establish a regression matrix for supported frequency range, accuracy,
  latency, jitter, CPU/battery use, and profile compatibility.
- Remove developer controls from release navigation and finish release notes,
  data reset, and local backup documentation.

**Exit criteria**

- All core acceptance journeys pass from a clean install with networking
  disabled.
- Phase 1 accuracy/latency targets pass on the supported-device matrix.
- Static analysis has no unexplained issues and the automated suite is green.
- There are no placeholder controls, dead-end screens, or unhandled core audio
  and persistence failures in the release build.

## Cross-phase work tracking

Each phase should be delivered as small issues/PRs using this order within the
phase: **model or pure logic → tests → persistence/controller integration → UI →
device validation → documentation**. An item is not complete when code merely
exists; its automated acceptance checks must pass and device-only checks must be
recorded.

Track the following for every delivery:

- user-visible behavior and whether it belongs to Standard or Expert mode;
- migration/backward-compatibility impact;
- deterministic tests added;
- device/manual checks still required;
- offline, accessibility, privacy, performance, and battery impact.

## Immediate next issues

1. [x] Replace the obsolete starter widget test and add pure cents/note-mapping
   tests. Completed with validated, reference-pitch-aware pure Dart pitch math
   and deterministic tests for intervals, note names, octaves, and invalid
   input.
2. Define the detector interface, result/confidence type, and immutable settings
   object without changing live behavior.
3. Add generated PCM fixtures for silence, 82.41 Hz, 110 Hz, 196 Hz, 329.63 Hz,
   and 440 Hz, then baseline all four detectors.
4. Resolve harmonic/no-signal behavior until Phase 1 thresholds pass.
5. Draft the versioned profile schema and migration for existing custom tunings.

Features should not move into the polished main journey until the relevant
engine and persistence exit criteria are met.
