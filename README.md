# E-Commerce Sales & Retention Analytics

Olist is a Brazilian online marketplace that connects small sellers with customers.
Its data shows 99,441 orders placed by only 96,096 unique customers, which means
most customers buy once and never return.

This project analyzes Olist's orders using SQL, Python and Power BI to find out:
1. Which months, categories and states generate the most revenue?
2. How many customers return, and how can retention be improved?
3. How do delivery delays affect customer review scores?

The goal is to give Olist data-backed recommendations to grow revenue and repeat purchases.

## Status

Work in progress.

- [x] Data model and inspection of all 9 tables
- [x] Data cleaning and delivery features
- [x] SQL analysis (11 business queries)
- [ ] RFM customer segmentation
- [ ] Power BI dashboard
- [ ] Final recommendations

## Key findings so far

All numbers are for delivered orders (Sep 2016 to Aug 2018) unless stated otherwise.

**1. Late delivery is linked to bad reviews** (95,824 delivered orders with a review)

| Delivery | Orders | Avg review score | 1-star reviews |
|---|---|---|---|
| On time or early | 89,443 | 4.29 | 6.6% |
| 1-3 days late | 1,852 | 3.29 | 25.1% |
| 4-7 days late | 1,748 | 2.10 | 58.6% |
| 8+ days late | 2,781 | 1.70 | 69.8% |

- Late orders are 6.7% of reviewed deliveries but account for 36.7% of all 1-star reviews.
- This is a correlation. Other causes, such as wrong or missing items, also drive low scores.
- Rio de Janeiro (2nd largest state by revenue) has 12.1% late orders, against 4.5% in São Paulo.

**2. Revenue grew fast in 2017 and then flattened**

- 96,478 orders generated 13.22M BRL in product revenue; average order value is 137.04 BRL.
- Revenue peaked in November 2017 (988K BRL).
- Jan-Aug 2018 revenue was 2.4x Jan-Aug 2017, but monthly revenue stayed between 840K and 980K after March 2018.

**3. Revenue is concentrated by category and state, but not by seller**

- The top 10 product categories generate 62.4% of revenue. health_beauty leads (1.23M BRL); watches_gifts is 2nd with fewer orders because its average product price per order is about 212 BRL.
- Three states (SP, RJ, MG) generate 63.3% of revenue; SP alone is 38.3%.
- Sellers are spread out: of 2,970 sellers with delivered sales, the largest brings 1.7% of revenue and the top 10 together 13.3%.

**4. Almost no customer comes back**

- Only 2.16% of customers (2,015 of 93,358) bought on more than one day.
- Cohort view: 1.3% of customers returned within 90 days of their first purchase (976 of 75,123, cohorts Jan 2017 to May 2018). The rate stayed flat even when cohorts grew 10x, so growth came from new customers, not from returning ones.
- Limit: orders on the same day count as one visit, and data ends in Aug 2018, so recent customers had less time to return.

## Tools

Python (Pandas), MySQL, SQL (JOINs, CTEs, window functions), Power BI

## Project structure

```
├── notebooks/
│   ├── Data_inspection.ipynb    # checks on all 9 tables
│   ├── data_cleaning.ipynb      # dates, delivery features, one review per order, delay vs review
│   └── load_to_mysql.ipynb      # loads cleaned data into MySQL
├── sql/
│   └── analysis_queries.sql     # 11 business queries with comments
├── docs/
│   └── data_quality_log.md      # issues found and how they are handled
└── dashboard/screenshots/
```

## How to reproduce

1. Download the dataset (link below) and place the CSV files in `data/`.
2. Run `Data_inspection.ipynb`, then `data_cleaning.ipynb` (saves cleaned CSVs to `data/cleaned/`).
3. Create a MySQL database named `olist` and run `load_to_mysql.ipynb`.
4. Run the queries in `sql/analysis_queries.sql`.

## Dataset

Brazilian E-Commerce Public Dataset by Olist
Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Data Model

![Data Model](dashboard/screenshots/model_view.png)

## Data Quality

Before analysis, I inspected all 9 tables for nulls, duplicates, key issues and cross-table mismatches.
See the full [Data Quality Log](docs/data_quality_log.md).