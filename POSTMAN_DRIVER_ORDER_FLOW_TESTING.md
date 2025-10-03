# 🚚 Driver Order Flow Testing with Postman

## 📋 Project Information
- **Firebase Project ID**: `jippymart-27c08`
- **Orders Collection**: `restaurant_orders`
- **Users Collection**: `users`

## 🔄 Order Status Flow (Based on Your Codebase)

| Step | Status Constant | Status Value | Description |
|------|----------------|--------------|-------------|
| 1 | `driverPending` | `"Driver Pending"` | Order waiting for driver acceptance |
| 2 | `driverAccepted` | `"Driver Accepted"` | Driver accepted the order |
| 3 | `orderShipped` | `"Order Shipped"` | Order accepted, ready for pickup |
| 4 | `orderInTransit` | `"In Transit"` | Order picked up, in delivery |
| 5 | `orderCompleted` | `"Order Completed"` | Order delivered successfully |

## 🔐 Prerequisites

### 1. Get Firebase Auth Token
```bash
# Option 1: Using Firebase CLI
firebase login:ci

# Option 2: From your Flutter app (debug)
# Add this code temporarily to get the token:
firebase.auth().currentUser.getIdToken().then((token) {
  print('ID Token: $token');
});
```

### 2. Set Environment Variables in Postman
Create a Postman environment with these variables:
- `firebase_project_id`: `jippymart-27c08`
- `firebase_auth_token`: Your Firebase ID token
- `test_order_id`: A test order ID from your Firestore
- `test_driver_id`: A test driver ID from your Firestore

## 🧪 Postman Test Collection

### ✅ 1. Get Order Details (GET)

**Request:**
```
GET https://firestore.googleapis.com/v1/projects/{{firebase_project_id}}/databases/(default)/documents/restaurant_orders/{{test_order_id}}
```

**Headers:**
```
Authorization: Bearer {{firebase_auth_token}}
Content-Type: application/json
```

**Expected Response:**
```json
{
  "name": "projects/jippymart-27c08/databases/(default)/documents/restaurant_orders/{{test_order_id}}",
  "fields": {
    "status": {
      "stringValue": "Driver Pending"
    },
    "driverID": {
      "stringValue": "{{test_driver_id}}"
    },
    "id": {
      "stringValue": "{{test_order_id}}"
    }
  }
}
```

### ✅ 2. Update Order Status - Driver Accepted (PATCH)

**Request:**
```
PATCH https://firestore.googleapis.com/v1/projects/{{firebase_project_id}}/databases/(default)/documents/restaurant_orders/{{test_order_id}}?updateMask.fieldPaths=status&updateMask.fieldPaths=driverID&updateMask.fieldPaths=driver
```

**Headers:**
```
Authorization: Bearer {{firebase_auth_token}}
Content-Type: application/json
```

**Body:**
```json
{
  "fields": {
    "status": {
      "stringValue": "Driver Accepted"
    },
    "driverID": {
      "stringValue": "{{test_driver_id}}"
    },
    "driver": {
      "mapValue": {
        "fields": {
          "id": {
            "stringValue": "{{test_driver_id}}"
          },
          "firstName": {
            "stringValue": "Test Driver"
          },
          "phoneNumber": {
            "stringValue": "+1234567890"
          }
        }
      }
    }
  }
}
```

### ✅ 3. Update Order Status - Order Shipped (PATCH)

**Request:**
```
PATCH https://firestore.googleapis.com/v1/projects/{{firebase_project_id}}/databases/(default)/documents/restaurant_orders/{{test_order_id}}?updateMask.fieldPaths=status
```

**Headers:**
```
Authorization: Bearer {{firebase_auth_token}}
Content-Type: application/json
```

**Body:**
```json
{
  "fields": {
    "status": {
      "stringValue": "Order Shipped"
    }
  }
}
```

### ✅ 4. Update Order Status - In Transit (PATCH)

