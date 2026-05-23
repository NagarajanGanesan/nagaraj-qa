# nagaraj-qa

> Personal QA automation portfolio — API and UI test suites for fintech lending workflows.
> Built with Robot Framework + Python.

<p>
  <img src="https://img.shields.io/badge/Robot%20Framework-000000?style=flat-square&logo=robotframework&logoColor=white"/>
  <img src="https://img.shields.io/badge/Python-3.10%2B-3776AB?style=flat-square&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/Domain-Fintech%20Lending-success?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square"/>
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square"/>
</p>

---

## 👋 About

I'm **Nagaraj**, a QA Automation Engineer with **4+ years** of experience automating mission-critical lending platforms (LOS, LMS, LAMF) at NBFC and fintech organizations. This repo is my personal sandbox for building reusable Robot Framework patterns I apply to real fintech work.

- 💼 **Current role:** QA Automation Engineer @ Finsire Technologies
- 🏦 **Domain:** Fintech lending — LOS, LMS, LAMF, Co-Lending, KYC
- 🌐 **LinkedIn:** [linkedin.com/in/nagarajan-ganesan-704130260](https://www.linkedin.com/in/nagarajan-ganesan-704130260/)
- 📧 **Email:** nagaraj99g@gmail.com

---

## 📦 What's in this repo

| Module | Description | Status |
|---|---|---|
| **Project 1 — Triton (LOS API Suite)** | Loan Origination System API tests — product creation, eligibility, KYC validation, asset limits, customer info, address, file upload | 🟢 Active |
| Custom keywords | Reusable Robot Framework keywords for API requests, validation, and chaining | 🟢 Active |
| Resources | Shared variables, locators, configuration | 🟢 Active |

> **Note:** This repo currently focuses on **Robot Framework API automation**. UI automation with Playwright and additional integrations are planned — see [Roadmap](#-roadmap) below.

---

## 🗂 Project Structure

```
nagaraj-qa/
├── Project 1-Triton/
│   └── robot/
│       └── API_Suite/
│           ├── testcases/      # Test cases organized by module
│           ├── keywords/       # Reusable Robot Framework keywords
│           └── resources/      # Variables, locators, configuration
├── requirements.txt            # Python dependencies
├── TAGS.md                     # Tag conventions used across suites
├── LICENSE                     # MIT
└── README.md
```

---

## 🛠 Tech Stack (currently used in this repo)

| Layer | Tool |
|---|---|
| Test framework | Robot Framework |
| Language | Python 3.10+ |
| HTTP testing | Robot Framework Requests Library |
| Reporting | Built-in Robot Framework log.html / report.html |

---

## 🚀 Getting Started

### Prerequisites
- Python 3.10+
- Git

### Setup

```bash
git clone https://github.com/NagarajanGanesan/nagaraj-qa.git
cd nagaraj-qa
python -m venv .venv
source .venv/bin/activate   # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Run the Triton API suite

```bash
# Run all test cases
robot Project\ 1-Triton/robot/API_Suite/testcases/

# Run with tags
robot --include smoke Project\ 1-Triton/robot/API_Suite/testcases/

# Output: log.html, report.html, output.xml in current directory
```

### Tag conventions
See [TAGS.md](TAGS.md) for the full tag taxonomy used across suites.

---

## 🧪 What I focus on

- **API contract validation** — JSON schema checks against Swagger/OpenAPI specs
- **End-to-end API chaining** — token → product creation → eligibility → KYC → disbursement
- **Reusable keyword design** — modular, composable, easy for non-Python folks to read
- **Data-driven testing** — variation testing via Robot Framework templates
- **Tag-based execution** — smoke / sanity / regression slices for CI

---

## 🗺 Roadmap

Planned additions to expand this portfolio:

- [ ] **Playwright + Python UI tests** — extend Triton with end-to-end UI flows
- [ ] **PostgreSQL + MongoDB validation library** — custom Python keywords for cross-DB assertions
- [ ] **CI/CD via GitHub Actions** — automated smoke runs on push
- [ ] **Allure reporting integration** — richer trend dashboards
- [ ] **JMeter performance test plans** — load testing for high-traffic endpoints
- [ ] **LMS test suite** — repayment, EMI, NACH, foreclosure flows
- [ ] **Synthetic test data generator** — Faker-based fintech-specific data (PAN, Aadhaar masking, mobile, etc.)

---

## 📚 Other relevant work (private repos / employer-owned)

The work I've shipped at **Finsire Technologies** and **Vivriti Capital** lives in private organization repos and cannot be shared publicly. Happy to walk through architecture, patterns, and metrics in an interview:

- **Finsire — LAMF:** 100+ end-to-end loan-lifecycle scenarios; regression cut from 2 days to 4 hours per release
- **Vivriti — Co-Lending LMS:** Numerical-accuracy validation suite catching 5+ high-impact financial discrepancies pre-production
- **Vivriti — Triton LOS:** API contract tests for 30+ endpoints achieving ~90% defect-leakage prevention

---

## 📜 License

MIT — see [LICENSE](LICENSE).

---

## 📫 Contact

- **LinkedIn:** [linkedin.com/in/nagarajan-ganesan-704130260](https://www.linkedin.com/in/nagarajan-ganesan-704130260/)
- **Email:** nagaraj99g@gmail.com
- **Location:** Chennai, India
