-- ============================================================
-- AfriTech Electronics — Analytical Views
-- 8 Pre-Built Views for Power BI and Dashboard Connection
-- Author: Samuel Ahinakwa — Finance & Analytics Professional
-- Database: Afritech | Table: afritech_social
-- ============================================================

-- Run afritech_setup.sql BEFORE running this script
-- These views depend on the calculated columns added in setup


-- ── VIEW 1: Brand Health KPIs ─────────────────────────────
-- Master KPI view — all headline metrics in one query
-- Connects to Dashboard 1 — Brand Health Overview

CREATE OR REPLACE VIEW vw_brand_health_kpis AS
SELECT
    COUNT(*)                                                                AS total_interactions,
    ROUND(AVG(NPSResponse)::NUMERIC, 2)                                     AS avg_nps_score,
    ROUND(
        (SUM(CASE WHEN NPSResponse >= 9  THEN 1.0 ELSE 0 END)
       - SUM(CASE WHEN NPSResponse <= 6  THEN 1.0 ELSE 0 END))
        / COUNT(*) * 100, 1)                                                AS net_promoter_score,
    SUM(CASE WHEN NPSResponse >= 9                  THEN 1 ELSE 0 END)      AS promoters,
    SUM(CASE WHEN NPSResponse BETWEEN 7 AND 8       THEN 1 ELSE 0 END)      AS passives,
    SUM(CASE WHEN NPSResponse <= 6                  THEN 1 ELSE 0 END)      AS detractors,
    SUM(CASE WHEN Sentiment = 'Negative'            THEN 1 ELSE 0 END)      AS negative_interactions,
    SUM(CASE WHEN ProductRecalled = TRUE            THEN 1 ELSE 0 END)      AS recalled_products,
    SUM(CASE WHEN CrisisEventTime IS NOT NULL       THEN 1 ELSE 0 END)      AS crisis_events,
    SUM(CASE WHEN ResolutionStatus = FALSE          THEN 1 ELSE 0 END)      AS unresolved_crises,
    ROUND(AVG(CrisisResponseDays)::NUMERIC, 0)                              AS avg_response_days,
    SUM(CASE WHEN CompetitorMention = TRUE          THEN 1 ELSE 0 END)      AS competitor_mentions,
    SUM(TotalEngagement)                                                    AS total_engagement,
    SUM(PurchaseAmount)                                                     AS total_revenue
FROM afritech_social;

-- Expected: net_promoter_score = -46.23 | total_interactions = 73,586


-- ── VIEW 2: NPS by Customer Segment ──────────────────────
-- NPS, revenue, and detractor rate by New / Returning / VIP
-- Connects to Dashboard 2 — Customer Segmentation

CREATE OR REPLACE VIEW vw_nps_by_segment AS
SELECT
    CustomerType,
    COUNT(*)                                                                AS total,
    SUM(CASE WHEN NPS_Category = 'Promoter'  THEN 1 ELSE 0 END)            AS promoters,
    SUM(CASE WHEN NPS_Category = 'Passive'   THEN 1 ELSE 0 END)            AS passives,
    SUM(CASE WHEN NPS_Category = 'Detractor' THEN 1 ELSE 0 END)            AS detractors,
    ROUND(
        (SUM(CASE WHEN NPSResponse >= 9 THEN 1.0 ELSE 0 END)
       - SUM(CASE WHEN NPSResponse <= 6 THEN 1.0 ELSE 0 END))
        / COUNT(*) * 100, 1)                                                AS nps_score,
    ROUND(SUM(PurchaseAmount), 2)                                           AS total_revenue,
    ROUND(AVG(PurchaseAmount), 2)                                           AS avg_purchase
FROM afritech_social
GROUP BY CustomerType;

-- Expected: VIP = -47.0 | Returning = -46.2 | New = -42.7


-- ── VIEW 3: Sentiment by Platform ────────────────────────
-- Engagement and sentiment breakdown across all 5 platforms
-- Connects to Dashboard 1 — Brand Health

CREATE OR REPLACE VIEW vw_sentiment_by_platform AS
SELECT
    Platform,
    Sentiment,
    COUNT(*)                AS interaction_count,
    SUM(EngagementLikes)    AS total_likes,
    SUM(EngagementShares)   AS total_shares,
    SUM(TotalEngagement)    AS total_engagement
FROM afritech_social
GROUP BY Platform, Sentiment
ORDER BY Platform, Sentiment;


-- ── VIEW 4: Crisis Analysis ───────────────────────────────
-- Crisis response times, resolution rates, and distribution bands
-- Connects to Dashboard 3 — Crisis Management

