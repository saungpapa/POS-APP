# POS App - Quick Start Guide

## Prerequisites
- Flutter SDK (>=3.0.0) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or Xcode for building
- Physical device or emulator with camera support

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

### 3. Run the App
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d iPhone
```

## First Time Setup

### Adding Your First Product

1. Open the app
2. Tap on **ပစ္စည်းများ** (Products) tab at the bottom
3. Tap the **ပစ္စည်းအသစ်** (New Product) button
4. Fill in the product details:
   - **Barcode**: Enter or scan a barcode
   - **ပစ္စည်းအမည်**: Product name (e.g., "Coca Cola")
   - **ဈေးနှုန်း**: Price in Kyat (e.g., 500)
   - **လက်ကျန်**: Stock quantity (e.g., 100)
5. Tap **ထည့်မည်** (Add) to save

### Making Your First Sale

1. Tap on **Scanner** tab at the bottom
2. Point camera at a product barcode
3. The product will automatically be added to cart
4. Tap on **ခြင်းတောင်း** (Cart) tab
5. Review items and quantities
6. Tap **ရောင်းချမှု ပြီးစီးမှု** (Complete Sale)
7. Confirm the sale

### Viewing Dashboard

1. Tap on **ပင်မ** (Home) tab
2. View today's statistics:
   - Total products
   - Today's sales count
   - Today's revenue
   - Current cart items

## Features Overview

### 📷 Barcode Scanner
- Open the Scanner tab
- Allow camera permission when prompted
- Point at any barcode or QR code
- Product automatically added to cart

### 🛒 Shopping Cart
- View all scanned items
- Adjust quantities with +/- buttons
- Remove items if needed
- See total amount in real-time
- Complete sales with one tap

### 📦 Product Management
- View all products in inventory
- Add new products manually
- Edit existing products
- Delete products
- See stock levels at a glance

### 📊 Dashboard
- Today's sales statistics
- Total revenue tracking
- Product inventory count
- Quick access to all features

## Tips and Tricks

### Scanning Tips
- Ensure good lighting
- Hold camera steady
- Keep barcode within the scanning frame
- Tap torch icon if needed for dark environments

### Managing Stock
- Low stock items (< 10) are highlighted in red
- Update stock quantities when receiving new inventory
- Stock automatically decreases when completing sales

### Offline Operation
- App works completely offline
- All data stored locally on device
- No internet connection required

## Troubleshooting

### Camera Not Working
- Check camera permissions in device settings
- Restart the app
- Ensure camera is not being used by another app

### Barcode Not Scanning
- Clean the barcode if dirty
- Try different angles
- Ensure barcode is not damaged
- Use manual product search if needed

### Database Issues
- App data stored in SQLite database
- If issues persist, clear app data and restart
- Database auto-created on first launch

## Support

For issues or questions:
- Check DOCUMENTATION.md for technical details
- Review CHANGELOG.md for recent changes
- Create an issue on GitHub

## Development

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/cart_provider_test.dart
```

### Building Release
```bash
# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

## Next Steps

1. Add your product inventory
2. Test barcode scanning
3. Practice completing sales
4. Review sales statistics
5. Customize as needed

Happy selling! 🎉
