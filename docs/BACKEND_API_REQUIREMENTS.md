# Namma Taxi – Driver App | Backend API Requirements

**Document Version:** 1.0  
**Date:** March 2025  
**Base URL:** `https://api.nammataxi.com/v1`  
**WebSocket URL:** `wss://api.nammataxi.com/ws/driver`

---

## Authentication

| Header | Value |
|--------|-------|
| `Authorization` | `Bearer <access_token>` |
| `Content-Type` | `application/json` |
| `Accept` | `application/json` |

---

# 1️⃣ AUTH MODULE

---

## 1.1 Google Sign-In

| Field | Value |
|-------|-------|
| **API Name** | Google Authentication |
| **Endpoint** | `POST /auth/google` |
| **Method** | POST |
| **Auth Required** | No |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "id_token": "string"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id_token | string | Yes | Google ID token from `GoogleSignIn.signIn().authentication.idToken` |

**Response Payload (200):**
```json
{
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "photo_url": "string|null",
    "phone": "string|null",
    "is_verified": false,
    "created_at": "2025-03-10T12:00:00.000Z"
  },
  "access_token": "string",
  "refresh_token": "string"
}
```

**Error Responses:**
- `401` – Invalid or expired ID token
- `422` – Validation error

---

## 1.2 Email/Password Login

| Field | Value |
|-------|-------|
| **API Name** | Email Login |
| **Endpoint** | `POST /auth/login` |
| **Method** | POST |
| **Auth Required** | No |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response Payload (200):**
```json
{
  "user": { "id": "string", "email": "string", "name": "string", "photo_url": null, "phone": null, "is_verified": false, "created_at": "ISO8601" },
  "access_token": "string",
  "refresh_token": "string"
}
```

---

## 1.3 Register (Email/Password)

| Field | Value |
|-------|-------|
| **API Name** | Driver Registration |
| **Endpoint** | `POST /auth/register` |
| **Method** | POST |
| **Auth Required** | No |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "email": "string",
  "password": "string",
  "name": "string"
}
```

**Response Payload (200):**
```json
{
  "user": { "id": "string", "email": "string", "name": "string", "photo_url": null, "phone": null, "is_verified": false, "created_at": "ISO8601" },
  "access_token": "string",
  "refresh_token": "string"
}
```

---

## 1.4 Refresh Token

| Field | Value |
|-------|-------|
| **API Name** | Refresh Access Token |
| **Endpoint** | `POST /auth/refresh` |
| **Method** | POST |
| **Auth Required** | No |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "refresh_token": "string"
}
```

**Response Payload (200):**
```json
{
  "access_token": "string",
  "refresh_token": "string"
}
```

**Notes:** Called automatically by `AuthInterceptor` on 401 to retry failed requests.

---

## 1.5 Logout

| Field | Value |
|-------|-------|
| **API Name** | Logout |
| **Endpoint** | `POST /auth/logout` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:** Empty body or `{}`

**Response Payload (200):**
```json
{}
```

**Notes:** Backend should invalidate refresh token if token blacklisting is used.

---

# 2️⃣ DRIVER PROFILE MODULE

---

## 2.1 Get Driver Profile

| Field | Value |
|-------|-------|
| **API Name** | Get Driver Profile |
| **Endpoint** | `GET /driver/profile` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:** None

**Response Payload (200):**
```json
{
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "photo_url": "string|null",
    "phone": "string|null",
    "is_verified": false,
    "created_at": "2025-03-10T12:00:00.000Z"
  }
}
```

---

## 2.2 Update Driver Details

| Field | Value |
|-------|-------|
| **API Name** | Update Driver Profile |
| **Endpoint** | `PUT /driver/profile` |
| **Method** | PUT |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Request Payload:**
```json
{
  "name": "string",
  "phone": "string"
}
```

**Response Payload (200):**
```json
{
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "photo_url": null,
    "phone": "string|null",
    "is_verified": false,
    "created_at": "ISO8601"
  }
}
```

**Note:** Frontend does not yet call this; prepare for profile edit screen.

---

## 2.3 Upload Documents

