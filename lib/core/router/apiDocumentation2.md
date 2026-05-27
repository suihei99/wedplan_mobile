# WebPlan API v1 Documentation

This document is a complete integration guide for the WebPlan mobile app. All endpoints below are rooted at `/api/v1`.

## Base URL

The Flutter app currently defaults to the hosted API at `https://wedplan.projectse.io/api/v1` and can be overridden with the `API_BASE_URL` compile-time environment variable.

Use your hosted app domain with the API prefix:

```text
https://your-domain.com/api/v1
```

For local development only:

```text
http://localhost:8000/api/v1
```

## Authentication

Most endpoints require a Sanctum bearer token. After login or registration, store the token and send it with all protected requests:

```http
Authorization: Bearer YOUR_SANCTUM_TOKEN
Accept: application/json
Content-Type: application/json
```

Note: Authentication responses (for example after `POST /auth/login` or `POST /auth/register/couple`) include a `user` object that already contains the related profile data. The user payload also includes `profile_photo_url` and the related raw `couple` or `vendor` model when that profile exists, so mobile clients can read profile data from a single response without making a second request.

## Common Response Pattern

### GET Requests (Retrieve Data)

Returns data wrapped in a `data` field:

```json
{
  "data": []
}
```

### POST Requests (Create)

Returns success message and created data:

```json
{
  "message": "Resource created successfully.",
  "data": {}
}
```

HTTP Status: `201 Created`

### PUT Requests (Update)

Returns success message and updated data:

```json
{
  "message": "Resource updated successfully.",
  "data": {}
}
```

HTTP Status: `200 OK`

### DELETE Requests

Returns success message only:

```json
{
  "message": "Resource deleted successfully."
}
```

HTTP Status: `200 OK`

### Validation Errors (422)

Laravel's default validation error response:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

## Public Endpoints

### Get Guest QR Data

`GET /api/v1/guest/qr/{code}`

Returns guest invitation data with QR image URL.

Example:

```http
GET /api/v1/guest/qr/ABC123
```

### Get Guest Invitation

`GET /api/v1/guest/invitation/{code}`

Returns detailed invitation information for guest check-in or RSVP.

Example:

```http
GET /api/v1/guest/invitation/INV12345
Accept: application/json
```

Successful response (200):

```json
{
  "data": {
    "invite_code": "INV12345",
    "guest_name": "Charlie Guest",
    "pax_count": 3,
    "rsvp_status": "pending",
    "couple": {
      "partner_1_name": "Adam",
      "partner_2_name": "Bella",
      "display_name": "Adam & Bella"
    },
    "wedding": {
      "venue": "Grand Ballroom",
      "date": "2026-12-25",
      "time": "18:30"
    },
    "checkin_url": "https://your-domain.com/guest/checkin/INV12345",
    "qr_image_url": "https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=..."
  }
}
```

Not found response (404):

```json
{
  "message": "Invitation not found."
}
```

### Update Guest RSVP (Public)

`PUT /api/v1/guest/rsvp/{code}`

Allows guests to update their RSVP status without authentication.

Request body:

```json
{
  "rsvp_status": "confirmed"
}
```

Valid values: `pending`, `confirmed`, `declined`

The app also sends `code` and, when available, `guest_name` so the backend can match the invitation record consistently.

Successful response (200):

```json
{
  "message": "RSVP updated successfully.",
  "data": {
    "id": 1,
    "name": "Charlie Guest",
    "phone": "+60111222333",
    "pax_count": 3,
    "rsvp_status": "confirmed",
    "invite_code": "INV12345",
    "created_at": "2026-05-17T10:30:00.000000Z",
    "updated_at": "2026-05-17T10:35:00.000000Z"
  }
}
```

### Public Guest Check-In

`POST /api/v1/guest/checkin/{code}`

Allows guests to check in without authentication.

Request body:

```json
{
  "code": "INV12345",
  "guest_name": "Charlie Guest"
}
```

