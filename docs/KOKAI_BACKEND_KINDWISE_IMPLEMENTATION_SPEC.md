# KOK.AI Backend and Kindwise Plant.id Implementation Specification

Version: 1.0  
Verified against Kindwise Plant.id v3 documentation: 2026-08-15  
Audience: backend engineers, backend Codex tasks, QA, DevOps, and security reviewers  
Status: normative for the KOK.AI backend implementation

This document defines the backend that the current Flutter application expects and the exact boundary between KOK.AI and Kindwise Plant.id. It covers the complete application: authentication, users, profiles, uploads, tree analysis, location evidence, duplicate detection, tree creation, map/list/detail views, scans, social posts, notifications, moderation, storage, observability, and testing.

The exact mobile wire schemas are also documented in:

- docs/KOKAI_MOBILE_BACKEND_CONTRACT.md
- docs/KOKAI_MOBILE_IMPLEMENTATION_REPORT.md

If this document and an older legacy tree contract disagree, this document and KOKAI_MOBILE_BACKEND_CONTRACT.md take precedence for the new TreeRepository flow.

## 1. Official Kindwise references

Backend implementers must re-check these sources when upgrading provider versions:

- Product: https://www.kindwise.com/plant-id
- Plant.id v3 documentation: https://plant.id/docs
- Plant.id v3 OpenAPI: https://plant.id/api/v3/openapi.yaml
- Kindwise handbook: https://www.kindwise.com/handbook
- Kindwise API and security FAQ: https://www.kindwise.com/faq
- Plant.id status: https://status.plant.id
- Suggestion filters: https://plant.id/suggestion_filters

Important facts verified from the official documentation:

- Plant.id v3 is hosted at https://plant.id/api/v3.
- Authentication uses the Api-Key request header.
- Kindwise explicitly recommends calling its API from the application's own backend instead of a mobile client.
- Plant.id accepts JSON with base64/public URLs or multipart file uploads.
- Latitude, longitude, and capture datetime may improve identification.
- Up to five varied images may be submitted; whole-object and detailed views are recommended.
- The API returns persistent taxon IDs, scientific names, probabilities, taxonomy, localized common names, and optional licensed content.
- Description and representative-image fields can include citation and license data that must be preserved.
- The response can contain up to ten suggestions; suggestions below Kindwise's threshold may be omitted.
- Plant.id can perform species identification, health assessment, or both.
- A normal identification costs one credit. Health can add another credit.
- Retrieve, delete, usage-info, feedback, and name-search operations do not consume identification credits according to the current FAQ.
- Provider identification results can be retrieved later, but KOK.AI must persist normalized results immediately and must not rely on provider retention as durable application storage.

## 2. Non-negotiable architecture

~~~text
Flutter application
    |
    | HTTPS + KOK.AI Bearer access token
    v
KOK.AI API
    |-- authentication and authorization
    |-- idempotency
    |-- image validation and object storage
    |-- location-evidence validation
    |-- geospatial duplicate search
    |-- durable PostgreSQL persistence
    |-- provider-neutral response normalization
    |
    | HTTPS + server-only Api-Key
    v
Kindwise Plant.id v3
~~~

Rules:

1. Flutter never receives, stores, logs, or sends a Kindwise API key.
2. Flutter never calls plant.id directly.
3. KOK.AI owns all durable tree, image, analysis, scan, user, and social data.
4. Kindwise response objects are normalized before crossing the public API boundary.
5. Provider-specific raw JSON may be stored encrypted for audit/debug purposes, but is never returned by normal mobile endpoints.
6. Changing providers later must not require changing Flutter domain models.
7. KOK.AI must not claim exact individual-tree visual re-identification. Duplicate detection is primarily geospatial and always requires a user decision.
8. KOK.AI must not infer health from registration, verification, or identification confidence.

## 3. Recommended backend stack

The exact framework is flexible. A production implementation should provide:

- PostgreSQL 16+ with PostGIS.
- Object storage compatible with S3 or Google Cloud Storage.
- A transaction-capable ORM.
- A Redis-compatible store for rate limiting, short-lived caching, and optional jobs.
- A job queue for cleanup, notification fan-out, and optional async provider work.
- OpenAPI 3.1 generated from source schemas.
- A secret manager for Kindwise keys, JWT signing keys, database credentials, and storage credentials.

All timestamps are UTC in persistence and ISO 8601 with a Z suffix over the API.

## 4. Environment and secrets

Required production configuration:

| Variable | Purpose |
|---|---|
| APP_ENV | local, staging, or production |
| PUBLIC_API_BASE_URL | Canonical KOK.AI API URL |
| DATABASE_URL | PostgreSQL/PostGIS connection |
| REDIS_URL | Cache, limits, optional jobs |
| JWT_ACCESS_SIGNING_KEY | Access-token signing |
| JWT_REFRESH_SIGNING_KEY | Refresh-token signing |
| ACCESS_TOKEN_TTL_SECONDS | Recommended 900 |
| REFRESH_TOKEN_TTL_DAYS | Recommended 30 |
| OBJECT_STORAGE_BUCKET | Durable images |
| OBJECT_STORAGE_REGION | Storage region |
| OBJECT_STORAGE_ENDPOINT | Storage endpoint |
| KINDWISE_BASE_URL | Default https://plant.id/api/v3 |
| KINDWISE_API_KEY | Server-only Plant.id key |
| KINDWISE_HEALTH_MODE | off, auto, or all; recommended auto for the award demo |
| KINDWISE_CLASSIFICATION_LEVEL | Recommended species |
| KINDWISE_SUGGESTION_FILTER | Recommended tree |
| KINDWISE_PROVIDER_TIMEOUT_SECONDS | Recommended 12 |
| KINDWISE_MAX_CONCURRENCY | Protect credits and upstream |
| ABANDONED_UPLOAD_TTL_HOURS | Recommended 24 |
| IDEMPOTENCY_TTL_HOURS | Minimum 24 |

