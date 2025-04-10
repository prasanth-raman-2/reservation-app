# Reservation Management Component

A Flutter-based reservation management component with Riverpod for state management, SQLite for local storage, and Firebase Firestore for cloud database.

## Features

- Create, read, update, and delete reservations
- Synchronize reservations between local SQLite database and Firebase Firestore
- Location-based reservations using Google Maps
- User authentication with Firebase Auth
- Push notifications for reservation updates

## Project Structure

```
lib/
├── models/           # Data models
├── services/         # Service classes for database, Firebase, etc.
├── providers/        # Riverpod providers
├── screens/          # UI screens
├── widgets/          # Reusable UI components
└── main.dart         # Application entry point
```

## Dependencies

- flutter_riverpod: State management
- sqflite: Local SQLite database
- firebase_core, cloud_firestore: Firebase integration
- google_maps_flutter: Location services
- firebase_auth: Authentication
- firebase_messaging: Push notifications

## Getting Started

1. Ensure you have Flutter installed and set up
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Configure Firebase project and add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
5. Run the app with `flutter run`

## Usage

The component can be integrated into a larger application by importing the necessary providers and screens.

```dart
import 'package:reservation_management/providers/reservation_provider.dart';
import 'package:reservation_management/screens/reservation_list_screen.dart';
```
