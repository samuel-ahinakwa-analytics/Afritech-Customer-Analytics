# AfriTech Electronics — DAX Measures Reference

**Tool:** Power BI Desktop  
**Table:** public afritech_social  
**Measures table:** _Measures  
**Author:** Samuel Ahinakwa — Finance & Analytics Professional  
**Total measures:** 26  

All measures confirmed against PostgreSQL and Python. Expected values shown for the full 73,586-row dataset with no filters applied.

---

## Display Folder Structure

```
_Measures/
├── 01 Core Totals
├── 02 NPS and Sentiment
├── 03 Crisis Management
├── 04 Revenue and Risk
├── 05 Competitive Threat
├── 06 VIP Recovery
└── 07 Point of No Return
```

---

## 01 — Core Totals

### Total Interactions
```dax
Total Interactions =
COUNTROWS('public afritech_social')
```
**Expected:** 73,586

---

### Total Revenue
```dax
Total Revenue =
SUM('public afritech_social'[purchaseamount])
```
**Expected:** 57,534,245

---

### Total Engagement
```dax
Total Engagement =
SUM('public afritech_social'[engagementlikes]) +
SUM('public afritech_social'[engagementshares]) +
SUM('public afritech_social'[engagementcomments])
```
**Expected:** 292,473,633

---

## 02 — NPS and Sentiment

### NPS Score
```dax
NPS Score =
DIVIDE(
    CALCULATE(COUNTROWS('public afritech_social'), 'public afritech_social'[npsresponse] >= 9) -
    CALCULATE(COUNTROWS('public afritech_social'), 'public afritech_social'[npsresponse] <= 6),
    COUNTROWS('public afritech_social')
) * 100
```
**Expected:** −46.23

---

### Promoters
```dax
Promoters =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[npsresponse] >= 9
)
```
**Expected:** 13,508

---

### Passives
```dax
Passives =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[npsresponse] >= 7,
    'public afritech_social'[npsresponse] <= 8
)
```
**Expected:** 12,550

---

### Detractors
```dax
Detractors =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[npsresponse] <= 6
)
```
**Expected:** 47,528

---

### Detractor Rate
```dax
Detractor Rate =
DIVIDE(
    CALCULATE(
        COUNTROWS('public afritech_social'),
        'public afritech_social'[npsresponse] <= 6
    ),
    COUNTROWS('public afritech_social')
)
```
**Expected:** 64.59% — format as percentage

---

### Negative Sentiment Count
```dax
Negative Sentiment Count =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[sentiment] = "Negative"
)
```
**Expected:** 13,383

---

## 03 — Crisis Management

### Crisis Events
```dax
Crisis Events =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[crisiseventtime] <> BLANK()
)
```
**Expected:** 13,383

---

### Crisis Unresolved
```dax
Crisis Unresolved =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[resolutionstatus] = FALSE(),
    'public afritech_social'[crisiseventtime] <> BLANK()
)
```
**Expected:** 7,014  
**Note:** Always include the `crisiseventtime <> BLANK()` filter. Power BI reads blank ResolutionStatus as FALSE — without this filter the measure overcounts.

---

### Crisis Resolution Rate
```dax
Crisis Resolution Rate =
DIVIDE(
    CALCULATE(
        COUNTROWS('public afritech_social'),
        'public afritech_social'[resolutionstatus] = TRUE(),
        'public afritech_social'[crisiseventtime] <> BLANK()
    ),
    CALCULATE(
        COUNTROWS('public afritech_social'),
        'public afritech_social'[crisiseventtime] <> BLANK()
    )
)
```
**Expected:** 47.59% — format as percentage

---

### Avg Crisis Response Days
```dax
Avg Crisis Response Days =
CALCULATE(
    AVERAGE('public afritech_social'[responsedays]),
    'public afritech_social'[crisiseventtime] <> BLANK(),
    'public afritech_social'[responsedays] > 0
)
```
**Expected:** 190

---

### Same Day Responses
```dax
Same Day Responses =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[crisiseventtime] <> BLANK(),
    'public afritech_social'[responsedays] = 0
)
```
**Expected:** 88

---

## 04 — Revenue and Risk

### Revenue at Risk
```dax
Revenue at Risk =
CALCULATE(
    SUM('public afritech_social'[purchaseamount]),
    'public afritech_social'[npsresponse] <= 6
)
```
**Expected:** 37,195,250

---

### VIP Revenue at Risk
```dax
VIP Revenue at Risk =
CALCULATE(
    SUM('public afritech_social'[purchaseamount]),
    'public afritech_social'[npsresponse] <= 6,
    'public afritech_social'[customertype] = "VIP"
)
```
**Expected:** 15,736,110

