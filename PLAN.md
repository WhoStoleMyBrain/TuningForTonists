# Tuning Accuracy Roadmap (Flutter)

This plan captures the current pitch-detection pipeline, likely error sources, and a phased roadmap to move the tuner from “working” to “reliable and accurate.” It focuses on correctness first, then stability, then UX.

## Repo analysis (current state)

### Pitch detection approach
- **Primary calculation mode** defaults to **Cepstrum** in `WaveDataController.calculationType`.
  - `CalculationController.calculateDisplayData` branches on `CalculationType` and calls **Cepstrum, HPS, Autocorrelation, or Zero Crossing**.
  - **Cepstrum path**: `calculateFrequenciesCepstrum` performs a Hann window, FFT (`fftea`), `log(magnitude)` transform, then FFT again (`applyRealFftHalf`) and picks the max index to estimate the fundamental. (`tuning_for_tonists/lib/controllers/calculation_controller.dart`)
- **HPS** path: FFT magnitudes + manual HPS product, then peak bin → frequency mapping. (`calculation_controller.dart`)
- **Zero-crossing**: sign-change counting. (`calculation_controller.dart`)
- **Autocorrelation**: naïve time-domain autocorrelation over a limited lag range. (`calculation_controller.dart`)
- **Libraries used**: `fftea` (FFT), `scidart` (Hann window, log), `mic_stream` (audio capture). (`fft_controller.dart`, `calculation_controller.dart`)

### Audio capture & buffering
- **Mic capture** via `mic_stream` (`MicStream.microphone`), configured with:
  - `sampleRate`: from `MicInitializationValuesController` (default **8192** in `main.dart`).
  - `channelConfig`: mono.
  - `audioFormat`: PCM 16-bit by default. (`microphone_helper.dart`, `main.dart`)
- Runtime mic metadata: `MicStream.bitDepth`, `MicStream.sampleRate`, and `MicStream.bufferSize` populate `MicTechnicalDataController`. (`microphone_helper.dart`)
- **Waveform buffering**:
  - `WaveDataController.waveDataLength` defaults to **4096** samples; data is appended and truncated to this size. (`wave_data_controller.dart`)
  - Visible samples list holds up to **200** detected frequencies, used for averaging and UI display. (`wave_data_controller.dart`)

### Windowing / filtering / FFT steps
- **Hann window** applied in `calculateFrequency2` (FFT/HPS path) and cepstrum path.
- Commented-out Butterworth filter code exists but is inactive. (`calculation_controller.dart`)
- FFT magnitude is taken via `fftea`’s `squareMagnitudes()`. (`fft_controller.dart`)
- Frequency mapping:
  - HPS/FFT: `(bin + 31) * sampleRate / waveDataLength`. (`calculation_controller.dart`)
  - Cepstrum: `sampleRate / maxIndex`, where `maxIndex` is derived after skipping bins. (`calculation_controller.dart`)

### Calibration assumptions (A4, temperament, cents, smoothing)
- **A4=440 Hz** is implied by the default `Note` and predefined tuning tables. (`tuning_controller.dart`, `constants/constants.dart`)
- **Equal temperament** is assumed implicitly by using fixed note frequencies in `constants.dart`.
- **Cents calculation** uses `log(x)/log(1.000577789)` and a default cent range of ±60 cents. (`tuning_controller.dart`)
- **Smoothing** is minimal: last-second averaging of detected frequencies and a tuning threshold for percent-in-range. (`tuning_controller.dart`)

### Likely failure points / sources of systematic error
1. **Sample-rate mismatch**
   - Capture uses `micInitializationValuesController.sampleRate` (default 8192), but some calculations use `MicStream.sampleRate` while others use the initialization value. Any mismatch will systematically skew frequency estimates. (`microphone_helper.dart`, `calculation_controller.dart`)
2. **PCM decoding / endianness errors**
   - The 16-bit conversion logic uses `asUint8List(4)` and a custom 2-byte combine with sign correction. This is likely incorrect for signed little-endian PCM and can distort waveforms. (`microphone_helper.dart`)
3. **Audio file stream is not decoded**
   - The testing path streams raw `.mp3` bytes as if they were PCM; this will yield nonsense frequencies. (`testing_controller.dart`, `microphone_helper.dart`)
