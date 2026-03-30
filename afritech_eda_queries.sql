-- ============================================================
-- AfriTech Electronics — EDA Query Library
-- Exploratory Data Analysis — All Confirmed Numbers
-- Author: Samuel Ahinakwa — Finance & Analytics Professional
-- Database: Afritech | Table: afritech_social
-- ============================================================

-- All numbers confirmed against Python and Excel
-- Run these queries after afritech_setup.sql and afritech_views.sql


-- ── 1. MASTER VERIFICATION ───────────────────────────────
-- Run this first in every session — confirms dataset integrity

SELECT
    COUNT(*)                                                                AS total_rows,
    COUNT(DISTINCT CustomerID)                                              AS unique_customers,
    ROUND(AVG(NPSResponse)::NUMERIC, 2)                                     AS avg_nps,
    ROUND(
        (SUM(CASE WHEN NPSResponse >= 9  THEN 1.0 ELSE 0 END)
       - SUM(CASE WHEN NPSResponse <= 6  THEN 1.0 ELSE 0 END))
        / COUNT(*) * 100, 2)                                                AS net_promoter_score,
    SUM(TotalEngagement)                                                    AS total_engagement,
    SUM(PurchaseAmount)                                                     AS total_revenue
FROM afritech_social;

-- Expected: total_rows = 73,586 | net_promoter_score = -46.23
-- total_revenue = 57,534,245 | total_engagement = 292,473,633


-- ── 2. NPS DISTRIBUTION ──────────────────────────────────

SELECT
    NPS_Category,
    COUNT(*)                                    AS count,
    ROUND(COUNT(*) * 100.0 / 73586, 2)          AS pct_of_total
FROM afritech_social
GROUP BY NPS_Category
ORDER BY count DESC;

-- Expected: Detractor = 47,528 (64.59%) | Passive = 12,550 | Promoter = 13,508


-- ── 3. NPS BY CUSTOMER SEGMENT ───────────────────────────

SELECT * FROM vw_nps_by_segment ORDER BY nps_score;

-- Expected: VIP = -47.0 | Returning = -46.2 | New = -42.7


-- ── 4. REVENUE AT RISK ───────────────────────────────────

SELECT
    CustomerType,
    COUNT(*)                                    AS detractor_count,
    ROUND(SUM(PurchaseAmount), 2)               AS revenue_at_risk,
    ROUND(AVG(NPSResponse)::NUMERIC, 1)         AS avg_nps
FROM afritech_social
WHERE NPSResponse <= 6
GROUP BY CustomerType
ORDER BY revenue_at_risk DESC;

-- Expected total: $37,195,250 | VIP = $15,736,110


-- ── 5. THE PIVOT FINDING — RECALL ANALYSIS ───────────────
-- Proves that recalls did NOT cause the brand damage

SELECT
    ProductRecalled,
    COUNT(*)                                    AS total,
    SUM(CASE WHEN Sentiment = 'Negative'
             THEN 1 ELSE 0 END)                 AS negative_count,
    ROUND(SUM(CASE WHEN Sentiment = 'Negative'
                   THEN 1.0 ELSE 0 END)
              / COUNT(*) * 100, 2)              AS negative_pct
FROM afritech_social
GROUP BY ProductRecalled;

-- Key finding: Recalled = 18.3% negative | Non-recalled = 18.1% negative
-- Difference: 0.2 percentage points — statistically zero


-- ── 6. CRISIS ANALYSIS ───────────────────────────────────

SELECT * FROM vw_crisis_analysis;

-- Expected: total_crises = 13,383 | unresolved = 7,014 | avg_response_days = 190


-- ── 7. CRISIS BY SEGMENT ─────────────────────────────────

SELECT
    CustomerType,
    COUNT(*)                                            AS total_crises,
    SUM(CASE WHEN ResolutionStatus = TRUE  THEN 1 ELSE 0 END) AS resolved,
    SUM(CASE WHEN ResolutionStatus = FALSE THEN 1 ELSE 0 END) AS unresolved,
    ROUND(AVG(CrisisResponseDays)::NUMERIC, 1)          AS avg_days,
    ROUND(SUM(CASE WHEN ResolutionStatus = FALSE
                   THEN PurchaseAmount ELSE 0 END), 2)  AS revenue_at_risk
FROM afritech_social
WHERE CrisisEventTime IS NOT NULL
GROUP BY CustomerType
ORDER BY total_crises DESC;


-- ── 8. RESPONSE TIME BANDS ───────────────────────────────

SELECT
    CASE
        WHEN CrisisResponseDays = 0              THEN 'Same Day (0)'
        WHEN CrisisResponseDays BETWEEN 1 AND 7  THEN '1-7 Days'
        WHEN CrisisResponseDays BETWEEN 8 AND 30 THEN '8-30 Days'
        WHEN CrisisResponseDays > 30             THEN 'Over 30 Days'
    END                                         AS response_band,
    COUNT(*)                                    AS count,
    ROUND(COUNT(*) * 100.0 / 13383, 2)          AS pct
