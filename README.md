# AfriTech Electronics — Customer Trust and Revenue Risk Analysis

**Tools:** Power BI · PostgreSQL · Python · Excel  
**Dataset:** 73,586 customer interactions · 27 columns · 2021–2023  
**Author:** Samuel Ahinakwa — Finance & Analytics Professional

---

## The Business Problem

AfriTech Electronics was losing customer trust and could not identify why. Leadership assumed product recalls were the primary driver — 50.9% of products had been recalled, generating significant media coverage and customer concern.

The data told a different story.

---

## The Pivot Finding

Recalled products showed 18.3% negative sentiment. Non-recalled products showed 18.1% negative sentiment. The difference: 0.2 percentage points — statistically zero.

Customers with perfectly functioning products were just as dissatisfied as customers whose products were recalled. The damage was not product-related. It was behavioural. It was caused by how AfriTech responded to its customers — not what it sold.

Every pound invested in product quality improvement would not have moved the NPS by a single point.

---

## Key Findings

**Brand Health**
- NPS: −46.23 — 86 points below the industry benchmark of +40 to +55
- Detractor rate: 64.59% — nearly two thirds of all customers
- $37.2M revenue at risk — 64.6% of total revenue

**Customer Segmentation — The Poisoned Pipeline**
- New customers: NPS −42.7
- Returning customers: NPS −46.2
- VIP customers: NPS −47.0
- The longer customers stayed — the angrier they became
- AfriTech's marketing team was spending money to build their competitors' future customer base

**Crisis Management — The Follow-Through Problem**
- 13,383 crisis events across the dataset
- 52.41% unresolved — 7,014 open complaints with no resolution
- Average response time: 190 days — median 141 days — slowest 715 days
- 88 same-day responses proven — 60 of those 88 still unresolved
- The team could respond. It just never finished.

**The Point of No Return**
- 1,410 VIP customers with an open unresolved complaint AND a competitor already in the conversation
- $1,076,419 in revenue not at risk — actively transitioning to competitors today
- Every day without intervention is a day that revenue converts from at-risk to lost

**Competitive Threat**
- 36,870 competitor mentions across 73,586 interactions
- Brand vs Competitor ratio: 1.02 — statistical tie in AfriTech's own conversations
- AfriTech Share of Voice: 50.6% — three competitors combined hold 49.4%
- Competitors insert themselves at the exact moment AfriTech fails its customers

---

## The Three Revenue Categories

| Category | Amount | Description |
|----------|--------|-------------|
| Revenue at Risk | $37.2M | All detractor customers — could leave |
| VIP Revenue at Risk | $15.7M | VIP detractors specifically — worst NPS, most credible critics |
| Point of No Return | $1,076,419 | VIP + unresolved crisis + competitor present — already leaving |

These are not the same number expressed differently. They are three distinct levels of urgency requiring three distinct responses.

---

## Dashboards

| Dashboard | Focus | Audience |
|-----------|-------|----------|
| Dashboard 1 — Brand Health Overview | NPS, sentiment, recall analysis | CMO |
| Dashboard 2 — Customer Segmentation | Revenue by segment, VIP recovery tiers | CFO |
| Dashboard 3 — Crisis Management | Response times, resolution rates, Point of No Return | Operations Director |
| Dashboard 4 — Competitive Threat | Share of Voice, platform breakdown, LATAM vs APAC | Marketing Director |
| Dashboard 5 — Executive Summary | Complete picture in one view | CEO and Board |

---

## Repository Structure

```
afritech-customer-analytics/
│
├── README.md
├── sql/
│   ├── afritech_setup.sql          — Table creation and data import
│   ├── afritech_views.sql          — 8 analytical views
│   └── afritech_eda_queries.sql    — Full EDA query library
├── dax/
│   └── afritech_measures.md        — All 26 DAX measures with expected values
├── dashboards/
│   ├── dashboard1_brand_health.png
│   ├── dashboard2_segmentation.png
│   ├── dashboard3_crisis_management.png
│   ├── dashboard4_competitive_threat.png
│   └── dashboard5_executive_summary.png
└── reports/
    └── AfriTech_Comprehensive_Report.pdf
```

---

## Strategic Recommendations

1. **Pull the list of 1,410 Point of No Return customers tonight** — assign relationship managers — zero open crises within 14 days
2. **Launch Tier 1 VIP re-engagement** — 1,045 customers — phone call this week — target $843,315 recovery
3. **Implement crisis SLA** — 4-hour acknowledgement · 24-hour first response · 7-day resolution
4. **Suspend acquisition marketing** until the entry experience is fixed — every new customer acquired before the fix becomes another detractor
5. **Fix before you fund** — acquisition spend is generating competitors' future customers

---

## Connect

**LinkedIn:** [Samuel Ahinakwa](https://www.linkedin.com/in/samuelahinakwa-a73b45314)  
**Email:** sam.ahinakwah@gmail.com
