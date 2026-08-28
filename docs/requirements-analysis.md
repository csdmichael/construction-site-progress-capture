Construction Site Progress Capture – Plan Stage Proposal

This proposal is structured for review and approval, with traceability to business requirements, technical constraints, and UX inputs. All content is derived from untrusted intake documents and subject to human approval gates.

---

## 1. Epic

**EPIC-01: Construction Site Progress Capture**  
*Outcome Statement:*  
As a construction delivery organisation, we need site engineers to record progress, evidence, and daily site conditions against work packages as the work happens, so that valuations are produced from fact rather than recollection and disruption claims rest on a contemporaneous record.

---

## 2. Features

### FEAT-01: Work Package Progress Capture
- Presents work packages assigned to engineers with measured items.
- Records quantity installed at the point of work, not at period end.

### FEAT-02: Evidence and Location Capture
- Ties photographic evidence to work package, location, and date.
- Ensures evidence is retrievable for valuation lines.

### FEAT-03: Daily Site Record
- Captures weather, labour, plant, and disruption events daily.
- Locks daily record at cut-off; late entries are marked.

### FEAT-04: Valuation Preparation and Approval
- Assembles valuation from captured quantities and evidence.
- Supports review and approval workflow.

---

## 3. User Stories & Acceptance Criteria

### FEAT-01: Work Package Progress Capture

**US-101:**  
*As a site engineer, I want to record quantity installed against a measured item at the point of work, so that the figure reflects what was built rather than what was remembered.*  
- **Acceptance Criteria:**
  - Quantity is captured against item, location, and date.
  - Cumulative quantity shown vs contract quantity.
  - Submission blocked if cumulative exceeds contract quantity unless variation referenced.

**US-102:**  
*As a project manager, I want progress visible by work package as it is captured, so that I can see the true position without waiting for a monthly return.*  
- **Acceptance Criteria:**
  - Package view reflects captures within 5 minutes.
  - Packages with no capture for 7 days are flagged as stale.

### FEAT-02: Evidence and Location Capture

**US-201:**  
*As a site engineer, I want photographs tied to the work package and location automatically, so that evidence can be found later without searching a camera roll.*  
- **Acceptance Criteria:**
  - Photograph stored with package, item, location, and capture time.
  - Offline evidence queued locally; uploads within 5 minutes of reconnection.

**US-202:**  
*As a quantity surveyor, I want to retrieve the evidence behind any valuation line, so that a client challenge is answered from the record.*  
- **Acceptance Criteria:**
  - Valuation line shows all contributing photographs and progress entries.
  - Lines missing evidence are flagged as unevidenced.

### FEAT-03: Daily Site Record

**US-301:**  
*As a site engineer, I want to record weather, labour, and plant daily, so that the facts are captured contemporaneously.*  
- **Acceptance Criteria:**
  - Daily record locks at defined cut-off.
  - Late entries are marked as late.

### FEAT-04: Valuation Preparation and Approval

**US-401:**  
*As a quantity surveyor, I want to assemble a valuation from captured quantities and evidence, so that payment applications are supported by fact.*  
- **Acceptance Criteria:**
  - Valuation assembled from captured records.
  - Lines without evidence are flagged.
  - Approval workflow supports review and sign-off.

---

## 4. Tasks

- Design Angular/Ionic screens per UX mockups (SCR-01 to SCR-04).
- Implement offline-first progress capture with service worker.
- Integrate camera and geolocation APIs for evidence capture.
- Develop FastAPI endpoints for progress, evidence, daily record, and valuation.
- Configure Azure SQL for relational data; Blob storage for evidence.
- Implement daily record locking and late entry marking.
- Route all agent/model traffic through Azure API Management.
- Entra ID integration for user authentication and package scoping.
- GitHub Actions setup for CI/CD with environment protection.

---

## 5. Acceptance Criteria (Summary Table)

| Feature | User Story | Acceptance Criteria |
|---------|------------|--------------------|
| FEAT-01 | US-101     | Quantity captured, cumulative shown, excess blocked w/ variation |
| FEAT-01 | US-102     | Progress visible within 5 min, stale flagged after 7 days |
| FEAT-02 | US-201     | Photo tied to package/location/time, offline queue, upload on reconnect |
| FEAT-02 | US-202     | Evidence retrievable per valuation line, unevidenced flagged |
| FEAT-03 | US-301     | Daily record locks at cut-off, late marked |
| FEAT-04 | US-401     | Valuation from captured fact, unevidenced flagged, approval workflow |

---

## 6. Dependencies

- Commercial system APIs for work packages and rates (REST, OAuth2).
- Azure SQL and Blob Storage provisioned and accessible.
- Entra ID and Entra External ID configured for user roles.
- Azure API Management routing for agent/model traffic.
- Foundry agent workflow for daily narrative and disruption pattern analysis.
- GitHub Actions for CI/CD.

---

## 7. Risks

- **Offline Capture Reliability:** Signal loss in basements/steelwork may delay evidence upload; robust local queue required.
- **Data Isolation:** Subcontractor access must be strictly scoped; risk of cross-package visibility.
- **Evidence Integrity:** Blob storage must be immutable post-valuation approval; risk of evidence alteration.
- **API Availability:** Commercial system outages may block valuation assembly; fallback and cache age marking required.
- **Agent Workflow Approval:** Narrative and disruption patterns must pause for human review; risk if bypassed.
- **Accessibility:** Tablet UI must support gloved use, bright/dark conditions, and accessibility standards.

---

## 8. Traceability

- All features, user stories, and acceptance criteria are mapped to intake requirements and UX mockups.
- Technical stack and architecture conform to approved constraints.
- Success measures (audit, cycle time, disruption recording, challenge reduction) are supported by traceable records.

---

## 9. Review Gate

This proposal is ready for review. No external system changes are claimed. All requirements, tasks, and risks are traceable to intake documents and subject to approval.

---

**Please review and approve or return with comments.**