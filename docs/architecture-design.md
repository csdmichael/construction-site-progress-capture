# Architecture Advisor — Design-Stage Reviewable Proposal

**Project:** Construction Site Progress Capture  
**Environment:** Dev  
**Status:** Proposed for review only — not approved for implementation  
**Basis:** User-supplied intake documents and the approved Requirements Agent summary. Source documents are marked **Draft v1.0 (2026-08-24)** and some extracted sections are truncated. Items marked **Needs confirmation** should be resolved before build approval.

---

## 1. Executive summary

I recommend a **mobile-first, offline-capable capture architecture** using:

- **Ionic 8 + Angular 18** client for tablet and browser experiences
- **Python 3.12 + FastAPI** as the domain API
- **Azure SQL Database** as the system of record for progress capture, daily records, valuation state, and audit metadata
- **Azure Blob Storage** for photographs and generated valuation/application packs
- **Azure App Service** for API hosting
- **Azure Functions** for scheduled locking and valuation assembly workloads
- **Microsoft Agent Framework / Foundry** for narrative and disruption analysis workflows
- **Azure API Management** as the mandatory gateway for all model traffic
- **Microsoft Entra ID / Entra External ID** for workforce and subcontractor identity

This architecture fits the stated constraints:

- **Offline-first capture** in low/no-signal site conditions
- **Strict package/subcontractor isolation**
- **Immutable evidence retention**
- **Daily record locking and contemporaneity**
- **Human approval before AI-authored narrative is attached**
- **Commercial system remains system of record** for work packages, quantities, and rates

---

## 2. Architecture recommendation

## 2.1 Proposed logical architecture

```text
[Site Engineer Tablet / Browser]
  Ionic + Angular PWA / hybrid app
  - offline queue
  - local encrypted storage
  - camera/geolocation
  - sync manager
          |
          v
[Azure API Management]
  - auth enforcement
  - throttling
  - correlation IDs
  - model traffic policy enforcement
          |
          v
[Progress Service - FastAPI on App Service]
  - package-scoped APIs
  - progress capture
  - evidence metadata
  - daily record APIs
  - valuation orchestration
  - audit trail
  - integration adapters
     |             |              |               |
     v             v              v               v
[Azure SQL]   [Blob Storage] [Commercial APIs] [Programme API]
     |
     +--> [Azure Functions]
           - Daily Record Locker
           - Valuation Assembler
           - Sync/cleanup jobs
           - retention/immutability workflows

[Site Narrative Workflow]
  Microsoft Agent Framework / Foundry
     ^
     |
[APIM model route only]
```

## 2.2 Bounded components

### A. Client application
Responsibilities:
- Render package list, capture forms, daily record, valuation review
- Support offline capture and deferred sync
- Capture photo, timestamp, location source, and local queue state
- Prevent obvious invalid input client-side, but rely on server for enforcement

### B. Progress service
Responsibilities:
- Authoritative business rules for:
  - package scoping
  - cumulative quantity validation
  - variation reference requirement
  - evidence linkage
  - daily record state transitions
  - valuation line assembly state
- Expose APIs to client and commercial users
- Persist audit events
- Integrate with commercial/package/programme systems

### C. Valuation assembler
Responsibilities:
- Build valuation periods from captured quantities
- Retrieve current contract rates from commercial system
- Flag unevidenced lines
- Fail closed if rates unavailable

### D. Daily record locker
Responsibilities:
- Lock each site day at configured cut-off
- Mark post-cutoff entries as late
- Enforce non-editability after lock

### E. Narrative/disruption workflow
Responsibilities:
- Produce draft narrative from captured records only
- Highlight disruption patterns
- Pause for commercial manager review
- Never auto-attach final narrative without human approval

---

## 3. Key architectural decisions

## ADR-001 — Use Azure SQL as primary transactional store
**Status:** Proposed

**Decision:** Use Azure SQL Database for progress entries, daily records, valuation state, package cache metadata, audit metadata, and sync tracking.

**Why:**
- Strong relational fit for packages, measured items, valuations, approvals, and auditability
- Predictable aggregation for valuation periods
- Easier enforcement of locking/state transitions and uniqueness constraints