The app sends `code` on every request and includes `guest_name` when it is available from the invitation form.

Successful response (200):

```json
{
  "data": {
    "id": 1,
    "name": "Charlie Guest",
    "checked_in_at": "2026-12-25T18:30:00.000000Z"
  }
}
```

## Authentication Endpoints

### Register Couple

`POST /api/v1/auth/register/couple`

Request body:

```json
{
  "email": "couple@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "partner_1_name": "Alya",
  "partner_2_name": "Haziq",
  "wedding_date": "2026-12-31",
  "wedding_venue": "Kuala Lumpur",
  "wedding_time": "19:30",
  "total_budget_limit": 50000
}
```

Notes:

- `password_confirmation` is required.
- `wedding_date`, `wedding_venue`, `wedding_time`, and `total_budget_limit` are optional.

Successful response (201):

```json
{
  "message": "Registration successful",
  "role": "couple",
  "token": "sanctum-token-here",
  "user": {
    "id": 1,
    "email": "couple@example.com",
    "role": "couple",
    "profile_photo_path": null,
    "is_active": true,
    "couple": {
      "id": 1,
      "partner_1_name": "Alya",
      "partner_2_name": "Haziq",
      "wedding_date": "2026-12-31",
      "wedding_time": "19:30",
      "wedding_venue": "Kuala Lumpur",
      "total_budget_limit": 50000,
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  }
}
```

Successful response (201):

```json
{
  "message": "Registration successful. Pending admin approval.",
  "user": {
    "id": 2,
    "email": "vendor@example.com",
    "role": "vendor",
    "profile_photo_path": null,
    "is_active": true
  }
}
```

Note: Vendor account will be inactive until admin approves the registration.
`business_documents` is stored on the public disk under `vendor-documents/` and is accessible through `/storage/...`.

The uploaded document must be a PDF, PNG, JPG, or JPEG file.

### Login

`POST /api/v1/auth/login`

Request body:

```json
{
  "email": "user@example.com",
  "password": "password123",
  "device_token": "firebase-device-token"
}
```

Note: The mobile app can send the Firebase device token during login. If present, the API stores it on the authenticated user for push notification delivery.

Successful response (200):

```json
{
  "message": "Login successful",
  "role": "couple",
  "token": "sanctum-token-here",
  "user": {
    "id": 1,
    "email": "couple@example.com",
    "role": "couple",
    "profile_photo_path": null,
    "is_active": true,
    "couple": {
      "id": 1,
      "partner_1_name": "Alya",
      "partner_2_name": "Haziq",
      "wedding_date": "2026-12-31",
      "wedding_time": "19:30",
      "wedding_venue": "Kuala Lumpur",
      "total_budget_limit": 50000,
      "display_name": "Alya & Haziq",
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  }
}
```

If `device_token` is included in the login request, it is saved to the authenticated user record but is not returned in the response payload.

For vendor login, the `vendor` object replaces `couple`:

```json
{
  "message": "Login successful",
  "role": "vendor",
  "token": "sanctum-token-here",
  "user": {
    "id": 2,
    "email": "vendor@example.com",
    "role": "vendor",
    "profile_photo_path": null,
    "is_active": true,
    "vendor": {
      "id": 1,
      "business_name": "Photography Plus",
      "business_type": "photography",
      "contact_number": "+60123456789",
      "address": "Kuala Lumpur, Malaysia",
      "status": "approved",
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  }
}
```

Error response (401):

```json
{
  "message": "Invalid credentials"
}
```

Vendor pending approval (403):

```json
{
  "message": "Vendor account is pending admin approval"
}
```

### Logout

`POST /api/v1/auth/logout`

Requires authentication.

Successful response (200):

```json
{
  "message": "Logged out successfully"
}
```

## Shared Authenticated Endpoints

These endpoints are available to all authenticated users (couple, vendor, admin).

### Get Settings

`GET /api/v1/settings`

Requires authentication.

