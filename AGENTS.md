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

## Security
- Never print or paste secrets (API keys, signing configs, `.env` contents).
- Do not introduce network calls, telemetry, analytics, or new permissions unless explicitly requested.

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
