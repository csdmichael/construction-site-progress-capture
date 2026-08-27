# API contracts — Construction Site Progress Capture

The OpenAPI document is the authoritative contract: Swagger UI at `/docs`, raw document at `/openapi.json`. This table is the summary.

| Method | Path | Purpose | Response |
| --- | --- | --- | --- |
| `GET` | `/health` | Liveness probe used by the deploy pipeline | `{"status": "ok"}` |
| `GET` | `/api/captures` | List captures; `?status=` filters | `Capture[]` |
| `POST` | `/api/captures` | Create a capture | `201` + `Capture` |
| `GET` | `/api/captures/{id}` | Fetch one capture | `Capture` or `404` |
| `PATCH` | `/api/captures/{id}` | Partial update | `Capture` or `404` |
| `DELETE` | `/api/captures/{id}` | Remove a capture | `204` or `404` |

## `Capture`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | integer | Server assigned |
| `title` | string | Required, 1–400 characters |
| `reference` | string | Optional, up to 200 characters |
| `status` | enum | `new`, `in-progress`, `complete` |
| `priority` | enum | `low`, `normal`, `high` |