---

### Revenue at Risk %
```dax
Revenue at Risk % =
DIVIDE(
    [Revenue at Risk],
    [Total Revenue]
)
```
**Expected:** 64.6% — format as percentage

---

## 05 — Competitive Threat

### Competitor Mentions
```dax
Competitor Mentions =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[competitormentention] = TRUE()
)
```
**Expected:** 36,870

---

### Brand Mentions
```dax
Brand Mentions =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[brandmention] = TRUE()
)
```
**Expected:** 37,773

---

### Brand vs Competitor Ratio
```dax
Brand vs Competitor Ratio =
DIVIDE(
    [Brand Mentions],
    [Competitor Mentions]
)
```
**Expected:** 1.02

---

### AfriTech Share of Voice
```dax
AfriTech Share of Voice =
DIVIDE(
    [Brand Mentions],
    [Brand Mentions] + [Competitor Mentions]
)
```
**Expected:** 50.6% — format as percentage

---

### High Influencer Detractors
```dax
High Influencer Detractors =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[influencerscore] >= 60,
    'public afritech_social'[npsresponse] <= 6
)
```
**Expected:** 18,715

---

### Brand With Competitor
```dax
Brand With Competitor =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[brandmention] = TRUE(),
    'public afritech_social'[competitormentention] = TRUE()
)
```
**Expected:** 18,912

---

## 06 — VIP Recovery

### VIP Recovery Tier 1
```dax
VIP Recovery Tier 1 =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[customertype] = "VIP",
    'public afritech_social'[npsresponse] IN {5, 6},
    'public afritech_social'[crisiseventtime] = BLANK(),
    'public afritech_social'[competitormentention] = FALSE(),
    'public afritech_social'[productrecalled] = FALSE()
)
```
**Expected:** 1,045

---

### VIP Tier 1 Revenue
```dax
VIP Tier 1 Revenue =
CALCULATE(
    SUM('public afritech_social'[purchaseamount]),
    'public afritech_social'[customertype] = "VIP",
    'public afritech_social'[npsresponse] IN {5, 6},
    'public afritech_social'[crisiseventtime] = BLANK(),
    'public afritech_social'[competitormentention] = FALSE(),
    'public afritech_social'[productrecalled] = FALSE()
)
```
**Expected:** 843,315

---

## 07 — Point of No Return

### Point of No Return Count
```dax
Point of No Return Count =
CALCULATE(
    COUNTROWS('public afritech_social'),
    'public afritech_social'[customertype] = "VIP",
    'public afritech_social'[resolutionstatus] = FALSE(),
    'public afritech_social'[competitormentention] = TRUE(),
    'public afritech_social'[crisiseventtime] <> BLANK()
)
```
**Expected:** 1,410

---

### Point of No Return Revenue
```dax
Point of No Return Revenue =
CALCULATE(
    SUM('public afritech_social'[purchaseamount]),
    'public afritech_social'[customertype] = "VIP",
    'public afritech_social'[resolutionstatus] = FALSE(),
    'public afritech_social'[competitormentention] = TRUE(),
    'public afritech_social'[crisiseventtime] <> BLANK()
)
```
**Expected:** 1,076,419  
**Definition:** VIP customer + unresolved crisis + competitor present simultaneously. This is not revenue at risk. This is revenue actively transitioning to a competitor today.

---

## Critical Notes for Reproducibility

**1 — Boolean column behaviour**  
Power BI reads blank `resolutionstatus` values as FALSE. Always pair ResolutionStatus = FALSE() with `crisiseventtime <> BLANK()` to avoid overcounting unresolved crises.

**2 — Competitor mention column name**  
The column is `competitormentention` — note the spelling. This matches the PostgreSQL column name exactly.

**3 — All measures live in the `_Measures` table**  
Create a blank table with `_Measures = {BLANK()}`, hide the Value column, and create all measures there. Keep columns in `public afritech_social`.

**4 — Three revenue categories — never conflate**

| Category | Amount | Definition |
|----------|--------|------------|
| Revenue at Risk | $37,195,250 | All detractor customers |
| VIP Revenue at Risk | $15,736,110 | VIP detractors only |
| Point of No Return | $1,076,419 | VIP + unresolved + competitor |

---

*All measures verified against PostgreSQL queries and Python EDA.*  
*GitHub: https://github.com/samuel-ahinakwa-analytics*  
*LinkedIn: https://www.linkedin.com/in/samuelahinakwa-a73b45314*