| Field | Value |
|-------|-------|
| **API Name** | Upload Driver Document |
| **Endpoint** | `POST /driver/documents` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Request Payload:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| document_type | string | Yes | `license`, `vehicle_registration`, `insurance` |
| file | file | Yes | Image or PDF |

**Response Payload (200):**
```json
{
  "document_id": "string",
  "document_type": "license",
  "status": "pending_review",
  "uploaded_at": "2025-03-10T12:00:00.000Z"
}
```

**Note:** Frontend does not yet implement document upload; prepare for onboarding flow.

---

## 2.4 Driver Verification Status

| Field | Value |
|-------|-------|
| **API Name** | Get Verification Status |
| **Endpoint** | `GET /driver/verification` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Response Payload (200):**
```json
{
  "status": "pending|approved|rejected",
  "documents": [
    { "type": "license", "status": "approved", "reviewed_at": "ISO8601" },
    { "type": "vehicle_registration", "status": "pending", "uploaded_at": "ISO8601" }
  ]
}
```

---

# 3️⃣ DRIVER STATUS MODULE

---

## 3.1 Go Online / Go Offline

| Field | Value |
|-------|-------|
| **API Name** | Update Driver Status |
| **Endpoint** | `POST /driver/status` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "status": "online"
}
```
or
```json
{
  "status": "offline"
}
```

**Response Payload (200):**
```json
{
  "status": "online",
  "updated_at": "2025-03-10T12:00:00.000Z"
}
```

**Notes:** Called when driver toggles online/offline. Backend should update driver availability and manage WebSocket room membership.

---

## 3.2 Update Driver Location (REST fallback)

| Field | Value |
|-------|-------|
| **API Name** | Update Driver Location (REST) |
| **Endpoint** | `POST /driver/location` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Request Payload:**
```json
{
  "latitude": 12.9716,
  "longitude": 77.5946,
  "heading": 45.0,
  "timestamp": "2025-03-10T12:00:00.000Z"
}
```

**Response Payload (200):**
```json
{
  "received": true
}
```

**Note:** Frontend primarily sends location via WebSocket. REST endpoint useful as fallback or for batch updates.

---

## 3.3 Heartbeat Ping

| Field | Value |
|-------|-------|
| **API Name** | Driver Heartbeat |
| **Endpoint** | `POST /driver/heartbeat` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Request Payload:** Empty or minimal `{}`

**Response Payload (200):**
```json
{
  "timestamp": "2025-03-10T12:00:00.000Z"
}
```

**Note:** WebSocket ping/pong may be used instead; backend can infer heartbeat from WebSocket activity.

---

# 4️⃣ RIDES MODULE

---

## 4.1 Fetch Nearby Rides (REST)

| Field | Value |
|-------|-------|
| **API Name** | Get Available Rides |
| **Endpoint** | `GET /rides/available` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| lat | number | Yes | Driver latitude |
| lng | number | Yes | Driver longitude |
| radius | number | No | Search radius in km (default: 5) |

**Response Payload (200):**
```json
{
  "rides": [
    {
      "id": "string",
      "pickup_lat": 12.9716,
      "pickup_lng": 77.5946,
      "drop_lat": 12.9352,
      "drop_lng": 77.6245,
      "pickup_address": "string",
      "drop_address": "string",
      "distance_km": 4.2,
      "estimated_earnings": 120.50,
      "estimated_minutes": 15,
      "status": "available",
      "created_at": "2025-03-10T12:00:00.000Z",
      "passenger_name": "string|null"
    }
  ]
}
```

**Ride Status Values:** `available`, `accepted`, `pickingUp`, `inProgress`, `completed`, `cancelled`

---

## 4.2 Accept Ride

| Field | Value |
|-------|-------|
| **API Name** | Accept Ride |
| **Endpoint** | `POST /rides/accept` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "ride_id": "string"
}
```

**Response Payload (200):**
```json
{
  "id": "string",
  "pickup_lat": 12.9716,
  "pickup_lng": 77.5946,
  "drop_lat": 12.9352,
  "drop_lng": 77.6245,
  "pickup_address": "string",
  "drop_address": "string",
  "distance_km": 4.2,
  "estimated_earnings": 120.50,
  "estimated_minutes": 15,
  "status": "accepted",
  "created_at": "2025-03-10T12:00:00.000Z",
  "passenger_name": "string|null"
}
```

