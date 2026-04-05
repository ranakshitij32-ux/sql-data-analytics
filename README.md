# sql-data-analytics
This project demonstrates advanced SQL analytics for a retail business, focusing on **customer segmentation**, **product performance**, and **sales trend analysis**. The goal is to transform raw transactional data into actionable business insights using MySQL.

## 🔍 Key SQL Features Demonstrated

| Technique | Where Used |
| :--- | :--- |
| **Window Functions** | `AVG() OVER()`, `LEAD()` for YoY comparison, `PARTITION BY` |
| **CTEs (Common Table Expressions)** | `WITH` clauses for modular, readable queries |
| **Conditional Logic** | `CASE` statements for customer/product segmentation |
| **Aggregations** | `SUM()`, `COUNT()`, `AVG()` with `GROUP BY` |
| **Views** | `CREATE VIEW` for reusable `report_customers` and `report_products` |
| **Joins** | `INNER JOIN`, `LEFT JOIN` across fact & dimension tables |
| **Date Functions** | `YEAR()`, `MONTH()`, `TIMESTAMPDIFF()`, `NOW()` |
