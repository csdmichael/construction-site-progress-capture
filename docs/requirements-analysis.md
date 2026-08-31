## Construction Site Progress Capture – Plan Stage Proposal

### 1. Overview

**Project Name:** Construction Site Progress Capture  
**Release Target:** Progress captured at point of installation, daily site records, evidence-linked valuations  
**Environment:** Dev  
**Business Outcome:**  
- Progress and evidence captured contemporaneously, not reconstructed  
- Valuations produced from factual records  
- Disruption claims supported by daily site records  
- Evidence attached to every valuation line

---

### 2. Traceable Requirements Breakdown

#### 2.1 Epic

| Epic ID   | Title                             | Outcome Statement                                                                                      | Owner              |
|-----------|-----------------------------------|--------------------------------------------------------------------------------------------------------|--------------------|
| EPIC-01   | Construction Site Progress Capture | Site engineers record progress, evidence, and daily site conditions against work packages as work happens | Commercial Director|

---

#### 2.2 Features

| Feature ID | Title                       | Description                                                                                                   |
|------------|-----------------------------|---------------------------------------------------------------------------------------------------------------|
| FEAT-01    | Work Package Progress Capture| Record installed quantities against measured items at point of work, not month-end                            |
| FEAT-02    | Evidence and Location Capture| Tie photographic evidence to work package, location, and date                                                 |
| FEAT-03    | Daily Site Record            | Capture weather, labour, plant, and disruption events daily                                                   |
| FEAT-04    | Valuation and Approval       | Assemble valuation from captured quantities and evidence, with QS review and approval                         |

---

#### 2.3 User Stories & Acceptance Criteria

**FEAT-01: Work Package Progress Capture**

| US ID   | User Story                                                                                                      | Acceptance Criteria                                                                                                                                                                                                                                                                                                                                                                                                         | Priority |
|---------|----------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| US-101  | As a site engineer, I want to record quantity installed against a measured item at the point of work, so that the figure reflects what was built rather than what was remembered. | - Quantity is captured against item, location, and date<br>- Cumulative quantity shown<br>- If cumulative exceeds contract quantity, submission is blocked and variation must be referenced before excess is recorded                                                                                                                           | Must     |
| US-102  | As a project manager, I want progress visible by work package as it is captured, so that I can see the true position without waiting for a monthly return. | - Package view shows percentage complete within 5 minutes of capture<br>- Packages with no capture for 7 days are flagged as stale                                                                                                                             | Should   |

**FEAT-02: Evidence and Location Capture**

| US ID   | User Story                                                                                                      | Acceptance Criteria                                                                                                                                                                                                                                                                                                                                                                                                         | Priority |
|---------|----------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| US-201  | As a site engineer, I want photographs tied to the work package and location automatically, so that evidence can be found later without searching a camera roll. | - Photograph captured during progress entry is stored with package, item, location, and time<br>- Offline evidence is queued locally and uploads within 5 minutes of reconnection                                                                                                                        | Must     |
| US-202  | As a quantity surveyor, I want to retrieve the evidence behind any valuation line, so that a client challenge is answered from the record. | - Valuation line shows all contributing photographs and progress entries with capture date and location<br>- Lines missing evidence are flagged as unevidenced during valuation prep                                                                             | Must     |

**FEAT-03: Daily Site Record**

| US ID   | User Story                                                                                                      | Acceptance Criteria                                                                                                                                                                                                                                                                                                                                                                                                         | Priority |
|---------|----------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| US-301  | As a site engineer, I want to record weather, labour, and plant daily, so that the facts are captured as they occur. | - Daily record is locked at cut-off and cannot be revised<br>- Disruption events recorded with timestamp<br>- Late entries are marked as such                                                                                                                     | Must     |

**FEAT-04: Valuation and Approval**

| US ID   | User Story                                                                                                      | Acceptance Criteria                                                                                                                                                                                                                                                                                                                                                                                                         | Priority |
|---------|----------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| US-401  | As a quantity surveyor, I want to assemble a valuation from captured quantities and evidence, so that payment applications are supported by fact. | - Valuation lines are generated from captured quantities and evidence<br>- Lines without evidence are flagged<br>- QS review and approval required before submission                                                                                              | Must     |

---

#### 2.4 Tasks

