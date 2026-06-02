import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import warnings
warnings.filterwarnings("ignore")

# ─────────────────────────────────────────────
# 1. LOAD & CLEAN DATA
# ─────────────────────────────────────────────

df = pd.read_csv("Sample - Superstore.csv", encoding="latin-1")

# Standardise column names
df.columns = df.columns.str.strip().str.replace(" ", "_").str.lower()

# Parse dates
df["order_date"] = pd.to_datetime(df["order_date"])
df["ship_date"]  = pd.to_datetime(df["ship_date"])

# Derived columns
df["year"]        = df["order_date"].dt.year
df["month"]       = df["order_date"].dt.month
df["month_name"]  = df["order_date"].dt.strftime("%b")
df["year_month"]  = df["order_date"].dt.to_period("M")
df["profit_margin"] = (df["profit"] / df["sales"]).replace([np.inf, -np.inf], 0).round(4)

print("✅ Data loaded successfully!")
print(f"   Rows: {len(df):,}  |  Columns: {df.shape[1]}")
print(f"   Date range: {df['order_date'].min().date()} → {df['order_date'].max().date()}")
print()

# ─────────────────────────────────────────────
# 2. KPI SUMMARY
# ─────────────────────────────────────────────

print("=" * 50)
print("         OVERALL KPI SUMMARY")
print("=" * 50)
print(f"  Total Revenue   : ${df['sales'].sum():>12,.2f}")
print(f"  Total Profit    : ${df['profit'].sum():>12,.2f}")
print(f"  Total Orders    : {df['order_id'].nunique():>12,}")
print(f"  Total Customers : {df['customer_id'].nunique():>12,}")
print(f"  Avg Order Value : ${df.groupby('order_id')['sales'].sum().mean():>12,.2f}")
print(f"  Overall Margin  : {df['profit'].sum()/df['sales'].sum()*100:>11.2f}%")
print("=" * 50)
print()

# ─────────────────────────────────────────────
# 3. REVENUE & SALES TRENDS (Monthly)
# ─────────────────────────────────────────────

monthly = (df.groupby("year_month")
             .agg(revenue=("sales", "sum"), profit=("profit", "sum"), orders=("order_id", "nunique"))
             .reset_index())
monthly["year_month_str"] = monthly["year_month"].astype(str)

print("── Monthly Revenue (last 12 months) ──────────────")
print(monthly.tail(12)[["year_month_str", "revenue", "profit", "orders"]]
      .rename(columns={"year_month_str": "Month"})
      .to_string(index=False))
print()

# ─────────────────────────────────────────────
# 4. REGIONAL PERFORMANCE
# ─────────────────────────────────────────────

regional = (df.groupby("region")
              .agg(revenue=("sales", "sum"),
                   profit=("profit", "sum"),
                   orders=("order_id", "nunique"),
                   customers=("customer_id", "nunique"))
              .reset_index()
              .sort_values("revenue", ascending=False))
regional["margin_%"] = (regional["profit"] / regional["revenue"] * 100).round(2)

print("── Regional Performance ───────────────────────────")
print(regional.to_string(index=False))
print()

# ─────────────────────────────────────────────
# 5. PRODUCT CATEGORY BREAKDOWN
# ─────────────────────────────────────────────

category = (df.groupby(["category", "sub-category"])
              .agg(revenue=("sales", "sum"),
                   profit=("profit", "sum"),
                   quantity=("quantity", "sum"))
              .reset_index()
              .sort_values("revenue", ascending=False))
category["margin_%"] = (category["profit"] / category["revenue"] * 100).round(2)

print("── Category & Sub-Category Breakdown ─────────────")
print(category.to_string(index=False))
print()

# ─────────────────────────────────────────────
# 6. TARGETS vs ACTUALS
# ─────────────────────────────────────────────
# Simulated annual targets (+15% over previous year actuals)

yearly = df.groupby("year").agg(actual_revenue=("sales", "sum"), actual_profit=("profit", "sum")).reset_index()
yearly["target_revenue"] = (yearly["actual_revenue"].shift(1) * 1.15).fillna(yearly["actual_revenue"] * 0.90)
yearly["target_profit"]  = (yearly["actual_profit"].shift(1)  * 1.15).fillna(yearly["actual_profit"]  * 0.90)
yearly["rev_achievement_%"] = (yearly["actual_revenue"] / yearly["target_revenue"] * 100).round(2)
yearly["pft_achievement_%"] = (yearly["actual_profit"]  / yearly["target_profit"]  * 100).round(2)