Successful response (200):

```json
{
  "data": {
    "id": 1,
    "email": "vendor@example.com",
    "role": "vendor",
    "profile_photo_path": "profile-photos/avatar.jpg",
    "profile_photo_url": "https://wedplan.projectse.io/storage/profile-photos/avatar.jpg",
    "is_active": true,
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z"
  }
}
```

### Update Settings

`PUT /api/v1/settings`

Requires authentication.

Request body:

```json
{
  "email": "new-email@example.com",
  "device_token": "expo-push-token",
  "current_password": "current-password",
  "password": "new-password123",
  "password_confirmation": "new-password123",
  "profile_photo": "multipart file"
}
```

Notes:

- `device_token` stores the mobile push token for the authenticated user and is used for push notification delivery.
- `profile_photo` is only accepted for vendor accounts.
- `device_token` is optional and can be used for push notification registration.
- To change the password, send `current_password`, `password`, and `password_confirmation` together.
- The uploaded profile photo is stored on the public disk under `profile-photos/`.

Successful response (200):

```json
{
  "message": "Settings updated successfully.",
  "data": {
    "id": 1,
    "email": "new-email@example.com",
    "role": "vendor",
    "profile_photo_path": "profile-photos/avatar.jpg",
    "profile_photo_url": "https://wedplan.projectse.io/storage/profile-photos/avatar.jpg",
    "is_active": true,
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:05:00.000000Z"
  }
}
```

Note: The `device_token` field is stored on the authenticated user but is not returned in the `data` payload.

## Couple Endpoints

All couple endpoints require:

- Authentication via Sanctum token
- `role:couple` (enforced via middleware)

### Dashboard

`GET /api/v1/couple/dashboard`

Returns overview of couple's wedding planning progress.

Successful response (200):

```json
{
  "data": {
    "wedding_date": "December 25, 2026",
    "days_until_wedding": 213,
    "progress_percentage": 67,
    "tasks_done": 8,
    "tasks_total": 12,
    "upcoming_tasks": [
      {
        "title": "Confirm photographer",
        "due_date": "01 Aug 2026"
      }
    ],
    "guests_total": 45,
    "guests_confirmed": 40,
    "total_budget": 50000,
    "budget_spent": 15000,
    "budget_remaining": 35000,
    "budget_categories": [
      {
        "name": "Venue",
        "amount": 15000,
        "percentage": 30
      }
    ],
    "vendors_booked": 5,
    "vendors_pending": 2,
    "budget": {},
    "guests_summary": {}
  }
}
```

### Budget Categories

Get all budget categories with summary:

`GET /api/v1/couple/budget`

Successful response (200):

```json
{
  "data": {
    "total_budget_limit": 50000,
    "effective_budget_limit": 50000,
    "total_allocated": 45000,
    "total_spent": 15000,
    "remaining": 35000,
    "categories": [
      {
        "id": 1,
        "category_name": "Venue",
        "allocated_amount": 15000,
        "total_spent": 10000,
        "remaining_budget": 5000,
        "is_overspent": false,
        "overspent_amount": 0
      }
    ]
  }
}
```

Create budget category:

`POST /api/v1/couple/budget`

Request body:

```json
{
  "category_name": "Venue",
  "allocated_amount": 15000
}
```

Successful response (201):

```json
{
  "message": "Budget category created successfully.",
  "data": {
    "id": 1,
    "couple_id": 1,
    "category_name": "Venue",
    "allocated_amount": 15000,
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z"
  }
}
```

Get specific budget category:

`GET /api/v1/couple/budget/{budgetCategory}`

Successful response (200):

```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "category_name": "Venue",
    "allocated_amount": 15000,
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z"
  }
}
```

Update budget category:

`PUT /api/v1/couple/budget/{budgetCategory}`

Request body:

```json
{
  "category_name": "Venue - Updated",
  "allocated_amount": 18000
}
```

Successful response (200):

