# Requirements Agent — Plan-Stage Proposal

**Project:** Construction Site Progress Capture  
**Environment:** Dev  
**Status:** Proposed for review — not approved for implementation  
**Source basis:** Three intake documents were supplied. All are marked **Draft, version 1.0, dated 24 August 2026**. No approved artifacts were supplied. The requirements and technical extracts are incomplete near the later user stories and API requirements; items identified as proposed below require confirmation.

---

## 1. Proposed product outcome

Site engineers can record installed quantities, location, photographs, weather, labour, plant, and disruption events at the point of work, including when offline. Quantity surveyors can then prepare, review, and approve valuations using captured quantities and linked evidence.

### Success measures

| Outcome | Baseline | Target |
|---|---:|---:|
| Valuation lines supported by captured quantities and evidence | 48% | 95% |
| Period end to submitted payment application | 12 days | 4 days |
| Disruption events recorded on the day | 27% | 90% |
| Valuation lines subsequently reduced after client challenge | 14% | 4% |

---

## 2. Scope proposal

### In scope

- Work-package and measured-item progress capture.
- Quantity installed and cumulative quantity display.
- Location capture using grid reference, level, and device geolocation where available.
- Photographic evidence linked to package, item, location, date/time, and user.
- Offline capture and synchronisation on reconnection.
- Daily site records covering weather, labour, plant, and disruption.
- Daily-record cut-off, locking, and late-entry handling.
- Valuation preparation from captured quantities and commercial rates.
- Quantity surveyor review and commercial approval.
- Evidence completeness and unevidenced-line handling.
- Role-based access and strict subcontractor package isolation.
- Agent-assisted daily narrative and disruption-pattern analysis, subject to human approval.
- Immutable retention of approved valuation packs and photographs.

### Out of scope

- Design authoring, drawing revision control, and model federation.
- Procurement, subcontract letting, and supplier payment processing.
- Programme scheduling and critical-path analysis.
- Health and safety incident reporting.
- New analytics outside existing commercial reporting.

---

# 3. Proposed delivery structure

| Epic | Outcome |
|---|---|
| **EPIC-01** | Construction Site Progress Capture — capture progress and contemporaneous site conditions, then produce evidence-backed valuations. |

| Feature | Outcome |
|---|---|
| **FEAT-01** | Work package and measured-item progress capture |
| **FEAT-02** | Evidence and location capture |
| **FEAT-03** | Daily site record |
| **FEAT-04** | Valuation preparation and approval |
| **FEAT-05** | Offline synchronisation and record integrity |
| **FEAT-06** | Identity, package isolation, and auditability |
| **FEAT-07** | Assisted narrative and disruption analysis |

---

# 4. Traceable user stories

## FEAT-01 — Work Package Progress Capture

### US-101 — Record installed quantity

**As a** site engineer,  
**I want** to record quantity installed against a measured item at the point of work,  
**so that** the quantity reflects what was built rather than what was remembered.

**Acceptance criteria**

1. Given an assigned package and measured item, when a valid quantity is entered, then it is stored against the item, package, location, user, and capture date/time.
2. The item view displays quantity entered today, cumulative captured quantity, contract quantity, and unit.
3. If cumulative quantity would exceed the contract quantity, submission is blocked unless a valid variation reference is supplied.
4. A quantity accepted under a variation reference is visibly marked as variation-related.
5. A saved progress entry cannot be edited or deleted by the site engineer.

**Priority:** Must  
**Traceability:** Requirements US-101; UX SCR-02

### US-102 — View package progress

**As a** project manager,  
**I want** progress visible by work package as it is captured,  
**so that** I can see the current position without waiting for a monthly return.

**Acceptance criteria**

1. Successful online captures are reflected in item and package percentages within five minutes under normal operating conditions.
2. A package with no capture for seven days is flagged as stale.
3. The stale state distinguishes lack of recording from lack of physical progress.
4. Cached package data is labelled with its age when the package API is unavailable.

**Priority:** Should  
**Traceability:** Requirements US-102; UX SCR-01

### Proposed US-103 — Enforce package assignment

**As a** project administrator,  
**I want** package access derived from user and subcontractor assignment,  
**so that** unauthorised users cannot view or capture against another party’s work.

**Acceptance criteria**

1. Engineers can access only authorised project packages.
2. Subcontractor users can access only their assigned packages.
3. Commercial users can access all packages within their authorised project scope.
4. Unauthorised package requests are rejected server-side and audit logged.
5. Access changes are applied when identity or assignment data changes.