CREATE OR REPLACE VIEW vw_crisis_analysis AS
SELECT
    SUM(CASE WHEN CrisisEventTime IS NOT NULL           THEN 1 ELSE 0 END)  AS total_crises,
    SUM(CASE WHEN ResolutionStatus = TRUE               THEN 1 ELSE 0 END)  AS resolved,
    SUM(CASE WHEN ResolutionStatus = FALSE              THEN 1 ELSE 0 END)  AS unresolved,
    ROUND(AVG(CrisisResponseDays)::NUMERIC, 0)                              AS avg_response_days,
    MIN(CrisisResponseDays)                                                 AS fastest_days,
    MAX(CrisisResponseDays)                                                 AS slowest_days,
    SUM(CASE WHEN CrisisResponseDays = 0                THEN 1 ELSE 0 END)  AS same_day,
    SUM(CASE WHEN CrisisResponseDays BETWEEN 1 AND 7    THEN 1 ELSE 0 END)  AS within_7_days,
    SUM(CASE WHEN CrisisResponseDays BETWEEN 8 AND 30   THEN 1 ELSE 0 END)  AS within_30_days,
    SUM(CASE WHEN CrisisResponseDays > 30               THEN 1 ELSE 0 END)  AS over_30_days
FROM afritech_social
WHERE CrisisEventTime IS NOT NULL;

-- Expected: total_crises = 13,383 | unresolved = 7,014 | avg_response_days = 190


-- ── VIEW 5: VIP Recovery Tiers ───────────────────────────
-- Segments disengaged VIP customers into four prioritised recovery tiers
-- Connects to Dashboard 2 — Customer Segmentation

CREATE OR REPLACE VIEW vw_vip_recovery_tiers AS
SELECT
    CASE
        WHEN CustomerType = 'VIP'
         AND NPSResponse IN (5, 6)
         AND CrisisEventTime IS NULL
         AND CompetitorMention = FALSE
         AND ProductRecalled = FALSE     THEN 'Tier 1 - Act This Week'
        WHEN CustomerType = 'VIP'
         AND NPSResponse IN (5, 6)
         AND CrisisEventTime IS NULL
         AND CompetitorMention = TRUE    THEN 'Tier 2 - Act This Month'
        WHEN CustomerType = 'VIP'
         AND NPSResponse IN (5, 6)
         AND ResolutionStatus = TRUE     THEN 'Tier 3 - Follow Up'
        WHEN CustomerType = 'VIP'
         AND NPSResponse IN (5, 6)
         AND ResolutionStatus = FALSE    THEN 'Tier 4 - Resolve First'
    END                                 AS recovery_tier,
    COUNT(*)                            AS customer_count,
    ROUND(SUM(PurchaseAmount), 2)       AS total_revenue
FROM afritech_social
WHERE CustomerType = 'VIP'
  AND NPSResponse IN (5, 6)
GROUP BY 1
ORDER BY 1;

-- Expected: Tier 1 = 1,045 / $843,315 | Tier 2 = 2,150 / $1,692,331


-- ── VIEW 6: Competitor Threat ─────────────────────────────
-- Competitor mention analysis by name, sentiment, and engagement
-- Connects to Dashboard 4 — Competitive Threat

CREATE OR REPLACE VIEW vw_competitor_threat AS
SELECT
    COALESCE(Competitor_x, 'Unattributed') AS competitor,
    COUNT(*)                                AS mentions,
    SUM(CASE WHEN Sentiment = 'Negative'
             THEN 1 ELSE 0 END)             AS negative_mentions,
    ROUND(SUM(CASE WHEN Sentiment = 'Negative'
                   THEN 1.0 ELSE 0 END)
              / COUNT(*) * 100, 1)          AS negative_pct,
    SUM(TotalEngagement)                    AS total_engagement
FROM afritech_social
WHERE CompetitorMention = TRUE
GROUP BY Competitor_x
ORDER BY mentions DESC;

-- Expected: MarsTech = 9,828 | MetaTech = 9,106 | SmartTech = 8,985


-- ── VIEW 7: Revenue at Risk ───────────────────────────────
-- Revenue exposure by customer segment and detractor band
-- Connects to Dashboard 2 — Customer Segmentation

CREATE OR REPLACE VIEW vw_revenue_at_risk AS
SELECT
    CustomerType,
    DetractorBand,
    COUNT(*)                                AS customer_count,
    ROUND(SUM(PurchaseAmount), 2)           AS revenue,
    ROUND(AVG(NPSResponse)::NUMERIC, 1)     AS avg_nps
FROM afritech_social
WHERE NPSResponse <= 6
GROUP BY CustomerType, DetractorBand
ORDER BY CustomerType, DetractorBand;

-- Expected total revenue at risk: $37,195,250


-- ── VIEW 8: Product Performance ──────────────────────────
-- NPS, sentiment, and revenue by product
-- Supports the recall pivot finding — recalled vs non-recalled

CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    ProductPurchased,
    COUNT(*)                                                                AS total_interactions,
    SUM(CASE WHEN ProductRecalled = TRUE        THEN 1 ELSE 0 END)          AS recalled,
    SUM(CASE WHEN Sentiment = 'Negative'        THEN 1 ELSE 0 END)          AS negative_sentiment,
    ROUND(
        (SUM(CASE WHEN NPSResponse >= 9 THEN 1.0 ELSE 0 END)
       - SUM(CASE WHEN NPSResponse <= 6 THEN 1.0 ELSE 0 END))
        / COUNT(*) * 100, 1)                                                AS nps_score,
    ROUND(SUM(PurchaseAmount), 2)                                           AS total_revenue
FROM afritech_social
GROUP BY ProductPurchased;


-- ── VERIFICATION ─────────────────────────────────────────
SELECT 'All 8 views created successfully' AS status;

SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'vw_%'
ORDER BY table_name;
