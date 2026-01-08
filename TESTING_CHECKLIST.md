# Testing Checklist for POS App

## Pre-Testing Setup

- [ ] Device/Emulator running
- [ ] App installed successfully
- [ ] Database initialized
- [ ] Sample products added

## Feature 1: Product Management

### Add Product
- [ ] Open Products screen
- [ ] Tap "+" button
- [ ] Fill all fields (Name, Barcode, Price, Stock)
- [ ] Tap Save
- [ ] Verify product appears in list
- [ ] Verify product details are correct

### Search Product
- [ ] Type in search box
- [ ] Verify filtering by name works
- [ ] Verify filtering by barcode works
- [ ] Clear search shows all products

### Barcode Scanner
- [ ] Tap scanner icon
- [ ] Grant camera permission if requested
- [ ] Scan a barcode
- [ ] Verify product is found (if exists)
- [ ] Verify product added to cart
- [ ] Verify error message (if product doesn't exist)

## Feature 2: Shopping Cart

### Add to Cart
- [ ] Tap product in Products screen
- [ ] Verify item added to cart
- [ ] Verify notification shown
- [ ] Check Cart tab shows item

### Adjust Quantity
- [ ] Go to Cart screen
- [ ] Tap "+" to increase quantity
- [ ] Verify quantity increases
- [ ] Verify total updates
- [ ] Tap "-" to decrease quantity
- [ ] Verify quantity decreases
- [ ] Tap "-" on quantity 1
- [ ] Verify item removed from cart

### Clear Cart
- [ ] Add items to cart
- [ ] Tap delete icon in app bar
- [ ] Confirm deletion
- [ ] Verify cart is empty

### Stock Validation
- [ ] Add product to cart
- [ ] Increase quantity beyond stock
- [ ] Verify error message shown
- [ ] Verify quantity doesn't exceed stock

## Feature 3: Receipt Print

### Receipt Preview
- [ ] Add items to cart
- [ ] Tap "ငွေရှင်းမယ်"
- [ ] Verify receipt preview shows
- [ ] Verify shop name displayed
- [ ] Verify date/time displayed
- [ ] Verify receipt number format
- [ ] Verify all items listed
- [ ] Verify quantities correct
- [ ] Verify prices correct
- [ ] Verify total correct

### Bluetooth Print
- [ ] From receipt preview, tap "ပရင့်ထုတ်မယ်"
- [ ] Verify permission request (if first time)
- [ ] Grant permissions
- [ ] Verify printer scan starts
- [ ] Verify paired printers appear
- [ ] Select printer
- [ ] Verify printing starts
- [ ] Check physical receipt output
- [ ] Verify receipt format matches preview
- [ ] Verify sale saved to database
- [ ] Verify cart cleared
- [ ] Verify redirected to home

### PDF Save/Share
- [ ] From receipt preview, tap "PDF သိမ်းရန်"
- [ ] Verify PDF generated
- [ ] Verify share dialog appears
- [ ] Share to another app (optional)
- [ ] Verify PDF content matches receipt

### Complete Without Print
- [ ] From receipt preview, tap "ပရင့်မထုတ်ဘဲ ပြီးမယ်"
- [ ] Verify sale saved
- [ ] Verify cart cleared
- [ ] Verify redirected to home
- [ ] Check Reports to confirm sale recorded

### Error Handling
- [ ] Try printing without Bluetooth printer
- [ ] Verify appropriate error message
- [ ] Verify can still save as PDF
- [ ] Verify can still complete without print

## Feature 4: Sales Report

### Today Report
- [ ] Complete some sales today
- [ ] Go to Reports screen
- [ ] Select "ယနေ့" chip
- [ ] Verify total sales correct
- [ ] Verify transaction count correct
- [ ] Verify items count correct
- [ ] Verify chart displays
- [ ] Verify top products list

### Week Report
- [ ] Select "ဒီအပတ်" chip
- [ ] Verify data updates
- [ ] Verify date range is current week
- [ ] Verify statistics correct

### Month Report
- [ ] Select "ဒီလ" chip
- [ ] Verify data updates
- [ ] Verify date range is current month
- [ ] Verify statistics correct

### Custom Date Range
- [ ] Tap "Custom" chip
- [ ] Select start date
- [ ] Select end date
- [ ] Tap OK
- [ ] Verify report updates
- [ ] Verify date range displayed
- [ ] Verify data matches selected range

### Chart Display
- [ ] View report with data
- [ ] Verify bar chart displays
- [ ] Verify bars show for days with sales
- [ ] Tap on bar
- [ ] Verify tooltip shows date and amount
- [ ] Verify formatting correct

### Top Products List
- [ ] Verify top 10 products shown
- [ ] Verify ranked 1-10
- [ ] Verify rank colors (gold, silver, bronze for top 3)
- [ ] Verify product names shown
- [ ] Verify quantities shown
- [ ] Verify revenue shown
- [ ] Verify sorted by quantity sold

### PDF Export
- [ ] View any report
- [ ] Tap share icon in app bar
- [ ] Verify PDF generated
- [ ] Verify share dialog appears
- [ ] Open PDF (optional)
- [ ] Verify PDF contains:
  - [ ] Report title
  - [ ] Date range
  - [ ] Summary statistics
  - [ ] Top products table

### Refresh Report
- [ ] View report
- [ ] Complete a new sale
- [ ] Tap refresh icon
- [ ] Verify data updates
- [ ] Verify new sale included

### Empty State
- [ ] Select date range with no sales
- [ ] Verify "အရောင်းဒေတာ မရှိပါ" message
- [ ] Verify chart shows empty state
- [ ] Verify top products shows empty state

## Feature 5: Settings

### Shop Name
- [ ] Go to Settings screen
- [ ] Verify current shop name displayed
- [ ] Tap on shop name
- [ ] Enter new name
- [ ] Tap "သိမ်းမည်"
- [ ] Verify success message
- [ ] Verify new name displayed
- [ ] Complete a sale
- [ ] Verify new name on receipt

### App Info
- [ ] Tap on Features item
- [ ] Verify about dialog shows
- [ ] Verify app name, version shown
- [ ] Verify features list shown

## Feature 6: Navigation

### Bottom Navigation
- [ ] Tap each tab
- [ ] Verify correct screen loads
- [ ] Verify all 4 tabs work:
  - [ ] ပစ္စည်းများ (Products)
  - [ ] ခြင်း (Cart)
  - [ ] အရောင်းစာရင်း (Reports)
  - [ ] ဆက်တင် (Settings)

### Back Navigation
- [ ] Navigate to sub-screens
- [ ] Tap back button
- [ ] Verify returns to previous screen
- [ ] Verify no crashes

## Performance Testing

### Database Operations
- [ ] Add 100+ products
- [ ] Verify list scrolls smoothly
- [ ] Search in large product list
- [ ] Verify search is responsive

### Large Transactions
- [ ] Add 20+ items to cart
- [ ] Complete sale
- [ ] Verify no lag
- [ ] Verify receipt generates quickly

### Report with Large Data
- [ ] Generate report with 100+ sales
- [ ] Verify loads in reasonable time
- [ ] Verify chart renders correctly
- [ ] Verify scrolling smooth

## Error Scenarios

### Permission Denied
- [ ] Deny camera permission
- [ ] Try to scan barcode
- [ ] Verify error message
- [ ] Grant permission
- [ ] Verify scanner works

- [ ] Deny Bluetooth permission
- [ ] Try to print
- [ ] Verify error message
- [ ] Grant permission
- [ ] Verify printing works

### Network/Offline
- [ ] Turn off internet
- [ ] Use all features
- [ ] Verify everything works offline

### Low Storage
- [ ] Create many sales
- [ ] Monitor storage usage
- [ ] Verify app handles gracefully

### App Restart
- [ ] Add items to cart
- [ ] Close app
- [ ] Reopen app
- [ ] Verify cart is cleared (expected behavior)
- [ ] Verify previous sales still in database

## UI/UX Testing

### Myanmar Text Display
- [ ] Verify all Myanmar text renders correctly
- [ ] Check for text overflow
- [ ] Verify fonts readable

### Responsive Layout
- [ ] Rotate device
- [ ] Verify layouts adapt
- [ ] Verify no overlapping elements

### Touch Targets
- [ ] Verify all buttons easy to tap
- [ ] Verify no accidental taps
- [ ] Verify appropriate spacing

### Loading States
- [ ] Verify loading indicators shown
- [ ] Verify appropriate messages
- [ ] Verify no infinite loading

### Error Messages
- [ ] Verify error messages clear
- [ ] Verify in Myanmar language
- [ ] Verify actionable

## Platform-Specific Testing

### Android
- [ ] Test on Android 5.0 (API 21)
- [ ] Test on latest Android version
- [ ] Verify permissions work
- [ ] Verify back button behavior
- [ ] Verify share intent works

### iOS (if available)
- [ ] Test on iOS 12.0
- [ ] Test on latest iOS version
- [ ] Verify permissions work
- [ ] Verify share sheet works
- [ ] Verify gesture navigation

## Regression Testing

After any code changes:
- [ ] Re-run critical path tests
- [ ] Verify no existing features broken
- [ ] Check for new crashes
- [ ] Verify data integrity

## Notes

- Mark items as complete ✓ when tested
- Note any issues found
- Include device/OS version for issues
- Screenshot errors when possible

---

**Testing Date**: ___________
**Tester**: ___________
**Device**: ___________
**OS Version**: ___________
**App Version**: ___________
