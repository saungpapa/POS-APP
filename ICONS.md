# App Icons Documentation

## 📱 POS App Icons

This document describes the custom app icons for the POS App and how to regenerate them if needed.

## 🎨 Icon Design

### Design Overview
The POS App uses a professional, modern icon design featuring:
- **🛒 Shopping Cart**: Primary element representing the POS/retail nature
- **📊 Barcode**: Secondary element representing the barcode scanning feature
- **🎨 Color Scheme**: Material Design primary blue (#1976D2) with gradient to darker blue (#1565C0)
- **Style**: Flat, modern design with clear silhouette for visibility at small sizes

### Icon Files Created

#### Source Icons (assets/icon/)
```
assets/icon/
├── app_icon.png              # Main app icon (1024x1024 px)
└── app_icon_foreground.png   # Adaptive icon foreground (432x432 px)
```

#### Generated Android Icons
```
android/app/src/main/res/
├── mipmap-mdpi/
│   ├── ic_launcher.png               # 48x48
│   └── ic_launcher_foreground.png
├── mipmap-hdpi/
│   ├── ic_launcher.png               # 72x72
│   └── ic_launcher_foreground.png
├── mipmap-xhdpi/
│   ├── ic_launcher.png               # 96x96
│   └── ic_launcher_foreground.png
├── mipmap-xxhdpi/
│   ├── ic_launcher.png               # 144x144
│   └── ic_launcher_foreground.png
├── mipmap-xxxhdpi/
│   ├── ic_launcher.png               # 192x192
│   └── ic_launcher_foreground.png
├── mipmap-anydpi-v26/
│   └── ic_launcher.xml               # Adaptive icon config
└── values/
    └── colors.xml                    # Background color definition
```

#### Generated iOS Icons
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png     # 20x20
├── Icon-App-20x20@2x.png     # 40x40
├── Icon-App-20x20@3x.png     # 60x60
├── Icon-App-29x29@1x.png     # 29x29
├── Icon-App-29x29@2x.png     # 58x58
├── Icon-App-29x29@3x.png     # 87x87
├── Icon-App-40x40@1x.png     # 40x40
├── Icon-App-40x40@2x.png     # 80x80
├── Icon-App-40x40@3x.png     # 120x120
├── Icon-App-60x60@2x.png     # 120x120
├── Icon-App-60x60@3x.png     # 180x180
├── Icon-App-76x76@1x.png     # 76x76
├── Icon-App-76x76@2x.png     # 152x152
├── Icon-App-83.5x83.5@2x.png # 167x167
├── Icon-App-1024x1024@1x.png # 1024x1024
└── Contents.json             # iOS asset catalog config
```

## 🔧 Configuration

### pubspec.yaml
The app uses the `flutter_launcher_icons` package for icon generation:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1976D2"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
  min_sdk_android: 21
```

### Android Adaptive Icons
Android 8.0 (API 26)+ supports adaptive icons with:
- **Background**: Solid color (#1976D2 - Primary blue)
- **Foreground**: Transparent PNG with shopping cart and barcode
- **Configuration**: `mipmap-anydpi-v26/ic_launcher.xml`

## 🔄 How to Regenerate Icons

### Method 1: Using flutter_launcher_icons (Recommended)
If you have Flutter installed and want to regenerate icons:

```bash
# Install dependencies
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons
```

### Method 2: Manual Generation
If Flutter is not available, you can use the Python scripts in the `/tmp` directory to regenerate icons:

1. **Prerequisites**: Install Pillow
   ```bash
   pip3 install Pillow
   ```

2. **Update source icons** (if needed):
   - Edit the design in `assets/icon/app_icon.png` (1024x1024)
   - Edit the foreground in `assets/icon/app_icon_foreground.png` (432x432)

3. **Run the generation script**:
   The icons were generated using custom Python scripts that create all required sizes for Android and iOS platforms.

## 📝 Design Specifications

### Color Palette
- **Primary Blue**: #1976D2 (Material Design Blue 700)
- **Dark Blue**: #1565C0 (Material Design Blue 800)
- **White**: #FFFFFF (for icon elements)

### Icon Elements
1. **Shopping Cart** (Upper section):
   - Represents the POS/retail functionality
   - White color for contrast against blue background
   - Includes cart body, handle, and wheels

2. **Barcode** (Lower section):
   - Represents the barcode scanning feature
   - Alternating vertical bars
   - White color for visibility

### Safe Zones
- **Android Adaptive Icons**: Inner 66% of the image is safe zone
- **iOS Icons**: No safe zone requirements, but design centered for consistency
- All icon elements are positioned within safe zones to prevent clipping

## 🎨 Customization

To customize the app icons:

1. **Modify the design**:
   - Update `assets/icon/app_icon.png` with your new design (1024x1024 px)
   - Update `assets/icon/app_icon_foreground.png` for Android adaptive icons (432x432 px)

2. **Update colors** (optional):
   - Edit `adaptive_icon_background` in `pubspec.yaml`
   - Edit `ic_launcher_background` in `android/app/src/main/res/values/colors.xml`

3. **Regenerate platform icons**:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

## 📱 Platform Support

- **Android**: API 21+ (Android 5.0 Lollipop and above)
  - Standard launcher icons for all Android versions
  - Adaptive icons for Android 8.0+ (API 26+)
  
- **iOS**: All supported iOS versions
  - iPhone and iPad icons
  - All required sizes including App Store icon (1024x1024)

## ✅ Verification

After building the app, verify the icons appear correctly:

### Android
```bash
flutter build apk --release
# Check the app icon on the home screen and in the app drawer
```

### iOS
```bash
flutter build ios --release
# Check the app icon on the home screen and in the App Store
```

## 🔍 Troubleshooting

### Icons not updating
1. Clean the build:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Rebuild the app:
   ```bash
   flutter run
   ```

### Android adaptive icon not showing
- Ensure Android version is 8.0+ (API 26+)
- Check that `mipmap-anydpi-v26/ic_launcher.xml` exists
- Verify `ic_launcher_background` color is defined in `values/colors.xml`

### iOS icons appear blurry
- Ensure source icons are high resolution (1024x1024)
- Check that all icon sizes were generated correctly
- Verify `Contents.json` references all icon files

## 📚 References

- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Material Design Icons](https://material.io/design/iconography)

---

**Last Updated**: January 2026  
**Icon Version**: 1.0.0
