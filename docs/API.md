# Shifter API

Base URL: `http://localhost:3000`

## Auth

### POST `/api/auth/send-otp`

```json
{ "countryCode": "+91", "phone": "9876543210" }
```

Response (development includes OTP):

```json
{ "message": "OTP sent successfully", "phone": "+919876543210", "devOtp": "1234" }
```

### POST `/api/auth/verify-otp`

```json
{ "countryCode": "+91", "phone": "9876543210", "otp": "1234" }
```

Response:

```json
{ "token": "<JWT>", "user": { "id": 1, "phone": "+919876543210", "name": null } }
```

## Catalog (Bearer token)

- `GET /api/catalog/transports`
- `GET /api/catalog/recent-locations`

## Bookings (Bearer token)

### POST `/api/bookings`

```json
{
  "transportCode": "mini_truck",
  "pickupAddress": "123 Main St",
  "dropoffAddress": "456 Park Ave",
  "senderName": "Alex",
  "senderPhone": "9876543210",
  "receiverName": "Sam",
  "receiverPhone": "9123456780",
  "receiverIsSelf": false,
  "vehicleBodyType": "open",
  "remarks": "Handle with care"
}
```

### GET `/api/bookings`

List recent bookings for the authenticated user.

## Health

- `GET /health`

Interactive docs: `http://localhost:3000/api/docs`
