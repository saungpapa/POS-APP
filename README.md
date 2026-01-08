# POS-APP

📱 ဈေးဆိုင်အတွက် Mobile POS App - Barcode Scanner နဲ့ ဈေးပေါင်းစနစ်

## Features
- 📷 Barcode Scanner (Camera)
- 🛒 Shopping Cart
- 💾 Local Database (SQLite)
- 🇲🇲 Myanmar UI
- 🧾 Receipt Print (Bluetooth Printer)
- 📄 PDF Export & Share
- 📊 Sales Report with Charts
- 📈 Top Selling Products Analytics
- ⚙️ Settings Management

## ထည့်သွင်းထားသော Packages

### Core
- `sqflite` - Local SQLite database
- `path_provider` - File system paths
- `provider` - State management
- `intl` - Internationalization & formatting

### Barcode & Camera
- `mobile_scanner` - Barcode scanning

### Receipt Print
- `esc_pos_bluetooth` - Bluetooth thermal printer
- `esc_pos_utils` - ESC/POS utilities
- `permission_handler` - Runtime permissions

### Sales Report & Export
- `fl_chart` - Charts and graphs
- `pdf` - PDF generation
- `printing` - PDF printing
- `share_plus` - Share functionality

## Project Structure

```
lib/
├── models/              # Data models
│   ├── product.dart
│   ├── sale.dart
│   ├── receipt.dart
│   └── sales_summary.dart
├── services/            # Business logic services
│   ├── database_service.dart
│   ├── print_service.dart
│   ├── pdf_service.dart
│   └── report_service.dart
├── screens/             # UI screens
│   ├── home_screen.dart
│   ├── products_screen.dart
│   ├── cart_screen.dart
│   ├── receipt_preview_screen.dart
│   ├── printer_settings_screen.dart
│   ├── sales_report_screen.dart
│   └── settings_screen.dart
├── widgets/             # Reusable widgets
│   ├── receipt_template.dart
│   ├── sales_chart.dart
│   ├── top_products_list.dart
│   └── report_summary_card.dart
├── utils/               # Utilities
│   └── cart_provider.dart
└── main.dart            # Entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android device/emulator or iOS device/simulator

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

## Features Usage

### 1. Products Management
- Add products with name, barcode, price, and stock
- Scan barcodes using camera
- Search products by name or barcode

### 2. Shopping Cart
- Add products to cart
- Adjust quantities
- View total amount

### 3. Receipt Print
- Preview receipt before printing
- Print to Bluetooth thermal printer
- Save as PDF or share
- Complete sale without printing

### 4. Sales Report
- View reports by: Today, This Week, This Month, or Custom range
- See total sales, transaction count, and items sold
- View sales chart
- Top 10 best-selling products
- Export report as PDF

### 5. Settings
- Configure shop name
- View app information

## Database Schema

### Products Table
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  barcode TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  stock INTEGER NOT NULL,
  created_at TEXT NOT NULL
)
```

### Sales Table
```sql
CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  receipt_number TEXT UNIQUE NOT NULL,
  sale_date TEXT NOT NULL,
  total_amount REAL NOT NULL
)
```

### Sale Items Table
```sql
CREATE TABLE sale_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  total_price REAL NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales (id)
)
```

### Settings Table
```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
```

## Permissions

### Android
- `BLUETOOTH` - For Bluetooth printer connection
- `BLUETOOTH_ADMIN` - For Bluetooth management
- `BLUETOOTH_SCAN` - For scanning Bluetooth devices
- `BLUETOOTH_CONNECT` - For connecting to Bluetooth devices
- `ACCESS_FINE_LOCATION` - Required for Bluetooth scanning
- `CAMERA` - For barcode scanning

### iOS
- `NSCameraUsageDescription` - Camera access for barcode scanning
- `NSBluetoothAlwaysUsageDescription` - Bluetooth access for printer
- `NSBluetoothPeripheralUsageDescription` - Bluetooth peripheral access

## Offline Support
- All features work offline
- Data stored in local SQLite database
- No internet connection required

## Known Requirements
- Thermal printer must support ESC/POS commands
- Bluetooth printer must be paired with device
- Android API Level 21+ (Android 5.0+)
- iOS 12.0+

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is open source and available under the MIT License.
