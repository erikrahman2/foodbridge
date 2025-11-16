# Driver System Documentation

## Overview

Complete driver delivery system integrated with order management. Drivers can view available orders, accept deliveries, and mark them as completed.

## System Architecture

### 1. Data Model (`lib/models/driver_model.dart`)

```dart
class DriverModel {
  String id;
  String userId;        // References user email
  String name;
  String phone;
  String vehicleType;   // Motor, Mobil, Sepeda
  String vehicleNumber;
  String status;        // available, busy, offline
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 2. State Management (`lib/providers/driver_provider.dart`)

**Methods:**

- `registerAsDriver()` - Creates driver record in Firestore
- `checkDriverStatus(userId)` - Validates if user is registered driver
- `updateDriverStatus(driverId, status)` - Changes online/offline/busy status
- `getDriverByUserId(userId)` - Retrieves driver data
- `logout()` - Clears current driver session

### 3. Order Provider Extension (`lib/providers/order_provider.dart`)

**New Methods:**

- `loadAllOrders()` - Fetches all orders from Firestore once (for driver dashboard)
- `allOrders` getter - Returns List<Map<String, dynamic>> of all orders

## User Flow

### Driver Registration

1. Go to Profile → "Daftar Sebagai Driver"
2. System checks if user is already registered
3. If not registered → Driver Registration Form:
   - Full Name
   - Phone Number
   - Vehicle Type (Motor/Mobil/Sepeda)
   - Vehicle Number
4. Submit → Creates driver record → Redirect to Driver Dashboard

### Driver Dashboard

**URL:** `/driver-dashboard`

**Header:**

- Driver name and vehicle info
- Online/Offline toggle switch
  - Online (available) → Can accept orders
  - Offline → Hidden from order assignments

**Three Tabs:**

#### 1. Pesanan Baru (Available Orders)

- Shows orders with status='confirmed' and driverId=null
- Each order shows:
  - Order ID
  - Delivery address
  - Item count
  - Total amount
- **Action Button:** "Ambil Pesanan"
  - Updates order.driverId = current driver ID
  - Changes order.status → 'on_delivery'
  - Changes driver.status → 'busy'
  - Moves order to "Sedang Diantar" tab

#### 2. Sedang Diantar (In Progress)

- Shows orders with status='on_delivery' and driverId=current driver
- Each order shows same info as available orders
- **Action Button:** "Selesaikan Pengiriman"
  - Changes order.status → 'delivered'
  - Changes driver.status → 'available'
  - Moves order to "Selesai" tab

#### 3. Selesai (Completed)

- Shows orders with status='delivered' and driverId=current driver
- Read-only view of completed deliveries
- No action buttons

## Order Status Flow

```
Order Lifecycle with Driver Integration:

1. Customer places order
   └─> status: 'pending'

2. Order confirmed (payment completed)
   └─> status: 'confirmed', driverId: null
   └─> APPEARS IN: Driver Dashboard → "Pesanan Baru" tab

3. Driver accepts order
   └─> status: 'on_delivery', driverId: <driver_id>
   └─> driver.status: 'busy'
   └─> APPEARS IN: Driver Dashboard → "Sedang Diantar" tab

4. Driver completes delivery
   └─> status: 'delivered'
   └─> driver.status: 'available' (can accept new orders)
   └─> APPEARS IN: Driver Dashboard → "Selesai" tab