**Request:**
```
PATCH https://firestore.googleapis.com/v1/projects/{{firebase_project_id}}/databases/(default)/documents/restaurant_orders/{{test_order_id}}?updateMask.fieldPaths=status
```

**Headers:**
```
Authorization: Bearer {{firebase_auth_token}}
Content-Type: application/json
```

**Body:**
```json
{
  "fields": {
    "status": {
      "stringValue": "In Transit"
    }
  }
}
```

### ✅ 5. Update Order Status - Order Completed (PATCH)

**Request:**
```
PATCH https://firestore.googleapis.com/v1/projects/{{firebase_project_id}}/databases/(default)/documents/restaurant_orders/{{test_order_id}}?updateMask.fieldPaths=status
```

**Headers:**
```
Authorization: Bearer {{firebase_auth_token}}
Content-Type: application/json
```

**Body:**
```json
{
  "fields": {
    "status": {
      "stringValue": "Order Completed"
    }
  }
}
```

## 🔍 Test Scripts for Postman

### Pre-request Script (for all requests):
```javascript
// Set timestamp for testing
pm.environment.set("timestamp", new Date().toISOString());
```

### Test Script (for all requests):
```javascript
// Verify response status
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Verify response has fields
pm.test("Response has fields", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('fields');
});

// Log the current status
pm.test("Log order status", function () {
    const jsonData = pm.response.json();
    if (jsonData.fields && jsonData.fields.status) {
        console.log("Current order status:", jsonData.fields.status.stringValue);
    }
});
```

## 🎯 Complete Test Flow

### Step 1: Create Test Order (if needed)
```bash
# First, create a test order in Firestore with status "Driver Pending"
# You can do this manually in Firebase Console or via your app
```

### Step 2: Run Status Updates in Sequence
1. **Driver Accepted** → Should show "Reached restaurant for Pickup" button
2. **Order Shipped** → Should show "Reached restaurant for Pickup" button  
3. **In Transit** → Should show "Reached Customer" button
4. **Order Completed** → Should show completion screen

## 🐛 Debugging Tips

### 1. Check Order Document Structure
```bash
# Verify the order document has all required fields:
- id: string
- status: string  
- driverID: string
- driver: map (driver details)
- author: map (customer details)
- vendor: map (restaurant details)
- products: array
- createdAt: timestamp
```

### 2. Monitor Real-time Updates
Use Firebase Console to watch the `restaurant_orders` collection in real-time while testing.

### 3. Check Driver Document
Verify the driver's `inProgressOrderID` array contains the test order ID.

## 📱 App Testing Checklist

After each Postman request, verify in your Flutter app:

- [ ] Order status updates correctly
- [ ] UI buttons change as expected
- [ ] Driver's order list updates
- [ ] Notifications are sent (if configured)
- [ ] Map navigation updates (if applicable)

## 🚨 Common Issues & Solutions

### Issue: Button not appearing after status update
**Solution:** Check if the order status exactly matches the constants in your code:
- `"Driver Pending"` (not "driver_pending")
- `"Order Shipped"` (not "order_shipped")
- `"In Transit"` (not "in_transit")

### Issue: Firestore permission denied
**Solution:** Ensure your Firebase Auth token has proper Firestore read/write permissions.

### Issue: Order not found
**Solution:** Verify the order ID exists in the `restaurant_orders` collection.

## 📊 Expected UI Flow

1. **"Driver Pending"** → Accept/Reject buttons
2. **"Driver Accepted"** → "Reached restaurant for Pickup" button
3. **"Order Shipped"** → "Reached restaurant for Pickup" button
4. **"In Transit"** → "Reached Customer" button
5. **"Order Completed"** → Completion screen

## 🎉 Success Criteria

✅ Order status updates correctly in Firestore  
✅ App UI responds to status changes  
✅ Driver can progress through all order stages  
✅ No errors in app console  
✅ Real-time updates work properly  

---

**Need Help?** Share your specific error messages or unexpected behavior, and I'll help you debug further! 🚀 