**Consequences:**
- Need careful schema/index design for sync and evidence retrieval
- Blob storage remains separate for binary evidence

---

## ADR-002 — Use Blob Storage for photographs and generated packs
**Status:** Proposed

**Decision:** Store image binaries and generated application packs in Azure Blob Storage; store only metadata and references in SQL.

**Why:**
- Better cost/performance for media
- Supports immutability and long retention
- Avoids bloating transactional database

**Consequences:**
- Need content hash, upload status, and immutable retention metadata in SQL
- Need secure SAS or proxy download strategy

---

## ADR-003 — Offline-first client with server-authoritative reconciliation
**Status:** Proposed

**Decision:** The client may capture offline and queue locally, but the server remains authoritative for final acceptance, timestamps received, cumulative validation, and lock enforcement.

**Why:**
- Required for basements/steelwork/no-signal use
- Prevents client-only rule bypass
- Supports auditability

**Consequences:**
- Must model:
  - local capture timestamp
  - device timestamp
  - server receipt timestamp
  - sync status
  - conflict/failure reasons
- UX must clearly distinguish:
  - saved locally
  - synced
  - rejected
  - late

---

## ADR-004 — Immutable append-only progress entries
**Status:** Proposed

**Decision:** Saved progress entries are not edited in place by engineers. Corrections are handled by compensating entries or controlled commercial/admin workflows.

**Why:**
- Aligns with contemporaneous record requirement
- Preserves evidential integrity
- Simplifies audit trail

**Consequences:**
- Need explicit correction model
- Reporting must net original and corrective entries appropriately

---

## ADR-005 — Daily record as state machine with scheduled lock
**Status:** Proposed

**Decision:** Daily records move through explicit states: `Draft -> Submitted -> Locked`, with `LateAddendum` or equivalent for post-cutoff additions if permitted by policy.

**Why:**
- Locking is a core business rule
- Clear state transitions improve auditability and implementation clarity

**Consequences:**
- Need confirmation whether late entries are:
  - prohibited entirely
  - allowed as append-only late records
  - allowed only with reason and role
- This is a **Needs confirmation** item

---

## ADR-006 — APIM as mandatory gateway for all model traffic
**Status:** Proposed

**Decision:** All Foundry/model calls must traverse Azure API Management.

**Why:**
- Matches stated governance constraint
- Centralizes quotas, content safety, correlation, and policy enforcement
- Supports proof that prohibited data is not sent to prompts

**Consequences:**
- Agent workflow must use APIM endpoint only
- Prompt payload contracts should be reviewed and logged at metadata level

---

## ADR-007 — Package-level authorization enforced server-side
**Status:** Proposed

**Decision:** Every package/item/evidence/daily-record request is authorized against project and package assignment in the API layer, not just in UI.

**Why:**
- Strict subcontractor isolation is a hard requirement
- UI-only filtering is insufficient

**Consequences:**
- Need package assignment cache or lookup strategy
- Need row-level filtering pattern in service layer and query layer

---

## 4. Proposed deployment architecture

## 4.1 Azure resources
- **Azure App Service Premium v3**
  - FastAPI Progress Service
- **Azure Functions**
  - Daily Record Locker
  - Valuation Assembler
  - scheduled maintenance jobs
- **Azure SQL Database**
- **Azure Storage Account**
  - Blob containers for evidence and valuation packs
- **Azure API Management**
  - client/API gateway policies
  - model gateway route
- **Microsoft Entra ID / Entra External ID**
- **Application Insights / Azure Monitor**
- **Key Vault** for secrets/certs if needed by platform pattern
- **Foundry project with Microsoft Agent Framework**
  - daily narrative agent
  - disruption pattern agent

## 4.2 Environment topology
For Dev:
- Single primary region is acceptable for development
- Paired-region warm standby can be deferred in Dev if cost-constrained, but production design should preserve it

**Needs confirmation:** whether Dev must mirror production HA topology.

---

## 5. Domain model recommendation

## 5.1 Core entities