```json
{
  "message": "Budget category updated successfully.",
  "data": {
    "id": 1,
    "category_name": "Venue - Updated",
    "allocated_amount": 18000,
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:05:00.000000Z"
  }
}
```

Delete budget category:

`DELETE /api/v1/couple/budget/{budgetCategory}`

Successful response (200):

```json
{
  "message": "Budget category deleted successfully."
}
```

### Vendor List (for couples)

Get all vendor services available to couples (approved vendors only):

`GET /api/v1/couple/vendors`

Query params:
- `search` (optional) filter by business name
- `type_service` (optional) filter by the stored service category name, such as `Venue`, `Catering`, or `Photography`
- `per_page` (optional) number of items per page (default 100 in the current app integration)

Successful response (200):

```json
{
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "service_name": "Photography Package",
        "type_service": "Photography",
        "price_estimate": 4500,
        "description": "Full day wedding coverage",
        "image_url": "services/photo_1.jpg",
        "image_url_resolved": "https://your-domain.com/storage/services/photo_1.jpg",
        "user": {
          "id": 2,
          "email": "vendor@example.com",
          "vendor": {
            "business_name": "Photography Plus",
            "business_type": "photography",
            "contact_number": "+60123456789"
          }
        }
      }
    ],
    "last_page": 10
  }
}
```

Get vendor service details:

`GET /api/v1/couple/vendors/{service}`

Successful response (200):

```json
{
  "data": {
    "service": { /* service object */ },
    "vendor": { /* vendor object */ },
    "booking_dates": ["2026-09-10"]
  }
}
```

### Expenses

Get all expenses:

`GET /api/v1/couple/expenses`

Successful response (200):

```json
{
  "data": [
    {
      "id": 1,
      "budget_category_id": 1,
      "expense_name": "Hall deposit",
      "amount": 3000,
      "date_paid": "2026-06-01",
      "description": "Initial deposit for venue",
      "payment_method": "cash",
      "receipt_path": null,
      "receipt_url": null,
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  ]
}
```

Create expense:

`POST /api/v1/couple/expenses`

Request body (supports file upload):

```json
{
  "budget_category_id": 1,
  "expense_name": "Hall deposit",
  "amount": 3000,
  "date_paid": "2026-06-01",
  "description": "Initial deposit for venue",
  "payment_method": "cash"
}
```

Optional: Include `receipt` as a multipart file (`pdf`, `jpg`, `jpeg`, `png`)

Successful response (201):

```json
{
  "message": "Expense created successfully.",
  "data": {
    "id": 1,
    "budget_category_id": 1,
    "expense_name": "Hall deposit",
    "amount": 3000,
    "date_paid": "2026-06-01",
    "description": "Initial deposit for venue",
    "payment_method": "cash",
    "receipt": "receipts/expense_1.pdf",
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z"
  }
}
```

Get specific expense:

`GET /api/v1/couple/expenses/{expense}`

Update expense:

`PUT /api/v1/couple/expenses/{expense}`

Delete expense:

`DELETE /api/v1/couple/expenses/{expense}`

### Guests

Get all guests:

`GET /api/v1/couple/guests`

Successful response (200):

```json
{
  "data": [
    {
      "id": 1,
      "name": "Siti Ahmad",
      "phone": "+60123456789",
      "pax_count": 2,
      "rsvp_status": "pending",
      "invite_code": "INV12345",
      "qr_code_string": "INVITE:INV12345",
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  ]
}
```

Create guest:

`POST /api/v1/couple/guests`

Request body:

```json
{
  "name": "Siti Ahmad",
  "phone": "+60123456789",
  "pax_count": 2,
  "rsvp_status": "pending"
}
```

Successful response (201):

```json
{
  "message": "Guest created successfully.",
  "data": {
    "id": 1,
    "name": "Siti Ahmad",
    "phone": "+60123456789",
    "pax_count": 2,
    "rsvp_status": "pending",
    "invite_code": "INV12345",
    "qr_code_string": "INVITE:INV12345",
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z"
  }
}
```

