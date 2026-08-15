# KOK.AI Frontend API Integration Guide

This document is for Flutter/mobile/frontend engineers integrating with the KOK.AI backend.

> **Backend implementation notice (2026-08-15):** This is a legacy frontend guide. For the current tree-registration flow and the Kindwise Plant.id v3 boundary, implement `docs/KOKAI_BACKEND_KINDWISE_IMPLEMENTATION_SPEC.md` together with `docs/KOKAI_MOBILE_BACKEND_CONTRACT.md`. Where they differ from this file, those two documents take precedence.

Base URL (local):
- `http://localhost:8000`

Mobile note:
- Android emulator should use `http://10.0.2.2:8000/api/v1`
- Physical devices must use your computer/server LAN IP, for example `http://192.168.1.50:8000/api/v1`
- APK builds can be pointed at that server with `--dart-define=API_BASE_URL=http://192.168.1.50:8000/api/v1`

API prefix:
- `/api/v1`

OpenAPI/Swagger:
- `http://localhost:8000/docs`

---

## 1. Global API Rules

### 1.1 Response envelope
All backend responses use this envelope:

```json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": null
}
```

Error envelope:

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "string_code",
    "message": "human readable message",
    "details": null
  },
  "meta": null
}
```

### 1.2 Authentication
Use Bearer token on protected endpoints:

```http
Authorization: Bearer <access_token>
```

### 1.3 Idempotency
Supported for create endpoints (recommended):
- `POST /trees/register`
- `POST /social/posts`

Header:

```http
Idempotency-Key: <unique-client-key>
```

If same key + same payload is retried, backend replays prior safe response.

### 1.4 Pagination
Cursor pagination list format:

```json
"meta": {
  "cursor": null,
  "next_cursor": "...",
  "limit": 20
}
```

Pass returned `next_cursor` as `cursor` query in next request.

---

## 2. Flutter Upload Integration (Critical)

Do NOT send local device paths as final URLs.

Correct flow:
1. Upload files to backend via `/uploads/images` or `/uploads/images/batch`.
2. Receive hosted uploaded asset metadata (including `id`).
3. Use upload IDs when creating trees/posts via JSON flow.

### 2.1 Upload single image
`POST /api/v1/uploads/images`

Request:
- `multipart/form-data`
- field: `file`

Response `data`:
```json
{
  "id": "uuid",
  "url": "http://...",
  "content_type": "image/jpeg",
  "file_name": "front.jpg",
  "file_size": 12345,
  "created_at": "2026-03-08T12:00:00Z"
}
```

### 2.2 Upload batch
`POST /api/v1/uploads/images/batch`
- `multipart/form-data`
- field: `files` (repeat for multiple files)

### 2.3 Get uploaded asset
`GET /api/v1/uploads/{upload_id}`

---

## 3. Authentication Endpoints

## 3.1 Register
`POST /api/v1/auth/register`

Body:
```json
{
  "email": "user@example.com",
  "username": "user001",
  "password": "Passw0rd123",
  "full_name": "User Name"
}
```

Response `data`:
```json
{
  "access_token": "...",
  "refresh_token": "...",
  "token_type": "bearer"
}
```

## 3.2 Login
`POST /api/v1/auth/login`

Body:
```json
{
  "email": "user@example.com",
  "password": "Passw0rd123"
}
```

## 3.3 Refresh token
`POST /api/v1/auth/refresh`

Body:
```json
{
  "refresh_token": "..."
}
```

## 3.4 Logout
`POST /api/v1/auth/logout`

Body:
```json
{
  "refresh_token": "..."
}
```

## 3.5 Current auth user
`GET /api/v1/auth/me`

---

## 4. Users & Profile

## 4.1 Users
- `GET /api/v1/users/me`
- `PATCH /api/v1/users/me`
- `GET /api/v1/users/{user_id}`
- `GET /api/v1/users/{user_id}/followers`
- `GET /api/v1/users/{user_id}/following`
- `POST /api/v1/users/{user_id}/follow`
- `DELETE /api/v1/users/{user_id}/follow`

`PATCH /users/me` body:
```json
{
  "full_name": "Updated Name",
  "bio": "Text",
  "avatar_url": "https://..."
}
```

## 4.2 Profile
- `GET /api/v1/profile/me/stats`
- `GET /api/v1/profile/me/achievements`
- `GET /api/v1/profile/me/posts`
- `GET /api/v1/profile/me/liked-posts`
- `GET /api/v1/profile/me/settings`
- `PATCH /api/v1/profile/me/settings`

`PATCH /profile/me/settings` body:
```json
{
  "privacy_profile_public": true,
  "notifications_enabled": true
}
```

## 4.3 Localization
- `GET /api/v1/localization/languages`
- `PATCH /api/v1/profile/me/localization`

Body:
```json
{
  "language_code": "en"
}
```

Supported codes only:
- `en`
- `ru`
- `uz`

---

## 5. Trees Module

## 5.1 Register tree (JSON flow with upload IDs)
`POST /api/v1/trees/register`

Body:
```json
{
  "name": "Oak near school",
  "location": {
    "latitude": 41.2995,
    "longitude": 69.2401,
    "accuracy_meters": 5
  },
  "images": {
    "front": "<upload_uuid>",
    "trunk": "<upload_uuid>",
    "leaves": "<upload_uuid>"
  },
  "captured_at": "2026-03-08T10:00:00Z"
}
```

## 5.2 Register tree (multipart flow)
Same endpoint: `POST /api/v1/trees/register`

`multipart/form-data` fields:
- `name`
- `latitude`
- `longitude`
- `accuracy_meters`
- `captured_at` (ISO string)
- `front` (file)
- `trunk` (file)
- `leaves` (file)

## 5.3 List trees
`GET /api/v1/trees`

Query params:
- `cursor`
- `limit`
- `sort` (`newest` or `oldest`)
- `status`
- `owner_id`
- `q`

## 5.4 Tree detail
`GET /api/v1/trees/{tree_id}`

## 5.5 Tree update
`PATCH /api/v1/trees/{tree_id}`

Body:
```json
{
  "name": "New tree name"
}
```

## 5.6 Tree map
`GET /api/v1/trees/map`

Option A (bbox):
- `bbox=min_lng,min_lat,max_lng,max_lat`
- optional `status`

Option B (center+radius):
- `center=lat,lng`
- `radius=meters`
- optional `status`

## 5.7 Tree timeline
`GET /api/v1/trees/{tree_id}/timeline`

## 5.8 Verify tree (moderator/admin)
`POST /api/v1/trees/{tree_id}/verify`

Body:
```json
{
  "note": "Looks correct"
}
```

## 5.9 Tree related posts
`GET /api/v1/trees/{tree_id}/posts`

---

## 6. Social Module

## 6.1 Create post (JSON)
`POST /api/v1/social/posts`

Body (recommended):
```json
{
  "content": "Great tree!",
  "upload_id": "<upload_uuid>",
  "location": {
    "latitude": 41.2995,
    "longitude": 69.2401
  },
  "created_at": "2026-03-08T10:10:00Z"
}
```

Compatibility body accepted:
```json
{
  "content": "Great tree!",
  "image_path": "<upload_uuid_or_null>",
  "location": {
    "latitude": 41.2995,
    "longitude": 69.2401
  },
  "created_at": "2026-03-08T10:10:00Z"
}
```

Important:
- Local device file path in `image_path` is rejected.
- Use upload ID from uploads API.

## 6.2 Create post (multipart)
`POST /api/v1/social/posts`

`multipart/form-data` fields:
- `content`
- `created_at`
- optional `latitude`
- optional `longitude`
- optional `image` (file)

## 6.3 List posts
`GET /api/v1/social/posts`

Query params:
- `cursor`
- `limit`
- `user_id`
- `near=lat,lng,radius_meters`

## 6.4 Post detail
`GET /api/v1/social/posts/{post_id}`

## 6.5 Update post
`PATCH /api/v1/social/posts/{post_id}`

Body:
```json
{
  "content": "Updated content"
}
```

## 6.6 Delete post
`DELETE /api/v1/social/posts/{post_id}`
(soft delete)

## 6.7 Likes
- `POST /api/v1/social/posts/{post_id}/likes`
- `DELETE /api/v1/social/posts/{post_id}/likes`
- `GET /api/v1/social/posts/{post_id}/likes`

## 6.8 Comments
- `POST /api/v1/social/posts/{post_id}/comments`
- `GET /api/v1/social/posts/{post_id}/comments`
- `DELETE /api/v1/social/comments/{comment_id}`

Create comment body:
```json
{
  "content": "Nice one"
}
```

---

## 7. Notifications

- `GET /api/v1/notifications`
- `PATCH /api/v1/notifications/{notification_id}/read`
- `PATCH /api/v1/notifications/read-all`

---

## 8. Common integration errors to handle on frontend

- `401` invalid/expired access token
- `403` forbidden (ownership/role mismatch)
- `409` idempotency conflict or duplicate like/follow
- `413` uploaded file too large
- `415` unsupported image MIME type
- `422` validation errors (check `error.details`)

Always parse `error.code` for deterministic client-side behavior.

---

## 9. Suggested Flutter client architecture

- `AuthRepository`
  - stores `access_token` + `refresh_token` securely
  - on 401, try refresh once then retry original request
- `UploadRepository`
  - upload files first, return `upload_id`
- `TreeRepository`
  - create register payload using upload IDs
- `SocialRepository`
  - create posts with `upload_id`
- `ApiClient`
  - inject auth header
  - supports idempotency key for create operations

---

## 10. Endpoint quick checklist for frontend

Auth:
- [ ] register/login/refresh/logout/me integrated

Uploads:
- [ ] single upload
- [ ] batch upload
- [ ] upload detail by id

Trees:
- [ ] register JSON flow
- [ ] register multipart fallback
- [ ] list + cursor pagination
- [ ] map bbox/near filters
- [ ] detail/timeline/posts

Social:
- [ ] create/list/detail/update/delete
- [ ] likes add/remove/list
- [ ] comments add/list/delete

Profile/Users:
- [ ] me/profile/settings/localization
- [ ] follow/unfollow/followers/following

Notifications:
- [ ] list/read/read-all

---

## 11. Useful cURL snippets

Login:
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"alice@example.com","password":"Passw0rd123"}'
```

Upload:
```bash
curl -X POST http://localhost:8000/api/v1/uploads/images \
  -H "Authorization: Bearer $ACCESS" \
  -F "file=@/tmp/front.jpg"
```

Tree register:
```bash
curl -X POST http://localhost:8000/api/v1/trees/register \
  -H "Authorization: Bearer $ACCESS" \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: reg-tree-001' \
  -d '{
    "name":"City Oak",
    "location":{"latitude":41.29,"longitude":69.24,"accuracy_meters":4},
    "images":{"front":"<id>","trunk":"<id>","leaves":"<id>"},
    "captured_at":"2026-03-08T12:00:00Z"
  }'
```

Social create:
```bash
curl -X POST http://localhost:8000/api/v1/social/posts \
  -H "Authorization: Bearer $ACCESS" \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: social-post-001' \
  -d '{
    "content":"New tree found",
    "upload_id":"<id>",
    "location":{"latitude":41.29,"longitude":69.24},
    "created_at":"2026-03-08T12:05:00Z"
  }'
```
