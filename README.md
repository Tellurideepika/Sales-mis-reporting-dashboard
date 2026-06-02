# 📊 Sales MIS Reporting Dashboard

A complete **Management Information System (MIS)** reporting project built on the Superstore Sales dataset using **Python**, **SQL (PostgreSQL)**, and **Power BI**.

---

## 🎯 Objective

Design a monthly MIS reporting framework to consolidate sales, revenue, and operational KPIs into an executive-facing dashboard — enabling management to track targets vs actuals, identify regional variance, and drill down by product category.

---

## 📁 Project Structure

```
sales-mis-dashboard/
│
├── sales_analysis.py       # Python EDA, KPI computation & 4-panel visualisation
├── sales_queries.sql       # PostgreSQL queries for all KPI reporting
├── sales_dashboard.png     # Auto-generated dashboard output (created on run)
└── README.md
```

> **Dataset:** [Superstore Sales – Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)  
> Download `Sample - Superstore.csv` and place it in the project folder before running.

---

## 📌 Key KPIs Tracked

| KPI | Description |
|-----|-------------|
| Total Revenue | Sum of all sales |
| Total Profit | Net profit across orders |
| Profit Margin % | Profit as % of revenue |
| Average Order Value | Revenue per unique order |
| MoM Revenue Growth | Month-over-month variance |
| Target Achievement % | Actual vs simulated yearly targets |

---

## 🔍 Analysis Performed

- **Revenue & Sales Trends** — Monthly revenue and profit line chart across all years
- **Regional Performance** — Revenue, profit, margin by East / West / Central / South
- **Product Category Breakdown** — Revenue and margin by Category and Sub-Category
- **Targets vs Actuals** — Simulated 15% YoY growth target vs actual performance
- **Top 10 Customers** — By revenue with margin and order count
- **Discount Impact Analysis** — Effect of discount bands on profit margin
- **Ship Mode Efficiency** — Average shipping days and revenue per mode
- **State-level Drill-down** — Top 20 states by revenue

---

## ⚙️ How to Run

### Python Analysis

```bash
# Install dependencies
pip install pandas numpy matplotlib

# Run analysis (generates terminal output + dashboard PNG)
python sales_analysis.py
```

### SQL Queries (PostgreSQL)

```bash
# 1. Create the table and import CSV
psql -U your_user -d your_db -f sales_queries.sql

# 2. Or paste individual queries into DBeaver / pgAdmin / TablePlus
```

---

## 📊 Dashboard Preview

![Sales Dashboard](sales_dashboard.png)

> 4-panel dashboard: Monthly Trend · Regional Performance · Category Breakdown · Targets vs Actuals

---

## 🛠️ Tech Stack

| Tool | Usage |
|------|-------|
| Python (Pandas, NumPy) | Data cleaning, EDA, KPI computation |
| Matplotlib | Dashboard visualisation |
| PostgreSQL | SQL-based KPI queries and aggregation |
| Power BI | Interactive executive dashboard (DAX + Power Query) |
| Excel | Pivot tables, data validation |

---

## 💡 Key Insights

- **West region** leads in revenue; **Central region** has the lowest profit margin
- **Technology** category generates the highest revenue; **Office Supplies** has the best margin
- Orders with **30%+ discount** consistently generate negative profit
- **Standard Class** shipping accounts for the majority of orders but **Same Day** has the highest margin

---

## 👩‍💻 Author

**Deepika Telluri**  
[LinkedIn](https://linkedin.com/in/telluri-deepika) · [GitHub](https://github.com/Tellurideepika/Deepika)
