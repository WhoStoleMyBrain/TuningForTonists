# Product Gap Report: Offline, Flexible Instrument Tuner

For implementation phases, dependencies, and acceptance criteria, see the
[`PLAN.md`](PLAN.md) roadmap.

## Current foundation

The project already has the main pieces of an offline tuner: microphone capture,
live frequency/note displays, guitar and ukulele presets, locally stored custom
tunings, and four selectable pitch detectors (HPS, autocorrelation, zero
crossing, and cepstrum). A custom tuning can contain any number of named notes
with manually entered frequencies. The app also includes diagnostic views and
sample-audio tooling.

The foundation is promising, but several settings are currently placeholders,
custom tuning is still a basic editor, automated coverage is only the starter
widget test, and the existing accuracy roadmap still identifies device
validation and signal-stability work.

## What is missing for a complete product

### 1. Dependable tuning engine — essential

- A single recommended **Auto** detector that chooses or combines methods, with
  the four individual methods retained as an expert option.
- Reliable noise rejection, confidence-based note locking, harmonic/octave
  rejection, and smooth but responsive readings.
- Configurable detection range, sensitivity, response speed, smoothing, noise
  gate, window/FFT size, and accuracy target, grouped into understandable
  presets such as Fast, Balanced, and Precise.
- Per-profile technical settings, so a bass, guitar, violin, or experimental
  instrument can use different detection parameters and frameworks.
- A clear “no usable signal” state instead of displaying unstable notes.
- Calibration against reference pitch (for example, adjustable A4 rather than
  fixed 440 Hz) and cents-based calculations generated from that reference.

### 2. Truly free instrument and tuning configuration — essential

- An instrument/profile editor separate from the tuning editor.
- Any number of strings or target notes, including one-note instruments and
  instruments with paired/coursed strings.
- Add, remove, reorder, duplicate, rename, and edit targets after creation.
- Note entry by note name and octave, exact frequency, or cents offset; support
  sharps/flats and custom labels.
- Chromatic mode alongside target-by-target/string mode, with automatic or
  manual target selection.
- Save, delete, duplicate, favorite, import, and export profiles entirely
  offline, with validation and safe recovery from invalid data.
- Useful bundled presets beyond guitar and ukulele, without preventing fully
  custom instruments or non-standard temperaments.

### 3. Polished everyday experience — important

- A focused primary screen with a large note, cents deviation, direction,
  confidence/signal level, and an unmistakable in-tune state.
- One-tap string selection, hands-free automatic progression, and optional
  audible/vibration confirmation.
- A guided first run for microphone permission, input-level checks, and a quick
  accuracy test.
- Responsive layouts, dark/light themes, large text, color-blind-safe feedback,
  screen-reader labels, and operation without relying on color alone.
- Friendly empty, error, permission-denied, and unsupported-device states.
- Consistent terminology and removal or completion of placeholder settings and
  developer-only controls from the normal user journey.

### 4. Offline completeness and trust — important

- An explicit offline/privacy promise: audio is processed on-device, recordings
  are opt-in, and no account, network, analytics, or telemetry is required.
- All help, presets, note data, and troubleshooting packaged with the app.
- Local backup/restore using a human-readable profile file and clear data-reset
  controls.
- Graceful startup and full operation in airplane mode, including first launch.

### 5. Product strength and release readiness — essential

- Deterministic tests for note mapping, cents, every detection method, silence,
  noise, harmonics, low bass notes, custom profiles, and saved settings.
- A decoded PCM/WAV fixture set plus generated reference tones; compressed audio
  bytes must not be treated as raw microphone samples.
- Measurements on representative phones/tablets and external microphones for
  latency, jitter, octave errors, sample-rate differences, and interruptions.
- Defined release targets, such as stable lock within 500 ms, silence producing
  no note, and sustained clean tones staying within a small cents tolerance.
- Robust handling of permission changes, calls/audio focus, app pause/resume,
  microphone disconnects, and corrupted local preferences.
- A concise built-in guide explaining calibration, target selection, and when
  expert detector settings are useful.

## Recommended product shape

Use two levels of control:

1. **Standard mode:** choose an instrument and tuning, then tune with an Auto
   detector and three simple response presets.
2. **Expert mode:** configure target frequencies, temperament/reference pitch,
   detector (Auto, HPS, autocorrelation, cepstrum, or zero crossing), range,
   window size, smoothing, confidence, and noise gate per profile.

This keeps the app welcoming for guitarists while preserving the freedom needed
for unusual instruments, arbitrary note sets, and technical experimentation.

## Suggested delivery order

1. Prove pitch accuracy and stability with deterministic tests and real devices.
2. Build the instrument/profile model and complete create/edit/delete workflows.
3. Add Auto detection, practical presets, calibration, and expert parameters.
4. Redesign the main tuning journey and finish accessibility/error states.
5. Verify airplane-mode behavior, local backup/restore, and release criteria.

**Definition of done:** a new user can install the app, stay offline, create an
instrument with any number of targets, choose simple or expert detection
settings, tune confidently in realistic noise, and retain or export everything
without an account.
