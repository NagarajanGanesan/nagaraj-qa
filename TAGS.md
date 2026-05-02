# Test Tags Reference

Tags let you filter which tests to run without editing suite files.

```
robot --include <tag> <suite_path>
robot --exclude <tag> <suite_path>
robot --include <tag1> --include <tag2> <suite_path>   # AND logic
```

---

## Smoke Tags — fast, high-value subset

| Tag | Description | Where used |
|-----|-------------|------------|
| `smoke` | Core happy-path steps; run on every push | `KVB_Regression.robot` — TC_01, TC_02, TC_04 |

---

## Functional Domain Tags

| Tag | Description | Where used |
|-----|-------------|------------|
| `auth` | Login / logout / session management | TC_01_Authentication_And_Customer |
| `dedupe` | Duplicate customer check (pre-application) | TC_01_Authentication_And_Customer |
| `kyc` | Email OTP validation (Know Your Customer) | TC_02_Loan_Application_Init |
| `loan-init` | Loan application creation & product selection | TC_02_Loan_Application_Init |
| `bank` | Bank account linking | TC_03_Bank_And_Mutual_Fund_Pledge |
| `pledge` | Mutual fund pledge flow (CAMS + KFIN) | TC_03_Bank_And_Mutual_Fund_Pledge |
| `cams` | CAMS RTAs-specific fetch and pledge | TC_03_Bank_And_Mutual_Fund_Pledge |
| `kfin` | KFintech RTA-specific fetch and pledge | TC_03_Bank_And_Mutual_Fund_Pledge |
| `digisign` | Digital signature (KFS + e-sign) | TC_04_Digital_Signature_And_Disbursement |
| `submit` | Final loan submission | TC_04_Digital_Signature_And_Disbursement |

---

## Negative Test Tags

| Tag | Description | Where used |
|-----|-------------|------------|
| `negative` | Any negative / error-path test case | `KVB_Negative/` — all 15 files |
| `neg-auth` | Auth negative scenarios (wrong creds, missing headers) | `01_AUTH_Negative.robot` |
| `neg-dedupe` | Dedupe with invalid PAN / mobile / no-auth | `02_Dedupe_Negative.robot` |
| `neg-otp` | OTP negative scenarios (expired, wrong, reused) | `03_OTP_Negative.robot` |
| `neg-customer` | Customer endpoint negative cases | `04_Customer_Negative.robot` |
| `neg-loan` | Loan application negative cases | `05_LoanApp_Negative.robot` |
| `neg-email` | Email KYC negative cases | `06_Email_Negative.robot` |
| `neg-bank` | Bank linking negative cases | `07_Bank_Negative.robot` |
| `neg-fetch` | CAMS/KFIN fetch negative cases | `08_Fetch_Negative.robot` |
| `neg-pledge` | Pledge negative cases | `09_Pledge_Negative.robot` |
| `neg-digisign` | DigiSign negative cases | `10_DigiSign_Negative.robot` |

---

## Platform / Gateway Tags

| Tag | Description | Where used |
|-----|-------------|------------|
| `gateway` | API gateway E2E tests | `api_gateWay/` suite |
| `platform` | Platform service tests | `E2E_PlatformService/` |
| `e2e` | Full end-to-end integration tests | `api_gateWay/` suite |

---

## Parallel Execution Tags

| Tag | Description | Where used |
|-----|-------------|------------|
| `od` | Overdraft (OD) product tests — Pabot worker 1 | `KVB_mock/parallel/OD_Parallel_Suite.robot` |
| `tl` | Term Loan (TL) product tests — Pabot worker 2 | `KVB_mock/parallel/TL_Parallel_Suite.robot` |

---

## Common Run Recipes

```bash
# Run only smoke tests (fast CI check)
robot --include smoke API_Suite/testcases/KVB_PositiveFlow/

# Run all auth-related tests (positive + negative)
robot --include auth --include neg-auth API_Suite/

# Run only negative tests
robot --include negative API_Suite/testcases/KVB_Negative/

# Skip pledge tests (long-running)
robot --exclude pledge --exclude cams --exclude kfin API_Suite/testcases/KVB_PositiveFlow/

# Run parallel OD suite only
pabot --processes 1 --resourcefile KVB_mock/pabot_valueset.dat --include od KVB_mock/parallel/

# Run parallel TL suite only
pabot --processes 1 --resourcefile KVB_mock/pabot_valueset.dat --include tl KVB_mock/parallel/
```
