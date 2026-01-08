# POS App - Receipt Print & Sales Report Features Documentation

## Overview

This document provides detailed information about the Receipt Print and Sales Report features implemented in the POS App.

## 1. Receipt Print Feature

### 1.1 Architecture

The Receipt Print feature consists of:
- **Models**: `Receipt` model containing receipt data
- **Services**: 
  - `PrintService` - Handles Bluetooth printer communication
  - `PdfService` - Generates PDF receipts
- **Screens**:
  - `ReceiptPreviewScreen` - Preview receipt before printing
  - `PrinterSettingsScreen` - Select and connect to Bluetooth printer
- **Widgets**: `ReceiptTemplate` - Reusable receipt display widget

### 1.2 User Flow

1. User adds products to cart
2. User clicks "ငွေရှင်းမယ်" (Checkout) button
3. Receipt preview screen appears
4. User has 3 options:
   - **Print**: Opens printer selection screen
   - **Save as PDF**: Generates and shares PDF
   - **Complete without printing**: Saves sale to database

### 1.3 Receipt Format

The receipt includes:
- Shop name (configurable in Settings)
- Date and time
- Receipt number (format: RYYYYMMDD-HHMMSS)
- List of items with:
  - Product name
  - Quantity
  - Price
- Total amount
- Thank you message in Myanmar

### 1.4 Bluetooth Printer Setup

**Requirements**:
- Thermal printer with ESC/POS support
- Bluetooth enabled on device
- Printer paired with device

**Permissions Required**:
- Android: BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_SCAN, BLUETOOTH_CONNECT, ACCESS_FINE_LOCATION
- iOS: NSBluetoothAlwaysUsageDescription, NSBluetoothPeripheralUsageDescription

**How to Use**:
1. Pair Bluetooth printer with device in system settings
2. In app, go to Receipt Preview
3. Click "ပရင့်ထုတ်မယ်" (Print)
4. App will scan for nearby Bluetooth printers
5. Select your printer from the list
6. Receipt will be printed

### 1.5 Error Handling

- No Bluetooth permission: Shows permission request
- No printer found: Shows message to turn on printer
- Print failed: Shows error message
- Fallback: Can always save as PDF

## 2. Sales Report Feature

### 2.1 Architecture

The Sales Report feature consists of:
- **Models**: `SalesSummary`, `TopProduct`
- **Services**:
  - `ReportService` - Calculates sales statistics
  - `PdfService` - Generates PDF reports
- **Screens**: `SalesReportScreen` - Main report screen
- **Widgets**:
  - `ReportSummaryCard` - Summary statistics cards
  - `SalesChart` - Bar chart visualization
  - `TopProductsList` - Top selling products list

### 2.2 Report Features

**Time Periods**:
- Today: Current day's sales
- This Week: Sales from Monday to today
- This Month: Sales from 1st to today
- Custom: User-selected date range

**Statistics Displayed**:
- Total Sales Amount (in Myanmar Kyat)
- Number of Transactions
- Total Items Sold
- Daily Sales Chart
- Top 10 Best-Selling Products

### 2.3 Data Visualization

**Sales Chart**:
- Bar chart showing daily sales
- X-axis: Dates
- Y-axis: Sales amount
- Interactive tooltips showing exact values

**Top Products**:
- Ranked list (1-10)
- Gold/Silver/Bronze colors for top 3
- Shows: Product name, quantity sold, total revenue

### 2.4 Export & Share

**PDF Export**:
- Generates professional PDF report
- Includes all statistics and top products
- Formatted in A4 size

**Share Options**:
- Share via installed apps (WhatsApp, Email, etc.)
- Save to device storage
- Print PDF

### 2.5 Performance

- Database queries optimized with indexes
- Statistics calculated on-demand
- Chart data limited to reasonable date ranges
- Works offline with local SQLite database

## 3. Database Schema

### 3.1 Sales Table
```sql
CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  receipt_number TEXT UNIQUE NOT NULL,
  sale_date TEXT NOT NULL,
  total_amount REAL NOT NULL
)
```

### 3.2 Sale Items Table
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

### 3.3 Products Table
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

### 3.4 Settings Table
```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
```

## 4. Configuration

### 4.1 Shop Name

The shop name appears on receipts. To configure:
1. Go to Settings screen
2. Tap on "ဆိုင်အမည်" (Shop Name)
3. Enter new name
4. Click "သိမ်းမည်" (Save)