**Priority:** Must  
**Traceability:** Technical requirements §1–§2; UX role definitions

---

## FEAT-02 — Evidence and Location Capture

### US-201 — Link photographs to progress

**As a** site engineer,  
**I want** photographs tied automatically to the package, item, location, and capture time,  
**so that** evidence can be retrieved later without searching a camera roll.

**Acceptance criteria**

1. A photograph is linked to project, package, measured item, location, capture time, and capturing user.
2. The source of location is recorded as device-derived or manually entered.
3. Offline photographs are queued locally with original capture time and location preserved.
4. Queued evidence uploads within five minutes of reconnection under normal conditions.
5. Each photograph supports a short description for accessible identification.
6. Upload failures remain visible and are not silently discarded.

**Priority:** Must  
**Traceability:** Requirements US-201; UX SCR-02

### US-202 — Retrieve valuation evidence

**As a** quantity surveyor,  
**I want** to retrieve evidence behind each valuation line,  
**so that** client challenges can be answered from the record.

**Acceptance criteria**

1. A valuation line lists every contributing progress entry and photograph.
2. Evidence displays capture date/time, location, measured item, and contributor.
3. Missing mandatory evidence causes the line to be flagged as unevidenced.
4. Unevidenced lines are not included silently; they are excluded or require an authorised, reasoned override.
5. Evidence access follows project and role permissions.

**Priority:** Must  
**Traceability:** Requirements US-202; UX SCR-04

### Proposed US-203 — Capture mandatory location

**As a** site engineer,  
**I want** to capture the grid reference or level for each entry,  
**so that** the installed work can be located later.

**Acceptance criteria**

1. Location is mandatory before a progress entry can be saved.
2. Device geolocation is offered where available.
3. Manual grid reference or level entry remains available.
4. A position outside the project boundary requires explicit confirmation.
5. The record identifies device-derived versus manually entered location.

**Priority:** Must  
**Traceability:** UX SCR-02

---

## FEAT-03 — Daily Site Record

### Proposed US-301 — Record daily conditions

**As a** site engineer,  
**I want** to record weather, labour, and plant daily,  
**so that** the site record reflects the facts of the day.

**Acceptance criteria**

1. The daily record supports weather observations, labour, and plant entries.
2. Each record is associated with project, site day, author, and capture timestamp.
3. The record can be captured offline.
4. The system preserves the author and capture time for each section.
5. Entries after the daily cut-off are marked as late.

**Priority:** Must  
**Traceability:** Requirements §1.2 and FEAT-03; UX SCR-03

### Proposed US-302 — Record disruption

**As a** site engineer,  
**I want** to record disruption events when they occur,  
**so that** delay and disruption claims have contemporaneous support.

**Acceptance criteria**

1. A disruption captures type, description, event start, event end or ongoing state, affected package/location, and author.
2. Photographs may be attached to the event.
3. Event time and record-capture time are stored separately.
4. Entries after cut-off are visibly marked late.
5. Disruption information is visible only to authorised project and commercial users.

**Priority:** Must  
**Traceability:** Requirements success measure; technical requirements §1

### Proposed US-303 — Lock daily record

**As a** commercial manager,  
**I want** the daily record to lock at a defined cut-off,  
**so that** it remains reliable as contemporaneous evidence.

**Acceptance criteria**

1. The project timezone and daily cut-off are configurable.
2. At cut-off, the record transitions to locked status.
3. A late entry cannot overwrite the locked record.
4. Corrections use an append-only amendment or linked correction with reason.
5. Lock, late-entry, and amendment actions are audit logged.

**Priority:** Must  
**Traceability:** Technical requirements §1; UX SCR-03

---

## FEAT-04 — Valuation Preparation and Approval

### Proposed US-401 — Assemble valuation

**As a** quantity surveyor,  
**I want** to assemble a valuation from captured quantities and current contract rates,  
**so that** the application reflects evidenced work in the selected period.

**Acceptance criteria**

1. Project and valuation period are explicit.
2. Eligible progress entries are aggregated by valuation line.
3. Rates are retrieved from the commercial rate API.
4. Each line links to source quantities and evidence status.
5. Rate API exhaustion causes assembly to fail closed with a stated reason.
6. A stale package schedule blocks assembly but does not block progress capture.
7. Unevidenced lines are flagged before review.

