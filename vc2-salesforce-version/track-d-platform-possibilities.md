# Track D — Layer 4 Platform Possibilities & Extensions

## 1. Executive Summary

This document defines **Layer 4 (Platform Extensions)** capabilities (`PLAT-D-001` through `PLAT-D-030`) that leverage Salesforce-native enterprise technologies beyond a standard data model.

A total of **30 distinct platform capabilities** across 17 Salesforce platform features have been evaluated for value, implementation effort, technical risk, and foundational dependencies.

---

## 2. Platform Capability Catalogue (30 Capabilities)

| Platform Cap ID | Capability Description | Salesforce Feature | Value | Effort Tier | Risk | Depends On |
|---|---|---|---|---|---|---|
| `PLAT-D-001` | **Real-Time Import Anomaly Alerts**: Publish Platform Events on severe economic/political anomalies during ingestion (e.g. GDP crash >30%, civil war outbreak). | Platform Events | HIGH | S | LOW | `SaveImportBatch` |
| `PLAT-D-002` | **Great War Outbreak Notification**: Trigger real-time event when a Great War declaration is ingested. | Platform Events | HIGH | S | LOW | `PLAT-D-001` |
| `PLAT-D-003` | **Sovereign Default Warning Event**: Broadcast event when a country's bankruptcy risk metric crosses 90%. | Platform Events | MEDIUM | S | LOW | `MET-D-019` |
| `PLAT-D-004` | **Einstein Discovery GDP Growth Model**: Train ML model on multi-save snapshots to predict 5-year GDP trajectory per nation. | CRM Analytics / Einstein Discovery | HIGH | M | MEDIUM | `FEAT-15` |
| `PLAT-D-005` | **Rebellion Risk Machine Learning Model**: Predictive model forecasting revolt probability per province based on POP militancy & consciousness. | CRM Analytics / Einstein Discovery | HIGH | M | MEDIUM | `MET-D-016` |
| `PLAT-D-006` | **Natural Language Campaign Advisor (Agentforce)**: Conversational AI assistant allowing query of campaign data ("Which nation is my biggest trade partner?"). | Einstein GPT / Agentforce | HIGH | L | MEDIUM | `SaveAnalysisController` |
| `PLAT-D-007` | **Strategic AI Target Recommender**: Agentforce bot recommending optimal military conquest or sphere expansion targets. | Einstein GPT / Agentforce | HIGH | L | HIGH | `PLAT-D-006` |
| `PLAT-D-008` | **Multi-Campaign Historical Data Warehouse**: Cross-save long-term campaign archive storing 100+ save files without consuming Custom Object storage limits. | External Objects / Data Cloud | HIGH | XL | HIGH | `FEAT-15` |
| `PLAT-D-009` | **Multi-Player Tournament Analytics Hub**: Centralized Data Cloud repository comparing performance across different players in multiplayer sessions. | Data Cloud | MEDIUM | XL | HIGH | `PLAT-D-008` |
| `PLAT-D-010` | **Mobile Save Game Overview App**: Optimized Salesforce Mobile layout for viewing save header, Great Power ranks, and budget summaries on smartphone/tablet. | Salesforce Mobile | MEDIUM | S | LOW | `FEAT-01` |
| `PLAT-D-011` | **Mobile Push Notifications on Import Complete**: Native push notification sent to user mobile device when async save ingestion finishes. | Salesforce Mobile | HIGH | S | LOW | `EconomyImportBatch` |
| `PLAT-D-012` | **Slack Milestone Channel Post**: Automatically post milestone achievements (e.g. "Prussia formed Germany in 1866!") to a dedicated Slack channel. | Slack Integration | MEDIUM | S | LOW | `PLAT-D-001` |
| `PLAT-D-013` | **Slack Command Campaign Query (`/v2-stats`)**: Slash command in Slack to fetch current date, top 5 GDP powers, and ongoing war count. | Slack Integration | MEDIUM | M | LOW | `SaveAnalysisController` |
| `PLAT-D-014` | **Community Player Dashboard Sharing**: Public or authenticated Experience Cloud portal allowing players to publish and share campaign walkthroughs and statistics. | Experience Cloud / Community | HIGH | L | MEDIUM | `FEAT-01` |
| `PLAT-D-015` | **Public Campaign Comparison Portal**: Experience Cloud site enabling head-to-head comparison between two players' save files. | Experience Cloud / Community | HIGH | L | MEDIUM | `PLAT-D-014` |
| `PLAT-D-016` | **Tableau Interactive Trade Flow Map**: Tableau CRM sankey/network visualization showing global trade flows between Great Powers and colonies. | Tableau CRM | HIGH | M | LOW | `CAP-D-021` |
| `PLAT-D-017` | **Native Salesforce Snapshot Reports**: Out-of-the-box Salesforce Reports for country GDP, brigade counts, and technology levels. | Salesforce Reports & Dashboards | MEDIUM | S | LOW | `salesforce_model_expanded.txt` |
| `PLAT-D-018` | **Executive Country Ranking Dashboard**: Native Salesforce Dashboard showing Great Power Prestige, Industry, and Military leaderboards. | Salesforce Reports & Dashboards | HIGH | S | LOW | `PLAT-D-017` |
| `PLAT-D-019` | **Scheduled Monthly Campaign Digest Email**: Scheduled Apex job emailing weekly summary report of save game stats and trends. | Scheduled Apex / Flows | LOW | S | LOW | `PLAT-D-017` |
| `PLAT-D-020` | **Original `.v2` File File-Connect Archival**: Attach original `.v2` save files directly to `Save_Game__c` record via Salesforce Files. | Files Connect / ContentVersion | MEDIUM | S | LOW | `Save_Game__c` |
| `PLAT-D-021` | **Serverless Save File Pre-Processing**: Offload heavy `.v2` text parsing and regex extraction to serverless Salesforce Functions (Node.js/Java). | Salesforce Functions | HIGH | L | MEDIUM | `IMPORT_CONTRACT.md` |
| `PLAT-D-022` | **Shield Encryption for Player Save Data**: Encrypt player identifiers, notes, and custom variables at rest using Shield Platform Encryption. | Shield Platform Encryption | LOW | M | LOW | Compliance |
| `PLAT-D-023` | **No-Code Custom Metric Alert Flows**: Salesforce Flow enabling non-developers to configure custom alerts (e.g., "Alert me when my country's badboy exceeds 20"). | Salesforce Flow | HIGH | S | LOW | `Country_Save_State__c` |
| `PLAT-D-024` | **Auto-Task Creation on Debt Default Risk**: Automatically create Salesforce Task for player when sovereign debt interest consumes >50% income. | Salesforce Flow | MEDIUM | S | LOW | `MET-D-019` |
| `PLAT-D-025` | **Bulk Ingestion via Bulk API 2.0**: Alternative high-volume REST ingestion pipeline using Bulk API 2.0 for 500k+ row POP uploads. | Bulk API 2.0 | HIGH | M | MEDIUM | `Pop__c` LDV |
| `PLAT-D-026` | **Streaming API Market Live Feed**: Real-time push updates to custom web clients when world market commodity prices update. | Streaming API | MEDIUM | M | LOW | `Price_Snapshot__c` |
| `PLAT-D-027` | **Embedded Lightning Out Dashboard in Web/Discord**: Embed LWC save dashboards in external Discord bots, blogs, or web apps via Lightning Out. | Lightning Out | HIGH | M | MEDIUM | `c-save-game-analyzer-shell` |
| `PLAT-D-028` | **Unify Multi-Game Save Data Platform**: Unified customer data platform aggregating save data across Victoria 2, Hearts of Iron IV, and Crusader Kings III. | Salesforce CDP | MEDIUM | XL | HIGH | Data Cloud |
| `PLAT-D-029` | **Automated Save File Backup to Cloud Storage**: Flow-triggered integration backing up parsed DTO JSON payloads to AWS S3. | Salesforce Flow / Named Credential | MEDIUM | S | LOW | `Save_Game__c` |
| `PLAT-D-030` | **In-App Chatter Campaign Discussion Feed**: Enable Chatter on `Save_Game__c` for multiplayer teams to comment on strategic turn decisions. | Salesforce Chatter | LOW | S | LOW | `Save_Game__c` |