### Project
- `project_id`
- `name`
- `boundary_geojson` or equivalent
- `daily_cutoff_time`
- `timezone`

### WorkPackage
- `work_package_id`
- `project_id`
- `external_package_ref`
- `title`
- `zone`
- `level`
- `subcontractor_id`
- `status`
- `last_source_sync_at`
- `source_version`

### MeasuredItem
- `measured_item_id`
- `work_package_id`
- `external_item_ref`
- `description`
- `unit`
- `contract_quantity`
- `evidence_threshold_rule`
- `variation_allowed`

### ProgressEntry
- `progress_entry_id`
- `project_id`
- `work_package_id`
- `measured_item_id`
- `captured_by_user_id`
- `capture_local_at`
- `received_server_at`
- `effective_site_date`
- `quantity_installed`
- `location_type` (`grid_ref`, `level`, `geo`, `manual`)
- `location_value`
- `geo_lat`
- `geo_lon`
- `location_source`
- `variation_reference`
- `entry_status` (`accepted`, `rejected`, `late`, `superseded`)
- `offline_submission_id`
- `content_hash`

### EvidenceAsset
- `evidence_asset_id`
- `progress_entry_id` nullable if linked later
- `project_id`
- `work_package_id`
- `measured_item_id`
- `blob_uri`
- `blob_version_id`
- `capture_local_at`
- `uploaded_at`
- `captured_by_user_id`
- `location_value`
- `location_source`
- `description_alt_text`
- `mime_type`
- `sha256`
- `upload_status`

### DailyRecord
- `daily_record_id`
- `project_id`
- `site_date`
- `created_by_user_id`
- `weather_summary`
- `labour_summary`
- `plant_summary`
- `state` (`draft`, `submitted`, `locked`)
- `submitted_at`
- `locked_at`
- `late_entry_policy_applied`

### DisruptionEvent
- `disruption_event_id`
- `daily_record_id`
- `event_type`
- `description`
- `started_at`
- `ended_at`
- `impact_area`
- `captured_at`
- `captured_by_user_id`

### ValuationPeriod
- `valuation_period_id`
- `project_id`
- `period_start`
- `period_end`
- `state` (`draft`, `assembled`, `reviewed`, `approved`, `published`)
- `assembled_at`
- `approved_at`
- `approved_by_user_id`

### ValuationLine
- `valuation_line_id`
- `valuation_period_id`
- `work_package_id`
- `measured_item_id`
- `quantity_this_period`
- `rate`
- `amount`
- `evidence_status` (`evidenced`, `unevidenced`, `partial`)
- `source_snapshot_ref`

### NarrativeDraft
- `narrative_draft_id`
- `daily_record_id` or `valuation_period_id`
- `prompt_contract_version`
- `input_snapshot_ref`
- `draft_text`
- `review_status`
- `reviewed_by`
- `reviewed_at`

### AuditEvent
- `audit_event_id`
- `actor_user_id`
- `actor_role`
- `action`
- `entity_type`
- `entity_id`
- `occurred_at`
- `correlation_id`
- `before_json`
- `after_json`

---

## 6. Data contract recommendations

## 6.1 Progress capture request
```json
{
  "offlineSubmissionId": "7f9b2d8a-4f5c-4f7f-9e2a-1f0d2f4d1abc",
  "workPackageId": "WP-123",
  "measuredItemId": "MI-456",
  "quantityInstalled": 12.5,
  "captureLocalAt": "2026-08-27T10:14:22+01:00",
  "effectiveSiteDate": "2026-08-27",
  "location": {
    "type": "grid_ref",
    "value": "Grid A3 / Level 02",
    "source": "manual",
    "geo": {
      "lat": 51.501,
      "lon": -0.141
    }
  },
  "variationReference": null,
  "evidenceIds": [
    "EV-001",
    "EV-002"
  ]
}
```

### Validation rules
- `quantityInstalled > 0`
- `workPackageId` and `measuredItemId` must be assigned and related
- cumulative quantity cannot exceed contract quantity unless `variationReference` supplied
- location required
- evidence required when item threshold rule applies
- request rejected if package/item not authorized
- request rejected or marked late based on daily lock policy

