# Calmly 🫧

**A context-aware regulation companion — human-centered AI for moments that overwhelm you.**

> Apple Intelligence sees what's around you. Calmly understands how it feels.

Calmly is an iOS app built with SwiftUI that detects when your environment becomes overwhelming and guides you through a 30-second regulation micro-session with empathetic, AI-generated support. It's not a meditation app — it's a pocket co-regulator that activates when you need it and disappears when you don't.

---

## The Problem

People who experience anxiety, sensory overload, or stress spikes **know** techniques like box breathing and grounding — but can't remember them mid-dysregulation. Existing apps require setup, streaks, subscriptions, or long sessions. None of them help **in the exact moment** you need it.

## The Solution

One tap (or zero taps with ambient detection) → AI interprets your context → empathetic message + 30-second guided intervention → done.

---

## Features (MVP)

| Feature | Description |
|---|---|
| **One-tap activation** | Large "Necesito una pausa" button — zero friction |
| **Context capture** | Optional camera snapshot + voice/text for AI context |
| **AI empathetic response** | LLM generates a warm, personalized message + picks the right intervention |
| **Breathing session** | Animated orb with haptic feedback guides inhale/exhale |
| **5-4-3-2-1 Grounding** | Step-by-step sensory grounding exercise |
| **Ambient detection** ⭐ | Mic monitors noise level; auto-suggests a pause when it's loud |
| **Voice response** ⭐ | TTS reads the empathetic message in a calm voice |
| **Demo mode** | Offline toggle with pre-baked responses for reliable demos |

---

## Tech Stack

- **UI:** SwiftUI (iOS 17+), SF Pro Rounded, dark mode first
- **Architecture:** MVVM with `@Observable`
- **AI:** OpenAI GPT-4o-mini (or Claude Haiku) — single structured JSON call per session
- **Frameworks:**
  - `AVFoundation` — camera capture + audio level metering
  - `CoreHaptics` — breathing cadence haptics
  - `Speech` — optional voice-to-text input
  - `AVSpeechSynthesizer` — TTS output
- **No:** CoreML, HealthKit, third-party UI libraries

---

## Project Structure

```
Calmly/
├── CalmlyApp.swift              # App entry point
├── Config/
│   └── APIConfig.swift          # API keys & endpoints (gitignored secrets)
├── Models/
│   ├── CalmlyContext.swift      # Context data sent to AI
│   ├── AIResponse.swift         # Structured AI response
│   └── Intervention.swift       # Intervention types & scripts
├── Services/
│   ├── AIService.swift          # LLM API wrapper
│   ├── AmbientSensorService.swift # AVAudioEngine dB monitoring
│   ├── CameraService.swift      # AVFoundation single-frame capture
│   ├── SpeechService.swift      # SFSpeechRecognizer wrapper
│   ├── TTSService.swift         # AVSpeechSynthesizer wrapper
│   └── HapticsService.swift     # CoreHaptics breathing patterns
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Capture/
│   │   └── CaptureView.swift
│   ├── Interpreting/
│   │   └── InterpretingView.swift
│   ├── Response/
│   │   └── ResponseView.swift
│   ├── Session/
│   │   ├── BreathingSessionView.swift
│   │   └── GroundingSessionView.swift
│   └── CheckIn/
│       └── CheckInView.swift
├── DesignSystem/
│   ├── OrbView.swift            # Animated breathing orb
│   ├── CalmlyColors.swift       # Color palette
│   └── CalmlyTypography.swift   # Typography styles
├── Assets.xcassets/
│   └── (app icon, colors, images)
└── Info.plist
```

---

## Setup

### Prerequisites
- **Xcode 15+** (macOS Sonoma recommended)
- **iOS 17+** target device or simulator
- An **OpenAI API key** (or Anthropic key for Claude Haiku)

### Getting started

1. Clone the repo:
   ```bash
   git clone <repo-url>
   cd Calmly
   ```

2. Create your secrets file:
   ```bash
   cp Config/APIConfig.example.swift Config/APIConfig.swift
   ```

3. Add your API key in `Config/APIConfig.swift`:
   ```swift
   enum APIConfig {
       static let openAIKey = "sk-your-key-here"
       static let baseURL = "https://api.openai.com/v1"
   }
   ```

4. Open `Calmly.xcodeproj` in Xcode (or create via File → New Project if starting fresh).

5. Build & run on a device (camera + mic require real hardware).

### Demo mode
Toggle demo mode in Settings to use pre-baked responses without network. **Always use this for stage demos.**

---

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   SwiftUI   │────▶│  ViewModels  │────▶│    Services      │
│   Views     │◀────│  @Observable │◀────│  (AI, Camera,    │
│             │     │              │     │   Audio, Haptics) │
└─────────────┘     └──────────────┘     └─────────────────┘
                                                  │
                                          ┌───────▼───────┐
                                          │  OpenAI API   │
                                          │  (structured  │
                                          │   JSON call)  │
                                          └───────────────┘
```

- **Views** are dumb — display state, send intents.
- **ViewModels** hold business logic, call services.
- **Services** are injectable, mockable, protocol-based.

---

## AI Prompt Strategy

Single call per session. Input: `{image?, transcript?, ambientLevel?}`. Output:

```json
{
  "empathy": "Parece que hay mucho ruido a tu alrededor. Estoy aquí contigo.",
  "type": "breathing",
  "script": "Inhala 4 segundos... Sostén 4 segundos... Exhala 6 segundos..."
}
```

The AI is prompted to:
- Speak in warm second-person Spanish
- Never use clinical language ("anxiety", "disorder", "symptom")
- Always propose exactly one intervention type
- Max 2 sentences of empathy

---

## Team

| Role | Focus |
|---|---|
| **P1 - iOS Lead** | Architecture, navigation, AIService, integration |
| **P2 - UI/Design** | Orb animation, screens, polish, Keynote |
| **P3 - Sensors & AI** | Camera, audio dB, speech, haptics, TTS, prompt engineering, fallback scripts, copy, pitch |

---

## Roadmap (4 Days)

| Day | Goal |
|---|---|
| **Day 1** | Project setup, design system, spike sensors, write AI prompts. App navigates all screens with placeholders. |
| **Day 2** | Core flow end-to-end with real AI. Text input path fully working. |
| **Day 3** | Wow features (ambient detection, TTS), polish, record backup demo video. |
| **Day 4** | Feature freeze at noon. Bug fixes, Keynote, pitch rehearsal x3. |

---

## License

Hackathon project — iOS Lab UPMX 2026.