**Error Responses:**
- `400` – Ride no longer available, already accepted, or driver has insufficient credits
- `404` – Ride not found

---

## 4.3 Get Ride Details

| Field | Value |
|-------|-------|
| **API Name** | Get Ride Details |
| **Endpoint** | `GET /rides/{id}` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Path Parameters:** `id` – ride ID

**Response Payload (200):** Same structure as single ride in 4.1 / 4.2

---

## 4.4 Reject Ride

| Field | Value |
|-------|-------|
| **API Name** | Reject Ride |
| **Protocol** | WebSocket only |
| **MVP** | ✅ Critical |

**Note:** Frontend sends rejection via WebSocket (`ride_rejected`). No REST endpoint currently used. Backend should handle rejections in WebSocket handler.

---

## 4.5 Ride History

| Field | Value |
|-------|-------|
| **API Name** | Get Ride History |
| **Endpoint** | `GET /rides/history` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| page | int | No | Page number (default: 1) |
| limit | int | No | Items per page (default: 20) |
| status | string | No | Filter by status |

**Response Payload (200):**
```json
{
  "rides": [ /* same structure as 4.1 */ ],
  "total": 100,
  "page": 1
}
```

---

## 4.6 Start Trip

| Field | Value |
|-------|-------|
| **API Name** | Start Trip (Arrived at Pickup) |
| **Endpoint** | `POST /rides/{id}/start-pickup` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Request Payload:** Empty or `{}`

**Response Payload (200):**
```json
{
  "ride_id": "string",
  "status": "pickingUp",
  "updated_at": "ISO8601"
}
```

**Note:** Frontend currently updates trip phase locally. Backend API recommended for consistency.

---

## 4.7 Begin Trip (Passenger Picked Up)

| Field | Value |
|-------|-------|
| **API Name** | Begin Trip |
| **Endpoint** | `POST /rides/{id}/begin` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Request Payload:** Empty or `{}`

**Response Payload (200):**
```json
{
  "ride_id": "string",
  "status": "inProgress",
  "updated_at": "ISO8601"
}
```

---

## 4.8 End Trip / Complete Trip

| Field | Value |
|-------|-------|
| **API Name** | Complete Ride |
| **Endpoint** | `POST /rides/{id}/complete` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "drop_lat": 12.9352,
  "drop_lng": 77.6245,
  "final_distance_km": 4.5,
  "final_fare": 130.00
}
```

**Response Payload (200):**
```json
{
  "ride_id": "string",
  "status": "completed",
  "earnings": 130.00,
  "credits_deducted": 1,
  "updated_at": "ISO8601"
}
```

**Note:** Frontend uses `completeTrip()` locally; backend should receive completion to deduct credits and update earnings.

---

## 4.9 Cancel Trip

| Field | Value |
|-------|-------|
| **API Name** | Cancel Ride |
| **Endpoint** | `POST /rides/{id}/cancel` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Request Payload:**
```json
{
  "reason": "string",
  "cancelled_by": "driver"
}
```

**Response Payload (200):**
```json
{
  "ride_id": "string",
  "status": "cancelled",
  "updated_at": "ISO8601"
}
```

---

# 5️⃣ MAP & LOCATION MODULE

---

## 5.1 Fetch Nearby Ride Requests (REST fallback)

| Field | Value |
|-------|-------|
| **API Name** | Nearby Ride Requests |
| **Endpoint** | Same as 4.1 `GET /rides/available` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Note:** Frontend uses both REST (polling) and WebSocket. REST used for initial load and when WebSocket is disconnected.

---

## 5.2 Route API (Pickup → Drop)

| Field | Value |
|-------|-------|
| **API Name** | Route Calculation |
| **Provider** | Mapbox Directions API (external) |
| **MVP** | N/A (client-side) |

**Note:** Frontend uses Mapbox Directions API directly at  
`https://api.mapbox.com/directions/v5/mapbox/driving/{coords}?access_token=...`  
No backend route API required unless you want server-side route caching or custom logic.

---

## 5.3 Distance & ETA Calculation

| Field | Value |
|-------|-------|
| **API Name** | Distance/ETA |
| **Provider** | Mapbox or backend |
| **MVP** | Advanced |