KINDWISE_API_KEY must be injected at runtime. It must not be committed, included in images, returned by diagnostics, or printed by request logging.

Production startup must fail closed when mandatory secrets are absent. The health endpoint may report provider configuration as unavailable without revealing secret values.

## 5. Public KOK.AI API conventions

Base path:

~~~text
/api/v1
~~~

Success envelope:

~~~json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": null
}
~~~

Error envelope:

~~~json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ai_provider_unavailable",
    "message": "Tree analysis is temporarily unavailable.",
    "details": {
      "retry_after_seconds": 30,
      "field_errors": null
    },
    "request_id": "req_01J5ERR"
  },
  "meta": null
}
~~~

Requirements:

- application/json for ordinary requests and responses.
- multipart/form-data only for file-bearing endpoints.
- Authorization: Bearer ACCESS_TOKEN for protected endpoints.
- Idempotency-Key for every create or externally billed operation.
- X-Request-Id accepted from trusted callers or generated by the backend.
- Cursor pagination rather than page-number pagination.
- Unknown request fields rejected in security-sensitive write operations.
- Unknown stored enum values returned only through a documented fallback.
- Never serialize missing values as the strings "null", "-", or "N/A".

## 6. Complete endpoint inventory

### 6.1 Platform

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | /health | no | Process and database readiness |
| GET | /api/v1/version | no | API version/build |

### 6.2 Authentication

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | /api/v1/auth/register | no | Create account and tokens |
| POST | /api/v1/auth/login | no | Authenticate |
| POST | /api/v1/auth/refresh | refresh token | Rotate token pair |
| POST | /api/v1/auth/logout | access token | Revoke refresh session |
| GET | /api/v1/auth/me | access token | Current auth identity |

### 6.3 Users and profiles

| Method | Path | Purpose |
|---|---|---|
| GET | /api/v1/users/me | Current user |
| PATCH | /api/v1/users/me | Update full name, biography, avatar |
| GET | /api/v1/users/{user_id} | Public/authorized profile |
| GET | /api/v1/users/{user_id}/followers | Followers |
| GET | /api/v1/users/{user_id}/following | Following |
| POST | /api/v1/users/{user_id}/follow | Follow idempotently |
| DELETE | /api/v1/users/{user_id}/follow | Unfollow idempotently |
| GET | /api/v1/profile/me/stats | Real user counts |
| GET | /api/v1/profile/me/achievements | Current achievements |
| GET | /api/v1/profile/me/posts | User posts |
| GET | /api/v1/profile/me/liked-posts | Liked posts |
| GET | /api/v1/profile/me/settings | Privacy/notifications/language |
| PATCH | /api/v1/profile/me/settings | Update settings |
| PATCH | /api/v1/profile/me/localization | Set en, ru, or uz |
| GET | /api/v1/localization/languages | Supported languages |

### 6.4 Uploads

| Method | Path | Purpose |
|---|---|---|
| POST | /api/v1/uploads/images | Upload one general image |
| POST | /api/v1/uploads/images/batch | Upload multiple general images |
| GET | /api/v1/uploads/{upload_id} | Resolve owned upload |

Tree analysis may ingest and store its multipart photos directly. The general upload endpoints remain for avatar/social compatibility.

### 6.5 Tree analysis and tree lifecycle

| Method | Path | Purpose |
|---|---|---|
| POST | /api/v1/tree-analyses | Categorized upload and Kindwise analysis |
| GET | /api/v1/tree-analyses/{analysis_id} | Resume/poll an analysis |
| GET | /api/v1/trees/nearby | Duplicate candidates |
| POST | /api/v1/trees | Create a tree from reviewed analysis |
| GET | /api/v1/trees | Home, list, and map data |
| GET | /api/v1/trees/{tree_id} | Full detail |
| PATCH | /api/v1/trees/{tree_id} | Owner/moderator editable metadata |
| GET | /api/v1/trees/{tree_id}/scans | Scan history |
| POST | /api/v1/trees/{tree_id}/scans | Add evidence to an existing tree |
| GET | /api/v1/trees/{tree_id}/timeline | Compatibility event timeline |
| GET | /api/v1/trees/{tree_id}/posts | Related social posts |
| POST | /api/v1/trees/{tree_id}/verify | Moderator verification |

Legacy POST /api/v1/trees/register may remain temporarily, but new clients use tree-analyses followed by POST /trees.

### 6.6 Social

| Method | Path | Purpose |
|---|---|---|
| POST | /api/v1/social/posts | Create post |
| GET | /api/v1/social/posts | Feed |
| GET | /api/v1/social/posts/{post_id} | Detail |
| PATCH | /api/v1/social/posts/{post_id} | Author update |
| DELETE | /api/v1/social/posts/{post_id} | Soft delete |
| POST | /api/v1/social/posts/{post_id}/likes | Like |
| DELETE | /api/v1/social/posts/{post_id}/likes | Unlike |
| GET | /api/v1/social/posts/{post_id}/likes | Like users |
| POST | /api/v1/social/posts/{post_id}/comments | Comment |
| GET | /api/v1/social/posts/{post_id}/comments | Comments |
| DELETE | /api/v1/social/comments/{comment_id} | Delete own/moderated comment |