## 6.2 Progress capture response
```json
{
  "progressEntryId": "PE-789",
  "status": "accepted",
  "receivedServerAt": "2026-08-27T10:16:03Z",
  "effectiveSiteDate": "2026-08-27",
  "cumulativeQuantity": 148.5,
  "contractQuantity": 200.0,
  "isLate": false,
  "auditRef": "AUD-12345"
}
```

## 6.3 Evidence upload metadata contract
```json
{
  "evidenceId": "EV-001",
  "workPackageId": "WP-123",
  "measuredItemId": "MI-456",
  "captureLocalAt": "2026-08-27T10:12:00+01:00",
  "location": {
    "type": "level",
    "value": "Basement B2",
    "source": "device"
  },
  "descriptionAltText": "Installed ductwork along corridor wall",
  "sha256": "base64-or-hex",
  "mimeType": "image/jpeg"
}
```

## 6.4 Daily record contract
```json
{
  "projectId": "PRJ-001",
  "siteDate": "2026-08-27",
  "weather": {
    "conditions": "Heavy rain AM, overcast PM",
    "temperatureMinC": 12,
    "temperatureMaxC": 17
  },
  "labour": [
    { "trade": "Groundworks", "headcount": 8 },
    { "trade": "Steelwork", "headcount": 5 }
  ],
  "plant": [
    { "type": "Excavator", "count": 2 }
  ],
  "disruptions": [
    {
      "eventType": "weather",
      "description": "Crane lift suspended due to wind",
      "startedAt": "2026-08-27T09:10:00+01:00",
      "endedAt": "2026-08-27T11:00:00+01:00"
    }
  ]
}
```

---

## 7. API surface recommendation

## 7.1 Client-facing APIs
Suggested REST endpoints:

### Package and item retrieval
- `GET /projects/{projectId}/work-packages`
- `GET /work-packages/{workPackageId}`
- `GET /work-packages/{workPackageId}/measured-items`

### Progress capture
- `POST /progress-entries`
- `GET /progress-entries/{progressEntryId}`
- `GET /work-packages/{workPackageId}/progress-summary`

### Evidence
- `POST /evidence/upload-session` or proxied upload initiation
- `POST /evidence/metadata`
- `GET /valuation-lines/{valuationLineId}/evidence`
- `GET /evidence/{evidenceId}`

### Daily record
- `GET /projects/{projectId}/daily-records/{siteDate}`
- `PUT /projects/{projectId}/daily-records/{siteDate}`
- `POST /projects/{projectId}/daily-records/{siteDate}/submit`
- `GET /projects/{projectId}/daily-records/{siteDate}/status`

### Valuation
- `POST /projects/{projectId}/valuations/assemble`
- `GET /projects/{projectId}/valuations/{valuationPeriodId}`
- `POST /projects/{projectId}/valuations/{valuationPeriodId}/review`
- `POST /projects/{projectId}/valuations/{valuationPeriodId}/approve`

### Narrative workflow
- `POST /daily-records/{dailyRecordId}/narrative/draft`
- `GET /daily-records/{dailyRecordId}/narrative`
- `POST /daily-records/{dailyRecordId}/narrative/review`

## 7.2 Integration APIs
- Commercial work package API
- Commercial rate API
- Programme milestone API
- Foundry model endpoint via APIM only

---

## 8. Sync and offline architecture

## 8.1 Recommended client sync pattern
Use a **local outbox/inbox pattern**:

### Local stores
- `package_cache`
- `measured_item_cache`
- `progress_outbox`
- `evidence_outbox`
- `daily_record_draft`
- `sync_status`
- `auth/session metadata`

### Sync flow
1. User captures progress/evidence offline
2. Entry stored locally with `offlineSubmissionId`
3. Evidence stored locally pending upload
4. On reconnection:
   - upload evidence binaries
   - submit evidence metadata
   - submit progress entry referencing evidence IDs
5. Server returns accepted/rejected/late state
6. Client updates local status and UI