**Optional Backend Endpoint:** `POST /map/distance`

**Request Payload:**
```json
{
  "origin": { "lat": 12.9716, "lng": 77.5946 },
  "destination": { "lat": 12.9352, "lng": 77.6245 }
}
```

**Response Payload (200):**
```json
{
  "distance_km": 4.2,
  "duration_minutes": 15,
  "eta": "2025-03-10T12:15:00.000Z"
}
```

---

# 6️⃣ WALLET & CREDITS MODULE

---

## 6.1 Get Wallet Balance

| Field | Value |
|-------|-------|
| **API Name** | Get Wallet Balance |
| **Endpoint** | `GET /wallet/balance` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Response Payload (200):**
```json
{
  "id": "string",
  "credits": 25,
  "updated_at": "2025-03-10T12:00:00.000Z"
}
```

---

## 6.2 Deduct Credits (per ride)

| Field | Value |
|-------|-------|
| **API Name** | Deduct Credits |
| **Endpoint** | Internal / called from ride completion |
| **MVP** | ✅ Critical |

**Note:** Frontend deducts 1 credit locally on accept; backend must deduct on ride completion and sync. Deduction should be idempotent for the same ride.

---

## 6.3 Add Credits (after payment)

| Field | Value |
|-------|-------|
| **API Name** | Add Credits |
| **Endpoint** | `POST /wallet/purchase` (called after Stripe success) |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "plan_id": "starter"
}
```

**Plan IDs:** `starter`, `pro`, `elite`

**Response Payload (200):**
```json
{
  "id": "string",
  "credits": 35,
  "updated_at": "2025-03-10T12:00:00.000Z"
}
```

**Note:** Only call after Stripe payment confirmed. Backend should validate payment before adding credits.

---

## 6.4 Transaction History

| Field | Value |
|-------|-------|
| **API Name** | Get Transactions |
| **Endpoint** | `GET /wallet/transactions` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| page | int | No | Page number |
| limit | int | No | Items per page |

**Response Payload (200):**
```json
{
  "transactions": [
    {
      "id": "string",
      "type": "purchase",
      "credits": 10,
      "description": "Purchased 10 credits",
      "created_at": "2025-03-10T12:00:00.000Z"
    }
  ]
}
```

**Transaction Types:** `purchase`, `rideAccepted`, `refund`, `bonus`

---

# 7️⃣ PAYMENT MODULE (STRIPE)

---

## 7.1 Create Payment Intent

| Field | Value |
|-------|-------|
| **API Name** | Create Stripe Payment Intent |
| **Endpoint** | `POST /payments/intent` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "amount": 999,
  "currency": "usd",
  "plan_id": "starter"
}
```

| Field | Type | Description |
|-------|------|-------------|
| amount | int | Amount in cents |
| currency | string | `usd` |
| plan_id | string | `starter`, `pro`, `elite` |

**Response Payload (200):**
```json
{
  "client_secret": "pi_xxx_secret_xxx",
  "payment_intent_id": "pi_xxx"
}
```

---

## 7.2 Confirm Payment (after Stripe Sheet success)

