# 22. Architectural Alternatives Evaluation

## Overview
This document evaluates three architectural patterns for importing and processing Victoria 2 save games.

---

## Comparative Evaluation Matrix

| Criterion | Architecture A: Pure Apex Parsing | Architecture B: External Parsing + Salesforce REST API (Selected) | Architecture C: Hybrid Cloud Worker |
| --------- | --------------------------------- | ----------------------------------------------------------------- | ------------------------------------ |
| **Parsing Strategy** | Parse raw 27MB text file directly inside Apex string parser. | External parser converts `.v2` to JSON DTO; transmits via Apex REST API. | Cloud Function parses `.v2` and writes directly via Salesforce Bulk API v2. |
| **Salesforce Heap Limit Risk** | **EXTREME FAIL.** 27MB file exceeds 6MB/12MB Apex heap limit immediately. | **LOW.** Apex REST endpoint receives normalized DTO payload. | **LOW.** Async Bulk API bypasses Apex heap limits. |
| **CPU Time Limit Risk** | **EXTREME FAIL.** Regex parsing 2M lines exceeds 10s Apex CPU limit. | **LOW.** Heavy parsing happens off-heap before API transmission. | **LOW.** Processing occurs in external cloud container. |
| **Infrastructure Complexity** | Very Low (Apex only). | Low (Standard REST API + Off-heap client parser). | High (Requires AWS Lambda / Heroku worker setup). |
| **Security & FLS Enforcement** | High (Native Apex). | High (`EconomyImportRestResource` enforces CRUD/FLS). | Medium (Requires OAuth API user context). |
| **Verdict** | REJECTED | **SELECTED (RECOMMENDED)** | REJECTED (Unnecessary complexity) |
