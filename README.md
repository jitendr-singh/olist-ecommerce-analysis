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
- [x] SQL analysis (revenue, monthly trend, growth)
- [ ] SQL analysis (categories, states, sellers, retention)
- [ ] RFM customer segmentation
- [ ] Power BI dashboard
- [ ] Final recommendations

## Key findings so far

**Delivery delay vs review score** (95,824 delivered orders with a review)

| Delivery | Orders | Avg review score | 1-star reviews |
|---|---|---|---|
| On time or early | 89,443 | 4.29 | 6.6% |
| 1-3 days late | 1,852 | 3.29 | 25.1% |
| 4-7 days late | 1,748 | 2.10 | 58.6% |
| 8+ days late | 2,781 | 1.70 | 69.8% |

- Late orders are 6.7% of reviewed deliveries but account for 36.7% of all 1-star reviews.
- This is a correlation. Other causes, such as wrong or missing items, also drive low scores.

**Revenue** (delivered orders only)

- 96,478 orders generated 13.22M BRL in product revenue; average order value is 137.04 BRL.
- Revenue peaked in November 2017 (988K BRL).
- Jan-Aug 2018 revenue was 2.4x Jan-Aug 2017, but monthly revenue stayed flat between 840K and 980K after March 2018.

**Retention (preliminary)**

- 2,149 of 96,096 customers (2.2%) bought on more than one day. This still includes canceled orders and will be recalculated on delivered orders.

## Tools

Python (Pandas), MySQL, SQL (JOINs, CTEs, window functions), Power BI

## Project structure

```
├── notebooks/
│   ├── Data_inspection.ipynb    # checks on all 9 tables
│   ├── data_cleaning.ipynb      # dates, delivery features, one review per order, delay vs review
│   └── load_to_mysql.ipynb      # loads cleaned data into MySQL
├── sql/
│   └── analysis_queries.sql     # business queries with comments
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