| Field | Value |
|-------|-------|
| **API Name** | Confirm Payment |
| **Endpoint** | `POST /payments/confirm` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "plan_id": "starter",
  "payment_intent_id": "pi_xxx"
}
```

**Response Payload (200):**
```json
{
  "success": true,
  "credits_added": 10,
  "new_balance": 25
}
```

**Error Responses:**
- `400` – Payment not completed or already confirmed
- `404` – Payment intent not found

---

## 7.3 Stripe Webhook

| Field | Value |
|-------|-------|
| **API Name** | Stripe Webhook |
| **Endpoint** | `POST /webhooks/stripe` |
| **Method** | POST |
| **Auth Required** | No (Stripe signature verification) |
| **MVP** | ✅ Critical |

**Headers:**
```
Stripe-Signature: <signature>
```

**Events to Handle:**
- `payment_intent.succeeded` – Add credits, update wallet
- `payment_intent.payment_failed` – Log, optionally notify user

**Note:** Use webhook as source of truth; `/payments/confirm` can be a lightweight confirmation after client-side success.

---

## 7.4 Credit Plans (Reference)

| Plan ID | Name | Credits | Price (cents) |
|---------|------|---------|--------------|
| starter | Starter Plan | 10 | 999 |
| pro | Pro Plan | 50 | 3999 |
| elite | Elite Plan | 100 | 6999 |

---

# 8️⃣ NOTIFICATIONS MODULE

---

## 8.1 Register FCM Token

| Field | Value |
|-------|-------|
| **API Name** | Register FCM Token |
| **Endpoint** | `POST /notifications/fcm` |
| **Method** | POST |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Request Payload:**
```json
{
  "fcm_token": "string"
}
```

**Response Payload (200):**
```json
{
  "registered": true,
  "updated_at": "ISO8601"
}
```

**Note:** Called on app init and on token refresh. Backend should upsert token per driver.

---

## 8.2 Send Push Notifications

| Field | Value |
|-------|-------|
| **API Name** | Send Push (backend-initiated) |
| **Provider** | Firebase Cloud Messaging |
| **MVP** | ✅ Critical |

**Data Payload Types (for `message.data`):**

| type | Description | data fields |
|------|--------------|-------------|
| ride_request | New ride request | ride_id, pickup_address, drop_address, fare, distance_km |
| payment_success | Payment completed | amount, credits_added |
| low_credits | Credits below threshold | credits, threshold |
| ride_cancelled | Ride cancelled | ride_id, reason |
| general | Generic notification | - |

---

# 9️⃣ EARNINGS MODULE

---

## 9.1 Get Driver Earnings

| Field | Value |
|-------|-------|
| **API Name** | Get Earnings Summary |
| **Endpoint** | `GET /driver/earnings` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | ✅ Critical |

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| period | string | Yes | `daily`, `weekly`, `monthly` |

**Response Payload (200):**
```json
{
  "today_earnings": 450.00,
  "weekly_earnings": 3200.00,
  "monthly_earnings": 12500.00,
  "total_rides": 156,
  "today_rides": 4,
  "weekly_rides": 28,
  "average_rating": 4.8,
  "average_earnings_per_ride": 115.25,
  "weekly_breakdown": [
    { "day": "Mon", "earnings": 520.00, "rides": 5 },
    { "day": "Tue", "earnings": 480.00, "rides": 4 }
  ],
  "recent_rides": [
    {
      "id": "string",
      "pickup_address": "string",
      "drop_address": "string",
      "earnings": 120.50,
      "distance_km": 4.2,
      "completed_at": "2025-03-10T12:00:00.000Z",
      "rating": 5.0
    }
  ]
}
```

---

## 9.2 Get Earnings History

| Field | Value |
|-------|-------|
| **API Name** | Get Earnings History |
| **Endpoint** | `GET /driver/earnings/history` |
| **Method** | GET |
| **Auth Required** | Yes |
| **MVP** | Advanced |

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| from | string | No | ISO8601 date |
| to | string | No | ISO8601 date |
| page | int | No | Page number |
| limit | int | No | Items per page |

**Response Payload (200):**
```json
{
  "rides": [ /* RideHistoryItem[] */ ],
  "total": 156,
  "page": 1
}
```

---

# 🔟 REAL-TIME SYSTEM (WebSocket)

---

## WebSocket Connection

| Field | Value |
|-------|-------|
| **URL** | `wss://api.nammataxi.com/ws/driver?token=<access_token>` |
| **Auth** | Query param `token` (access token) |
| **MVP** | ✅ Critical |

---

## Client → Server (Driver sends)

| Event | Payload | Description |
|-------|---------|-------------|
| `location_update` | `{ "type": "location_update", "lat": 12.97, "lng": 77.59, "heading": 45, "timestamp": "ISO8601" }` | Location update (every ~10s when online) |
| `ride_accepted` | `{ "type": "ride_accepted", "ride_id": "string" }` | Driver accepted ride |
| `ride_rejected` | `{ "type": "ride_rejected", "ride_id": "string" }` | Driver rejected ride |
| `driver_status` | `{ "type": "driver_status", "is_online": true }` | Online/offline status |
| `ping` | `{ "type": "ping" }` | Keep-alive (~every 30s) |

---

## Server → Client (Driver receives)

