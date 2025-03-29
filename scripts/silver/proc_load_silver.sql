/*
======================================================================================================
Stored Procedure: Loading the Silver Tables (Bronze -> Silver)
======================================================================================================
Script Purpose:
This stored procedure performs the ETL (extract, transform, load) to populate the silver schema tables.
Actions Performed:
	- Truncating the silver schema tables.
	- Inserting transformed and cleansed data from the bronze to the silver tables.

Paramters:
This stored procedure does not accept any parameters and does not return any values.

Usage Example:
EXEC silver.load_silver;
======================================================================================================
*/

create or alter procedure silver.load_silver as 
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime
	begin try
	set @batch_start_time = GETDATE();
	print '================================';
	print 'Loading Silver Layer';
	print '================================';

	print '================================';
	print 'Loading CRM Tables';
	print '================================';
	
	-- truncate and load table silver.crm_cust_info
	set @start_time = GETDATE();
	print 'Truncating Table: silver.crm_cust_info'
	truncate table silver.crm_cust_info; 
	print 'Inserting Data Into: silver.crm_cust_info'
	insert into silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	)
	select
	cst_id,
	cst_key,-- run separate query checking if trimmed value does not output the same character length
	trim(cst_firstname), -- use trim to remove white spaces at the start and end
	trim(cst_lastname),
	case when upper(trim(cst_marital_status)) = 'M' then 'Married' --Normalize marital status values to readable format
	when upper(trim(cst_marital_status)) = 'S' then 'Single'
	else 'n/a'
	end as cst_marital_status,
	case when upper(trim(cst_gndr)) = 'M' then 'Male' -- Normalize gender values to readable format
	when upper(trim(cst_gndr)) = 'F' then 'Female'
	else 'n/a'
	end as cst_gndr,
	cst_create_date
	from
	(select
	*,
	ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as recency
	from bronze.crm_cust_info) as t1
	where recency = 1
	and cst_id is not null;
	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast(datediff(second,@end_time,@start_time) as nvarchar) + 'seconds';
	print '>> --------------------------------------------';
	-- repeat the process for the rest of the tables

	set @start_time = GETDATE();
	print 'Truncating Table: silver.crm_prd_info';
	truncate table silver.crm_prd_info;
	print 'Inserting Data Into: silver.crm_prd_info';
	insert into silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)
	
	select
	prd_id,
	replace(substring(prd_key,1,5),'-','_') as cat_id,
	substring(prd_key,7,LEN(prd_key)) as prd_key,
	prd_nm,
	ISNULL(prd_cost,0) as prd_cost,
	case when upper(trim(prd_line)) = 'M' then 'Mountain'
	when upper(trim(prd_line)) = 'R' then 'Road'
	when upper(trim(prd_line)) = 'S' then 'Other Sales'
	when upper(trim(prd_line)) = 'T' then 'Touring'
	else 'n/a'
	end as prd_line,
	cast(prd_start_dt as date) as prd_start_dt,
	cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt asc) - 1 as date) as prd_end_dt
	from bronze.crm_prd_info
	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast(datediff(second,@end_time,@start_time) as nvarchar) + 'seconds';
	print '>> --------------------------------------------';

	--crm_sales_details
	set @start_time = getdate();
	print'Truncating Table: silver.crm_sales_details';
	truncate table silver.crm_sales_details;
	print 'Inserting Data Into: silver.crm_sales_details';
	insert into silver.crm_Sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)
	select
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case 
		when len(sls_order_dt) != 8 or sls_order_dt <= 0 then null
		else cast(cast(sls_order_dt as varchar) as date)
	end as sls_order_dt,
	case 
		when len(sls_ship_dt) != 8 or sls_ship_dt <= 0 then null
		else cast(cast(sls_ship_dt as varchar) as date)
	end as sls_ship_dt,
	case 
		when len(sls_due_dt) != 8 or sls_due_dt <= 0 then null
		else cast(cast(sls_due_dt as varchar) as date)
	end as sls_due_dt,
	case
		when sls_sales is null or sls_sales != sls_quantity*sls_price or sls_sales <= 0 then ABS(sls_price)*sls_quantity
		else sls_sales
	end as sls_sales,
	sls_quantity,
	case
		when sls_price is null or sls_price <= 0 then sls_sales / nullif(sls_quantity,0)
		else sls_price
	end as sls_price
	from bronze.crm_sales_details

	set @end_time = getdate();
	print '>> Load Duration: ' + cast(datediff(second,@end_time,@start_time) as nvarchar) + 'seconds';
	print '>> --------------------------------------------';

	print '================================';
	print 'Loading ERP Tables';
	print '================================';

	--erp_cust_az12
	set @start_time = getdate();
	print'Truncating Table: silver.erp_cust_az12';
	truncate table silver.erp_cust_az12;
	print 'Inserting Data Into: silver.erp_cust_az12';
	insert into silver.erp_cust_az12 (
	cid, bdate, gen)
	select
	case
		when cid like 'NAS%' then substring(cid,4,LEN(cid))
		else cid
	end as cid,
	case
		when bdate > GETDATE() then null
		else bdate
	end as bdate,
	case
		when upper(trim(gen)) in ('MALE','M') then 'Male'
		when upper(trim(gen)) in ('FEMALE','F') then 'Female'
		else 'n/a'
	end as gen
	from bronze.erp_cust_az12
	set @end_time = getdate();
	print '>> Load Duration: ' + cast(datediff(second,@end_time,@start_time) as nvarchar) + 'seconds';
	print '>> --------------------------------------------';

	--erp_loc_a101
	set @start_time = getdate();
	print'Truncating Table: silver.erp_loc_a101';
	truncate table silver.erp_loc_a101;
	print 'Inserting Data Into: silver.erp_loc_a101';
	insert into silver.erp_loc_a101 (cid, cntry)
	select
	replace(cid,'-','') as cid,
	case
		when trim(cntry) in ('US','USA') then 'United States'
		when trim(cntry) = 'DE' then 'Germany'
		when trim(cntry) = '' or cntry is null then 'n/a'
		else trim(cntry)
	end as cntry
	from bronze.erp_loc_a101
	set @end_time = getdate();
	print '>> Load Duration: ' + cast(datediff(second,@end_time,@start_time) as nvarchar) + 'seconds';
	print '>> --------------------------------------------';
	
	--erp_px_cat_g1v2
	set @start_time = getdate();
	print'Truncating Table: silver.erp_px_cat_g1v2';
	truncate table silver.erp_px_cat_g1v2;
	print 'Inserting Data Into: silver.erp_px_cat_g1v2';
	insert into silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance)
	select
	id,
	cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2
	set @end_time = getdate();
	print '>> Load Duration: ' + cast(datediff(second,@end_time,@start_time) as nvarchar) + 'seconds';
	print '>> --------------------------------------------';

	end try
	-- Using the catch to display all error messages caused by the try.
	begin catch
		print '====================================================';	
		print 'Error Occured while loading Silver Layer';
		print 'Error Message: ' + error_message();
		print 'Error Number: ' + cast(error_number() as nvarchar);
		print 'Error State: ' + cast(error_state() as nvarchar);
		print '====================================================';	
	end catch
end