**Priority:** Must  
**Traceability:** Requirements §1.2; technical API requirements

### Proposed US-402 — Review valuation

**As a** quantity surveyor,  
**I want** to review quantities, evidence, exceptions, and late entries,  
**so that** issues are resolved before approval.

**Acceptance criteria**

1. Review shows quantity, rate, value, source entries, evidence status, and exceptions.
2. The QS can filter unevidenced, late, variation-related, and failed lines.
3. Overrides require a reason and are audit logged.
4. The preparer cannot approve their own valuation where segregation of duties applies.
5. Blocking exceptions prevent approval until resolved or explicitly authorised.

**Priority:** Must  
**Traceability:** Technical requirements; UX SCR-04

### Proposed US-403 — Approve and retain pack

**As a** commercial manager,  
**I want** to approve the reviewed valuation and retain the application pack,  
**so that** the submission has a durable audit record.

**Acceptance criteria**

1. Approval requires an authorised commercial manager.
2. Approval records approver, timestamp, valuation version, and decision.
3. Approved valuations and packs are immutable.
4. The pack includes lines, source quantities, evidence references, exceptions, overrides, and approval history.
5. Approved photographs and packs use retention-controlled or immutable Blob storage.
6. Rejected valuations return to review with a reason.

**Priority:** Must  
**Traceability:** Technical requirements §2; UX SCR-04

---

## FEAT-05 — Offline Synchronisation

### Proposed US-501 — Capture without connectivity

**As a** site engineer,  
**I want** to capture progress, evidence, and daily records offline,  
**so that** poor signal does not force delayed or reconstructed records.

**Acceptance criteria**

1. The client displays a clear offline state.
2. Previously synchronised packages and items remain available offline with cache age.
3. Offline records are stored in an encrypted local queue.
4. Original capture timestamp and local record identity are preserved.
5. The user can see queued, synchronising, synchronised, and failed states.

**Priority:** Must  
**Traceability:** Requirements §1.2; technical requirements §1; UX offline states

### Proposed US-502 — Synchronise safely

**As a** site engineer,  
**I want** queued records to synchronise safely after reconnection,  
**so that** entries are not lost or duplicated.

**Acceptance criteria**

1. Synchronisation starts when connectivity is restored.
2. Retries use bounded backoff.
3. Idempotency prevents duplicate progress entries or evidence links.
4. Failed entries remain available for retry or resolution.
5. Records crossing the daily cut-off while offline follow the late-entry rules.
6. Synchronisation outcomes are audit logged.

**Priority:** Must  
**Traceability:** Requirements US-201; technical integration failure requirements

---

## FEAT-06 — Access and Audit

### Proposed US-601 — Enforce identity and role boundaries

**Acceptance criteria**

1. Delivery users authenticate using Microsoft Entra ID.
2. Subcontractor users use Entra External ID where approved.
3. Subcontractors cannot access another subcontractor’s package, evidence, daily record, or valuation.
4. Commercial rates are not exposed to unauthorised users or agent prompts.
5. Revoked access prevents subsequent authorised operations.

**Priority:** Must  
**Traceability:** Technical requirements §2; UX role definitions

### Proposed US-602 — Audit material actions

**Acceptance criteria**

1. Audit events record actor, action, object, timestamp, outcome, and correlation ID.
2. The system logs late entries, overrides, approvals, rejections, failed access, and synchronisation outcomes.
3. Audit records cannot be altered through the application.
4. Authorised users can retrieve audit history by project and period.

**Priority:** Must  
**Traceability:** Technical requirements §1–§2

---

## FEAT-07 — Governed Agent Assistance

### Proposed US-701 — Draft daily narrative

**As a** commercial manager,  
**I want** an agent to draft a daily narrative from authorised captured records,  
**so that** I can review site progress and conditions efficiently.

**Acceptance criteria**

1. Model traffic is routed through Azure API Management.
2. APIM uses managed identity, quotas, content-safety controls, and correlation headers.
3. Agent context contains only approved, authorised source records.
4. The output distinguishes captured facts from generated interpretation.
5. A commercial manager must review and approve the narrative before attachment to an official record.
6. Agent failure does not block progress capture, daily records, or valuation.

**Priority:** Should  
**Traceability:** Technical requirements §1–§2

### Proposed US-702 — Highlight disruption patterns

**Acceptance criteria**