| Event | Payload | Description |
|------|---------|-------------|
| `ride_request` | `{ "type": "ride_request", "data": { "ride_id", "pickup_lat", "pickup_lng", "drop_lat", "drop_lng", "pickup_address", "drop_address", "fare", "distance_km", "estimated_minutes", "ride_type", "expires_at" } }` | New ride request |
| `ride_expired` | `{ "type": "ride_expired", "ride_id": "string" }` | Ride request timeout (e.g. 15s) |
| `ride_cancelled` | `{ "type": "ride_cancelled", "ride_id": "string" }` | Ride cancelled by passenger |
| `pong` | `{ "type": "pong" }` | Response to ping |

---

## ride_request data schema

```json
{
  "ride_id": "string",
  "pickup_lat": 12.9716,
  "pickup_lng": 77.5946,
  "drop_lat": 12.9352,
  "drop_lng": 77.6245,
  "pickup_address": "string",
  "drop_address": "string",
  "fare": 120.50,
  "distance_km": 4.2,
  "estimated_minutes": 15,
  "ride_type": "standard",
  "expires_at": "2025-03-10T12:00:15.000Z"
}
```

**Ride timeout:** Frontend expects `expires_at` ~15 seconds from request creation.

---

# EXTRA: Missing Backend Dependencies & Assumptions

---

## Missing / Assumed APIs

| Item | Status | Action |
|------|--------|--------|
| Start trip (arrived at pickup) | Not called from frontend | Add `POST /rides/{id}/start-pickup` |
| Begin trip (passenger picked up) | Not called from frontend | Add `POST /rides/{id}/begin` |
| Complete trip | Not called from frontend | Add `POST /rides/{id}/complete`; frontend to call |
| Cancel trip | Not called from frontend | Add `POST /rides/{id}/cancel` |
| Update driver profile | Not called from frontend | Add `PUT /driver/profile` |
| Document upload | Not implemented | Add `POST /driver/documents` |
| REST location update | Not used (WebSocket only) | Optional `POST /driver/location` fallback |

---

## Frontend Assumptions

1. **Credits:** 1 credit deducted per ride acceptance. Deduction happens locally; backend must deduct on ride completion and reconcile.
2. **Wallet response:** Expects `credits` as int, `id`, `updated_at`.
3. **Ride IDs:** Unique string IDs (UUID recommended).
4. **Timestamps:** ISO8601 format (`2025-03-10T12:00:00.000Z`).
5. **Token storage:** Access + refresh tokens stored securely; refresh used on 401.
6. **Base URL:** `https://api.nammataxi.com/v1`.
7. **WebSocket URL:** `wss://api.nammataxi.com/ws/driver`.
8. **Credit plans:** Hardcoded `starter`, `pro`, `elite` with fixed credits/prices. Backend should support configurable plans.
9. **Ride timeout:** 15 seconds for real-time requests; backend should set `expires_at` accordingly.

---

## Validation Rules (Recommendations)

| Field | Rules |
|-------|-------|
| email | Valid email format |
| password | Min 8 chars, strength rules |
| id_token | Valid JWT from Google |
| ride_id | Non-empty, exists, driver-eligible |
| lat/lng | -90 to 90, -180 to 180 |
| credits | Non-negative |
| amount | Positive, matches plan |
| plan_id | One of supported plan IDs |
| fcm_token | Non-empty string |
| period | `daily`, `weekly`, or `monthly` |

---

## MVP vs Advanced APIs

**MVP (Critical for launch):**
- Auth: Google, login, register, refresh, logout
- Profile: Get driver profile
- Status: Go online/offline
- Rides: Available, accept, details
- Wallet: Balance, purchase, transactions
- Payments: Create intent, confirm, Stripe webhook
- Notifications: Register FCM
- Earnings: Get earnings
- WebSocket: ride_request, ride_expired, ride_cancelled, location_update, ride_accepted, ride_rejected, driver_status, ping/pong

**Advanced (post-MVP):**
- Profile: Update, documents, verification
- Status: REST location, heartbeat
- Rides: History, start/begin/complete/cancel (if not in MVP)
- Map: Optional distance/ETA API
- Earnings: History with filters

---

*End of Document*
