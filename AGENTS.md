# AGENTS.md — Flutter Tuner App

## Goal
This repository is a Flutter app for tuning guitar strings (and other instruments). Prioritize:
- correctness and stability (audio signal path is sensitive)
- small, reviewable diffs
- clear separation of UI, audio capture, and pitch detection logic

## Environment
Codex Cloud runs on Linux. Do not attempt iOS builds/signing.
Assume Flutter SDK is available on PATH (installed by Codex Cloud setup).

## Commands to use (in this order)
1) Fetch deps (only if needed):
- `flutter pub get`

2) Format:
- `dart format .`

3) Static analysis:
- `flutter analyze`

4) Tests (when present):
- `flutter test`

## Working agreements
- Keep changes scoped to the task; avoid drive-by refactors.
- Do not add new dependencies without explicit approval. If a dependency must be added:
  - update `pubspec.yaml` and explain why
  - note that `flutter pub get` may require internet; if agent internet is off, request that the user run it locally or re-run with appropriate allowlist.
- Prefer pure Dart for pitch detection where possible (easier to unit test), and keep platform-channel/native code changes minimal and well-justified.
- Do not change Android/iOS native project files (`android/`, `ios/`) unless the task explicitly requires it.

## Architecture / Key Modules
**Entry point & navigation**
- App entry: `tuning_for_tonists/lib/main.dart` (`MyApp` + `GetMaterialApp`).
- Routes: `tuning_for_tonists/lib/constants/routes.dart` with `GetPage` definitions in `main.dart`.
- Primary screens: `tuning_for_tonists/lib/screens/` (e.g., `main_screen.dart`, `loading_page.dart`, `settings_screen.dart`, `mic_detail_screen.dart`, `advanced_mic_data_screen.dart`, `all_tunings_screen.dart`, `create_tuning_screen.dart`, `knowledgebase_screen.dart`, `testing_screen.dart`).

**Audio input & pitch-detection pipeline**
- Mic capture: `tuning_for_tonists/lib/helpers/microphone_helper.dart` uses `mic_stream` (`MicStream.microphone`) and requests permissions via `MicStream.shouldRequestPermission(true)`.
- Stream control: `tuning_for_tonists/lib/controllers/microphone_controller.dart` starts/stops listening and forwards chunks to `CalculationController.calculateDisplayData`.
- DSP/pitch: `tuning_for_tonists/lib/controllers/calculation_controller.dart` computes frequency using FFT/HPS/zero-crossing/autocorrelation/cepstrum; uses `fftea` (`FftController`) and `scidart` for windowing math.
- FFT utilities: `tuning_for_tonists/lib/controllers/fft_controller.dart` wraps `fftea` FFT operations and max-frequency lookup.
- Waveform buffers: `tuning_for_tonists/lib/controllers/wave_data_controller.dart` stores wave data, FFT bins, and visible samples for UI plots.
- Pitch → note state: `tuning_for_tonists/lib/controllers/tuning_controller.dart` compares detected frequency against target note/range and updates tuning status.
- Tuning configs: `tuning_for_tonists/lib/controllers/tuning_configurations_controller.dart` (defaults in `tuning_for_tonists/lib/constants/constants.dart`, custom configs via `shared_preferences`).

**UI + state**
- GetX controllers in `tuning_for_tonists/lib/controllers/` and `tuning_for_tonists/lib/view_controllers/`.
- UI widgets for pitch displays live in `tuning_for_tonists/lib/widgets/` (frequency bars/pointer/plots, mic controls, etc.).
- Audio test samples: `tuning_for_tonists/assets/samples/` (e.g., guitar `.mp3` files used by `TestingController`).

## Platform-specific code (Android/iOS)
- Android: `android/app/src/main/kotlin/.../MainActivity.kt` (Flutter boilerplate) and generated registrant. No custom platform channel code identified.
- iOS: `ios/Runner/AppDelegate.swift` and generated registrant. No custom platform channel code identified.

## Configuration & tooling
- Flutter/Dart config: `tuning_for_tonists/pubspec.yaml`, `tuning_for_tonists/analysis_options.yaml`, `.metadata`.
- Generated files (do not edit manually): `.dart_tool/`, `.flutter-plugins-dependencies`, platform registrants.
- No FVM config or CI workflows detected.

## Third-party packages critical to tuning
- Audio capture: `mic_stream`, `flutter_sound` (dependency present), `just_audio` (audio file playback).
- DSP/FFT: `fftea`, `scidart`, `iirjdart` (filters), `flutter_fft` (dependency present; not referenced in `lib/` currently).
- State/navigation: `get`, `shared_preferences`, `fl_chart` for plots.

## How to run
- `flutter pub get` (if needed)
- `flutter run` (on a device/emulator with microphone access; grant mic permission when prompted).
- To exercise sample audio files, use the test/audio controls in `TestingScreen` (`tuning_for_tonists/lib/screens/testing_screen.dart`).

## Verification
- `dart format .`
- `flutter analyze`
- `flutter test` (uses `test/widget_test.dart`)

## Do not touch unless asked
- Native configs and signing files (`android/`, `ios/`), especially `android/app/build.gradle`, `android/key.properties`, keystores, and any platform provisioning files.
- Generated files (`.dart_tool/`, `.flutter-plugins-dependencies`, platform registrants).

## Security
- Never print or paste secrets (API keys, signing configs, `.env` contents).
- Do not introduce network calls, telemetry, analytics, or new permissions unless explicitly requested.
- Treat signing/key material as sensitive if it appears in `android/` or `ios/` (e.g., `key.properties`, keystores, provisioning profiles).

## Project structure expectations
- UI: `lib/` (widgets, screens)
- Core logic (pitch detection, note mapping): keep in `lib/` under a clearly named module (e.g. `lib/tuning/`).
- If you add tests later, place them under `test/` and keep them deterministic (no microphone/device dependency).

## Output expectations
When you finish:
- summarize what changed and why
- list files touched
- show the diff
- report results of: `dart format .` and `flutter analyze` (and `flutter test` if available)
