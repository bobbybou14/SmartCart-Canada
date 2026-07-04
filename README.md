# SmartCart Canada

SmartCart Canada is a Flutter-based grocery shopping assistant designed for Canadian shoppers.

The app helps users scan grocery products, identify items, estimate Ontario HST, manage a shopping cart, and eventually compare prices across Canadian retailers.

---

## Current Features

- Barcode scanning
- Manual barcode lookup
- Product lookup using Open Food Facts
- Product images
- Shopping cart
- Quantity controls
- Remove items from cart
- Ontario HST calculation
- Running subtotal and total
- Supabase cloud backend
- Cloud product lookup
- Admin screen
- Add products to Supabase
- Add stores to Supabase
- Product catalog
- GitHub version control

---

## Tech Stack

- Flutter
- Dart
- Supabase
- PostgreSQL
- Open Food Facts API
- GitHub

---

## Current Database Tables

### products

Stores product details such as:

- barcode
- name
- brand
- category
- size
- image URL
- taxable status

### stores

Stores Canadian grocery retailers and locations.

### prices

Stores price records for products by store, city, province, and date.

---

## Roadmap

### Version 0.5 — Canadian Price Intelligence

- Add product prices
- Display store price comparisons
- Highlight cheapest store
- Show last updated date
- Add price submission screen

### Version 0.6 — Receipt Intelligence

- Receipt image upload
- OCR receipt scanning
- Automatic price extraction
- Automatic cart creation from receipts

### Version 0.7 — Smart Shopping

- Shopping list optimization
- Cheapest store recommendations
- Savings tracker
- Price history

### Version 1.0 — Public Release

- User accounts
- Community pricing
- Android release
- iOS release
- AI shopping assistant

---

## Project Status

SmartCart Canada is currently in active early-stage development.

The current focus is building a stable Flutter app, cloud backend, and Canadian grocery price intelligence system.