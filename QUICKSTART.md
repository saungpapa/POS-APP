# Quick Start Guide - POS App Development

## Prerequisites

Before you begin, ensure you have:
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Git
- A physical device or emulator (iOS Simulator / Android Emulator)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/saungpapa/POS-APP.git
cd POS-APP
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Installation

```bash
flutter doctor
```

Fix any issues reported by `flutter doctor`.

### 4. Run the App

#### On Android
```bash
flutter run
```

#### On iOS
```bash
cd ios
pod install
cd ..
flutter run
```

## First Time Setup

### 1. Add Sample Products

When you first run the app, the database will be empty. You'll need to add products:

1. Open the app
2. Navigate to "ပစ္စည်းများ" (Products) tab
3. Tap the "+" floating action button
4. Fill in product details:
   - အမည် (Name): Product name
   - ဘားကုဒ် (Barcode): Any unique code
   - ဈေး (Price): Product price
   - လက်ကျန် (Stock): Stock quantity
5. Tap "သိမ်းရန်" (Save)

**Sample Products**:
```
Name: ကိုကာကိုလာ
Barcode: 001
Price: 500
Stock: 100

Name: မမီးနုဒယ်
Barcode: 002
Price: 700
Stock: 50

Name: စက္ကူ
Barcode: 003
Price: 300
Stock: 200
```

### 2. Configure Shop Name

1. Go to "ဆက်တင်" (Settings) tab
2. Tap on "ဆိုင်အမည်" (Shop Name)
3. Enter your shop name
4. Tap "သိမ်းမည်" (Save)

### 3. Complete a Test Sale

1. Go to "ပစ္စည်းများ" (Products) tab
2. Tap on a product to add it to cart
3. Go to "ခြင်း" (Cart) tab
4. Adjust quantities if needed
5. Tap "ငွေရှင်းမယ်" (Checkout)
6. Preview the receipt
7. Choose action:
   - Print (requires Bluetooth printer)
   - Save as PDF
   - Complete without printing

### 4. View Sales Report

1. Go to "အရောင်းစာရင်း" (Sales Report) tab
2. Select time period (Today/Week/Month/Custom)
3. View statistics and charts
4. Export as PDF if needed

## Development Workflow

### Project Structure

```
lib/
├── models/              # Data models
├── services/            # Business logic
├── screens/             # UI screens
├── widgets/             # Reusable widgets
├── utils/               # Utilities
└── main.dart           # Entry point
```

### Making Changes

1. **Adding a new screen**:
   - Create file in `lib/screens/`
   - Add route in navigation
   - Import required models/services

2. **Modifying database**:
   - Update schema in `database_service.dart`
   - Increment database version
   - Add migration logic

3. **Adding a widget**:
   - Create file in `lib/widgets/`
   - Make it reusable and configurable
   - Document parameters

### Running Tests

Currently no automated tests are configured. To add tests:

```bash
# Create test file
mkdir -p test
touch test/widget_test.dart

# Run tests
flutter test
```

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### iOS
```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode for archiving.

## Common Development Tasks

### Adding a New Dependency

1. Add to `pubspec.yaml`:
```yaml
dependencies:
  new_package: ^1.0.0
```

2. Install:
```bash
flutter pub get
```

3. Import in Dart file:
```dart
import 'package:new_package/new_package.dart';
```

### Debugging

#### Enable Debug Mode
```bash
flutter run --debug
```

#### View Logs
```bash
flutter logs
```

#### Hot Reload
Press `r` in terminal or save file in IDE with hot reload enabled.

#### Hot Restart
Press `R` in terminal.

### Database Inspection

To view the SQLite database:

1. Find database location:
```dart
final dbPath = await getDatabasesPath();
print(dbPath); // /data/data/com.example.pos_app/databases/
```

2. Use Android Studio Database Inspector or ADB:
```bash
adb pull /data/data/com.example.pos_app/databases/pos_app.db
sqlite3 pos_app.db
```

### Troubleshooting

#### Build Errors

**Error**: "Gradle build failed"
- Solution: Update Android Gradle plugin in `android/build.gradle`

**Error**: "Pod install failed"
- Solution: 
```bash
cd ios
pod deintegrate
pod install
```

**Error**: "Permission denied"
- Solution: Update `AndroidManifest.xml` and `Info.plist` with required permissions

#### Runtime Errors

**Error**: "MissingPluginException"
- Solution: Run `flutter clean && flutter pub get`

**Error**: "Database is locked"
- Solution: Close all database connections properly

**Error**: "Bluetooth not available"
- Solution: Check device has Bluetooth and permissions are granted

## IDE Setup

### VS Code

Recommended extensions:
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets

### Android Studio

Plugins:
- Flutter plugin
- Dart plugin

## Code Style

Follow the Dart style guide:
- Use `const` constructors where possible
- Prefer single quotes for strings
- Use trailing commas
- Run `flutter format .` before committing

## Git Workflow

1. Create feature branch:
```bash
git checkout -b feature/my-feature
```

2. Make changes and commit:
```bash
git add .
git commit -m "Add new feature"
```

3. Push to remote:
```bash
git push origin feature/my-feature
```

4. Create Pull Request on GitHub

## Performance Tips

1. Use `const` constructors for widgets
2. Avoid rebuilding entire widget trees
3. Use `ListView.builder` for long lists
4. Profile with DevTools:
```bash
flutter run --profile
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)
- [ESC/POS Documentation](https://reference.epson-biz.com/modules/ref_escpos/index.php)

## Support

For help:
1. Check IMPLEMENTATION.md for detailed feature docs
2. Review existing code and comments
3. Check Flutter documentation
4. Create GitHub issue

---

Happy Coding! 🚀