### 6.7 Notifications

| Method | Path | Purpose |
|---|---|---|
| GET | /api/v1/notifications | User notifications |
| PATCH | /api/v1/notifications/{notification_id}/read | Mark one read |
| PATCH | /api/v1/notifications/read-all | Mark all read |

## 7. Authentication and account contract

Register request:

~~~json
{
  "email": "user@example.com",
  "username": "user001",
  "password": "Passw0rd123",
  "full_name": "User Name"
}
~~~

Login request:

~~~json
{
  "email": "user@example.com",
  "password": "Passw0rd123"
}
~~~

Token response:

~~~json
{
  "success": true,
  "data": {
    "access_token": "opaque-or-jwt-access-token",
    "refresh_token": "opaque-rotating-refresh-token",
    "token_type": "bearer",
    "expires_in": 900
  },
  "error": null,
  "meta": null
}
~~~

Security requirements:

- Passwords hashed with Argon2id or a current equivalent.
- Email and username uniqueness enforced case-insensitively.
- Refresh tokens stored hashed, bound to a session/device record, and rotated on every refresh.
- Reuse of a rotated refresh token revokes the token family.
- Access tokens contain subject, role, issued-at, expiry, session ID, and token ID.
- Login/register are rate limited by IP and normalized identity.
- The six-tap fake login in Flutter is debug-only and produces local fake tokens. Production backend must never accept those token strings.

User response:

~~~json
{
  "id": "user_01J5",
  "email": "user@example.com",
  "username": "user001",
  "full_name": "User Name",
  "role": "user",
  "bio": null,
  "avatar_url": null,
  "created_at": "2026-08-15T05:00:00Z"
}
~~~

## 8. Tree-analysis request from Flutter

POST /api/v1/tree-analyses

Headers:

~~~http
Authorization: Bearer ACCESS_TOKEN
Idempotency-Key: tree-DRAFT_ID-analysis
Content-Type: multipart/form-data
~~~

Repeated multipart parts:

| Field | Type | Required |
|---|---|---|
| photos | binary file repeated 2–5 times | yes |
| photo_types | text repeated once per photo | yes |
| location_evidence | JSON text field | yes |

Accepted photo_types:

- whole_tree
- leaf
- bark
- flower_or_fruit
- additional

Validation:

- Exactly one whole_tree photo.
- Exactly one leaf photo for the current mobile contract.
- At most one photo for every other typed slot.
- Two to five total photos.
- Equal photos and photo_types counts.
- Decode each image; do not trust MIME or extension alone.
- Accepted input: JPEG, PNG, and optionally HEIC if the backend can decode and normalize it.
- Reject animated content and polyglot files.
- Recommended maximum: 10 MB per original and 30 MB total.
- Remove unnecessary EXIF GPS from durable derivatives.
- Correct orientation before generating the provider derivative.
- Keep a high-quality KOK.AI original/derivative for tree detail.
- Generate a provider derivative between 1 and 2 megapixels. Kindwise advises that larger images add delay without improving identification.

Location evidence:

~~~json
{
  "latitude": 41.299503,
  "longitude": 69.240098,
  "horizontal_accuracy_meters": 5.8,
  "accepted_sample_count": 8,
  "rejected_sample_count": 2,
  "capture_duration_ms": 12000,
  "best_sample_accuracy_meters": 4.2,
  "captured_at": "2026-08-15T05:00:12.000Z",
  "quality": "acceptable"
}
~~~

The backend validates and stores this evidence. It sends only latitude, longitude, and captured_at to Kindwise. Sample counts and accuracy remain KOK.AI metadata.

## 9. Exact Kindwise Plant.id call

### 9.1 Endpoint

~~~http
POST https://plant.id/api/v3/identification
~~~

Recommended query:

~~~text
details=common_names,description,taxonomy,rank,gbif_id,inaturalist_id,image
language=USER_LANGUAGE,en
~~~

Rules:

- USER_LANGUAGE comes from profile settings and is one of en, ru, uz.
- If USER_LANGUAGE is en, send only en.
- Kindwise allows up to three comma-separated languages.
- Mapper code must support both a single-language details object and a multiple-language details object.
- Fall back to English locally when a preferred-language value is null.

### 9.2 Provider authentication

~~~http
Api-Key: SERVER_SECRET
~~~

Never forward the KOK.AI Authorization header to Kindwise. Never use Basic authentication unless required by an approved provider migration.

### 9.3 Recommended provider payload

Use multipart/form-data from KOK.AI to Kindwise. This avoids public temporary image URLs and keeps provider access under backend control. Kindwise states that multipart file field names are not significant.

Text fields:

~~~text
latitude=41.299503
longitude=69.240098
datetime=2026-08-15T05:00:12.000Z
similar_images=false
custom_id=INTERNAL_NUMERIC_ANALYSIS_ID
health=auto
suggestion_filter={"classification":"tree"}
classification_level=species
classification_raw=false
~~~

Binary fields:

~~~text
image1=@whole-tree-provider.jpg
image2=@leaf-provider.jpg
image3=@bark-provider.jpg
image4=@flower-provider.jpg
image5=@additional-provider.jpg
~~~

Configuration decisions:

- suggestion_filter=tree matches KOK.AI's tree-only registration goal and should be configurable for regional pilots.
- Do not add a continent filter unless product owners approve the supported geography; an incorrect region filter can remove the correct species.
- classification_level=species returns genus and species suggestions using Kindwise's normal post-processing.
- classification_raw=false keeps the normal deduplicated result.
- similar_images=false avoids an unnecessary response because KOK.AI requests the licensed representative image detail separately.
- health=auto returns health data only when Kindwise classifies the plant as diseased. It may consume a second credit. Use KINDWISE_HEALTH_MODE=off to disable this cost or all to always request health.
- Do not call a separate health endpoint after health=auto unless explicitly requested by a scan workflow; that can consume another credit.

### 9.4 Synchronous versus async

The current Flutter request expects a synchronous KOK.AI response and has a 30-second network timeout. The initial backend implementation should:

1. Persist the analysis row and idempotency record.
2. Validate/store images.
3. Call Kindwise synchronously with a provider timeout around 12 seconds.
4. Normalize and commit the result.
5. Return HTTP 201.

Also implement GET /tree-analyses/{analysis_id} so the backend can migrate to async processing without losing drafts. If synchronous processing exceeds the KOK.AI request budget, return HTTP 202 with status=processing and let a later mobile revision poll.

## 10. Kindwise response handling

Kindwise v3 returns:

- access_token: provider identification identifier.
- status and completion timestamps.
- model_version.
- result.is_plant with binary, probability, and threshold.
- result.classification.suggestions.
- optional result.is_healthy and result.disease.suggestions.

Every species suggestion may contain:

- id: persistent Kindwise taxon ID.
- name: current scientific taxon name.
- probability: 0.0–1.0.
- details.common_names.
- details.taxonomy.
- details.rank.
- details.gbif_id.
- details.inaturalist_id.
- details.description as a cited/licensed value.
- details.image as a cited/licensed value.

### 10.1 No-plant behavior

If result.is_plant.binary is false:

- Persist the provider result and input audit.
- Mark analysis status no_plant_detected.
- Return HTTP 422 with code no_plant_detected.
- Do not create a tree automatically.
- Do not consume a second provider call on automatic retry.

Include the provider's probability only in server logs/metrics or safe error details when product policy allows it. Never present it as certainty.

### 10.2 Low-confidence behavior

Do not reject merely because the top species confidence is low:

- Preserve all returned suggestions in provider order.
- Return up to five normalized candidates to the mobile app.
- Allow the user to select an alternative, correct manually, or mark unknown.
- candidates may be empty.
- Do not invent a confidence percentage or rescale Kindwise probability.
- A future product threshold may add a warnings array, but must not overwrite the raw probability.

### 10.3 Normalization table

| Kindwise source | KOK.AI output | Rule |
|---|---|---|
| access_token | provider_reference encrypted in DB | Never return to mobile |
| model_version | provider_model_version in DB | Admin/audit only |
| suggestion.id | provider_taxon_id in DB | Persistent provider key |
| internal analysis-candidate UUID | candidate.id | Opaque mobile selection key |
| suggestion.name | candidate.scientific_name | Required |
| suggestion.probability | candidate.confidence | Clamp defensively to 0–1 |
| details.common_names[0] | candidate.common_name | Preferred locale, then English, else null |
| details.taxonomy.genus | candidate.genus | Nullable |
| details.taxonomy.family | candidate.family | Nullable |
| details.description.value | candidate.description | Nullable, sanitized |
| details.description.citation | description source metadata | Persist |
| details.description.license_name | description license metadata | Persist |
| details.description.license_url | description license metadata | Persist |
| details.image.value | candidate.representative_image_url | Return only with permitted attribution |
| details.image.citation | candidate.image_source_url | Preserve |
| details.image.license_name | image license metadata | Persist |
| details.image.license_url | image license metadata | Persist |
| details.rank | candidate rank in DB | Optional public future field |
| details.gbif_id | candidate GBIF ID | Optional future field |
| details.inaturalist_id | candidate iNaturalist ID | Optional future field |

Do not proxy the raw Kindwise JSON to Flutter.

## 11. Normalized analysis response to Flutter

HTTP 201:

~~~json
{
  "success": true,
  "data": {
    "id": "analysis_01J5ABC",
    "provider": "kindwise_plant_id",
    "analyzed_at": "2026-08-15T05:00:25.000Z",
    "candidates": [
      {
        "id": "candidate_01J5A",
        "common_name": "Oriental plane",
        "scientific_name": "Platanus orientalis",
        "confidence": 0.87,
        "genus": "Platanus",
        "family": "Platanaceae",
        "description": "A large deciduous tree...",
        "representative_image_url": "https://cdn.example/species/1.jpg",
        "image_source_url": "https://source.example/item/1"
      }
    ],
    "health": null
  },
  "error": null,
  "meta": null
}
~~~

Nullable fields:

- common_name
- genus
- family
- description
- representative_image_url
- image_source_url
- health

Candidate id is a KOK.AI candidate ID, not a value supplied by the user. POST /trees must verify that it belongs to the authenticated user's analysis.

## 12. Optional health normalization

When Kindwise returns is_healthy:

~~~json
{
  "status": "possible_issue",
  "confidence": 0.64,
  "summary": "Possible powdery mildew"
}
~~~

Mapping:

- is_healthy.binary=true → status likely_healthy.
- is_healthy.binary=false → status possible_issue.
- confidence is is_healthy.probability for likely_healthy.
- For possible_issue, confidence may use the top non-redundant disease suggestion probability; if absent, use 1 - is_healthy.probability and record the calculation method internally.
- summary uses the preferred localized disease name or scientific provider name.
- Exclude Kindwise disease suggestions marked redundant when a more specific non-redundant child is present.
- Never call this a medical, arboricultural, or professional diagnosis.
- Health remains null when health mode is off or when auto returns no assessment.

The current Flutter model displays only status, confidence, and summary. Store richer disease IDs, treatment, causes, and citations for a future API version, but do not expose treatment as professional advice.

## 13. Provider idempotency and credit safety

POST /tree-analyses is externally billed and must be idempotent.

Required state machine:

~~~text
received
  -> validating
  -> images_stored
  -> provider_pending
  -> completed
  -> failed_retryable
  -> failed_terminal
~~~

Algorithm:

1. Start a database transaction.
2. Lock or create the idempotency row using user ID + route + key.
3. Hash normalized fields and image digests.
4. If completed with the same hash, return the original response.
5. If the same key has a different hash, return 409 idempotency_conflict.
6. Create a numeric internal analysis sequence value and use it as Kindwise custom_id.
7. Commit before calling Kindwise.
8. Call Kindwise once.
9. On a connection loss after request transmission, try GET /api/v3/identification/{custom_id} before creating another provider identification.
10. Persist normalized output and original KOK.AI response atomically.

Never blindly retry a provider POST after an ambiguous timeout. That may consume multiple credits.

## 14. Provider error mapping

| Kindwise/provider condition | KOK.AI HTTP | code | Retry |
|---|---:|---|---|
| Invalid/missing server API key | 503 | ai_provider_misconfigured | no; alert operations |
| Out of Kindwise credits / provider 429 | 429 | ai_quota_exceeded | after credits added |
| Kindwise rate/temporary limit | 429 | ai_rate_limited | Retry-After |
| Provider timeout, no retrievable result | 504 | request_timeout | same KOK idempotency key |
| Provider 5xx/unavailable | 502 | ai_provider_unavailable | exponential backoff |
| Input rejected by Kindwise | 422 | provider_rejected_input | correct input |
| No plant detected | 422 | no_plant_detected | retake photos |
| Successful response, no candidates | 201 | none | user can mark unknown |
| Unexpected response schema | 502 | ai_provider_invalid_response | alert operations |

Do not expose Kindwise's plain-text 401/429 body. Attach request_id and provider incident metadata to internal logs only.

## 15. Kindwise usage and operations

Poll GET https://plant.id/api/v3/usage_info from an internal scheduled monitor, not per mobile request.

Track:

- active.
- can_use_credits.
- remaining credits.
- configured credit limits.
- provider latency.
- provider status/error rate.
- health second-credit frequency.

Alerts:

- remaining credits below configured thresholds.
- can_use_credits=false.
- provider 401.
- provider 429 spike.
- p95 provider latency above budget.
- normalized schema failures.

Use reusable HTTP sessions/connection pools. Kindwise notes that backend session reuse can reduce transaction delay.

## 16. Nearby duplicate detection

GET /api/v1/trees/nearby

Query:

~~~text
latitude=41.299503
longitude=69.240098
radius_meters=20
~~~

PostGIS concept:

~~~sql
ST_DWithin(
  trees.coordinate_geography,
  ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography,
  :radius_meters
)
~~~

Use ST_Distance for distance_meters and sort ascending.

Rules:

- Default radius 20 m.
- Maximum public radius 100 m.
- Use the captured coordinate as supplied; do not move it to an existing tree.
- Return recorded horizontal accuracy for each candidate.
- Optionally compute overlap_hint when distance is less than the sum of both accuracy radii, but do not auto-merge.
- Species is secondary evidence only.
- Never claim two records are the same individual solely due to distance or species.
- Hide coordinates/images according to visibility and authorization policies.

Response:

~~~json
{
  "success": true,
  "data": {
    "items": [
      {
        "tree_id": "tree_01J5XYZ",
        "display_name": "Library plane",
        "scientific_name": "Platanus orientalis",
        "image_url": "https://cdn.example/trees/tree_01J5XYZ/primary.jpg",
        "distance_meters": 4.3,
        "horizontal_accuracy_meters": 6.1,
        "registered_at": "2026-07-20T10:30:00.000Z"
      }
    ]
  },
  "error": null,
  "meta": null
}
~~~

## 17. Tree creation

POST /api/v1/trees

Request:

~~~json
{
  "analysis_id": "analysis_01J5ABC",
  "selected_candidate_id": "candidate_01J5A",
  "manual_scientific_name": null,
  "location_evidence": {
    "latitude": 41.299503,
    "longitude": 69.240098,
    "horizontal_accuracy_meters": 5.8,
    "accepted_sample_count": 8,
    "rejected_sample_count": 2,
    "capture_duration_ms": 12000,
    "best_sample_accuracy_meters": 4.2,
    "captured_at": "2026-08-15T05:00:12.000Z",
    "quality": "acceptable"
  },
  "duplicate_check_status": "noNearbyTrees",
  "nickname": "Library plane",
  "notes": "Near the north entrance",
  "visibility": "public"
}
~~~

Validation:

- analysis exists, is completed, belongs to caller, and has not expired.
- selected_candidate_id belongs to that analysis.
- selected_candidate_id and manual_scientific_name are mutually exclusive.
- both null means unknown.
- location evidence matches the analysis evidence. Reject material changes rather than silently replacing.
- duplicate_check_status is noNearbyTrees, possibleMatches, or skippedDueToNetworkFailure.
- visibility is public or private until additional scopes are designed.
- Idempotency-Key is required.

