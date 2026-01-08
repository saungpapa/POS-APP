# POS-APP

📱 ဈေးဆိုင်အတွက် Mobile POS App - Barcode Scanner နဲ့ ဈေးပေါင်းစနစ်

## 🎯 ရည်ရွယ်ချက်
ဈေးဆိုင်အတွက် Mobile POS (Point of Sale) App တစ်ခု တည်ဆောက်ထားပြီး၊ ဖုန်း Camera နဲ့ Barcode scan ဖတ်ပြီး ပစ္စည်းဈေးနှုန်းများ အလိုအလျောက် ပေါင်းပေးနိုင်ပါတယ်။

## ✨ Features
- 📷 **Barcode Scanner** - ဖုန်း Camera သုံးပြီး Barcode/QR code scan ဖတ်နိုင်
- 🛒 **Shopping Cart** - ပစ္စည်းများကို Cart ထဲ စုဆောင်းပြီး ရောင်းချမှု လုပ်ဆောင်နိုင်
- 💾 **Local Database (SQLite)** - Offline အလုပ်လုပ်နိုင်
- 📦 **Product Management** - ပစ္စည်းများ ထည့်/ပြင်/ဖျက် လုပ်ဆောင်နိုင်
- 📊 **Sales Tracking** - ရောင်းချမှု မှတ်တမ်းများ သိမ်းဆည်းနိုင်
- 🇲🇲 **Myanmar UI** - Myanmar language interface

## 📱 Technology Stack
- **Framework**: Flutter (Dart)
- **Database**: SQLite (sqflite package) - Local storage
- **Barcode Scanner**: mobile_scanner package (Camera-based)
- **State Management**: Provider

## 🏗️ Project Structure
```
lib/
├── main.dart                     # App entry point
├── models/
│   ├── product.dart              # Product model (id, barcode, name, price, stock)
│   ├── cart_item.dart            # Cart item model
│   ├── sale.dart                 # Sale model
│   └── sale_item.dart            # Sale item model
├── screens/
│   ├── home_screen.dart          # Main dashboard
│   ├── scanner_screen.dart       # Barcode scanner screen
│   ├── cart_screen.dart          # Shopping cart with total
│   ├── products_screen.dart      # Product list/management
│   └── add_product_screen.dart   # Add new product form
├── services/
│   └── database_service.dart     # SQLite database operations
├── providers/
│   └── cart_provider.dart        # Cart state management
└── widgets/
    ├── product_card.dart         # Product display widget
    └── cart_item_tile.dart       # Cart item widget
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / Xcode (for building)
- Physical device or emulator with camera support

### Installation

1. Clone the repository
```bash
git clone https://github.com/saungpapa/POS-APP.git
cd POS-APP
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📦 Dependencies

Main packages used in this project:

- **sqflite**: ^2.3.0 - SQLite database for local storage
- **path**: ^1.8.3 - Path manipulation
- **mobile_scanner**: ^3.5.5 - Camera-based barcode scanning
- **provider**: ^6.1.1 - State management
- **intl**: ^0.18.1 - Internationalization and formatting

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/database_service_test.dart
flutter test test/cart_provider_test.dart
```

## 📱 Features Details

### 1. Barcode Scanner
- ဖုန်း Camera သုံးပြီး Barcode/QR code scan ဖတ်နိုင်ရမည်
- Scan ဖတ်လိုက်တာနဲ့ Database ထဲက ပစ္စည်းကို ရှာပေးရမည်
- တွေ့ရင် Cart ထဲ အလိုအလျောက် ထည့်ပေးရမည်
- မတွေ့ရင် "ပစ္စည်းအသစ်ထည့်မလား" dialog ပြရမည်

### 2. Product Management
- ပစ္စည်းအသစ် ထည့်နိုင်ရမည် (Barcode, အမည်, ဈေးနှုန်း, လက်ကျန်)
- ပစ္စည်းစာရင်း ကြည့်နိုင်ရမည်
- ပစ္စည်း ပြင်ဆင်/ဖျက်နိုင်ရမည်

### 3. Shopping Cart
- Scan ဖတ်တဲ့ ပစ္စည်းများ Cart ထဲ စုဆောင်းပေးရမည်
- အရေအတွက် တိုး/လျှော့ နိုင်ရမည်
- စုစုပေါင်းဈေးနှုန်း အလိုအလျောက် ပေါင်းပြပေးရမည်
- Cart ရှင်းလင်းနိုင်ရမည်

### 4. Database (SQLite)
- **Products table**: id, barcode, name, price, stock_quantity, created_at
- **Sales table**: id, total_amount, sale_date
- **Sale_items table**: id, sale_id, product_id, quantity, unit_price

## 🔒 Permissions

### Android
Camera permission is required for barcode scanning. The app will request this permission at runtime.

### iOS
Camera usage description is included in Info.plist.

## 📝 Notes
- Offline အလုပ်လုပ်နိုင်ရမည် (Local SQLite database သုံးထားသောကြောင့်)
- Android နှင့် iOS နှစ်ခုလုံးအတွက် အလုပ်လုပ်ရမည်
- ဈေးနှုန်းများကို Myanmar Kyat (ကျပ်) ဖြင့် ပြသပါသည်

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License
This project is open source and available under the MIT License.

## 👨‍💻 Author
Saung Papa