Default shop name: "ကျွန်တော့်ဆိုင်"

## 5. Testing Guide

### 5.1 Testing Receipt Print

**Test Case 1: Complete Sale with Print**
1. Add products to cart
2. Click checkout
3. Preview receipt
4. Click print button
5. Select printer
6. Verify receipt prints correctly

**Test Case 2: Save as PDF**
1. Add products to cart
2. Click checkout
3. Preview receipt
4. Click "PDF သိမ်းရန်" (Save PDF)
5. Verify PDF is generated and shared

**Test Case 3: Complete without Print**
1. Add products to cart
2. Click checkout
3. Preview receipt
4. Click "ပရင့်မထုတ်ဘဲ ပြီးမယ်" (Complete without printing)
5. Verify sale is saved
6. Verify cart is cleared

### 5.2 Testing Sales Report

**Test Case 1: View Today's Report**
1. Complete some sales
2. Go to Reports screen
3. Select "ယနေ့" (Today)
4. Verify statistics are correct
5. Verify chart shows data
6. Verify top products list

**Test Case 2: Custom Date Range**
1. Go to Reports screen
2. Click "Custom" chip
3. Select date range
4. Verify report updates
5. Verify date range is displayed

**Test Case 3: Export PDF Report**
1. View any report
2. Click share button
3. Verify PDF is generated
4. Verify PDF contains all data

## 6. Troubleshooting

### 6.1 Bluetooth Printer Issues

**Problem**: Printer not found
- Solution: Ensure printer is turned on and paired in system Bluetooth settings

**Problem**: Print failed
- Solution: Check if printer supports ESC/POS commands

**Problem**: Permission denied
- Solution: Grant Bluetooth and Location permissions in app settings

### 6.2 Sales Report Issues

**Problem**: No data shown
- Solution: Ensure sales have been completed for the selected date range

**Problem**: Chart not loading
- Solution: Check if there are sales in the selected period

### 6.3 Database Issues

**Problem**: App crashes on startup
- Solution: Database initialization may have failed. Clear app data and restart

## 7. Code Examples

### 7.1 Adding a Sale Programmatically

```dart
final sale = Sale(
  receiptNumber: 'R20260108-123456',
  saleDate: DateTime.now(),
  totalAmount: 15000,
  items: [
    SaleItem(
      productId: 1,
      productName: 'Product A',
      quantity: 2,
      unitPrice: 5000,
      totalPrice: 10000,
    ),
    SaleItem(
      productId: 2,
      productName: 'Product B',
      quantity: 1,
      unitPrice: 5000,
      totalPrice: 5000,
    ),
  ],
);

await databaseService.insertSale(sale);
```

### 7.2 Generating Sales Report

```dart
final reportService = ReportService(databaseService);
final summary = await reportService.generateSalesReport(
  DateTime(2026, 1, 1),
  DateTime(2026, 1, 31),
);

print('Total Sales: ${summary.totalSales}');
print('Transactions: ${summary.transactionCount}');
```

### 7.3 Printing Receipt

```dart
final printService = PrintService();
final devices = await printService.scanDevices();
final success = await printService.printReceipt(receipt, devices.first);
```

## 8. Future Enhancements

Potential improvements:
1. Support for WiFi/Network printers
2. Email receipt functionality
3. Multiple payment methods
4. Sales comparison charts
5. Product categories in reports
6. Employee/cashier tracking
7. Inventory alerts
8. Customer management
9. Discounts and promotions
10. Multi-currency support

## 9. Dependencies Used

### Receipt Print
- `esc_pos_bluetooth: ^0.4.1` - Bluetooth printer communication
- `esc_pos_utils: ^1.1.0` - ESC/POS command utilities
- `permission_handler: ^11.0.1` - Runtime permissions

### Sales Report
- `fl_chart: ^0.65.0` - Chart library
- `pdf: ^3.10.4` - PDF generation
- `printing: ^5.11.0` - PDF printing
- `share_plus: ^7.2.1` - Share functionality

### Core
- `sqflite: ^2.3.0` - SQLite database
- `provider: ^6.1.1` - State management
- `intl: ^0.18.1` - Formatting and internationalization

## 10. Contact & Support

For issues or questions:
- Create an issue on GitHub
- Check existing documentation
- Review code comments

---

**Last Updated**: January 8, 2026
**Version**: 1.0.0
