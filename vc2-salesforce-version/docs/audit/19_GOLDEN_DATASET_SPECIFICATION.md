# 19. Golden Dataset Specification: `egypt.v2`

## Overview
The Phase 0 Golden Dataset Oracle defines the authoritative reference benchmark derived from `egypt.v2` (SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`).

---

## Key Golden Benchmarks for Verification

| Metric / Scope | Benchmark Value in `egypt.v2` | Tolerance Rules | Verification Script / Test |
| -------------- | ----------------------------- | --------------- | -------------------------- |
| Total World GDP | `£124,850.42` | ±£0.01 | `test_csv_export_parity.py` |
| Total World Population | `142,504,112` | Exact Match (0 diff) | `compare.py` |
| Player Country Tag | `"TUR"` | Exact Match | `compare.py` |
| In-Game Date | `1872-09-25` | Exact Match | `compare.py` |
| Top 1 Power (GDP) | Great Britain (`ENG`) | Rank 1 Exact | `compare.py` |
| Top Commodity Supply | Timber (`2811.51483`) | ±0.0001 | `compare.py` |
| Total Country Records | 221 active nations | Exact Match | `compare.py` |
| Total Product Records | 49 commodities | Exact Match | `compare.py` |
| Total State Records | 107 states | Exact Match | `compare.py` |
| Total Factory Records | 714 factories | Exact Match | `compare.py` |
| Total Artisan Records | 4,428 artisan rows | Exact Match | `compare.py` |
