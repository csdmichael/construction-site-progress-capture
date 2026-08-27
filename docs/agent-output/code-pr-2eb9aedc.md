**Build-Stage Code Generation Proposal (for review)**  
_Project:_ Construction Site Progress Capture — Dev environment  
_Status:_ Proposal only; implementation contingent on stakeholder approval.

---

### 1. Objectives & Traceability
| Requirement | Goal in this build increment |
|-------------|-----------------------------|
| US-101 / SCR-02 | Capture installed quantities with contract/cumulative context, enforce variation reference for overruns. |
| US-102 / SCR-01 | Surface near-real-time package progress and stale capture flagging. |
| US-201 / SCR-02 | Bind photographs to package, item, location, and capture metadata; support offline queueing. |
| NFR focus | Offline resilience, latency ≤5 min package refresh, subcontractor isolation, immutable evidence retention hooks. |

---

### 2. High-Level Approach
1. **Frontend (Angular 18 + Ionic 8)**
   - Extend **SCR-01 Work Package List** page:
     - Consume refreshed package summaries via new `/packages/summary` API (poll or push-based refresh within 5 min).
     - Compute and label stale packages (≥7 days without capture).
     - Display cache-age banner when backend serves cached data (per US-102 AC4).
   - Implement **SCR-02 Progress & Evidence Capture** form enhancements:
     - Live cumulative quantity widget with polite ARIA announcements.
     - Variation reference modal when cumulative > contract.
     - Integrated camera component storing local blob + metadata, even offline.
     - Location selector (device geolocation with manual override) with source attribution.
     - Offline queue service persisting pending progress entries + evidence in IndexedDB; background sync on reconnect.

2. **Backend (FastAPI, Python 3.12)**
   - **Data contracts & models**
     - `ProgressEntry` model adds fields: `variation_reference`, `location_source`, `evidence_ids`.
     - `PackageSummary` adds `last_capture_at`, `is_stale`, `data_age_seconds`.
   - **Endpoints**
     - `POST /packages/{package_id}/items/{item_id}/progress`:
       - Validates cumulative totals vs contract, enforcing variation reference requirement.
       - Persists entry + evidence linkage transactionally (Azure SQL + Blob metadata pointer).
       - Returns enriched cumulative stats for UI.
     - `GET /packages/summary`:
       - Returns packages visible to caller (role-aware filtering per US-103).
       - Includes stale flag logic and cache-age metadata when commercial API fallback used.
     - `POST /evidence` (or combined within progress endpoint):
       - Accepts photo uploads (likely chunked) and stores to Azure Blob with immutability flags ready for later WORM policy.

   - **Offline sync support**
     - Idempotent request ID header to avoid duplicate progress entries when queued uploads replay.
     - Server returns conflict details (e.g., contract exceeded) for queued submissions.

3. **Evidence Storage**
   - Blob path convention: `/projects/{projectId}/packages/{packageId}/items/{itemId}/{entryId}/{timestamp}.jpg`.
   - Metadata includes `location`, `location_source`, `captured_at`, `captured_by`, `offline_captured` boolean.

4. **Security & Access Control**
   - Backend enforces package visibility (US-103). Frontend hides unavailable packages but does not rely on that for protection.
   - Every capture action audit-logged with user, device (where available), offline flag.

5. **Performance & Reliability**
   - Package summary refresh target ≤5 min using:
     - Event-driven push (SignalR/Websocket) when practical; otherwise short polling with exponential backoff when offline.
     - Cache stampede prevention with shared Redis/SQL cache flagging timestamp served to clients.
   - Offline queue flush within 5 minutes of reconnection (US-201 AC4) via service worker sync.

---

### 3. Data Model & Schema Updates
| Table | Change |
|-------|--------|
| `progress_entries` | Add `variation_reference VARCHAR`, `location_source NVARCHAR(20)`, `captured_offline BIT`, `client_request_id UNIQUEIDENTIFIER`. |
| `progress_evidence` | New table referencing entries; columns: `id`, `entry_id`, `blob_uri`, `description`, `location`, `location_source`, `captured_at`, `captured_by`, `checksum`. |
| `package_summary_cache` | Add `last_capture_at DATETIMEOFFSET`, `stale_flag BIT`, `cache_generated_at DATETIMEOFFSET`. |

Include migration script with idempotent guards.

---

### 4. Testing Strategy
1. **Frontend Unit/Component Tests (Jest + Testing Library)**
   - Quantity entry component blocking submission without variation reference when over contract.
   - Offline queue service: enqueue when offline, flush on reconnect, ensure metadata preserved.
   - Package list view: stale flag rendering and cache-age banner states.

2. **E2E / Integration (Playwright or Cypress)**
   - Simulate offline capture with queued evidence, restore network, confirm auto-sync and UI confirmation.
   - Variation-required flow with modal input and server validation.

3. **Backend Unit Tests (pytest)**
   - Validation of cumulative totals, variation logic, access control enforcement.
   - Evidence metadata persistence and blob path creation.
   - Package summary stale-flag calculation (>=7 days).

4. **Contract/API Tests (schemathesis or similar)**
   - Ensure new/updated endpoints conform to OpenAPI spec, including error payloads (409 for contract exceed, 403 for package access).

5. **Performance/Resilience**
   - Load test package summary endpoint under 5‑minute refresh cycle.
   - Retry logic validation for commercial API fallback; confirm cache-age surfaced.

---

### 5. Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Offline queue conflicts (e.g., contract quantity changed while offline). | Duplicate or invalid entries. | Use server-side cumulative validation + descriptive conflict responses; UI prompts user to reconcile. |
| Large evidence uploads on poor connectivity. | Failed sync within SLA. | Support resumable uploads (chunked) and show progress; ensure worker retries exponential backoff. |
| Cache staleness misinterpreted as current data. | Decisions based on stale info. | Prominent cache-age banner + explicit stale flag copy per requirements. |
| Role misconfiguration leaking packages. | Data isolation breach. | Enforce server-side package scope derived from Entra claims + project ACL; add automated tests. |

---

### 6. Open Questions (need stakeholder input)
1. **Variation reference format & validation source** – free text vs. lookup from commercial system?
2. **Evidence threshold rules** – are thresholds per item type configured server-side, and how exposed to UI?
3. **Preferred offline storage limits** – max queued items/photos per device before requiring manual cleanup?
4. **Cache refresh trigger** – should backend push notifications be attempted now or defer to later phase?

---

### 7. Next Steps
1. Confirm open questions and any missing acceptance criteria sections in draft documents.
2. Upon approval, generate detailed task breakdown (frontend, backend, infra), story-point estimates, and begin implementing with traceable commits + unit tests per above plan.
3. Prepare OpenAPI updates and migration scripts alongside code changes for review.

---

Please review this proposal for completeness and alignment with the approved design intent. Once validated, I can proceed to produce traceable source changes, accompanying tests, and code-review guidance per the governed SDLC workflow.