Persist both:

- immutable AI candidates/provider evidence.
- user-confirmed candidate, user correction, or unknown selection.

Never overwrite the original analysis when the user corrects it.

## 18. Tree list, Home, and Map

GET /api/v1/trees supports:

- cursor.
- limit: 1–200.
- q: nickname/common/scientific-name search.
- sort: newest, nearest, last_scanned.
- species: normalized filter.
- optional owner_id and visibility policy.
- optional latitude/longitude when sort=nearest.
- optional bbox for map optimization in a backward-compatible revision.

Response data:

~~~json
{
  "items": [],
  "next_cursor": null,
  "has_more": false
}
~~~

The Home page requests five newest trees. My Trees requests 20 with incremental pagination. The current Map may request up to 200. Do not return fake statistics or fake trees.

For sort=nearest, require latitude and longitude. Return 400 unsupported_sort_parameters when absent.

## 19. Tree detail

GET /api/v1/trees/{tree_id} must include:

- id and nickname.
- registered_at and last_scanned_at.
- primary_image_url.
- all registration photos with types.
- full location evidence and quality.
- confirmed identification.
- AI confidence/provider only when available.
- identification source: user_confirmed_ai, user_corrected, or unknown.
- description only with source/license policy satisfied.
- optional health only when actually assessed.
- visibility and owner fields if authorized.

Do not include raw Kindwise JSON or Kindwise credentials.

## 20. Scan history and existing-tree path

GET /api/v1/trees/{tree_id}/scans:

~~~json
{
  "items": [
    {
      "id": "scan_01J6AAA",
      "scanned_at": "2026-09-15T08:00:00.000Z",
      "summary": "Follow-up visual scan",
      "image_url": "https://cdn.example/scans/scan_01J6AAA.jpg"
    }
  ]
}
~~~

POST /api/v1/trees/{tree_id}/scans should use multipart fields equivalent to tree analysis:

- photos.
- photo_types.
- optional location_evidence.
- optional run_analysis boolean.
- Idempotency-Key.

If run_analysis=true:

- use a distinct Kindwise custom_id and idempotency state.
- preserve prior identification and analysis history.
- do not silently replace the confirmed species.
- add the new result to the timeline.

The current Flutter UI does not yet submit this endpoint. It preserves the draft when the user says a nearby candidate is the same tree.

## 21. Upload and object-storage rules

UploadedAsset response:

~~~json
{
  "id": "upload_01J5",
  "url": "https://cdn.example/uploads/upload_01J5.jpg",
  "content_type": "image/jpeg",
  "file_name": "front.jpg",
  "file_size": 12345,
  "created_at": "2026-08-15T05:00:00Z"
}
~~~

Storage:

- Use generated object keys, never raw user paths.
- Originals and normalized derivatives are separate objects.
- Store SHA-256 digest, detected MIME, dimensions, owner, purpose, status, and retention.
- Unattached general uploads expire after ABANDONED_UPLOAD_TTL_HOURS.
- Photos attached to an analysis/tree/scan follow the tree retention policy.
- Signed URLs must be short-lived when content is private.
- Prevent one user from attaching another user's upload.
- Scan for malware and image parser abuse.
- Do not log precise signed URLs.

## 22. Social module contract

Create post:

~~~json
{
  "content": "Great tree!",
  "upload_id": "upload_01J5",
  "location": {
    "latitude": 41.2995,
    "longitude": 69.2401
  },
  "created_at": "2026-08-15T05:10:00Z"
}
~~~

Post response fields used by Flutter:

~~~json
{
  "id": "post_01J5",
  "author_id": "user_01J5",
  "content": "Great tree!",
  "image_url": "https://cdn.example/posts/1.jpg",
  "location": {
    "latitude": 41.2995,
    "longitude": 69.2401
  },
  "created_at": "2026-08-15T05:10:00Z"
}
~~~

Rules:

- content length 1–2000 after trimming.
- location optional and subject to privacy/precision policy.
- POST is idempotent.
- delete is soft delete.
- like uniqueness: user_id + post_id.
- follow uniqueness: follower_id + followed_id.
- comment length 1–1000.
- lists currently return arrays inside data for compatibility.
- apply ownership/moderator authorization.

Social remains an existing secondary feature; it must not fabricate environmental impact or tree health claims.

## 23. Profiles, settings, and notifications

Profile stats response:

~~~json
{
  "followers_count": 10,
  "following_count": 4,
  "posts_count": 3,
  "trees_count": 2
}
~~~

Counts must be calculated from real persisted data or maintained transactionally. Never return demo totals in remote mode.

Settings:

~~~json
{
  "language_code": "uz",
  "privacy_profile_public": true,
  "notifications_enabled": true
}
~~~

Notification response:

~~~json
{
  "id": "notification_01J5",
  "title": "Tree registered",
  "body": "Library plane was added to your collection.",
  "is_read": false,
  "created_at": "2026-08-15T05:10:00Z"
}
~~~

Notification rules:

- User can only read/update own notifications.
- read/read-all are idempotent.
- Respect notifications_enabled before push/email delivery.
- In-app audit notifications may still be persisted when legally required.
- Avoid putting precise coordinates or private notes in push payloads.

## 24. Moderation and achievements

Roles:

