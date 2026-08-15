# KOK.AI Backend Contract Gaps

Version: 1.0  
Mobile review date: 2026-08-15  
Reviewed contract: `KOKAI_MOBILE_BACKEND_CONTRACT.md` version 1.1 / backend 1.1.0  
Audience: KOK.AI backend engineers

## Purpose

The Flutter client now integrates every endpoint documented in contract 1.1 that has a corresponding app flow. This document lists missing or underspecified backend capabilities that prevent the remaining product features from using real data.

The backend remains the only system allowed to call Kindwise Plant.id. None of the additions below should expose a Kindwise key or raw provider response to the mobile app.

## P0 — blocks an existing core flow

### 1. Contribute a scan to a duplicate tree not owned by the current user

The duplicate review endpoint can return any readable nearby tree, but `POST /trees/{tree_id}/scans` is owner-only. Therefore a user can confirm “Same tree” but cannot attach their evidence when another user owns the existing record.

Recommended endpoint:

```http
POST /api/v1/trees/{tree_id}/scan-contributions
Authorization: Bearer <token>
Idempotency-Key: tree-<draft-id>-scan-<tree-id>
Content-Type: multipart/form-data
```

Use the same `photos`, `photo_types`, `location_evidence`, `captured_at`, `notes`, and `run_analysis=true` fields as owner scans. Return `201`:

```json
{
  "id": "uuid",
  "tree_id": "uuid",
  "status": "pending_review",
  "submitted_at": "2026-08-15T06:00:00Z"
}
```

The owner or moderator should be able to accept/reject the contribution. If product policy instead allows trusted contributions to become scans immediately, document that policy and relax the existing scan authorization accordingly.

### 2. Attach a social post to a tree

`GET /trees/{tree_id}/posts` exists, but `POST /social/posts` has no `tree_id`. The app cannot create the relationship needed for the tree-posts endpoint to return data.

Add nullable `tree_id` to post creation and to post data:

```json
{
  "content": "Spring follow-up",
  "upload_id": "uuid-or-null",
  "tree_id": "uuid-or-null",
  "location": null,
  "created_at": "2026-08-15T06:00:00Z"
}
```

Validate that the tree is readable by the caller. Return `tree_id` in post list/detail/profile responses.

### 3. Durable avatar assignment

The contract says signed image URLs can expire and should not be persisted, but `PATCH /users/me` only accepts `avatar_url`. This can store a temporary URL as durable profile state.

Preferred change:

```http
PATCH /api/v1/users/me
{"full_name":"Alice","bio":"...","avatar_upload_id":"uuid"}
```

The backend should own the durable object reference and generate a fresh display URL in user responses. Alternatively add `POST /users/me/avatar` with an `upload_id`.

## P1 — required for visible product features

### 4. Guardian leaderboard, score, and coins

The app contains a Top Guardians destination and coin concept, but the contract has no ranking or score endpoint. The mobile client now shows an honest unavailable state instead of fabricated users.

Recommended endpoint:

```http
GET /api/v1/community/leaderboard?period=weekly&cursor=&limit=50
```

```json
{
  "items": [
    {
      "rank": 1,
      "user": {"id":"uuid","username":"alice","full_name":"Alice","avatar_url":null},
      "trees_count": 156,
      "score": 8450,
      "coins": 8450
    }
  ],
  "current_user": {"rank": 42,"score": 1200,"coins": 350},
  "next_cursor": null,
  "has_more": false
}
```

Backend/product must define how points and coins are earned, reversed after moderation, and scoped by period.

### 5. Challenges, streaks, and impact metrics

The profile/community designs include challenges, streaks, participation, progress, rewards, CO₂ impact, and time-series charts. Tree/post counts are insufficient to calculate these honestly.

Recommended endpoints:

```text
GET  /api/v1/profile/me/impact?period=6m
GET  /api/v1/profile/me/streak
GET  /api/v1/challenges?status=active&cursor=&limit=20
GET  /api/v1/challenges/{challenge_id}
POST /api/v1/challenges/{challenge_id}/join
GET  /api/v1/profile/me/challenges
```

