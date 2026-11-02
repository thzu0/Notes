# 📝 Notes

A modern and feature-rich note-taking application built with **Flutter** and **Dart**.

Notes is designed to provide a clean and practical environment for creating, organizing, editing, and protecting personal notes. The application includes rich-text editing, folders, pinned notes, reminders, image support, and security features such as PIN and biometric authentication.

## ✨ Features

* 📝 Create, edit, and delete notes
* 📂 Organize notes using folders
* 📌 Pin important notes
* 🔒 Lock notes with a secure PIN
* 👆 Biometric authentication for protected notes
* 🔍 Search through notes
* 🖼️ Add images to notes
* ⏰ Create reminders and local notifications
* ✍️ Rich-text editing
* ☑️ Checklist support
* 🌙 Dark-themed user interface
* 🚀 Onboarding experience for first-time users
* 💾 Local data persistence
* 🌐 Localization support

## 🛠️ Built With

* **Flutter**
* **Dart**
* **Isar** — Local database
* **Fleather** — Rich-text editor
* **SharedPreferences** — Local preferences
* **Flutter Local Notifications** — Reminder notifications
* **Local Auth** — Biometric authentication
* **Flutter Secure Storage** — Secure storage
* **Image Picker** — Image selection
* **Intl** — Date and formatting utilities
* **Flutter Staggered Grid View** — Note layout
* **Flutter Color Picker** — Custom colors

## 🏗️ Architecture

The project is organized into feature-based modules with a separation between presentation, data, models, repositories, and core services.

```text
lib/
├── core/
│   ├── Security & Authentication
│   ├── Notifications
│   ├── Theme
│   ├── Colors
│   └── Text Styles
│
├── data/
│   └── database/
│       ├── Isar
│       └── repositories/
│
└── features/
    ├── onboarding/
    └── notes/
        ├── model/
        ├── presentation/
        └── widgets/
```

## 🔐 Security

Protected notes can be secured using a **4-digit PIN**.

When biometric authentication is enabled and supported by the device, the application can use biometric authentication as the primary method, with PIN authentication available as a fallback.

Sensitive security data is handled using secure local storage.

## 💾 Data Storage

Notes and folders are stored locally using **Isar**, allowing the application to work without requiring a remote backend.

Application preferences such as onboarding state are stored using `SharedPreferences`.

## ⏰ Reminders

The application supports local reminders for notes through Flutter Local Notifications and timezone-aware scheduling.

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

* Flutter SDK
* Dart SDK
* Android Studio or another Flutter-compatible IDE
* Android SDK for Android builds

### Installation

Clone the repository:

```bash
git clone https://github.com/thzu0/Notes.git
```

Enter the project directory:

```bash
cd Notes
```

Install dependencies:

```bash
flutter pub get
```

Generate Isar files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run the application:

```bash
flutter run
```

## 📦 Build APK

To build a release APK:

```bash
flutter build apk --release
```

For architecture-specific APKs:

```bash
flutter build apk --split-per-abi
```

## 📱 Project Status

🚧 **In Development**

The application is actively being developed and improved.

## 👨‍💻 Author

**thzu0**

GitHub: https://github.com/thzu0

## 📄 License

This project is currently provided for educational and personal development purposes.