1. Each highlighted pattern identifies its supporting source records.
2. Incomplete evidence is explicitly qualified.
3. The agent does not make an unreviewed claim determination.
4. Human edits and approval decisions are retained.
5. Commercial rates and unrelated subcontractor data are excluded from model context.

**Priority:** Should  
**Traceability:** Technical requirements §1–§2

---

# 5. Proposed non-functional requirements

The supplied extracts reference NFR identifiers but do not include the full NFR section. These are proposed for confirmation.

| ID | Requirement | Verification |
|---|---|---|
| NFR-001 | Online package progress reflects successful captures within five minutes under normal conditions. | Performance test |
| NFR-002 | Package API uses a three-second timeout and three retries with backoff; exhausted failure serves aged cache and blocks valuation. | Resilience test |
| NFR-003 | Offline records preserve original capture time, location, and identity; queued evidence synchronises within five minutes of reconnection under normal conditions. | Field/offline test |
| NFR-004 | Server-side authorization enforces project and subcontractor package isolation. | Security and negative-access testing |
| NFR-005 | Photographs and approved application packs are retained for 12 years and protected from alteration. | Storage and immutability test |
| NFR-006 | All model traffic uses APIM with managed identity, quotas, content safety, and correlation headers. | Gateway/configuration review |
| NFR-007 | The client supports the specified Android tablet field context and accessible commercial browser view. | Device, accessibility, and usability testing |
| NFR-008 | The Dev deployment uses the approved Azure hosting, identity, storage, database, and CI/CD patterns. | Architecture/deployment review |
| NFR-009 | Agent prompts do not contain commercial rates or unauthorised subcontractor information. | Data-flow and prompt inspection |
| NFR-010 | Material actions have tamper-evident audit history. | Audit integrity test |

---

# 6. Proposed technical plan

## Architecture baseline

| Component | Proposed technology | Responsibility |
|---|---|---|
| Field/commercial client | Angular 18, TypeScript, Ionic 8 | Capture, commercial views, camera, geolocation, offline queue |
| API | Python 3.12, FastAPI, Azure App Service | Progress, evidence linkage, daily records, authorization, valuation orchestration |
| Relational data | Azure SQL Database | Packages, items, progress, daily records, valuations, approvals, audit metadata |
| Evidence and packs | Azure Blob Storage | Photographs and generated packs, retention and immutability |
| Valuation assembler | Python 3.12 on Azure Functions | Period aggregation and rate integration |
| Daily-record locker | Python 3.12 on Azure Functions | Cut-off scheduling, locking, late-entry marking |
| Agent workflow | Microsoft Foundry with Microsoft Agent Framework | Narrative and disruption drafts, human review pause |
| Model gateway | Azure API Management | Managed identity, quotas, content safety, correlation |
| Identity | Microsoft Entra ID / Entra External ID | Workforce and subcontractor authentication |
| CI/CD | GitHub Actions | Build, provenance, protected Dev deployment |

---

# 7. Proposed implementation tasks

## Foundation

- **TASK-001:** Confirm domain model and state transitions.
- **TASK-002:** Confirm commercial API contracts for packages, quantities, rates, and milestones.
- **TASK-003:** Define roles, project scope, subcontractor scope, and revocation behavior.
- **TASK-004:** Produce threat model and end-to-end data-flow diagram.
- **TASK-005:** Create Angular/Ionic, FastAPI, SQL, Blob, Functions, App Service, and CI/CD foundations.
- **TASK-006:** Define API versioning, correlation IDs, idempotency, error responses, and audit schema.

## Progress and evidence

- **TASK-101:** Implement scoped work-package and measured-item retrieval with cache age.
- **TASK-102:** Implement quantity validation, cumulative calculations, variation references, and immutable progress saves.
- **TASK-103:** Implement package percentage, stale-capture, and behind-programme views.
- **TASK-104:** Implement camera, location, evidence descriptions, and progress linkage.
- **TASK-105:** Implement Blob upload, metadata, checksum/content validation, and retention settings.
- **TASK-106:** Implement encrypted local queue and synchronisation state machine.
- **TASK-107:** Test retries, interrupted uploads, duplicate prevention, and reconnect behavior.

## Daily record

- **TASK-201:** Implement weather, labour, plant, and disruption data model and screens.
- **TASK-202:** Implement project timezone and configurable daily cut-off.
- **TASK-203:** Implement scheduled locking and late-entry handling.
- **TASK-204:** Implement append-only amendments and audit history.
- **TASK-205:** Test offline records that cross the cut-off.