Impact data must include units, calculation methodology/version, period buckets, and whether values are measured or estimated. Do not make the mobile app infer kilograms of CO₂ from a tree count.

### 6. Push notification device registration

Inbox and read-state endpoints exist, but there is no way to register an APNs/FCM token.

```text
POST   /api/v1/notification-devices
PATCH  /api/v1/notification-devices/{device_id}
DELETE /api/v1/notification-devices/{device_id}
```

Suggested body: `platform`, `push_token`, `app_version`, `locale`, and a stable installation ID. Tokens must be encrypted/redacted and replaceable after rotation.

Also add `GET /notifications/unread-count` or return `unread_count` in notification list metadata for the app badge.

### 7. User discovery and relationship state

Follow/unfollow works only after the app already knows a user ID. Add:

```http
GET /api/v1/users?q=alice&cursor=&limit=20
```

User/profile results should include viewer-relative fields such as `is_following`, `follows_you`, and whether the profile is readable. This removes extra full-following-list requests and prevents incorrect button state.

### 8. Account lifecycle and credential recovery

There are no endpoints for forgotten passwords, password changes, email verification, session/device management, or account deletion. At minimum define:

```text
POST   /api/v1/auth/password/forgot
POST   /api/v1/auth/password/reset
PATCH  /api/v1/auth/password
GET    /api/v1/auth/sessions
DELETE /api/v1/auth/sessions/{session_id}
DELETE /api/v1/users/me
```

Account deletion must specify retention/anonymization rules for public trees, scans, posts, comments, and audit records.

### 9. Moderation discovery

`POST /trees/{tree_id}/verify` works only when a moderator already knows a tree ID. Add a cursor-paginated review queue with stable filters and assignment state, for example:

```text
GET  /api/v1/moderation/trees?status=pending&cursor=&limit=50
POST /api/v1/moderation/trees/{tree_id}/claim
```

If verification is intentionally an external/admin-only workflow, remove the mobile verification feature from the product scope and document that decision.

## P1 — schemas that must be made explicit

The current mobile client parses these defensively, but production compatibility requires exact OpenAPI schemas and examples:

- Achievement object returned by `/profile/me/achievements`: IDs/codes, title, description, icon, unlock state/time, progress, and target.
- Like record returned by `/social/posts/{post_id}/likes`: specifically the user identifier used to determine whether the current user liked the post.
- Comment create response and comment object: `id`, `author_id`, `content`, `created_at`.
- `/trees/map` response item shape and units/limits for `radius`.
- Allowed `status` values for tree list, map, and `PATCH /trees/{tree_id}`.
- `details` schema per tree timeline `event_type`.
- Success response for tree verification.
- Exact `meta` shape for social cursor pagination (`next_cursor`, `has_more`) and whether list data remains an array.
- `/version`, `/health`, and `/ready` response schemas.
- Notification ordering, pagination, entity/deep-link metadata, and retention.

## P2 — settings currently omitted from production UI

The previous UI exposed local-only toggles for activity status, tagging, and auto-saving posts. They have been removed because the contract only persists profile privacy and notification enablement. If these features remain in scope, extend profile settings with documented fields and server-side behavior.

## Acceptance criteria for contract revision 1.2

1. Add the P0 endpoints/fields or explicitly document the chosen alternative behavior.
2. Publish OpenAPI schemas and examples for every underspecified response above.
3. Use the standard `{success,data,error,meta}` envelope and stable error codes.
4. Define ownership, privacy, pagination, idempotency, and rate limits for each new endpoint.
5. Add backend contract tests for authorization, idempotent replay, cursor behavior, signed URL refresh, and deletion/anonymization.
6. Provide a staging base URL and test users for `user`, `moderator`, and `admin` roles so the mobile team can run end-to-end verification.
