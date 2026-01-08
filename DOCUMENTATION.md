# POS App - Developer Documentation

## Architecture Overview

The POS App follows a clean architecture pattern with separation of concerns:

### Layer Structure

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (Screens, Widgets, UI Logic)     │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│        Business Logic Layer         │
│      (Providers, State Mgmt)       │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│          Data Layer                 │
│   (Models, Services, Database)     │
└─────────────────────────────────────┘
```

## Core Components

### 1. Models (`lib/models/`)

#### Product
Represents a product in the inventory with:
- `id`: Unique identifier
- `barcode`: Product barcode
- `name`: Product name
- `price`: Product price in Kyat
- `stockQuantity`: Available stock
- `createdAt`: Creation timestamp

#### CartItem
Represents an item in the shopping cart with:
- `product`: Reference to Product
- `quantity`: Number of items
- `totalPrice`: Computed property (price × quantity)

#### Sale & SaleItem
Represents completed sales transactions.

### 2. Services (`lib/services/`)

#### DatabaseService
Singleton service managing SQLite database operations:
- **Product CRUD**: Create, Read, Update, Delete products
- **Sale Management**: Create sales and update inventory
- **Transaction Safety**: Uses database transactions for data integrity

**Key Methods:**
- `createProduct(Product)`: Add new product
- `getProductByBarcode(String)`: Find product by barcode
- `getAllProducts()`: List all products
- `createSale(Sale, List<SaleItem>)`: Complete a sale transaction

### 3. Providers (`lib/providers/`)

#### CartProvider
State management for shopping cart using Provider package:
- Manages cart items list
- Calculates total amount
- Handles quantity updates
- Notifies listeners on changes

**Key Methods:**
- `addProduct(Product)`: Add or increment product in cart
- `increaseQuantity(int)`: Increase item quantity
- `decreaseQuantity(int)`: Decrease item quantity
- `removeItem(int)`: Remove item from cart
- `clear()`: Empty the cart

### 4. Screens (`lib/screens/`)

#### HomeScreen
Dashboard showing:
- Today's statistics (products, sales, revenue)
- Quick actions
- Cart summary

#### ScannerScreen
Barcode scanning interface:
- Uses `mobile_scanner` package
- Searches product by barcode
- Auto-adds to cart if found
- Prompts to add new product if not found

#### CartScreen
Shopping cart management:
- List of cart items
- Quantity controls
- Total calculation
- Complete sale functionality

#### ProductsScreen
Product list and management:
- Display all products
- Edit/delete operations
- Navigate to add product

#### AddProductScreen
Product form for adding/editing:
- Barcode input
- Name, price, stock quantity
- Validation
- Save to database

### 5. Widgets (`lib/widgets/`)

#### ProductCard
Reusable card component displaying product information.

#### CartItemTile
Reusable tile for cart items with quantity controls.

## Data Flow

### Adding Product to Cart via Scanner

```
1. User opens Scanner Screen
2. Camera scans barcode
3. ScannerScreen calls DatabaseService.getProductByBarcode()
4. If found:
   a. CartProvider.addProduct() is called
   b. UI updates automatically via Provider
5. If not found:
   a. Show dialog
   b. Navigate to AddProductScreen with barcode
```

### Completing a Sale

```
1. User taps "ရောင်းချမှု ပြီးစီးမှု" in Cart Screen
2. Confirmation dialog appears
3. If confirmed:
   a. Create Sale object with total amount
   b. Create SaleItem objects for each cart item
   c. DatabaseService.createSale() is called
   d. Transaction updates sale, sale_items, and product stock
   e. CartProvider.clear() empties the cart
   f. Success message shown
```

## Database Schema

### products
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  barcode TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  stock_quantity INTEGER NOT NULL,
  created_at TEXT NOT NULL
)
```

### sales
```sql
CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  total_amount REAL NOT NULL,
  sale_date TEXT NOT NULL
)
```

### sale_items
```sql
CREATE TABLE sale_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
)
```

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Provider state management
- Database CRUD operations

### Widget Tests
- UI component rendering
- User interaction callbacks
- Display of data

### Integration Tests
- End-to-end workflows
- Barcode scanning flow
- Sale completion flow

## Best Practices

1. **Singleton Pattern**: DatabaseService uses singleton to maintain single database connection
2. **Provider Pattern**: State management with ChangeNotifier
3. **Transaction Safety**: Database operations use transactions for data integrity
4. **Error Handling**: Try-catch blocks with user-friendly messages
5. **Myanmar Localization**: All UI text in Myanmar language
6. **Offline-First**: SQLite ensures app works without internet

## Future Enhancements

- Sales history screen
- Product search and filtering
- Sales reports and analytics
- Backup/restore functionality
- Multi-user support
- Receipt printing
- Export to CSV/Excel
