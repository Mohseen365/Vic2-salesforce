# 02. Victoria 2 Save File Structural Hierarchy and Syntax Grammar

## 1. File Grammar & Low-Level Formatting
- **File Size:** 27,059,272 bytes (~25.81 MB)
- **Character Encoding:** Single-byte `latin1` / ISO-8859-1.
- **Compression:** None (Plain ASCII text).
- **Line Endings:** Windows CRLF (`\r\n`) and LF (`\n`) mixed.
- **Top-Level Structural Delimiters:** Curly braces `{}` denote nested blocks. Key-value pairs use equality operators (`key=value` or `key="value"`).
- **Arrays & Lists:** Primitive lists use space-delimited values inside braces (e.g. `technology={ post_napoleonic_thought={1 0.000} }`).

---

## 2. Root Block Hierarchy Tree

```text
ROOT (egypt.v2)
├── Global Metadata
│   ├── date="1872.9.25"
│   ├── player="TUR"
│   ├── start_date="1836.1.1"
│   ├── government=5
│   ├── automate_trade=no
│   └── great_wars_enabled=no
├── Worldmarket Block (worldmarket=)
│   ├── worldmarket_pool={ <commodity>=<float> ... }
│   ├── price_pool={ <commodity>=<float> ... }
│   ├── demand_pool={ <commodity>=<float> ... }
│   ├── supply_pool={ <commodity>=<float> ... }
│   └── price_history={ ... }
├── Diplomacy Block (diplomacy=)
│   ├── alliance={ first="TAG" second="TAG" ... }
│   └── relation={ first="TAG" second="TAG" value=<int> ... }
├── Active & Historical Wars
│   ├── active_war={ name="..." attacker="..." defender="..." }
│   └── previous_war={ name="..." attacker="..." defender="..." }
├── Country Entities (271 tags e.g. EGY, TUR, ENG, FRA, RUS, PRU)
│   ├── capital=<prov_id>
│   ├── treasury=<float>
│   ├── bank=<float>
│   ├── technology={ <tech_code>={1 0.000} ... }
│   ├── invention={ <invention_code> ... }
│   └── state={ (State/Region Blocks - 107 total)
│       └── state_buildings={ (Factories - 714 total)
│           ├── building="<goods_type>"
│           ├── level=<int>
│           ├── stockpile={ ... }
│           └── employment={ employees={ ... } }
└── Province Entities (3,248 numeric blocks e.g. 1..3248)
    ├── name="<province_name>"
    ├── owner="<TAG>"
    ├── controller="<TAG>"
    ├── colonial=<int>
    ├── rgo={ employment={ ... } }
    └── POP Entities (46,282 total blocks e.g. farmers, artisans)
        ├── id=<int>
        ├── size=<int>
        ├── <culture>=<religion>
        ├── money=<float>
        ├── ideology={ <id>=<float> ... }
        └── issues={ <id>=<float> ... }
```

---

## 3. Structural Entity Counts & Cardinalities

| Entity Type | Save Structural Representation | Count in `egypt.v2` | Parent Entity |
| ----------- | ------------------------------ | ------------------ | ------------- |
| Country Block | `[A-Z0-9]{3}={` | 271 | ROOT |
| Province Block | `\d+={` | 3,248 | ROOT |
| Region / State | `state={` within Country | 107 | Country |
| Factory Building | `building="..."` within State | 714 | State |
| RGO Block | `rgo={` within Province | 2,703 | Province |
| POP Block | `<pop_type>={` within Province | 46,282 | Province |
| Active War | `active_war={` | 3 | ROOT |
| Previous War | `previous_war={` | 55 | ROOT |
| Rebel Faction | `rebel_faction={` | 106 | ROOT |