Get specific guest:

`GET /api/v1/couple/guests/{guest}`

Update guest:

`PUT /api/v1/couple/guests/{guest}`

Request body:

```json
{
  "name": "Siti Ahmad Updated",
  "phone": "+60123456789",
  "pax_count": 3,
  "rsvp_status": "pending"
}
```

Update guest RSVP (authenticated):

`PUT /api/v1/couple/guests/{guest}/rsvp`

Request body:

```json
{
  "rsvp_status": "confirmed"
}
```

Valid values: `pending`, `confirmed`, `declined`

Guest check-in:

`POST /api/v1/couple/guests/{guest}/check-in`

Marks guest as checked in on wedding day.

Successful response (200):

```json
{
  "message": "Guest checked in successfully.",
  "data": {
    "id": 1,
    "name": "Siti Ahmad",
    "checked_in_at": "2026-12-25T18:30:00.000000Z"
  }
}
```

Delete guest:

`DELETE /api/v1/couple/guests/{guest}`

### Tasks

Get all tasks:

`GET /api/v1/couple/tasks`

Successful response (200):

```json
{
  "data": [
    {
      "id": 1,
      "task_name": "Confirm photographer",
      "description": "Call and finalize package",
      "deadline": "2026-08-01",
      "is_completed": false,
      "priority": 2,
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  ]
}
```

Create task:

`POST /api/v1/couple/tasks`

Request body:

```json
{
  "task_name": "Confirm photographer",
  "description": "Call and finalize package",
  "deadline": "2026-08-01",
  "is_completed": false,
  "priority": 2
}
```

Priority values: `0` (Low), `1` (Medium), `2` (High)

Successful response (201):

```json
{
  "message": "Task created successfully.",
  "data": {
    "id": 1,
    "task_name": "Confirm photographer",
    "description": "Call and finalize package",
    "deadline": "2026-08-01",
    "is_completed": false,
    "priority": 2,
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z"
  }
}
```

Get specific task:

`GET /api/v1/couple/tasks/{task}`

Update task:

`PUT /api/v1/couple/tasks/{task}`

Mark task as complete:

`PUT /api/v1/couple/tasks/{task}/complete`

Successful response (200):

```json
{
  "message": "Task marked as completed.",
  "data": {
    "id": 1,
    "task_name": "Confirm photographer",
    "is_completed": true,
    "completed_at": "2026-05-18T10:05:00.000000Z"
  }
}
```

Delete task:

`DELETE /api/v1/couple/tasks/{task}`

### AI Budget Assistant

Get initial budget estimate:

`POST /api/v1/couple/ai-budget/estimate`

Request body:

```json
{
  "guest_count": 250,
  "budget_range": "RM 25000 - RM 40000"
}
```

Supported `budget_range` values:

- `RM 10000 - RM 20000`
- `RM 25000 - RM 40000`
- `RM 2500 - RM 40000`
- `RM 50000 And Above`
- `None Of Above`

Successful response (200):

```json
{
  "success": true,
  "message": "For 250 guests with a budget of RM 25000 - RM 40000, we recommend..."
}
```

Chat with AI assistant:

`POST /api/v1/couple/ai-budget/chat`

Request body:

```json
{
  "message": "How should I split the budget for 250 guests?",
  "guest_count": 250,
  "budget_range": "RM 25000 - RM 40000"
}
```

Successful response (200):

```json
{
  "success": true,
  "message": "Based on 250 guests and your budget range of RM 25000 - RM 40000..."
}
```

Possible error responses:

- `429` with `success: false` and `rate_limited: true` when the AI limit is exceeded
- `503` with `success: false` and `offline: true` when the assistant is unavailable
- `500` with `success: false` for unexpected errors

## Vendor Endpoints

All vendor endpoints require:

- Authentication via Sanctum token
- `role:vendor` (enforced via middleware)
- Vendor account must be approved by admin

