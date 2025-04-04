/* 
======================================================
DDL Script: Create Gold Layer Views
======================================================

Script Purpose:
	This script creates views for the gold layer in the data warehouse.
	The gold layer represents the final fact and dimension tables in a Star Schema format.
	Each view performs transformations and combines data from the Silver layer 
	to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.

*/

-- ======================================================
-- Create the Customers View
-- ======================================================

if object_id('gold.dim_customer','V') is not null
drop view gold.dim_customer;
go

create view gold.dim_customer as
select
row_number() over (order by ci.cst_id) as customer_key, -- surrogate key
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_marital_status as marital_status,
case
	when ci.cst_gndr  != 'n/a' then ci.cst_gndr
	else coalesce(ca.gen,'n/a')
end as gender,
ca.bdate as brithdate,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid;
go

-- ======================================================
-- Create the Products View
-- ======================================================

if object_id('gold.dim_products','V') is not null
	drop view gold.dim_products;
go

create view gold.dim_products as
select
row_number() over (order by pi.prd_start_dt, pi.prd_key) as product_key, -- surrogate key
pi.prd_id as product_id,
pi.prd_key as product_number,
pi.prd_nm as product_name,
pi.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance as maintenance,
pi.prd_cost cost,
pi.prd_line as product_line,
pi.prd_start_dt as start_date
from silver.crm_prd_info pi
left join silver.erp_px_cat_g1v2 pc
on pi.cat_id = pc.id
where pi.prd_end_dt is null; -- Filter out all historical data
go

-- ======================================================
-- Create the Sales View
-- ======================================================

if object_id('gold.fact_sales','V') is not null
	drop view gold.fact_sales;
go

create view gold.fact_sales as
select
sd.sls_ord_num as order_number,
gp.product_key,
gc.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_customer gc
on sd.sls_cust_id = gc.customer_id
left join gold.dim_products gp
on sd.sls_prd_key = gp.product_number
go