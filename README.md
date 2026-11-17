# Daylist

A modern, lightweight to-do list built with Flutter and Dart.

## Features
- Add, edit, complete, and delete tasks
- Optional descriptions and due dates
- All, Today, and Completed filters
- Instant task search
- Progress indicator
- Persistent local storage using SharedPreferences
- Material 3 interface

## Run
```bash
flutter pub get
flutter run
```

## Validate
```bash
flutter analyze
flutter test
```

## Structure
```text
lib/
  main.dart
  models/task.dart
  screens/home_screen.dart
  services/task_storage.dart
  theme/app_theme.dart
  widgets/task_tile.dart
test/widget_test.dart
```