### Dashboard

`GET /api/v1/vendor/dashboard`

Returns overview of vendor's bookings and statistics.

Successful response (200):

```json
{
  "vendor": {
    "id": 1,
    "business_name": "Photography Plus",
    "business_type": "photography",
    "contact_number": "+60123456789",
    "status": "approved",
    "address": "Kuala Lumpur, Malaysia"
  },
  "dashboard": {
    "bookings_total": 12,
    "bookings_confirmed": 10,
    "bookings_pending": 2,
    "services_total": 5,
    "booking_dates": ["2026-09-10"]
  },
  "bookings": [],
  "services": []
}
```

### Services

Get all vendor services:

`GET /api/v1/vendor/services`

Successful response (200):

```json
{
  "data": [
    {
      "id": 1,
      "service_name": "Photography Package",
      "type_service": "photography",
      "price_estimate": 4500,
      "description": "Full day wedding coverage",
      "image_url": "services/photo_1.jpg",
      "image_url_resolved": "https://wedplan.projectse.io/storage/services/photo_1.jpg",
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  ]
}
```

Create service:

`POST /api/v1/vendor/services`

Request body (can include file upload):

```json
{
  "service_name": "Photography Package",
  "type_service": "photography",
  "price_estimate": 4500,
  "description": "Full day wedding coverage"
}
```

Optional: Include `image_url` as a multipart file (`jpg`, `jpeg`, `png`)

The uploaded file is stored on the public disk under `services/` and returned as `image_url_resolved`.

Successful response (201):

```json
{
  "message": "Service created successfully.",
  "data": {
    "id": 1,
    "service_name": "Photography Package",
    "type_service": "photography",
    "price_estimate": 4500,
    "description": "Full day wedding coverage",
    "image_url": null,
    "image_url_resolved": null,
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z"
  }
}
```

Get specific service:

`GET /api/v1/vendor/services/{service}`

Update service:

`PUT /api/v1/vendor/services/{service}`

Request body:

```json
{
  "service_name": "Photography Package - Updated",
  "type_service": "photography",
  "price_estimate": 5000,
  "description": "Full day wedding coverage with album"
}
```

Successful response (200):

```json
{
  "message": "Service updated successfully.",
  "data": {
    "id": 1,
    "service_name": "Photography Package - Updated",
    "type_service": "photography",
    "price_estimate": 5000,
    "description": "Full day wedding coverage with album",
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:05:00.000000Z"
  }
}
```

Delete service:

`DELETE /api/v1/vendor/services/{service}`

Successful response (200):

```json
{
  "message": "Service deleted successfully."
}
```

### Bookings

The current backend does not expose a dedicated vendor couples endpoint. The Flutter app keeps the booking add form aligned with the existing booking resources and still submits only `couple_id` when saving.

Get all vendor bookings:

`GET /api/v1/vendor/bookings`

Successful response (200):

```json
{
  "data": [
    {
      "id": 1,
      "couple_id": 5,
      "type_service": "photography",
      "booking_date": "2026-09-10",
      "status": true,
      "notes": "Morning session",
      "created_at": "2026-05-18T10:00:00.000000Z",
      "updated_at": "2026-05-18T10:00:00.000000Z"
    }
  ]
}
```

Create booking:

`POST /api/v1/vendor/bookings`

Request body:

```json
{
  "couple_id": 5,
  "type_service": "photography",
  "booking_date": "2026-09-10",
  "status": true,
  "notes": "Morning session"
}
```

Note: `status: true` means confirmed, `status: false` means pending.

Important: the API only needs `couple_id` in the request body. The backend stores that ID in the booking record. Flutter should not call a nonexistent vendor couples route.

Successful response (201):