```

## Database Collections

### drivers

```json
{
  "id": "auto-generated",
  "userId": "user_email@example.com",
  "name": "John Doe",
  "phone": "08123456789",
  "vehicleType": "Motor",
  "vehicleNumber": "B 1234 XYZ",
  "status": "available",
  "createdAt": "2024-01-01T00:00:00",
  "updatedAt": "2024-01-01T00:00:00"
}
```

### orders (updated fields)

```json
{
  "id": "auto-generated",
  "userId": "customer_email",
  "items": [...],
  "totalAmount": 50000,
  "deliveryAddress": "Jl. Example No. 123",
  "status": "on_delivery",
  "driverId": "driver_document_id",  // NEW FIELD
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Routes

### New Routes Added

```dart
// lib/routes/app_routes.dart
static const String driverRegistration = '/driver-registration';
static const String driverDashboard = '/driver-dashboard';

// lib/routes/app_pages.dart
AppRoutes.driverRegistration: (context) => const DriverRegistrationPage(),
AppRoutes.driverDashboard: (context) => const DriverDashboardPage(),
```

## Provider Registration

Added to `lib/main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProvider(create: (_) => FoodProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
    ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    ChangeNotifierProvider(create: (_) => SellerProvider()),
    ChangeNotifierProvider(create: (_) => DriverProvider()),  // NEW
  ],
  // ...
)
```

## Testing Workflow

### 1. Register as Driver

```
Profile → "Daftar Sebagai Driver"
→ Fill form (name, phone, vehicle)
→ Submit
→ Redirected to Driver Dashboard
```

### 2. Test Order Acceptance

```
Prerequisites:
- Have at least one order with status='confirmed' in Firestore

Steps:
1. Driver Dashboard → "Pesanan Baru" tab
2. See available orders
3. Click "Ambil Pesanan" on any order
4. Verify:
   - Order moves to "Sedang Diantar" tab
   - Driver status changes to 'busy'
   - Order document updated with driverId
   - Order status changed to 'on_delivery'
```

### 3. Test Order Completion

```
Prerequisites:
- Have at least one order in "Sedang Diantar" tab

Steps:
1. Driver Dashboard → "Sedang Diantar" tab
2. Click "Selesaikan Pengiriran" on any order
3. Verify:
   - Order moves to "Selesai" tab
   - Driver status changes back to 'available'
   - Order status changed to 'delivered'
```

### 4. Test Online/Offline Toggle

```
1. Driver Dashboard → Toggle switch in AppBar
2. Set to Offline
3. Verify driver.status = 'offline'
4. Set back to Online
5. Verify driver.status = 'available'
```

## Key Features

✅ **Multi-Driver Support** - Multiple drivers can be online simultaneously
✅ **First-Come-First-Serve** - Any available driver can accept any order
✅ **Real-Time Status Updates** - Order status reflects actual delivery state
✅ **Driver Availability Management** - Online/offline toggle prevents unwanted assignments
✅ **Order Filtering** - Each tab shows only relevant orders for current driver
✅ **Atomic Updates** - Order acceptance updates both order and driver documents
✅ **Status Tracking** - Clear visibility of order progression through delivery stages

## Integration with Existing Systems

### Seller System

- Sellers create products → Orders generated → Available for drivers
- No direct interaction between seller and driver

### Order System

- Orders from OrderProvider automatically appear in driver dashboard
- Order status updates reflect in OrdersHistoryPage
- Order tracking shows driver assignment

### User Profile

- New menu item "Daftar Sebagai Driver" below "Daftar Sebagai Penjual"
- Same userId (email) can be both seller and driver simultaneously

## Files Created/Modified

### New Files

1. `lib/models/driver_model.dart` - Driver data model
2. `lib/providers/driver_provider.dart` - Driver state management
3. `lib/pages/driver_registration_page.dart` - Registration form
4. `lib/pages/driver_dashboard_page.dart` - Main driver interface

### Modified Files

1. `lib/providers/order_provider.dart` - Added loadAllOrders() method
2. `lib/routes/app_routes.dart` - Added driver routes
3. `lib/routes/app_pages.dart` - Registered driver pages
4. `lib/pages/profile_page.dart` - Added driver menu item
5. `lib/main.dart` - Registered DriverProvider

## Future Enhancements

### Potential Improvements

- Real-time location tracking with Google Maps
- Push notifications for new order alerts
- Driver ratings and reviews
- Earnings dashboard
- Order history with statistics
- Distance-based order suggestions
- Delivery time estimation
- In-app chat with customers
- Photo proof of delivery
- Multiple order handling (batch delivery)

## Troubleshooting

### Issue: Orders not showing in "Pesanan Baru"

**Solution:** Verify orders in Firestore have:

- `status: 'confirmed'`
- `driverId: null` or field doesn't exist

### Issue: Can't accept order

**Solution:** Check:

- Driver status is 'available' (Online toggle is ON)
- Order hasn't been accepted by another driver
- Firestore permissions allow write access

### Issue: Order stuck in "Sedang Diantar"

**Solution:**

- Click "Selesaikan Pengiriman" to complete
- Verify Firestore write permissions
- Check network connection

### Issue: Driver registration fails

**Solution:**

- Ensure userId (email) is being passed correctly
- Check Firestore 'drivers' collection permissions
- Verify all required fields are filled

## Summary

The driver system is now fully integrated with the FoodBridge app. Drivers can:

- Register through the profile page
- View available orders in real-time
- Accept and complete deliveries
- Manage their online/offline status

The system seamlessly connects with existing order management, allowing for smooth delivery operations from order placement to completion.