---

## 3. Evaluation by Platform Feature Category

### 3.1 AI & Predictive Analytics (Agentforce & Einstein Discovery)
- **Capabilities**: `PLAT-D-004`, `PLAT-D-005`, `PLAT-D-006`, `PLAT-D-007`
- **Value**: High strategic value for natural language querying and forward predictive insights.
- **Risk**: Moderate to High due to potential LLM hallucination on precise game state values and model training requirements.

### 3.2 Real-Time Integration & Messaging (Events, Slack, Streaming)
- **Capabilities**: `PLAT-D-001`, `PLAT-D-002`, `PLAT-D-003`, `PLAT-D-012`, `PLAT-D-013`, `PLAT-D-026`
- **Value**: High engagement value for multiplayer groups and instant anomaly detection.
- **Risk**: Low technical risk; relies on established Salesforce event-driven architecture.

### 3.3 Scalability & Big Data (Data Cloud, Bulk API, Functions)
- **Capabilities**: `PLAT-D-008`, `PLAT-D-009`, `PLAT-D-021`, `PLAT-D-025`, `PLAT-D-028`
- **Value**: Essential for overcoming custom object governor limits when storing hundreds of save games and millions of POP records.
- **Risk**: High effort and cost; requires enterprise Salesforce licenses.

### 3.4 Community & Mobile (Experience Cloud, Mobile, Embedded)
- **Capabilities**: `PLAT-D-010`, `PLAT-D-011`, `PLAT-D-014`, `PLAT-D-015`, `PLAT-D-027`
- **Value**: High social value enabling campaign sharing, walkthrough publishing, and mobile check-ins.
- **Risk**: Moderate effort around user security and access control.
