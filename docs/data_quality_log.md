# Data Quality Log

Inspection of the 9 Olist tables in Python (Pandas) before cleaning. For each table I checked shape, data types, nulls, duplicates, key uniqueness, value distributions, and cross-table orphans.

**Severity:** **High** = changes the analysis results if ignored. **Medium** = needs handling, small impact. **Low** = documented only.

## Summary

| Table | Rows | Cols | Main issue | Severity |
|---|---|---|---|---|
| orders | 99,441 | 8 | Delivery dates missing for undelivered orders; dates stored as text | High |
| order_items | 112,650 | 7 | No quantity column (1 row = 1 unit); includes canceled orders | High |
| order_payments | 103,886 | 5 | Multiple payment rows per order | High |
| order_reviews | 99,224 | 7 | Multiple reviews per order; `review_id` reused across orders | High |
| customers | 99,441 | 5 | `customer_id` is per order; `customer_unique_id` identifies the person | High |
| products | 32,951 | 9 | 610 products missing category | Medium |
| translation | 71 | 2 | 2 categories have no English name | Low |
| sellers | 3,095 | 4 | No issues found | None |
| geolocation | 1,000,163 | 5 | Not used in the model | Low |

## Key findings that shape the analysis

1. **Revenue** is calculated from `order_items.price` on delivered orders. Joining `payments` row by row would double count.
2. **Delivery delay** is analysed on 96,470 orders (delivered, with a delivery date).
3. **Retention** uses `customer_unique_id`. A repeat customer is defined by distinct purchase dates: 2,149 of 96,096 customers (2.2%). This is preliminary, before filtering to delivered orders.
4. **Reviews** are reduced to one per order (latest by `review_answer_timestamp`).
5. **Most nulls are explained by order status, not data errors** (for example 2,957 of 2,965 missing delivery dates are undelivered orders).

## orders

| Issue | Count | Impact | Resolution |
|---|---|---|---|
| 5 date columns stored as text | 99,441 | Cannot compute durations | Convert with `pd.to_datetime` |
| `order_delivered_customer_date` null | 2,965 (2,957 undelivered, 8 delivered) | Delay cannot be computed | Analyse delay only on delivered orders with a date |
| `order_approved_at` null | 160 (14 delivered) | Not used in analysis | Keep |
| `order_delivered_carrier_date` null | 1,783 (2 delivered) | Not used in analysis | Keep |

`order_id` is unique. No duplicate rows. 97% of orders are delivered (96,478).

## order_items

| Issue | Count | Impact | Resolution |
|---|---|---|---|
| No quantity column, one row per unit | 112,650 | Quantity = row count | Count rows; do not drop repeated products |
| 775 orders have no items (0 delivered) | 775 | None on revenue | Keep |
| Canceled orders still have items | 461 | Inflates revenue | Filter revenue to delivered orders |
| `shipping_limit_date` stored as text | 112,650 | Minor | Convert to datetime |
| `price` right-skewed (mean 120.65, median 74.99, max 6,735) | - | Mean misleads | Keep outliers, report median too |
| `freight_value` = 0 | 383 (0.34%) | Negligible | Keep (free shipping) |

## order_payments

| Issue | Count | Impact | Resolution |
|---|---|---|---|
| Multiple payment rows per order (97% have 1, max 29) | 2,961 orders | Double counting on joins | Aggregate by `order_id` before joining |
| 1 delivered order has no payment record | 1 | None (revenue from items) | Keep |
| `not_defined` payment type (all canceled, value 0) | 3 | Skews payment mix | Exclude from payment-type analysis |
| `payment_value` = 0 | 9 | None | Keep |
| `payment_installments` = 0 on credit card | 2 | Invalid value | Exclude from installment analysis |

## order_reviews

| Issue | Count | Impact | Resolution |
|---|---|---|---|
| Multiple reviews per order | 547 orders (551 extra rows) | Double counting on joins | Keep latest review per order |
| `review_id` reused across orders | 814 extra rows | Wrong review counts | Join on `order_id`; use `COUNT(DISTINCT review_id)` |
| Comment title / message null | 88.3% / 58.7% | None (analysis uses score) | Keep |
| Orders with no review | 768 (646 delivered) | Smaller sample | Analyse only reviewed orders |
| 2 date columns stored as text | 99,224 | Minor | Convert to datetime |

Score distribution: 5 stars 57.8%, 4 stars 19.3%, 3 stars 8.2%, 2 stars 3.2%, 1 star 11.5%.

## customers

| Issue | Count | Impact | Resolution |
|---|---|---|---|
| `customer_id` unique per order; `customer_unique_id` repeats | 99,441 vs 96,096 | Using `customer_id` shows 0% retention | Use `customer_unique_id` |
| Customers with 2+ orders but only one purchase date | 848 | Overstates repeat rate | Repeat = distinct purchase dates |
| Zip prefix stored as integer, leading zero lost | 23,995 (24%) | Breaks joins and maps | Convert to 5-digit text |

No orphans between `customers` and `orders`. São Paulo accounts for 42% of customers.

## products, translation, sellers, geolocation

| Table | Issue | Count | Resolution |
|---|---|---|---|
| products | Category, name length, description length, photos all null | 610 (1.32% of revenue) | Label "Unknown" or exclude from category charts |
| products | `product_weight_g` = 0 (placeholder for missing) | 4 | Exclude from any weight analysis |
| products | Weight and size null | 2 | Not used |
| products | Column names misspelled (`lenght`) | 2 | Rename |
| translation | No English name for `pc_gamer` and `portateis_cozinha_e_preparadores_de_alimentos` | 2 | Add rows manually |
| sellers | No nulls, `seller_id` unique | 3,095 | None |
| geolocation | Not joined to the model | 1,000,163 | Not used |

## Validation

Order-level `price + freight_value` matches `payment_value` on sample orders (exact on a 29-payment order: 457.99; within 0.06 on another).

## Cleaning checklist

- [ ] Convert date columns in orders, items, reviews
- [ ] Create `delivery_days`, `delay_days`, `is_late` for delivered orders
- [ ] Keep one review per order
- [ ] Zip codes to 5-digit text
- [ ] Add 2 rows to translation; rename `lenght` columns