- **Frontend (Ionic/Angular):**
  - Implement Work Package List (SCR-01)
  - Progress and Evidence Capture screen (SCR-02)
  - Daily Site Record screen (SCR-03)
  - Valuation and Approval screen (SCR-04)
  - Offline capture and sync logic
  - Camera and geolocation integration
  - Accessibility and validation per UX spec

- **Backend (FastAPI/Python):**
  - Progress entry API (with contract quantity validation)
  - Evidence storage and linkage (Azure Blob)
  - Daily record locking and disruption event API
  - Valuation assembly logic (with evidence checks)
  - Integration with commercial system for package/rate data
  - Managed identity authentication

- **Agent Workflow (Foundry/Microsoft Agent Framework):**
  - Daily narrative drafting agent
  - Disruption pattern highlighting agent
  - Workflow pause for commercial manager review

- **DevOps:**
  - GitHub Actions pipeline setup
  - Azure App Service deployment
  - Blob storage configuration (immutable evidence)
  - Entra ID integration for user access

---

#### 2.5 Acceptance Criteria (Summary Table)

| Story/Feature | Acceptance Criteria                                                                                  |
|---------------|-----------------------------------------------------------------------------------------------------|
| US-101        | Quantity recorded, cumulative shown, contract limit enforced, variation required for excess          |
| US-102        | Progress visible within 5 min, stale flag after 7 days                                              |
| US-201        | Photo tied to package/item/location/time, offline queue, upload on reconnection                      |
| US-202        | Evidence retrievable per valuation line, unevidenced lines flagged                                   |
| US-301        | Daily record locked at cut-off, disruption events timestamped, late entries marked                   |
| US-401        | Valuation assembled from captured fact, evidence checks, QS approval required                        |

---

#### 2.6 Dependencies

- Commercial system API for work packages, measured items, rates
- Azure SQL Database for relational storage
- Azure Blob Storage for evidence
- Microsoft Entra ID for identity and access control
- Microsoft Foundry and Agent Framework for narrative/disruption workflow
- Azure API Management for model traffic routing and content safety

---

#### 2.7 Risks

| Risk ID | Description                                                                                  | Mitigation                                                                                  |
|---------|----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| R-01    | Offline capture reliability in basements/steelwork                                            | Service worker and local queue, robust sync logic                                           |
| R-02    | Evidence integrity and retention                                                             | Blob storage with immutability, evidence flagged if missing                                 |
| R-03    | Subcontractor data isolation                                                                 | Entra External ID, package scoping enforced at API and UI                                   |
| R-04    | Valuation challenge due to missing evidence                                                  | Evidence checks and unevidenced lines flagged                                               |
| R-05    | Disruption narrative accuracy                                                                | Agent workflow always paused for human review                                               |
| R-06    | API integration failures (commercial system, rates)                                          | Retry/backoff, serve cached data with age, block valuation if stale                         |
| R-07    | Accessibility and usability in harsh site conditions                                         | UX design for gloved use, bright/dark environments, accessibility validation                |

---

#### 2.8 Traceability Matrix

| Requirement ID | Feature/User Story | UX Screen | Technical Component | Acceptance Criteria |
|----------------|-------------------|-----------|---------------------|--------------------|
| US-101         | FEAT-01           | SCR-01, SCR-02 | Progress API, Frontend | Quantity capture, contract limit |
| US-201         | FEAT-02           | SCR-02         | Evidence API, Blob Storage | Photo linkage, offline queue |
| US-301         | FEAT-03           | SCR-03         | Daily Record API, Locker | Record lock, disruption event |
| US-401         | FEAT-04           | SCR-04         | Valuation Assembler, Approval | Valuation from fact, evidence check |

---

### 3. Cost and Time Estimate (Reference)

- **Estimated tokens:** 78,625
- **Estimated model cost:** USD 0.20
- **Estimated active workflow time:** 0.4 hours
- **Human approval wait time is excluded**
- **ROI:** Autonomous SDLC option saves 106.4 hours and USD 10,640.00 vs manual orchestration

---

### 4. Proposal Summary

This proposal defines a traceable, reviewable plan for the Construction Site Progress Capture application, mapping approved business requirements and UX inputs to actionable epics, features, user stories, tasks, acceptance criteria, dependencies, and risks. All requirements are traceable to intake documents and mapped to UX screens and technical components. No external system changes are claimed; all integrations and workflow pauses are enforced per architecture and compliance constraints.

**Ready for review and human approval.**