## 8.2 Idempotency
Required:
- `offlineSubmissionId` unique per client submission
- API should treat retries idempotently
- Evidence upload should use content hash to prevent duplicate blobs where feasible

## 8.3 Conflict handling
Expected conflict cases:
- package assignment changed while offline
- item contract quantity changed since cache
- daily record locked before sync
- variation reference missing for now-excess cumulative quantity
- duplicate submission after retry

Recommended behavior:
- preserve original local record
- mark sync result explicitly
- require user review for rejected items
- never silently discard

---

## 9. Security architecture and threat-model considerations

## 9.1 Primary security requirements
- Enforce package-level authorization server-side
- Separate internal and subcontractor identities
- Protect evidence and valuation data for 12-year retention
- Prevent prompt leakage of commercial rates or restricted data
- Preserve non-repudiation and auditability

## 9.2 Threat model summary using STRIDE

### Spoofing
Threats:
- stolen tablet session
- impersonated subcontractor account
- forged API requests

Mitigations:
- Entra ID / External ID
- short-lived tokens
- device/session timeout
- conditional access where approved
- server-side authorization on every request
- correlation IDs and audit logs

### Tampering
Threats:
- altered offline payloads
- modified evidence files
- post-approval evidence replacement

Mitigations:
- server-side validation
- content hash for evidence
- immutable blob policies after approval
- append-only audit trail
- no in-place edits for saved entries

### Repudiation
Threats:
- user denies capture or approval
- dispute over when record was created

Mitigations:
- store local capture time, server receipt time, user identity, device/app version
- immutable audit events
- approval events with actor and timestamp

### Information disclosure
Threats:
- subcontractor sees another package
- evidence exposed via insecure URLs
- AI prompt includes rates or sensitive commercial data

Mitigations:
- package-scoped authorization
- avoid public blob access
- time-limited access tokens or API proxy
- APIM policy to inspect/limit model payloads
- prompt contracts excluding rates unless explicitly approved

### Denial of service
Threats:
- end-of-shift sync surge
- oversized image uploads
- dependency outages

Mitigations:
- queue-friendly upload pattern
- image size limits and compression
- autoscaling App Service plan
- retries with backoff
- cached package reads when source unavailable
- fail closed for valuation/rate dependency

### Elevation of privilege
Threats:
- engineer invoking commercial approval endpoints
- subcontractor enumerating package IDs

Mitigations:
- role-based authorization plus package scope checks
- opaque IDs where practical
- deny-by-default API policies
- audit unauthorized attempts

## 9.3 Specific AI governance controls
- All model traffic through APIM
- Prompt input contract limited to captured operational facts
- Exclude commercial rates unless approved use case requires them
- Human review required before narrative attachment
- Log prompt/response metadata, not sensitive raw content unless governance approves
- Content safety and quota policies in APIM

---

## 10. Non-functional design alignment

## 10.1 Availability and resilience
- Client must remain usable offline for core capture
- Package cache available when commercial package API unavailable
- Valuation assembly must fail closed if rates unavailable
- Narrative workflow failure must not block core capture

## 10.2 Performance
Targets inferred from requirements:
- package progress updates reflected within 5 minutes
- offline evidence uploads within 5 minutes of reconnection under normal conditions
- source API timeout 3 seconds per technical requirements

Recommendation:
- asynchronous summary refresh for package progress
- precomputed progress summary table/materialized pattern if needed

## 10.3 Audit and retention
- photographs and approved packs retained 12 years
- immutable retention after valuation approval
- audit events retained per compliance policy
- daily record lock events must be durable and queryable

## 10.4 Accessibility and field usability
- large touch targets
- high contrast modes
- explicit text labels, not icon-only states
- manual location entry always available
- queue/sync state visible in plain language

---

## 11. Sequence recommendations

## 11.1 Progress capture with evidence
```text
Engineer -> Client: capture quantity + location + photos
Client -> Local store: save draft/outbox
Client -> Blob/API: upload evidence on reconnect
Client -> Progress API: submit progress with evidence refs
Progress API -> SQL: validate and persist
Progress API -> Client: accepted/rejected/late
Client -> UI: show sync state
```