4. **Incorrect bin-to-frequency mapping**
   - Manual offsets like `sublist(31)` and `(maxIdx + 31)` suggest bin skipping without clear rationale; could misalign peaks. (`calculation_controller.dart`)
5. **Window size & resolution**
   - Default `waveDataLength=4096` with `sampleRate=8192` yields ~0.5s windows; note detection may be sluggish and may bias towards low-frequency content.
6. **Octave errors / harmonic locking**
   - Cepstrum/HPS can lock onto strong harmonics if preprocessing and peak picking are not robust. (`calculation_controller.dart`)
7. **Autocorrelation constraints**
   - `autocorrLength` is capped at 137, making low-frequency detection unreliable. (`calculation_controller.dart`)
8. **Platform audio-session differences**
   - `mic_stream` permissions/sessions can return unexpected sample rates or buffer sizes on specific devices. (`microphone_helper.dart`)

---

## PLAN

### Phase 0 — Baseline & instrumentation
**Goal:** Make the pipeline observable and repeatable without changing algorithms yet.

**Tasks**
- Add a debug overlay / log line that shows: **IMPLEMENTED—NEEDS LOCAL VERIFICATION**
  - actual runtime sample rate, buffer size, bit depth, channel config
  - selected calculation method (Cepstrum/HPS/Autocorrelation/ZeroCrossing)
  - raw detected frequency + confidence/strength metric (peak magnitude / ratio)
  - Local verification: run on a device to confirm values populate in the debug overlay.
- Add a “capture a short sample” path that stores a few seconds of **raw PCM** to a local file (if feasible with existing deps). **IMPLEMENTED—NEEDS LOCAL VERIFICATION** (verify on device that the file is created and playable).
- Add an in-app **synthetic tone generator** for validation (pure Dart), so known frequencies can be fed directly into the analysis pipeline. **IMPLEMENTED—NEEDS LOCAL VERIFICATION** (needs device validation for ±3 cents after 300 ms)

**Likely files to change**
- `tuning_for_tonists/lib/controllers/calculation_controller.dart`
- `tuning_for_tonists/lib/controllers/microphone_controller.dart`
- `tuning_for_tonists/lib/controllers/wave_data_controller.dart`
- `tuning_for_tonists/lib/screens/mic_detail_screen.dart`
- `tuning_for_tonists/lib/controllers/testing_controller.dart`

**Acceptance criteria**
- Debug overlay shows live sample rate/buffer size and detected frequency.
- Synthetic 440 Hz tone reads within **±3 cents** after **300 ms**.
- Raw PCM capture produces a playable file on device (validated via OS file viewer).

**Manual test procedure (device)**
1. Open the mic detail screen.
2. Start mic stream; verify debug overlay values populate.
3. Enable synthetic tone at 440 Hz and confirm displayed frequency/cents.
4. Record a 3-second sample and verify file exists and plays back.

### Phase 1 — Correctness fixes (sample rate, format, mapping)
**Goal:** Fix the most likely sources of systematic error.

**Tasks**
- Ensure **all frequency calculations use the actual runtime sample rate** (from `MicStream.sampleRate`) rather than the initialization value. **IMPLEMENTED—NEEDS LOCAL VERIFICATION** (verify on device that detected pitch does not shift when runtime sample rate differs from initialization).
- Replace the 16-bit PCM conversion logic with a verified **little-endian Int16** decoder (consistent with mic_stream output). **IMPLEMENTED—NEEDS LOCAL VERIFICATION** (verify on device mic capture that waveform/pitch accuracy is correct for PCM16).
- Make bin-skipping explicit and documented, or remove ad-hoc offsets like `sublist(31)` unless justified. **IMPLEMENTED—NEEDS LOCAL VERIFICATION** (verify bin-to-frequency mapping on device with synthetic tones).
- Ensure window length and FFT size are consistent with the visible sample rate, and track the effective FFT resolution.
- Introduce a simple **confidence metric** (peak-to-average ratio or harmonic ratio) to gate low-confidence readings.

**Likely files to change**
- `tuning_for_tonists/lib/helpers/microphone_helper.dart`
- `tuning_for_tonists/lib/controllers/calculation_controller.dart`
- `tuning_for_tonists/lib/controllers/fft_controller.dart`
- `tuning_for_tonists/lib/controllers/mic_technical_data_controller.dart`

