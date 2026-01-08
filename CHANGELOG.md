# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-01-08

### Added
- Initial release of POS App
- Barcode scanner functionality using mobile device camera
- Product management (Create, Read, Update, Delete)
- Shopping cart with quantity management
- SQLite local database for offline operation
- Sale transaction processing with inventory updates
- Myanmar language UI
- Home dashboard with statistics
- Bottom navigation for easy access to features
- Product card widget with edit/delete options
- Cart item tile widget with quantity controls
- Comprehensive unit tests for database and cart provider
- Widget tests for UI components
- Model tests for data classes
- Android and iOS camera permissions configuration
- Developer documentation
- README with setup instructions

### Features
- 📷 **Barcode Scanner**: Scan barcodes using phone camera
- 🛒 **Shopping Cart**: Add products, manage quantities, complete sales
- 💾 **Local Database**: SQLite for offline functionality
- 📦 **Product Management**: Add, edit, delete products
- 📊 **Sales Tracking**: Save sales history with transaction details
- 🇲🇲 **Myanmar UI**: Complete Myanmar language interface
- 📱 **Cross-Platform**: Works on both Android and iOS

### Technical Details
- Flutter SDK >= 3.0.0
- State Management: Provider
- Database: SQLite (sqflite)
- Barcode Scanner: mobile_scanner
- Formatting: intl package

### Database Schema
- Products table with barcode, name, price, and stock
- Sales table for transaction records
- Sale items table linking sales to products

### Testing
- 10+ unit tests for cart provider
- 8+ unit tests for database service
- Widget tests for ProductCard and CartItemTile
- Model tests for Product and CartItem

## [Unreleased]

### Planned Features
- Sales history screen
- Product search and filtering
- Sales reports and analytics
- Backup/restore functionality
- Receipt printing support
- Export to CSV/Excel
- Multi-user support
