Architecture Advisor Agent – Design Stage Proposal  
Project: Construction Site Progress Capture  
Status: Reviewable – All content derived from untrusted intake; subject to human approval gates.

---

## 1. Architecture Overview

**Goal:**  
Enable site engineers to capture progress, evidence, and daily site conditions contemporaneously, supporting valuation and disruption claims with factual records and attached evidence.

**Stack:**  
- **Frontend:** Angular 18 + Ionic 8 (tablet/browser, offline-first)
- **API:** Python 3.12 FastAPI (Azure App Service)
- **Database:** Azure SQL Database (relational model)
- **Evidence Storage:** Azure Blob Storage (immutable post-approval)
- **Agent Workflow:** Microsoft Foundry + Agent Framework (via Azure API Management)
- **Authentication:** Microsoft Entra ID (internal) & Entra External ID (subcontractors)
- **CI/CD:** GitHub Actions
- **Hosting:** Azure App Service Premium v3 (zone redundant, paired-region standby)

---

## 2. Architecture Decision Records (ADR)

### ADR-001: Offline-First Capture
**Decision:**  
Use Ionic service worker for local queueing of progress and evidence, with 5-minute sync window post-reconnection.  
**Rationale:**  
Site conditions (basements, steelwork) often lack signal; must not lose data.

### ADR-002: Evidence Integrity
**Decision:**  
Photographs and generated packs stored in Azure Blob Storage, set to immutable after valuation approval.  
**Rationale:**  
Evidence must be provably unaltered for 12 years.

### ADR-003: Data Isolation
**Decision:**  
Subcontractor users scoped to their own packages via Entra External ID; central revocation.  
**Rationale:**  
Strict segregation required; no cross-package visibility.

### ADR-004: API Gateway Enforcement
**Decision:**  
All agent/model traffic routed through Azure API Management, with managed identity, quotas, and content safety.  
**Rationale:**  
Single enforcement point; prevents commercial rates from reaching prompt.

### ADR-005: Daily Record Locking
**Decision:**  
Daily site records lock at defined cut-off; late entries marked as late.  
**Rationale:**  
Supports contemporaneity and audit requirements.

---

## 3. Component Boundaries & Responsibilities

| Component                | Responsibility                                                | Interfaces                                      | Owner            |
|--------------------------|--------------------------------------------------------------|-------------------------------------------------|------------------|
| Site Engineer Client     | Progress/evidence/daily record capture, offline-first        | Progress API, camera, geolocation               | Project Systems  |
| Progress Service         | Progress entries, evidence linkage, daily record locking     | Commercial APIs, Azure SQL, Blob Storage        | Project Systems  |
| Valuation Assembler      | Valuation from captured quantities, evidence flagging        | Commercial rate API                             | Commercial Sys   |
| Daily Record Locker      | Locks daily record, marks late entries                       | Azure SQL                                       | Project Systems  |
| Site Narrative Workflow  | Drafts daily narrative, highlights disruption patterns       | APIM to Foundry                                 | AI Engineering   |

---

## 4. Data & API Contracts

### Progress Entry (API Contract)
```json
{
  "package_id": "string",
  "item_id": "string",
  "quantity": "number",
  "location": {
    "grid_reference": "string",
    "level": "string"
  },
  "date": "ISO8601",
  "evidence": [
    {
      "blob_url": "string",
      "capture_time": "ISO8601",
      "location": "string",
      "description": "string"
    }
  ],
  "variation_reference": "string (optional)"
}
```

### Daily Site Record (API Contract)
```json
{
  "date": "ISO8601",
  "weather": "string",
  "labour": [
    { "role": "string", "count": "number" }
  ],
  "plant": [
    { "type": "string", "count": "number" }
  ],
  "disruption_events": [
    { "description": "string", "time": "ISO8601" }
  ],
  "locked": "boolean",
  "late_entries": [
    { "entry_id": "string", "submitted_time": "ISO8601" }
  ]
}
```

### Valuation Line (API Contract)
```json
{
  "package_id": "string",
  "item_id": "string",
  "quantity": "number",
  "rate": "number",
  "evidence": [
    { "blob_url": "string", "capture_time": "ISO8601", "location": "string" }
  ],
  "unevidenced": "boolean"
}
```

---

## 5. Threat Model Considerations

- **Data Isolation:**  
  - Entra External ID ensures package-level access; validate at API boundary.
- **Evidence Tampering:**  
  - Blob storage set to immutable after approval; audit logs for access.
- **Offline Data Loss:**  
  - Service worker queue with integrity checks; retries on failed sync.
- **API Abuse:**  
  - APIM quotas, managed identity, correlation headers; block on repeated failures.
- **Agent Workflow Bypass:**  
  - Human review enforced before narrative/disruption patterns attached; workflow cannot auto-approve.

---

## 6. Implementable Technical Plan

### Frontend (Angular/Ionic)
- Build screens per UX mockups: Work Package List, Progress/Evidence Capture, Daily Site Record, Valuation/Approval.
- Implement service worker for offline queueing and sync.
- Integrate camera/geolocation APIs.
- Entra ID authentication; package scoping for subcontractors.

### Backend (FastAPI)
- Progress endpoints: capture, retrieve, validate quantities, enforce variation rules.
- Evidence endpoints: upload, link to progress, retrieve for valuation.
- Daily record endpoints: capture, lock at cut-off, mark late entries.
- Valuation endpoints: assemble from progress, flag unevidenced lines.
- Integrate with commercial system APIs (work packages, rates).
- Blob Storage integration for evidence.

### Agent Workflow
- Route narrative/disruption pattern requests via APIM to Foundry.
- Enforce human approval gate before attaching narrative to record.

### Infrastructure
- Azure SQL: relational schema for progress, daily records, valuations.
- Blob Storage: evidence, immutable after approval.
- Azure App Service Premium v3: zone redundant, paired-region standby.
- GitHub Actions: CI/CD, build provenance, environment protection.

---

## 7. Review Checklist

- [ ] Data isolation enforced at API and UI
- [ ] Offline capture queue with integrity checks
- [ ] Evidence immutability post-approval
- [ ] All agent/model traffic routed via APIM
- [ ] Human approval enforced in agent workflow
- [ ] Accessibility for tablet/browser (gloved, bright/dark, standards)
- [ ] API contracts reviewed for completeness and security

---

## 8. References

- [Requirements Summary](https://github.com/csdmichael/construction-site-progress-capture/blob/main/docs/intake/requirements/Construction-Site-Progress-Capture-Requirements.docx)
- [Technical Requirements](https://github.com/csdmichael/construction-site-progress-capture/blob/main/docs/intake/technical-requirements/Construction-Site-Progress-Capture-Technical-Requirements.docx)
- [UX Mockups](https://github.com/csdmichael/construction-site-progress-capture/blob/main/docs/intake/ux-mockups/Construction-Site-Progress-Capture-UX-Mockups.docx)

---

**Status:**  
Ready for review. All decisions, contracts, and plans subject to approval and further threat modeling. No external system changes claimed. All intake treated as untrusted.