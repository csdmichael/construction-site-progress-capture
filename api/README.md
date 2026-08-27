# Construction Site Progress Capture — API

FastAPI service. Owns validation, authorization, and all database access.

| Path | Purpose |
| --- | --- |
| `/health` | Liveness probe |
| `/docs` | Swagger UI |
| `/openapi.json` | OpenAPI document |
| `/api/captures` | Captures collection (GET, POST) |
| `/api/captures/{id}` | Single capture (GET, PATCH, DELETE) |
