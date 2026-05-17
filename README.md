# 👁 VisionAid — Visual Assistant for the Visually Impaired 👓🤖

✨🚀 A Flutter mobile application that uses Google ML Kit to assist blind
and visually impaired people in their daily lives 📴💡 — 100% offline,
no internet required.🌐❌

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)
![MLKit](https://img.shields.io/badge/Google-ML%20Kit-blue?style=flat&logo=google)
![Offline](https://img.shields.io/badge/Connection-100%25%20Offline-green)

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/fbdd7924-34ca-4f55-971a-b4409ada6acb" width="150" alt="1" /></td>
    <td><img src="https://github.com/user-attachments/assets/3677315a-9ed1-47f9-a98b-e490b9b49366" width="150" alt="2" /></td>
    <td><img src="https://github.com/user-attachments/assets/ee876de2-e957-4944-9055-50ed7caf202d" width="150" alt="3" /></td>
    <td><img src="https://github.com/user-attachments/assets/468f7b47-7302-4e23-937c-576f55c5c5c7" width="150" alt="4" /></td>
    <td><img src="https://github.com/user-attachments/assets/5438a13d-347c-492b-ad31-e0f232fad9c8" width="150" alt="5" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/fed3f0bf-ea2c-460f-bc43-e8da8040cef5" width="150" alt="6" /></td>
    <td><img src="https://github.com/user-attachments/assets/a034ed94-164d-43db-8688-c1a4a018e820" width="160" alt="7" /></td>
    <td><img src="https://github.com/user-attachments/assets/9f656c5d-86d9-46e6-ab4e-763f0fb01daa" width="150" alt="8" /></td>
    <td><img src="https://github.com/user-attachments/assets/3408783c-4f74-4f42-87d6-75ef8bf15cb5" width="150" alt="9" /></td>
    <td><img src="https://github.com/user-attachments/assets/5c4e6eee-902e-4d9c-9133-197d5cdee304" width="150" alt="10" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/a943a1c5-0cf2-4fbc-8458-5492b841ced9" width="150" alt="11" /></td>
    <td><img src="https://github.com/user-attachments/assets/cc66f023-b5ae-447d-ab5a-cb3022857b4f" width="150" alt="12" /></td>
    <td><img src="https://github.com/user-attachments/assets/67b0e124-e9a9-4f4d-8626-d62d13648248" width="150" alt="13" /></td>
    <td><img src="https://github.com/user-attachments/assets/a78378c8-1261-4b49-9d0a-bfb9746a78c5" width="150" alt="14" /></td>
    <td><img src="https://github.com/user-attachments/assets/9f1f885b-335d-4307-b378-23fc5331c1b7" width="150" alt="15" /></td>
  </tr>
</table>

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
