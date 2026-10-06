# Phase Execution Index (`PHASE_EXECUTION_INDEX.md`)

## Index of Implementation Blueprints & Verification Gates

This index provides a mapping of each implementation phase (Phases 0 through 6) to its primary objectives, technical deliverables, and verification criteria.

---

### Phase 0: Backend Resilience & Schema Hardening
- **Primary Objectives:** Eliminate schema defects, resolve lookup over-limit risks, and enforce zero data-loss object model mapping across all 141 objects.
- **Key Deliverables:** `salesforce_model_expanded.txt`, `scripts/run_track_d_phase1_audit.py`, `scripts/validate_metadata.py`.
- **Verification Criteria:** Audit script returns `PASS` across all 8 metadata rules with zero duplicate objects or double suffixes.

---

### Phase 1: Master Workspace Shell & Unified Navigation Architecture
- **Primary Objectives:** Implement the master LWC shell, global navigation rail, context bar, and workspace tabs supporting responsive SLDS design and Dark Mode.
- **Key Deliverables:** `economyAnalyzerShell`, `saveGameAnalyzerShell`, `navRail`, `globalContextBar`, `workspaceTabs`, `contextStore`.
- **Verification Criteria:** LWC Jest unit test suite passes cleanly (`npm run test:lwc`).

---

### Phase 2: Cross-Domain Analytics & Junction Intelligence Engine
- **Primary Objectives:** Implement cross-domain SOQL join selectors and DTO models linking economy, diplomacy, military, and sphere records.
- **Key Deliverables:** `CrossDomainIntelligenceEngine.cls`, `CrossDomainLensDTO.cls`, `lensGallery`, `lensView`.
- **Verification Criteria:** Cross-domain selectors return composite metrics across tags/snapshots without N+1 query patterns.

---

### Phase 3: Derived Intelligence, Growth Engine & Real-Time Alert System
- **Primary Objectives:** Calculate growth rates, market concentration (HHI), price volatility index, and publish `EconomyAnomalyEvent__e` platform events.
- **Key Deliverables:** `DerivedIntelligenceEngine.cls`, `DerivedMetricDTO.cls`, `EconomyAnomalyEventTrigger.trigger`, `alertDrawer`.
- **Verification Criteria:** Derived metrics calculate accurately and alert drawer renders real-time anomaly events.

---

### Phase 4: Agentforce AI Campaign Advisor & Natural Language Suite
- **Primary Objectives:** Implement generative narrative campaign summaries, historical context prompts, and executive decision recommendations.
- **Key Deliverables:** `CampaignAdvisorController.cls`, `CampaignAdvisorPromptTemplate.cls`, `campaignAdvisor`.
- **Verification Criteria:** Apex prompt template generates structured narrative recommendations and passes unit tests.

---

### Phase 5: Multi-Save Time Series Comparison Suite & Community Portal
- **Primary Objectives:** Implement 12-snapshot capped narrow time series queries, filmstrip selectable timeline, split-screen variance, bump charts, and Experience Cloud public campaign gallery.
- **Key Deliverables:** `TimeSeriesController.cls`, `NarrowMetricDTO.cls`, `compareSuite`, `snapshotFilmstrip`, `multiSaveTrend`, `h2hCompare`, `campaignGallery`.
- **Verification Criteria:** Enforces 12-snapshot hard cap (RSK-03), Guest user read-only safety, and 100% LWC Jest component test pass.

---

### Phase 6: Enterprise Polish, Parity Regression Suite & Final Attestation
- **Primary Objectives:** Execute end-to-end parity harness against golden dataset, stress-test governor limits under LDV, enforce 5-campaign storage retention pruning, and verify protected baseline SHA-256 hash.
- **Key Deliverables:** `CampaignRetentionService.cls`, `EconomyLdvValidationTest.cls`, `e2e/parity/compare.py`, `AUDIT_AND_IMPLEMENTATION_SUMMARY.md`.
- **Verification Criteria:** Parity compare script returns `PASS` with 0 numeric discrepancies and SHA-256 baseline matches `976a8638bbbba3e52848e32e34d1144b3ca5a5dc46f723fc9fba8a10d5ef2a38`.