```json
{
  "message": "Booking created successfully.",
  "data": {
    "id": 1,
    "couple_id": 5,
    "type_service": "photography",
    "booking_date": "2026-09-10",
    "status": true,
    "notes": "Morning session",
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:00:00.000000Z",
    "couple": {
      "id": 5,
      "email": "couple@example.com",
      "couple": {
        "id": 2,
        "partner_1_name": "Alya",
        "partner_2_name": "Haziq",
        "display_name": "Alya & Haziq"
      }
    }
  }
}
```

Get specific booking:

`GET /api/v1/vendor/bookings/{booking}`

Update booking:

`PUT /api/v1/vendor/bookings/{booking}`

Request body:

```json
{
  "booking_date": "2026-09-11",
  "status": true,
  "notes": "Updated notes"
}
```

Notes:

- The mobile app currently updates `booking_date`, `status`, and `notes`.
- `status: true` means confirmed, `status: false` means pending.
- The API may return the updated booking together with related couple resource data when available, including the couple email and nested profile display name.
- The booking form can show the couple label from that nested resource data, but it still submits `couple_id` when saving.

Successful response (200):

```json
{
  "message": "Booking updated successfully.",
  "data": {
    "id": 1,
    "couple_id": 5,
    "type_service": "photography",
    "booking_date": "2026-09-11",
    "status": true,
    "notes": "Updated notes",
    "created_at": "2026-05-18T10:00:00.000000Z",
    "updated_at": "2026-05-18T10:05:00.000000Z",
    "couple": {
      "id": 5,
      "email": "couple@example.com",
      "couple": {
        "id": 2,
        "partner_1_name": "Alya",
        "partner_2_name": "Haziq",
        "display_name": "Alya & Haziq"
      }
    }
  }
}
```

Delete booking:

`DELETE /api/v1/vendor/bookings/{booking}`

### Notifications

Get all vendor notifications:

`GET /api/v1/vendor/notifications`

Successful response (200):

```json
{
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "user_id": 2,
        "title": "New booking request",
        "message": "A couple has requested your service",
        "is_read": false,
        "created_at": "2026-05-18T10:00:00.000000Z",
        "updated_at": "2026-05-18T10:00:00.000000Z"
      }
    ],
    "last_page": 1
  }
}
```

Get specific notification:

`GET /api/v1/vendor/notifications/{notification}`

Mark notification as read:

`PUT /api/v1/vendor/notifications/{notification}/read`

Successful response (200):

```json
{
  "success": true,
  "message": "Notification marked as read.",
}
```

Delete notification:

`DELETE /api/v1/vendor/notifications/{notification}`

Successful response (200):

```json
{
  "message": "Notification deleted successfully."
}
```

## Couple Notification Endpoints

All couple notification endpoints require:

- Authentication via Sanctum token
- `role:couple` (enforced via middleware)

### Get Couple Notifications

`GET /api/v1/couple/notifications`

Successful response (200):

```json
{
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "user_id": 2,
        "title": "Booking Approved",
        "message": "Your venue booking has been approved.",
        "is_read": false,
        "created_at": "2026-05-18T10:00:00.000000Z",
        "updated_at": "2026-05-18T10:00:00.000000Z"
      }
    ],
    "last_page": 1
  }
}
```

### Get Specific Couple Notification

`GET /api/v1/couple/notifications/{notification}`

### Mark Couple Notification as Read

`PUT /api/v1/couple/notifications/{notification}/read`

Successful response (200):

```json
{
  "success": true,
  "message": "Notification marked as read."
}
```

### Delete Couple Notification

`DELETE /api/v1/couple/notifications/{notification}`

Successful response (200):

```json
{
  "message": "Notification deleted successfully."
}
```

## Error Codes

| Code | Status | Description |
|------|--------|-------------|
| `200` | OK | Successful GET, PUT, DELETE request |
| `201` | Created | Successful POST request |
| `400` | Bad Request | Invalid request format or parameters |
| `401` | Unauthorized | Missing or invalid authentication token |
| `403` | Forbidden | Insufficient permissions, role mismatch, or profile missing |
| `404` | Not Found | Resource not found |
| `422` | Validation Error | Invalid request data (see response for details) |
| `429` | Too Many Requests | Rate limit exceeded (e.g., AI assistant usage) |
| `500` | Server Error | Internal server error |
| `503` | Service Unavailable | AI assistant service unavailable |

