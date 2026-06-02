# 📊 Sales Performance & Business Intelligence Dashboard

An end-to-end Business Intelligence (BI) project built using Power BI, SQL (PostgreSQL), Python, and Excel to analyze sales performance, profitability, customer behavior, and regional trends. The dashboard provides management-level insights through interactive reporting and KPI monitoring.

---

## 🎯 Business Problem

Organizations often struggle with fragmented sales data, making it difficult to monitor performance, track targets, and identify growth opportunities.

This project was developed to create a centralized MIS reporting solution that enables stakeholders to:

- Monitor key business KPIs
- Compare actual performance against targets
- Identify profitable regions and products
- Analyze customer purchasing behavior
- Support data-driven decision making

---

## 📌 Key KPIs

| KPI | Description |
|------|-------------|
| Total Sales | Total revenue generated |
| Total Profit | Net profit earned |
| Profit Margin % | Profit as a percentage of sales |
| Total Orders | Number of orders processed |
| Average Order Value | Revenue per order |
| YoY Growth % | Year-over-Year sales growth |
| Target Achievement % | Actual vs Target performance |

---

## 📊 Dashboard Features

### Executive Overview
- KPI Cards
- Monthly Sales Trend
- Monthly Profit Trend
- Sales vs Target Analysis

### Regional Analysis
- Revenue by Region
- Profit by Region
- State-wise Sales Performance
- Regional Summary Matrix

### Product Analysis
- Sales by Category
- Top Products by Revenue
- Pareto Analysis (80/20 Rule)
- Sales vs Profit Analysis

### Customer Insights
- Customer Segmentation
- Top Customers
- Repeat Customer Analysis
- Revenue Contribution Analysis

---

## 📈 Power BI Features

- Interactive Slicers & Filters
- Drill-Through Analysis
- KPI Cards
- Dynamic DAX Measures
- Power Query Transformations
- Custom Tooltips
- Bookmark Navigation
- Responsive Dashboard Design

---

## 🧮 Sample DAX Measures

```DAX
Total Sales =
SUM(Orders[Sales])

Total Profit =
SUM(Orders[Profit])

Profit Margin % =
DIVIDE([Total Profit],[Total Sales])

Average Order Value =
DIVIDE(
    [Total Sales],
    DISTINCTCOUNT(Orders[Order ID])
)

YoY Growth % =
VAR PrevYear =
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR(Date[Date])
)
RETURN
DIVIDE([Total Sales]-PrevYear,PrevYear)
```

---

## 📸 Dashboard Preview

### Executive Dashboard
![Executive Dashboard](screenshots/executive_dashboard.png)

### Regional Analysis
![Regional Analysis](screenshots/regional_analysis.png)

### Product Analysis
![Product Analysis](screenshots/product_analysis.png)

---

## 💡 Key Business Insights

- West region contributed the highest share of total sales revenue.
- Technology category generated the largest revenue contribution.
- Orders with discounts above 30% consistently resulted in negative profit margins.
- Same Day shipping showed the highest profitability despite lower order volume.
- Top 20% of products contributed approximately 80% of total sales revenue.
- Revenue exceeded annual targets and achieved strong year-over-year growth.

---

## 🛠️ Tech Stack

| Tool | Purpose |
|--------|---------|
| Power BI | Dashboard Development |
| SQL (PostgreSQL) | Data Extraction & Analysis |
| Python (Pandas, NumPy) | Data Cleaning & KPI Computation |
| Power Query | Data Transformation |
| DAX | Business Calculations |
| Excel | Data Validation & Reporting |

---

## 📌 Project Impact

✔ Analyzed 5,000+ sales transactions across multiple regions and categories

✔ Built an interactive management reporting solution for KPI monitoring

✔ Automated business reporting using SQL, Python, and Power BI

✔ Enabled data-driven decision making through visual analytics

✔ Delivered actionable insights into sales, profitability, and customer behavior

---

## 📂 Dataset

Dataset Used: Superstore Sales Dataset

Source: Kaggle – Superstore Dataset

---

## 👩‍💻 Author

**Deepika Telluri**

Aspiring Data Analyst | Power BI Developer | SQL Analyst

Skills: Power BI • SQL • Python • Excel • Data Visualization • Business Intelligence
