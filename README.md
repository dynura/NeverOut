# NeverOut: AI Tracking Inventory App

This AI-powered inventory assistant helps users track household essentials, groceries, and personal care products. The app ensures users never run out of essential items using receipt scanning, smart usage estimation, and automated reminders. It predicts when products will be depleted and sends timely restock alerts, making household management effortless and more sustainable.

## Table of Contents

- [Setup](#setup)
- [Usage](#usage)
- [Dependencies](#dependencies)

## Setup

To set up the project locally, follow these steps:

### Prerequisites

- **Flutter SDK** (version 3.13.0 or later)
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **VS Code** (with Flutter & Dart extensions)
- **Firebase account** with a project set up (Android/iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/dynura/NeverOut.git
   cd NeverOut
   ```
   
2. **Install dependencies**
  ```bash 
  flutter pub get
  ```

3. **Set up Firebase**
    - Follow Firebase's Flutter setup guide.
    - Add google-services.json (Android) and GoogleService-Info.plist (iOS) into their respective platform folders.
    - Enable necessary Firebase services (Authentication, Firestore, Storage, etc.)

4. **Run build**
   ```bash
   flutter run
   ```

## Usage

To run the app:
```bash
flutter run
```
### Running on Devices
- Android Emulator / iOS Simulator: Make sure one is running before executing flutter run.
- Physical Device: Enable developer mode and USB debugging. The device should appear in flutter devices.

## Dependencies
```bash
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^3.6.0	
  cloud_firestore: ^5.4.4
  firebase_auth: ^5.3.1
  firebase_storage: ^12.3.3
  flutter_dotenv: ^5.2.1
  google_fonts: ^6.2.1
  provider: ^6.1.2
  image_picker: ^1.1.2
  google_ml_kit: ^0.19.0 # For OCR
  tflite_flutter: ^0.11.0   # For TensorFlow Lite
  intl: ^0.20.1           # For date formatting
  shared_preferences: ^2.3.2  # For storing user preferences
  flutter_local_notifications: ^17.2.3
```
   