- user.
- moderator.
- admin.

Tree verification:

- Moderator/admin only.
- Verification confirms record review, not species certainty and not health.
- Store reviewer, timestamp, note, previous state, and new state.
- Add a timeline event.

Achievements:

- Must be deterministic and based on real events.
- No transferable token, payment, redemption, or KOK Coin semantics.
- Define stable achievement code, localized label key, earned_at, and evidence reference.
- The API may return an empty list until rules are approved.

## 25. Recommended database model

Core tables:

### users

- id UUID/ULID primary key.
- email normalized unique.
- username normalized unique.
- password_hash.
- full_name, bio, avatar_upload_id.
- role.
- language_code.
- privacy_profile_public.
- notifications_enabled.
- created_at, updated_at, deleted_at.

### auth_sessions

- id.
- user_id.
- refresh_token_hash.
- token_family_id.
- expires_at, rotated_at, revoked_at.
- device metadata with privacy controls.

### uploads

- id, owner_id.
- purpose.
- object_key_original, object_key_derivative.
- detected_mime, size, width, height, sha256.
- status.
- created_at, attached_at, expires_at.

### tree_analyses

- id.
- numeric_provider_custom_id unique.
- owner_id.
- status.
- idempotency_key.
- request_hash.
- provider enum.
- provider_reference encrypted.
- provider_model_version.
- provider_is_plant_probability.
- provider_is_plant_binary.
- health_mode.
- normalized_response_json.
- raw_provider_response_encrypted optional.
- created_at, analyzed_at, failed_at.

### tree_analysis_photos

- id, analysis_id, upload_id.
- photo_type.
- ordinal.
- captured_at.

### tree_analysis_candidates

- id.
- analysis_id.
- provider_taxon_id.
- scientific_name, common_name.
- confidence.
- rank, genus, family.
- gbif_id, inaturalist_id.
- description.
- description_citation/license fields.
- representative_image_url.
- image citation/license fields.
- ordinal.

### tree_health_assessments

- id, analysis_id or scan_id.
- status, confidence, summary.
- provider disease ID/name/probability.
- disclaimer version.
- created_at.

### trees

- id, owner_id.
- analysis_id.
- selected_candidate_id nullable.
- confirmed_common_name nullable.
- confirmed_scientific_name nullable.
- manual_scientific_name nullable.
- identification_source.
- nickname, notes, visibility.
- coordinate geography(Point, 4326).
- all location-evidence numeric fields.
- duplicate_check_status.
- registered_at, last_scanned_at, updated_at, deleted_at.

### tree_photos

- tree_id, upload_id, photo_type, ordinal.

### tree_scans

- id, tree_id, creator_id.
- optional analysis_id.
- optional coordinate and evidence.
- summary.
- scanned_at.

### idempotency_records

- principal_id, method, route, key composite unique.
- request_hash.
- state.
- response_status.
- response_body.
- resource_type/resource_id.
- expires_at.

Also create normalized tables for follows, posts, post_likes, comments, notifications, achievements, and tree timeline events.

Indexes:

- GiST index on trees.coordinate.
- tree owner + registered_at.
- analysis owner + created_at.
- unique idempotency scope.
- unique follow and like pairs.
- feed created_at cursor index.
- unread notification user index.

## 26. Transactions and consistency

- Tree creation and attaching analysis photos occur in one database transaction.
- Incremental stats must update transactionally or be rebuilt from source data.
- Deleting a tree is soft delete first; storage deletion is asynchronous after retention.
- Provider calls never occur inside a long-running database transaction.
- Use an outbox table for notification/timeline jobs.
- Idempotency response is committed with the resource.
- Concurrent same-key requests wait for/reuse the active record rather than calling Kindwise twice.

## 27. Error catalog

| HTTP | code |
|---:|---|
| 400 | validation_error |
| 400 | unsupported_sort |
| 400 | unsupported_sort_parameters |
| 401 | unauthorized |
| 403 | forbidden |
| 404 | user_not_found |
| 404 | analysis_not_found |
| 404 | tree_not_found |
| 404 | post_not_found |
| 409 | idempotency_conflict |
| 409 | already_following |
| 409 | already_liked |
| 413 | upload_too_large |
| 415 | unsupported_image |
| 422 | invalid_image |
| 422 | invalid_location_evidence |
| 422 | no_plant_detected |
| 422 | provider_rejected_input |
| 429 | rate_limited |
| 429 | ai_quota_exceeded |
| 429 | ai_rate_limited |
| 502 | ai_provider_unavailable |
| 502 | ai_provider_invalid_response |
| 503 | backend_unavailable |
| 503 | ai_provider_misconfigured |
| 504 | request_timeout |

Every error must have a stable code and request_id. User-facing message text can be localized independently.

## 28. Privacy and security

- TLS everywhere.
- Encrypt storage and databases at rest.
- Never log image bytes, Kindwise keys, refresh tokens, raw authorization headers, or exact production coordinates.
- Redact signed URL query strings.
- Use structured logs with coarse location only when essential.
- Strip unnecessary EXIF metadata.
- Provide retention/deletion policies for abandoned uploads, analyses, trees, and provider artifacts.
- Restrict raw provider response access to audited admin/support roles.
- Validate URL inputs to prevent SSRF; prefer direct provider multipart uploads.
- Rate limit analysis by user, IP, device/session, and credit budget.
- Add content security rules for served media.
- Do not expose private tree coordinates through map/nearby/social endpoints.
- Follow Kindwise license requirements for descriptions and images.