### Example Error Response (401)

```json
{
  "message": "Unauthenticated."
}
```

### Example Error Response (403)

```json
{
  "message": "Couple profile not found."
}
```

## Current Response Notes

- Vendor service types are TitleCase values from `Venue`, `Catering`, `Photography`, `Makeup Artist`, `Wedding Planner`, `Bridal Wear`, `Decor & Styling`, `Entertainment`, `Transportation`, and `Other`.
- Booking `status` is a boolean in the API: `true` means confirmed and `false` means pending.
- Notification lists are paginated and return `user_id`, `title`, `message`, `is_read`, `created_at`, and `updated_at`.
- Notification lists are paginated for both vendor and couple APIs.
- `device_token` is accepted by `PUT /api/v1/settings` and stored on the authenticated user for push notification delivery.

- Booking forms should submit `couple_id` and can display couple name/email only when the existing booking payload already includes nested couple data.
- There is no dedicated `GET /api/v1/vendor/couples` route in the current backend.

### Example Error Response (404)

```json
{
  "message": "Not Found"
}
```

## Mobile Integration Tips

### Headers

Always include these headers with every request:

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer YOUR_SANCTUM_TOKEN
```

### File Uploads

For endpoints that accept file uploads (e.g., vendor registration, expense receipts, service images):

- Send as `multipart/form-data`
- Include all other fields along with the file
- Follow the field name specified in the endpoint documentation

Example with cURL:

```bash
curl -X POST https://your-domain.com/api/v1/auth/register/vendor \
  -H "Accept: application/json" \
  -F "email=vendor@example.com" \
  -F "password=password123" \
  -F "password_confirmation=password123" \
  -F "business_name=Photography Plus" \
  -F "business_type=photography" \
  -F "contact_number=+60123456789" \
  -F "address=Kuala Lumpur" \
  -F "business_documents=@document.pdf"
```

### Token Storage

- Store the Sanctum token securely on the mobile device (secure storage/keychain)
- Include it with every authenticated request
- Refresh or re-authenticate if the token expires
- Delete the token on logout

### Push Notification Token

- The app obtains the Firebase device token at startup with `FirebaseMessaging.getToken()`.
- The token is not part of the login request in the current integration.
- Send the token to the backend after authentication via `PUT /api/v1/settings` using the `device_token` field.

### Role-Based Routing

Note: The login/register response includes a `user` object with profile details. In Flutter access `response['user']['couple']` or `response['user']['vendor']` depending on `response['role']`.

Use the returned `role` from login/registration to route users:

```javascript
const response = await login(email, password);

switch(response.role) {
  case 'couple':
    navigate('/couple/dashboard');
    break;
  case 'vendor':
    navigate('/vendor/dashboard');
    break;
  case 'admin':
    navigate('/admin/dashboard');
    break;
}
```

### Handling Public Guest Endpoints

Guest invitation and RSVP endpoints are public and don't require authentication:

```javascript
// Get guest invitation without token
const invitation = await fetch('/api/v1/guest/invitation/INV12345');

// Update RSVP without authentication
const response = await fetch('/api/v1/guest/rsvp/INV12345', {
  method: 'PUT',
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ rsvp_status: 'confirmed' })
});
```

### Pagination & Filtering

List endpoints return all results. For large datasets, consider:

- Implementing client-side pagination
- Adding request parameters to the API (if needed for optimization)

### Date Format

All dates are ISO 8601 format with UTC timezone:

```
2026-12-25T18:30:00.000000Z
```

### Handling Validation Errors

Validation errors return HTTP `422` with detailed error messages:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."],
    "partner_1_name": ["The partner 1 name field is required."]
  }
}
```

Display these errors to the user to guide input correction.