## 11.2 Daily record lock
```text
Scheduler -> Daily Record Locker Function
Function -> SQL: find records past cutoff
Function -> SQL: transition submitted/draft to locked per policy
Function -> Audit: write lock events
```

## 11.3 Narrative draft
```text
User -> Progress API: request draft
Progress API -> APIM -> Agent Framework/Foundry
Agent -> APIM -> Progress API: draft response
Progress API -> SQL: store draft pending review
Commercial Manager -> API/UI: approve/reject/edit outcome
```

---

## 12. Implementation plan

## Phase 1 — Foundation
- Set up repo structure and CI/CD
- Provision Dev Azure baseline
- Establish Entra auth integration
- Define OpenAPI contracts
- Create SQL schema baseline
- Implement package cache integration
- Implement audit/correlation framework

## Phase 2 — Offline capture MVP
- Package list and measured item retrieval
- Local cache and outbox
- Progress capture API
- Evidence metadata and upload flow
- Sync status UX
- Package-scoped authorization

## Phase 3 — Daily record and locking
- Daily record UI/API
- disruption event model
- scheduled locker function
- late-entry policy implementation
- audit/reporting for lock state

## Phase 4 — Valuation workflow
- valuation period model
- assembler function
- rate API integration
- unevidenced line flags
- review/approval workflow
- generated pack output to Blob

## Phase 5 — Narrative workflow
- APIM model route
- Agent Framework workflow
- prompt contracts
- human review UI
- governance logging

## Phase 6 — Hardening
- performance testing for end-of-shift sync
- security testing for package isolation
- retention/immutability configuration
- observability dashboards
- DR/runbook documentation

---

## 13. Recommended backlog for technical delivery

## Must-have engineering stories
1. Define canonical package/item/progress/evidence schema
2. Implement package-scoped authorization middleware
3. Implement offline outbox with idempotent submission
4. Implement evidence upload and metadata persistence
5. Implement cumulative quantity validation with variation rule
6. Implement daily record state machine and lock scheduler
7. Implement valuation assembly with fail-closed rate retrieval
8. Implement immutable storage policy for approved evidence/packs
9. Implement APIM-routed model integration only
10. Implement audit trail and correlation IDs end-to-end

## Should-have engineering stories
1. Precomputed progress summaries
2. Duplicate image detection via hash
3. Device/app version capture for supportability
4. Admin tooling for rejected sync resolution
5. Operational dashboards for stale packages and sync failures

---

## 14. Open issues / needs confirmation

1. **Late-entry policy**
   - Are post-cutoff additions prohibited, or allowed as append-only late records with reason?
2. **Correction model**
   - How should erroneous saved progress entries be corrected?
3. **Evidence threshold rules**
   - Which item types require mandatory photos and at what threshold?
4. **Location model**
   - Is project-standard location primarily grid reference, level, geofence, or mixed?
5. **Subcontractor assignment source**
   - Which system is authoritative for package-to-subcontractor mapping?
6. **Valuation approval roles**
   - Is QS review separate from commercial manager approval in all cases?
7. **Narrative storage**
   - Should reviewed narrative become part of immutable record after approval?
8. **Dev HA expectations**
   - Must Dev include paired-region standby?
9. **Blob immutability timing**
   - On upload, on valuation approval, or both?
10. **Prompt data policy**
   - Confirm exact fields allowed into model prompts

---

## 15. Reviewable proposal summary

## Recommended architecture
Approve, subject to confirmation of the open issues above:
- Angular/Ionic offline-capable client
- FastAPI domain API on App Service
- Azure SQL + Blob Storage
- Azure Functions for lock/assembly jobs
- Entra/External ID for identity
- APIM-governed Agent Framework/Foundry workflow

## Why this is reviewable
It:
- aligns with the approved stack
- preserves commercial system boundaries
- supports offline capture and evidential integrity
- enforces subcontractor isolation
- keeps AI usage governed and human-reviewed

If helpful, I can next convert this into:
1. a **formal ADR set**,  
2. a **C4-style architecture pack**, or  
3. a **detailed API/OpenAPI draft and SQL schema proposal**.