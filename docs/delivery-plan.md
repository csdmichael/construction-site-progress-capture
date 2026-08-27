# Delivery plan — Construction Site Progress Capture

Sprints are two weeks. Each sprint closes with a demo and an approval gate.

| Sprint | Focus | Exit criteria |
| --- | --- | --- |
| Sprint 1 | Foundation: repo, pipelines, schema | CI green, API deployed |
| Sprint 2 | Core scope | Approved user stories delivered |
| Sprint 3 | Hardening and release | Tests pass, release gate approved |

## Approved scope

- **Frontend (Angular 18 + Ionic 8)**
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
- **Backend (FastAPI, Python 3.12)**