## 29. Observability

Metrics:

- request count/latency/error by route.
- analysis validation failures by reason.
- provider call count by health mode.
- provider latency/error/status.
- Kindwise credits remaining.
- no-plant rate.
- candidate-empty and low-top-confidence rates.
- idempotency replay/conflict counts.
- duplicate-candidate frequency.
- image-processing time and failures.
- tree creation success/rollback.

Traces:

- KOK request ID.
- internal analysis/tree ID.
- provider call span without API key or image content.
- object storage spans.
- database transaction spans.

Logs:

- Structured JSON.
- No precise coordinates in normal logs.
- No raw request bodies on file-bearing/location endpoints.
- Security/audit stream separated from operational logs.

## 30. Backend automated tests

No automated test may call live Kindwise or consume credits.

### Unit tests

- Envelope and error serialization.
- Location-evidence validation.
- Photo/type cardinality.
- Image MIME/dimension validation.
- Single/multi-language Kindwise details mapping.
- Null descriptions/common names/images.
- Citation/license preservation.
- Persistent provider taxon ID mapping.
- Unknown provider enum/field tolerance.
- is_plant false behavior.
- empty candidates.
- health likely_healthy/possible_issue/null.
- redundant disease filtering.
- user correction preserving AI results.
- idempotency request hashing.
- authorization/visibility rules.

### Provider adapter tests with fixtures

- Successful identification.
- Five-image request.
- tree suggestion filter.
- locale plus English fallback.
- no plant.
- no candidates.
- malformed provider response.
- provider 401.
- provider 429 credits exhausted.
- provider 5xx.
- connection timeout before send.
- ambiguous timeout after send and retrieval by custom_id.
- health off, auto without disease, auto with disease, and all.

### API contract tests

- Register/login/refresh rotation/logout.
- Upload ownership and invalid MIME/size.
- Successful tree analysis multipart.
- Mismatched photo/type counts.
- Poor but valid location accepted and persisted.
- Analysis idempotency replay and conflict.
- Nearby empty/candidates and distance ordering.
- No automatic duplicate merge.
- Tree create with candidate/manual/unknown.
- Creation delayed-response retry.
- List pagination/search/sorts.
- Map visibility.
- Tree detail nullable fields.
- Scan list/create.
- Social CRUD/likes/comments.
- Follow/unfollow.
- Profile real counts/settings/language.
- Notification authorization/read/read-all.
- Moderator verification without health mutation.

### Integration tests

- PostgreSQL/PostGIS distance query.
- Object storage upload/cleanup.
- Transaction rollback.
- Outbox delivery.
- Signed URL authorization.
- OpenAPI examples validate against schemas.

## 31. Acceptance criteria

The backend is ready for mobile integration only when:

- Staging is HTTPS and reachable from a physical phone.
- Authentication and refresh rotation work.
- All new TreeRepository endpoints match the documented envelope and fields.
- Tree analysis accepts the Flutter multipart shape.
- Kindwise is called only by the backend with Api-Key from secret storage.
- Two to five categorized photos are forwarded correctly.
- GPS and datetime are forwarded; accuracy evidence is persisted in KOK.AI.
- suggestion_filter=tree and classification_level are configurable and tested.
- Provider candidate, taxonomy, locale, and license mappings are tested.
- No-plant, empty, nullable, quota, timeout, and unavailable cases are stable.
- Analysis and creation retries are idempotent and credit-safe.
- Nearby search uses PostGIS and never auto-merges.
- Tree create preserves AI output and user confirmation separately.
- Home/list/map/detail all read persisted tree data.
- Health is optional, honestly labelled, and never inferred.
- Scan history works and scan creation has an idempotent contract.
- Uploads, profiles, social, notifications, and moderation pass authorization tests.
- OpenAPI is published and examples pass schema validation.
- No test consumes live Kindwise credits.
- Kindwise key and precise location are absent from normal logs.

## 32. Implementation sequence

Recommended backend task order:

1. Establish envelope, request IDs, authentication, refresh rotation, and authorization middleware.
2. Add PostgreSQL/PostGIS migrations and object storage.
3. Add idempotency middleware/state table.
4. Implement image ingestion/normalization.
5. Implement the Kindwise adapter behind an interface and fixture adapter.
6. Implement POST/GET tree-analyses with provider normalization.
7. Implement nearby geospatial search.
8. Implement idempotent tree creation.
9. Implement tree list/detail/scans/timeline.
10. Implement profiles, uploads, social, notifications, and moderation compatibility endpoints.
11. Publish OpenAPI and run contract tests against Flutter fixtures.
12. Enable staging Kindwise credentials with a strict credit budget.
13. Perform physical-device end-to-end testing.
14. Enable production only after privacy, licensing, retention, and observability review.

## 33. First backend milestone

The first backend Codex task should deliver:

- Tree/provider database migrations.
- Object storage abstraction.
- KindwisePlantIdClient interface.
- MockKindwisePlantIdClient with committed fixtures.
- POST /api/v1/tree-analyses.
- GET /api/v1/tree-analyses/{analysis_id}.
- Idempotency and custom_id recovery.
- Normalized candidate/health mapping.
- Stable provider error mapping.
- Unit, provider-adapter, and API contract tests.
- OpenAPI examples matching the Flutter DTO tests.

Do not start with live Kindwise calls. First make the full flow pass against recorded, sanitized fixtures; then enable a staging key with monitored credits.
