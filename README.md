# 👁 VisionAid — Visual Assistant for the Visually Impaired 👓🤖

✨🚀 A Flutter mobile application that uses Google ML Kit to assist blind
and visually impaired people in their daily lives 📴💡 — 100% offline,
no internet required.🌐❌

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)
![MLKit](https://img.shields.io/badge/Google-ML%20Kit-blue?style=flat&logo=google)
![Offline](https://img.shields.io/badge/Connection-100%25%20Offline-green)

## Features

- **Real-time scene description** — Camera analyzes surroundings and
  describes objects out loud (chair, person, car...)
- **Obstacle detection** — Vibration + voice alert when an obstacle
  is detected nearby
- **OCR text scanner** — Reads any document, sign or screen aloud
  (supports Latin script: French & English, and Arabic)
- **Auto language detection & translation** — Detects text language
  and translates to user's preferred language (FR/EN/AR)
- **100% on-device AI** — All ML processing runs locally,
  no data sent to any server

## Tech Stack

| Technology | Usage |
|---|---|
| Flutter 3.x (Dart) | Cross-platform framework |
| Google ML Kit | Image labeling, object detection, OCR, language ID |
| flutter_tts | Text-to-speech in French, English and Arabic |
| SQLite (sqflite) | Local scan history storage |
| Provider | State management |
| GoRouter | Navigation between 11 screens |

## ML Kit Services Used

1. `google_mlkit_image_labeling` — Scene description
2. `google_mlkit_object_detection` — Obstacle detection with bounding boxes
3. `google_mlkit_text_recognition` — OCR (Latin + Arabic scripts)
4. `google_mlkit_language_id` + `google_mlkit_translation` — Auto translation

## Requirements

- Flutter 3.0+
- Android SDK 21+ (minSdk)
- Android Studio

## Installation

```bash
git clone https://github.com/AmalRg/VisionAid
cd VisionAid
flutter pub get
flutter run
```