FROM afritech_social
WHERE CrisisEventTime IS NOT NULL
GROUP BY 1
ORDER BY count DESC;

-- Expected: Over 30 Days = 10,927 (81.65%) | Same Day = 88 (0.66%)


-- ── 9. THE SAME-DAY DEEP DIVE ────────────────────────────
-- 88 same-day responses — 60 still unresolved

SELECT
    COUNT(*)                                            AS same_day_responses,
    SUM(CASE WHEN ResolutionStatus = TRUE  THEN 1 ELSE 0 END) AS resolved,
    SUM(CASE WHEN ResolutionStatus = FALSE THEN 1 ELSE 0 END) AS still_unresolved
FROM afritech_social
WHERE CrisisEventTime IS NOT NULL
  AND CrisisResponseDays = 0;

-- Expected: same_day = 88 | resolved = 28 | still_unresolved = 60


-- ── 10. POINT OF NO RETURN ───────────────────────────────
-- VIP + Unresolved Crisis + Competitor Present

SELECT
    COUNT(*)                            AS point_of_no_return_count,
    ROUND(SUM(PurchaseAmount), 2)       AS revenue_at_risk
FROM afritech_social
WHERE CustomerType = 'VIP'
  AND ResolutionStatus = FALSE
  AND CompetitorMention = TRUE
  AND CrisisEventTime IS NOT NULL;

-- Expected: count = 1,410 | revenue = $1,076,419


-- ── 11. COMPETITOR ANALYSIS ──────────────────────────────

SELECT * FROM vw_competitor_threat;

-- Expected: MarsTech = 9,828 | MetaTech = 9,106 | SmartTech = 8,985


-- ── 12. BRAND VS COMPETITOR RATIO ────────────────────────

SELECT
    SUM(CASE WHEN BrandMention = TRUE       THEN 1 ELSE 0 END) AS brand_mentions,
    SUM(CASE WHEN CompetitorMention = TRUE  THEN 1 ELSE 0 END) AS competitor_mentions,
    ROUND(
        SUM(CASE WHEN BrandMention = TRUE THEN 1.0 ELSE 0 END)
      / NULLIF(SUM(CASE WHEN CompetitorMention = TRUE THEN 1.0 ELSE 0 END), 0)
    , 2)                                                        AS brand_vs_competitor_ratio,
    ROUND(
        SUM(CASE WHEN BrandMention = TRUE THEN 1.0 ELSE 0 END)
      / (SUM(CASE WHEN BrandMention = TRUE THEN 1.0 ELSE 0 END)
       + SUM(CASE WHEN CompetitorMention = TRUE THEN 1.0 ELSE 0 END))
      * 100, 2)                                                 AS share_of_voice_pct
FROM afritech_social;

-- Expected: brand = 37,773 | competitor = 36,870 | ratio = 1.02 | SOV = 50.6%


-- ── 13. VIP RECOVERY TIERS ───────────────────────────────

SELECT * FROM vw_vip_recovery_tiers;

-- Expected: Tier 1 = 1,045 / $843,315 | Tier 2 = 2,150 / $1,692,331


-- ── 14. UNRESOLVED + COMPETITOR BY SEGMENT ───────────────

SELECT
    CustomerType,
    SUM(CASE WHEN CompetitorMention = TRUE  THEN 1 ELSE 0 END) AS with_competitor,
    SUM(CASE WHEN CompetitorMention = FALSE THEN 1 ELSE 0 END) AS without_competitor,
    ROUND(SUM(CASE WHEN CompetitorMention = TRUE
                   THEN PurchaseAmount ELSE 0 END), 2)          AS revenue_with_competitor
FROM afritech_social
WHERE ResolutionStatus = FALSE
  AND CrisisEventTime IS NOT NULL
GROUP BY CustomerType
ORDER BY with_competitor DESC;

-- Expected: Total with competitor = 3,432 | VIP = 1,410 ($1,076,419)


-- ── 15. MARKETING CONTRADICTION ──────────────────────────
-- New customers exposed to competitor mentions

SELECT
    CustomerType,
    COUNT(*)                                            AS total,
    SUM(CASE WHEN CompetitorMention = TRUE THEN 1 ELSE 0 END) AS competitor_exposed,
    ROUND(SUM(CASE WHEN CompetitorMention = TRUE
                   THEN 1.0 ELSE 0 END)
              / COUNT(*) * 100, 1)                      AS competitor_exposure_pct
FROM afritech_social
WHERE NPS_Category = 'Detractor'
GROUP BY CustomerType
ORDER BY CustomerType;

-- Key finding: 51.5% of new customers already exposed to competitor mentions