print("── Targets vs Actuals (Yearly) ────────────────────")
print(yearly.to_string(index=False))
print()

# ─────────────────────────────────────────────
# 7. TOP 10 CUSTOMERS BY REVENUE
# ─────────────────────────────────────────────

top_customers = (df.groupby("customer_name")
                   .agg(revenue=("sales", "sum"), profit=("profit", "sum"), orders=("order_id", "nunique"))
                   .reset_index()
                   .sort_values("revenue", ascending=False)
                   .head(10))

print("── Top 10 Customers by Revenue ────────────────────")
print(top_customers.to_string(index=False))
print()

# ─────────────────────────────────────────────
# 8. VISUALISATIONS (4-panel dashboard)
# ─────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(16, 10))
fig.suptitle("Sales MIS Reporting Dashboard", fontsize=18, fontweight="bold", y=1.01)

# --- Panel 1: Monthly Revenue Trend ---
ax1 = axes[0, 0]
x_labels = monthly["year_month_str"]
ax1.plot(x_labels, monthly["revenue"], color="#2563EB", linewidth=2, marker="o", markersize=4, label="Revenue")
ax1.fill_between(range(len(x_labels)), monthly["revenue"], alpha=0.15, color="#2563EB")
ax1.plot(x_labels, monthly["profit"], color="#16A34A", linewidth=1.5, linestyle="--", marker="s", markersize=3, label="Profit")
step = max(1, len(x_labels) // 8)
ax1.set_xticks(range(0, len(x_labels), step))
ax1.set_xticklabels(x_labels[::step], rotation=45, ha="right", fontsize=8)
ax1.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
ax1.set_title("Monthly Revenue & Profit Trend", fontweight="bold")
ax1.legend(fontsize=9)
ax1.grid(axis="y", alpha=0.3)

# --- Panel 2: Regional Revenue Bar ---
ax2 = axes[0, 1]
colors = ["#2563EB", "#16A34A", "#DC2626", "#D97706"]
bars = ax2.bar(regional["region"], regional["revenue"], color=colors[:len(regional)], edgecolor="white", width=0.55)
ax2.bar(regional["region"], regional["profit"], color=[c + "99" for c in ["#2563EB99","#16A34A99","#DC262699","#D9770699"]][:len(regional)],
        bottom=0, width=0.55, label="Profit (overlay)")
for bar, margin in zip(bars, regional["margin_%"]):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 500,
             f"{margin}%", ha="center", va="bottom", fontsize=9, fontweight="bold")
ax2.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
ax2.set_title("Regional Revenue & Profit Margin", fontweight="bold")
ax2.grid(axis="y", alpha=0.3)

# --- Panel 3: Category Revenue Pie ---
ax3 = axes[1, 0]
cat_summary = df.groupby("category")["sales"].sum().reset_index().sort_values("sales", ascending=False)
wedge_colors = ["#2563EB", "#16A34A", "#DC2626"]
wedges, texts, autotexts = ax3.pie(
    cat_summary["sales"], labels=cat_summary["category"],
    autopct="%1.1f%%", colors=wedge_colors[:len(cat_summary)],
    startangle=140, pctdistance=0.75,
    wedgeprops={"edgecolor": "white", "linewidth": 2}
)
for t in autotexts:
    t.set_fontsize(10)
    t.set_fontweight("bold")
ax3.set_title("Revenue by Category", fontweight="bold")

# --- Panel 4: Targets vs Actuals ---
ax4 = axes[1, 1]
x = np.arange(len(yearly))
w = 0.35
ax4.bar(x - w/2, yearly["target_revenue"],  width=w, label="Target",  color="#94A3B8", edgecolor="white")
ax4.bar(x + w/2, yearly["actual_revenue"],  width=w, label="Actual",  color="#2563EB", edgecolor="white")
for i, (t, a) in enumerate(zip(yearly["target_revenue"], yearly["actual_revenue"])):
    color = "#16A34A" if a >= t else "#DC2626"
    pct = a / t * 100
    ax4.text(i + w/2, a + 1000, f"{pct:.0f}%", ha="center", fontsize=9, color=color, fontweight="bold")
ax4.set_xticks(x)
ax4.set_xticklabels(yearly["year"].astype(int).astype(str))
ax4.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
ax4.set_title("Yearly Targets vs Actuals", fontweight="bold")
ax4.legend(fontsize=9)
ax4.grid(axis="y", alpha=0.3)

plt.tight_layout()
plt.savefig("sales_dashboard.png", dpi=150, bbox_inches="tight")
print("✅ Dashboard saved as 'sales_dashboard.png'")
plt.show()
