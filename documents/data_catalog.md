# Data Catalog for the Gold Layer

## Overview
The gold layer provides a **business-level representation** of the data, consisting of two **dimension** tables and one **fact** table.

---

### View #1: **gold.dim_customer**
- **Purpose:** This table stores all of the customer information, including demographics and geographics.
- **Columns:**

| Column Name | Data Type | Description |
| ------------|-----------|-------------|
| customer_key | INT | Surrogate key that identifies each customer record in the table. |
| customer_id  | INT | Unique numerical identifier assigned to each customer.
| customer_number | NVARCHAR(50) | Alphanumeric identifier representing the customer, used for tracking and referencing. |
| first_name | NVARCHAR(50) | String representing the customer's first name |
| last_name | NVARCHAR(50) | String representing the customer's last name |
| country | NVARCHAR(50) | String representing the customer's country of residence (e.g., Canada, Australia) |
| marital_status | NVARCHAR(50) | String representing the marital status of the customer (e.g., Single, Married) |
| gender | NVARCHAR(50) | String representing the gender of the customer (e.g., Male, Female) |
| birthdate | DATE | The birth date of the customer in the format YYYY-MM-DD (e.g., 1999-01-01) |
| create_date | DATE | The date at which the customer record was entered into the system |

---

## View #2: **gold.dim_products**
- **Purpose:** This table stores all of the product information, including the category, cost, and product_line.
- **Columns:**

| Column Name | Data Type | Description |
| ------------|-----------|-------------|
| product_key | INT | Surrogate key that identifies each product record in the table. |
| produt_id | INT | Unique numerical identifier assigned to each product. |
| product_number | NVARCHAR(50) | Alphanumeric identifier representing the product, used for tracking and referencing. |
| product_name | NVARCHAR(50) | String representing the name of the product |
| category_id | NVARCHAR(50) | String representing the identifier for each product category. |
| category | NVARCHAR(50) | String representing the product category. |
| subcategory | NVARCHAR(50) | String representing the product subcategory. |
| maintenance | NVARCHAR(50) | String stating whether the product requires maintenance (e.g., Yes, No)
| cost | INT | Cost of the product in whole currency units (e.g., 100). |
| product_line | NVARCHAR(50) | String representing the product line (e.g., Road, Mountain).
| start_date | DATE | The date when the product became available for sale or use (e.g., 2011-09-07). | |

---

## View #3: **gold.fact_sales**
-  **Purpose:** This table stores all of the sales information, including the order date, sales amount, and prices.
-  **Columns:**

| Column Name | Data Type | Description |
| ------------|-----------|-------------|
| order_number | NVARCHAR(50) | Alphanumeric identifier representing the order, used for tracking and referencing. |
| product_key | INT | Key for navigating to the customer referenced from **gold.dim_customer**. |
| customer_key | INT | Key for navigating to the product referenced from **gold.dim_products**.|
| order_date | DATE | The date that the product was ordered. |
| shipping_date | DATE | The date that the product was shipped. |
| due_date | DATE | The date when the order payment is due (e.g., (1999-01-01). |
| sales_amount | INT | The amount purchased from the sale, in whole currency units (e.g., 1000) |
| quantity | INT | The quantity of the product that was purchased, in whole units (e.g., 3) |
| price | INT | The price per unit of the product that was purchased, in whole currency units (e.g., 100). |
