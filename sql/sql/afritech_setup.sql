-- ============================================================
-- AfriTech Electronics — Database Setup
-- Calculated Columns and Data Preparation
-- Author: Samuel Ahinakwa — Finance & Analytics Professional
-- Database: Afritech | Table: afritech_social
-- ============================================================

-- Run this script ONCE after importing the raw data
-- It adds four calculated columns used across all views and dashboards


-- ── COLUMN 1: NPS Category ───────────────────────────────
-- Classifies each customer as Promoter, Passive, or Detractor
-- based on their NPS response score

ALTER TABLE afritech_social
ADD COLUMN IF NOT EXISTS NPS_Category VARCHAR(20);

UPDATE afritech_social
SET NPS_Category =
    CASE
        WHEN NPSResponse >= 9 THEN 'Promoter'
        WHEN NPSResponse >= 7 THEN 'Passive'
        ELSE 'Detractor'
    END;


-- ── COLUMN 2: Detractor Band ─────────────────────────────
-- Segments detractors into three bands by severity
-- Used in revenue at risk analysis and VIP recovery tiers

ALTER TABLE afritech_social
ADD COLUMN IF NOT EXISTS DetractorBand VARCHAR(30);

UPDATE afritech_social
SET DetractorBand =
    CASE
        WHEN NPSResponse BETWEEN 0 AND 2 THEN '1 - Hostile (0-2)'
        WHEN NPSResponse BETWEEN 3 AND 4 THEN '2 - Disappointed (3-4)'
        WHEN NPSResponse BETWEEN 5 AND 6 THEN '3 - Disengaged (5-6)'
        WHEN NPSResponse BETWEEN 7 AND 8 THEN '4 - Passive (7-8)'
        ELSE '5 - Promoter (9-10)'
    END;


-- ── COLUMN 3: Crisis Response Days ───────────────────────
-- Calculates days between crisis event and first response
-- NULL where no crisis event or no response recorded

ALTER TABLE afritech_social
ADD COLUMN IF NOT EXISTS CrisisResponseDays INTEGER;

UPDATE afritech_social
SET CrisisResponseDays = (FirstResponseTime - CrisisEventTime)
WHERE CrisisEventTime IS NOT NULL
  AND FirstResponseTime IS NOT NULL
  AND FirstResponseTime >= CrisisEventTime;


-- ── COLUMN 4: Total Engagement ───────────────────────────
-- Sums likes + shares + comments into a single engagement metric

ALTER TABLE afritech_social
ADD COLUMN IF NOT EXISTS TotalEngagement INTEGER;

UPDATE afritech_social
SET TotalEngagement = EngagementLikes + EngagementShares + EngagementComments;


-- ── VERIFICATION ─────────────────────────────────────────
-- Run after setup to confirm all columns populated correctly

SELECT
    COUNT(*)                                        AS total_rows,
    COUNT(NPS_Category)                             AS nps_category_populated,
    COUNT(DetractorBand)                            AS detractor_band_populated,
    COUNT(CrisisResponseDays)                       AS response_days_populated,
    COUNT(TotalEngagement)                          AS total_engagement_populated,
    ROUND(AVG(NPSResponse)::NUMERIC, 2)             AS avg_nps,
    SUM(TotalEngagement)                            AS total_engagement
FROM afritech_social;

-- Expected: total_rows = 73,586 | avg_nps ≈ 4.47 | total_engagement = 292,473,633

SELECT DetractorBand, COUNT(*) AS count
FROM afritech_social
GROUP BY DetractorBand
ORDER BY DetractorBand;
