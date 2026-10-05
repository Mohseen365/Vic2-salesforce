# Track C — Permission Set Assignment & Security Architecture Guide

## 1. Operating Context & Governance Overview

The Victoria 2 Economy Analyzer project currently operates with **exactly one active user: a System Administrator.**

In Salesforce Lightning Experience, the System Administrator profile possesses the system permissions `View All Data` and `Modify All Data`, which bypass standard object-level (CRUD) and field-level security (FLS) checks. Consequently, assigning or unassigning the permission sets provisioned in Track C does not alter what the single System Administrator user can view, edit, or execute.

### Strategic Value of Track C Provisioning
Despite operating in a single-admin environment, Track C permission sets fulfill three vital governance functions:

1. **Codification of Access Intent:** Establishes explicit metadata definitions for read-only vs. administrative read/write access across all 139 custom objects and 997 custom fields, replacing implicit profile assumptions with version-controlled artifacts.
2. **Future User Provisioning:** Enables instant onboarding of non-administrator analysts or data steward service accounts without requiring custom profile creation or administrative profile modifications.
3. **Security Auditability:** Provides full visibility to security auditors and automated compliance tools regarding the intended authorization surface for save-game and economy data model entities.

---

## 2. Recommended Assignment Procedure

### 2.1 Current Single System Administrator Setup
- **Recommended Action:** Assign the `Economy_Analyzer_Admin` permission set to the System Administrator user.
- **Optional Action:** Assign `Economy_Analyzer_User` if the administrator wishes to test read-only interface views or verify field visibility via Permission Set Groups or user-impersonation tools.
- **Strict Prohibition:** Do **NOT** modify or restrict the System Administrator profile. Profiles in modern Salesforce deployments serve as container shells for administrative credentials; access expansion and restriction should be handled via Permission Sets and Muting Permission Sets.

### 2.2 Provisioning Architecture for Future Users

When additional users or service integrations are introduced to the environment, follow these assignment rules:

| User Category / Persona | Primary Assigned Permission Set | Scope & Privileges |
|---|---|---|
| **Data Analysts / Viewers** | `Economy_Analyzer_User` | Full read-only access to all 139 objects and 997 fields. Apex controller and selector execution enabled. No edit, delete, or import privileges. |
| **Data Stewards / ETL Service Accounts** | `Economy_Analyzer_Admin` | Full read/write/create/delete access to all 139 objects and 997 fields. Includes batch execution and REST import pipeline privileges. |
| **Guest / Community Users** | **NONE (Strict Prohibition)** | Neither permission set may ever be assigned to Experience Cloud site guests or external unauthenticated profiles. |

---

## 3. Profiles vs. Permission Sets Design Philosophy

In alignment with Salesforce's official product roadmap (deprecating permissions on profiles in favor of permission set-driven security architecture), this repository uses a **Zero-Custom-Profile Strategy**:

- **No Custom Profiles:** No custom profiles are created or managed in this repository.
- **Permission Sets as Authorization Vectors:** All object CRUD, field FLS, and Apex class accesses are maintained exclusively inside permission sets under `force-app/main/default/permissionsets/`.
- **Permission Set Generator Maintenance:** Any future data model expansions (Track D/E) must re-run `vc2-salesforce-version/track-c-generate-permission-sets.py` to regenerate `Economy_Analyzer_User` and `Economy_Analyzer_Admin` metadata.

---

## 4. Static Verification Note

Because the sandbox environment contains only one active System Administrator user, empirical runtime testing of FLS and object CRUD enforcement cannot be performed without creating a test user without `View All Data`/`Modify All Data`.

Therefore, all verification for Track C is **static verification**:
- 100% XML well-formedness validation.
- Complete 139/139 object and 997/997 field coverage check.
- Zero-orphan reference validation against existing object, field, and Apex class metadata.
- Zero-violation rule constraint checks (no Edit without Read, no C/E/D without Read).
