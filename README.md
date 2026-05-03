# FinTech-Customer-LTV-Analysis

---

## Project Background

This project analyses 7,000 digital wallet customers to understand what drives Customer Lifetime Value (LTV) in a fintech context. The dataset spans 20 customer attributes — covering demographics, transaction behaviour, engagement, incentive history, and service interactions — and was sourced from an Indian digital payments platform, with all monetary values converted to CAD.
 
Insights and recommendations are provided on the following key areas:
 
- **LTV Measurement:** How to accurately measure and decompose customer LTV in a digital wallet context, and what the LTV formula actually captures
- **Behavioural Drivers:** Which customer behaviours and engagement patterns most strongly distinguish high-LTV users from low-LTV users
- **Segment Opportunities:** Which customer segments offer the greatest opportunity for LTV improvement through targeted operational or engagement interventions
**Interactive Power BI Dashboard:** [Download .pbix](#) *(link once published)*
 
**Jump to section:**
[Problem](#the-problem) · [Dataset](#dataset-information) · [Tools](#tools-used) · [Process](#process-walkthrough) · [Summary](#executive-summary) · [Recommendations](#business-recommendations)
 
---

## The Problem
 
To understand Customer LTV, we can broadly define it as the total revenue or profit a customer brings during their lifecycle with the company. Digital wallet platforms accumulate large customer bases quickly, but not all customers contribute equally to long-term revenue. Without a clear understanding of what separates high-LTV customers from low-LTV ones, growth investment gets spread uniformly across the base — rewarding the wrong customers, misallocating incentive spend, and missing early signals of churn among the platform's most valuable users.
 
The core business questions this project addresses:
 
1. Do demographic factors (age, location, income level) predict which customers will generate the most long-term value?
2. What spending and engagement behaviours reliably correlate with high LTV — and how do they differ by magnitude across customer tiers?
3. Are the platform's existing incentive programmes (cashback, loyalty points, referrals) independently driving LTV growth, or simply rewarding customers who would have been high-value regardless?

---

## Dataset Information
 
| Attribute | Detail |
|-----------|--------|
| **Source** | Synthetic digital wallet dataset (Indian payments context) |
| **Rows** | 7,000 customers |
| **Columns** | 20 features |
| **Currency** | Originally INR — converted to CAD at 0.016 rate |
| **LTV Definition** | Projected lifetime revenue; scales linearly with total spend (~6.4–6.8× multiplier) |
 
**Feature categories:**
 
- **Demographics:** `age`, `location` (Urban/Suburban/Rural), `income_level` (Low/Middle/High)
- **Transaction behaviour:** `total_transactions`, `avg_transaction_value`, `min_transaction_value`, `max_transaction_value`, `total_spent`
- **Engagement:** `active_days`, `last_transaction_days_ago`, `app_usage_frequency`, `preferred_payment_method`
- **Incentives:** `loyalty_points_earned`, `referral_count`, `cashback_received`
- **Service:** `support_tickets_raised`, `issue_resolution_time`, `customer_satisfaction_score`
- **Target:** `ltv`

---
 
## Tools Used
 
| Tool | Purpose |
|------|---------|
| **Python (pandas, matplotlib, seaborn)** | Data cleaning, transformation, EDA, and visualisation |
| **PostgreSQL + SQLAlchemy** | Structured querying and analytical segmentation |
| **Jupyter Notebook** | End-to-end analysis walkthrough with embedded charts |
| **Power BI** | Interactive dashboard for stakeholder reporting |
 
---

## Process Walkthrough

### Data Cleaning (`main_complete.ipynb`)
 
- Standardized all column names to lowercase
- Checked for and confirmed no missing values or duplicate rows across all 7,000 records
- Converted five monetary columns from INR to CAD using a 0.016 exchange rate: `avg_transaction_value`, `total_spent`, `max_transaction_value`, `min_transaction_value`, `cashback_received`
- Rounded all numeric columns to 2 decimal places for consistency
- Engineered three derived features for use in EDA: `spent_per_active_day`, `txn_per_active_day`, and `age_group` bins

### Exploratory Data Analysis
 
The EDA is split across six SQL files and a Jupyter notebook, structured to answer the three project questions in sequence.
 
**`customer_overview.sql`** — Establishes baseline statistics: LTV ranges from $3,771 to $1,956,988 CAD with a median of $387,818. The distribution is right-skewed, confirming that a smaller cohort of high-transaction customers drives a disproportionate value of digital wallet platforms.
 
**`customer_demographics.sql` (Q1)** — Tested LTV against location, income level, age group, and app usage frequency. All demographic segments fell within a 3% spread of the overall average LTV (~$512K). A cross-tabulation of Q1 vs. Q4 LTV customers showed no dominant demographic profile — the only meaningful difference between the bottom and top quartile was behavioural, not demographic.
 
**`customer_spending.sql` + `customer_engagement.sql` (Q2)** — Identified total transactions as the primary LTV driver (r = 0.65). Top-quartile customers averaged 757 transactions vs. 267 for the bottom quartile. Spending velocity (total spent ÷ active days) showed the clearest separation: $3,047/day for Q4 vs. $188/day for Q1. RFM segmentation (Recency × Frequency × Monetary) cleanly classified the customer base into Champions to Lost customers. A recency risk analysis flagged high-LTV customers inactive for 6+ months as the top churn exposure.
 
**`customer_incentives.sql` (Q3)** — Measured cashback and loyalty points as a rate per dollar spent across all LTV quartiles. The rate was statistically identical across all four tiers, confirming that incentive programs proportionally reward existing spend — they do not independently generate it. Referral count showed near-zero correlation with LTV (r ≈ 0.0).
 
**`customer_service.sql` (Q3)** — Customer satisfaction (avg 5.4/10) and support ticket volume (avg ~10 per customer) were uniform across all LTV quartiles, meaning service quality neither explains high LTV nor predicts its absence. However, a "silent churner" segment — combine dormancy (40%), satisfaction score (35%), LTV (25%) into a risk score — represents the most at-risk LTV pool and the clearest proactive intervention opportunity.
 
---

## Executive Summary

LTV in this digital wallet dataset is almost entirely explained by total spending (r ≈ 1.0), and total spending is driven by **transaction volume** — not demographics, not incentives, and not app usage frequency.
 
Three findings define the story:
 
1. **Demographics are uniform.** Age, location, and income level each show less than 3% variance in average LTV across segments. A high-income urban 30-year-old and a low-income rural 55-year-old are statistically indistinguishable in LTV terms. Demographic targeting is effectively useless for this platform.
2. **Transaction volume separates the tiers.** The top LTV quartile completes nearly 3× more transactions than the bottom quartile (757 vs. 267). Spending velocity — dollars spent per active day — amplifies this: the difference between Q4 and Q1 is 16×. The platform's high-value customers are simply transacting far more frequently and at higher individual amounts. There is no shortcut segment to find them other than observing their behaviour.
3. **Incentives and service are lagging, not leading indicators.** Cashback and loyalty point density is identical across all LTV tiers — the programme rewards high spenders proportionally, but there is no evidence it converts lower-tier customers upward. Customer satisfaction averaging 5.4/10 is mediocre platform-wide and does not correlate with LTV — but the silent churner cohort (high LTV, low satisfaction, 90+ days dormant) represents concentrated, recoverable risk.

---
 
## Business Recommendations
 
**1. Retire demographic targeting — shift to behavioural segmentation**
The data makes a clear case: no demographic segment predictably produces high-LTV customers. Marketing and acquisition spend calibrated to income level or location is misallocated. Replace with RFM-based segmentation (Champions, Loyal, At Risk, Lost) which produces a $500K+ LTV gap between top and bottom segments and directly drives tactical decisions.
 
**2. Prioritize transaction frequency over acquisition volume**
Since LTV scales almost perfectly with transaction count, the highest-ROI lever is getting existing customers to transact more often — not acquiring new ones. Introduce frequency-based nudges (streaks, usage milestones, spending reminders) targeted at Mid-Low and Mid-High quartile customers who have the most room to increase activity.
 
**3. Redesign the incentive programme to lift mid-tier behaviour, not reward existing high-spenders**
Currently, cashback and loyalty points are proportional — they flow to customers who were already going to spend. Restructuring incentives around frequency thresholds (e.g., bonus cashback for the 10th transaction in a month) would target the behavioural lever that actually moves LTV, rather than rewarding the customers who need the least encouragement.
 
**4. Launch an immediate outreach program for silent churners**
Customers in the top 10% risk score are the highest-priority intervention target. These customers have demonstrated high value and something has gone wrong — a personalized re-engagement campaign (direct outreach, one-time incentive, service recovery) has greater upside given their established LTV.
 
**5. Address platform-wide satisfaction**
An average satisfaction score of 5.4/10 across all 7,000 customers is a structural risk regardless of its current LTV correlation. Satisfaction is a leading indicator of future churn that may not yet be visible in the transaction data. Identifying and resolving the most common support ticket categories (especially for the 10+ tickets/customer segment) would reduce service burden and improve retention odds for the whole base.