## Valuation

- **TASK-301:** Implement commercial API clients with managed identity, timeout, retries, and fail-closed behavior.
- **TASK-302:** Implement valuation-period selection and quantity aggregation.
- **TASK-303:** Implement evidence lineage and unevidenced-line detection.
- **TASK-304:** Implement QS review, filters, overrides, and reasons.
- **TASK-305:** Implement segregation-of-duties approval.
- **TASK-306:** Generate and immutably retain the application pack.
- **TASK-307:** Test stale schedules, unavailable rates, missing evidence, variations, rejection, and reapproval.

## Agent workflow

- **TASK-401:** Define agent input allow-list, exclusions, output schema, and retention policy.
- **TASK-402:** Configure APIM route, managed identity, quotas, content safety, and correlation.
- **TASK-403:** Implement narrative workflow with mandatory commercial review.
- **TASK-404:** Implement disruption-pattern output with source references and uncertainty.
- **TASK-405:** Test model failure, prompt injection in captured text, data leakage, and approval bypass.

---

# 8. Dependencies

1. Commercial work-package API and authoritative package/version semantics.
2. Commercial rate API and rate-effective-date behavior.
3. Programme milestone API, if “behind programme” remains in scope.
4. Microsoft Entra ID and Entra External ID tenant configuration.
5. Azure SQL, Blob Storage, Functions, App Service, APIM, and Foundry environments.
6. Device camera, geolocation, local storage, and supported Android tablet models.
7. Defined site timezone and daily cut-off.
8. Contract variation process and reference format.
9. Evidence threshold by measured-item type.
10. Existing valuation/application-pack format and commercial reporting integration.
11. Approved data-retention, privacy, and evidence-access policies.
12. Approved agent models, prompts, data boundaries, and human approval roles.

---

# 9. Key risks

| Risk | Rating | Mitigation |
|---|---:|---|
| Offline records are duplicated or lost | High | Durable encrypted queue, idempotency, explicit sync states, field testing |
| Subcontractor data isolation fails | Critical | Deny-by-default authorization, server-side filtering, negative security tests |
| Stale packages or rates are used for valuation | Critical | Cache-age display, package freshness gate, rate API fail-closed behavior |
| Locked records can be altered | High | Append-only amendments, scheduled lock, immutable audit events |
| Evidence is missing or cannot be traced to a line | High | Mandatory evidence rules, lineage model, blocking exceptions |
| Approved pack or evidence is altered | High | Blob immutability/retention policies, checksums, approval versioning |
| Agent output is treated as an approved claim | High | Draft-only output, source references, mandatory human approval |
| Sensitive commercial data reaches the model | Critical | Context allow-list, APIM controls, prompt inspection, leakage tests |
| Poor field usability reduces adoption | High | Field pilot under bright/dark/no-signal conditions; large touch targets and simple capture flow |
| Source requirements are incomplete | High | Resolve decisions below before establishing the implementation baseline |

---

# 10. Approval decisions required

The following decisions are blocking for a firm implementation baseline:

1. Exact daily-record cut-off time and project timezone.
2. Correction process after daily-record lock.
3. Evidence thresholds by item type.
4. Variation-reference validation and authorization.
5. Rules for excluding or overriding unevidenced valuation lines.
6. Commercial API contracts and system-of-record ownership for package versions and cumulative quantities.
7. Valuation/application-pack output format.
8. Supported Android tablet models and minimum OS version.
9. Required accessibility conformance level.
10. Location accuracy and project-boundary tolerance.
11. Photograph privacy, compression, metadata, and retention rules.
12. Agent input allow-list, approved model deployments, and generated-content retention.
13. RPO/RTO for the paired-region warm standby.
14. Whether the assisted narrative is included in the retained valuation/application pack.
15. Acceptance-test baselines for each success measure.

---

## Plan-stage recommendation

**Recommendation: Conditional approval for elaboration only.**

The supplied material is sufficient to proceed with domain modelling, API-contract discovery, UX clarification, threat modelling, and Dev environment design. It is **not yet sufficient for implementation approval** because the source documents are draft and incomplete, particularly around daily-record locking, valuation approval rules, non-functional requirements, integration contracts, evidence thresholds, and agent data boundaries.

**Next gate:** obtain the decisions above, update the requirements and technical documents to an approved version, then baseline the stories, acceptance criteria, and traceability matrix for implementation.