**Acceptance criteria**
- With synthetic 440 Hz input, output is **±3 cents** and stable after **300 ms**.
- With a pre-tuned A string (~110 Hz), output is **±5 cents** within **1 second**.
- Changing device sample rate does not shift the detected pitch.

**Manual test procedure (device)**
1. Start synthetic 110 Hz tone → verify A2 within ±5 cents.
2. Start synthetic 440 Hz tone → verify A4 within ±3 cents.
3. Use a pre-tuned guitar A string; verify within ±5 cents after 1 second.

### Phase 2 — Stability & quality
**Goal:** Reduce jitter and improve robustness without masking correctness.

**Tasks**
- Add temporal smoothing/hysteresis (e.g., exponential moving average) gated by confidence.
- Add a basic noise gate: ignore frames below an energy threshold.
- Add harmonic rejection: prefer fundamentals over harmonics using HPS/cepstrum heuristics.
- Adjust window length and overlap to balance latency vs. stability (e.g., 2048/4096 with 50% overlap).

**Likely files to change**
- `tuning_for_tonists/lib/controllers/calculation_controller.dart`
- `tuning_for_tonists/lib/controllers/wave_data_controller.dart`
- `tuning_for_tonists/lib/controllers/tuning_controller.dart`

**Acceptance criteria**
- Holding a steady tone yields < **±2 cents** jitter after 500 ms.
- Sudden pitch changes settle within **<500 ms**.
- Silence does not produce spurious note locks.

**Manual test procedure (device)**
1. Hold a steady 440 Hz tone; observe cents jitter over 3 seconds.
2. Switch between 440 Hz and 392 Hz; observe convergence speed.
3. Test in a quiet room and then with background noise.

### Phase 3 — UX improvements
**Goal:** Make the tuner feel stable and usable.

**Tasks**
- Add “note lock” behavior: lock to a detected note when confidence is high, unlock when confidence drops or pitch shifts.
- Smooth needle/cent display using the same filtered frequency.
- Show confidence indicator (e.g., color/opacity).
- Improve tuning selection & alternate tunings workflow (without changing pitch logic).

**Likely files to change**
- `tuning_for_tonists/lib/widgets/` (needle, bars, plots)
- `tuning_for_tonists/lib/controllers/tuning_controller.dart`
- `tuning_for_tonists/lib/screens/main_screen.dart`

**Acceptance criteria**
- Needle display does not “jump” between harmonics on sustained tones.
- Note name stays stable when the frequency is within ±10 cents for 500 ms.

**Manual test procedure (device)**
1. Sustain a single note for 3 seconds; watch for stable note lock.
2. Slightly bend pitch; verify needle movement without flicker.

### Phase 4 — Tests
**Goal:** Prevent regressions and document expected behavior.

**Tasks**
- Unit tests for:
  - note mapping and cents calculation
  - confidence thresholds and smoothing
- Optional golden tests for key UI widgets (needle, cents display).

**Likely files to change**
- `tuning_for_tonists/test/` (new tests)
- `tuning_for_tonists/lib/controllers/tuning_controller.dart`

**Acceptance criteria**
- Test coverage for cents and note mapping; tests pass locally (`flutter test`).
- Synthetic tone validation re-usable in tests.

**Manual test procedure (device)**
1. Run `flutter test` locally and verify all green.

---

## Minimal reproducible audio validation strategy
**Preferred (no new deps):**
- Add a **pure Dart sine-wave generator** that outputs PCM samples (Int16) and feeds them into `calculateDisplayData`. This avoids mic variability and MP3 decoding issues.
  - Frequencies to include: 110 Hz, 220 Hz, 440 Hz, 329.6 Hz (E4), 196 Hz (G3).
  - Add an on-screen toggle or dev-only button to inject these samples.

**Fallback (existing assets, but needs decoding):**
- If PCM data can be extracted via existing packages (e.g., `flutter_sound` already in deps), add a mode to decode a short PCM clip from assets and feed the same pipeline.
- Avoid adding any new dependencies unless explicitly approved.

---

## Summary of immediate next steps
1. Instrument the pipeline (Phase 0) to expose real sample rate, buffer size, and detected frequency.
2. Fix sample-rate usage and PCM decoding (Phase 1) — these are most likely to cause systematic errors.
3. Add minimal synthetic audio validation to prove correctness across a few target tones.
