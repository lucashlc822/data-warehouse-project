/*
==============================
Stored Procedure: Load the Bronze Layer (Source -> Bronze)
==============================
Script Purpose:
	This stored procedure loads data into the bronze schema from external CSV files.
	It performs the following steps:
	- Truncates all of the bronze tables before loading any data.
	- Uses the bulk insert command to load the data
	- Identifies the time duration to load the batch of files, as well as the duration to load each table.

Parameters:
	None. This stored procedure does not accept paraemeters or return any values.

Usage Examples:
EXEC bronze.load_bronze
==============================
*/

-- create the stored procedure
create or alter procedure bronze.load_bronze as
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
	begin try
		set @batch_start_time = getdate();
		print '==============================';
		print 'Loading Bronze Layer';
		print '==============================';
		
		print '==============================';
		print 'Loading CRM Tables';
		print '==============================';
		
		set @start_time = getdate();
		print '>> Truncating Table: bronze.crm_cust_info';
		truncate table bronze.crm_cust_info; -- clear out the table before uploading data.
		print '>> Inserting Data Into: bronze.crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'D:\Data Analytics\Projects\Date Warehouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
				firstrow = 2, -- first row of data starts on row 2, which is right beneath the header.
				fieldterminator = ',', -- this denotes the delimiter of the csv file.
				tablock -- lock the entire table into the transaction is completed (bulk insert).
		);
		set @end_time = getdate();
		print '>> Load Duration:' + cast(datediff(second, @end_time, @start_time) as nvarchar) + 'seconds';
		print '>> --------------------------------------';

		-- repeat process for the rest of the tables:

		set @start_time = getdate();
		print '>> Truncating Table: bronze.crm_prd_info';
		truncate table bronze.crm_prd_info;
		print '>> Inserting Data Into: bronze.crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'D:\Data Analytics\Projects\Date Warehouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
				firstrow = 2, 
				fieldterminator = ',',
				tablock
		);
		set @end_time = getdate();
		print '>> Load Duration:' + cast(datediff(second, @end_time, @start_time) as nvarchar) + 'seconds';
		print '--------------------------------------';

		set @start_time = getdate();
		print '>> Truncating Table: bronze.crm_sales_details';
		truncate table bronze.crm_sales_details;
		print '>> Inserting Data Into: bronze.crm_sales_details';
			bulk insert bronze.crm_sales_details
			from 'D:\Data Analytics\Projects\Date Warehouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			with (
					firstrow = 2, 
					fieldterminator = ',',
					tablock
		);
		set @end_time = getdate();
		print '>> Load Duration:' + cast(datediff(second, @end_time, @start_time) as nvarchar) + 'seconds';
		print '--------------------------------------';

		print '==============================';
		print 'Loading CRM Tables';
		print '==============================';

		set @start_time = getdate();
		print 'Truncating Table: bronze.erp_cust_az12';
		truncate table bronze.erp_cust_az12;
		print 'Inserting Data Into: bronze.erp_cust_az12';
		bulk insert bronze.erp_cust_az12
		from 'D:\Data Analytics\Projects\Date Warehouse Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
				firstrow = 2, 
				fieldterminator = ',',
				tablock
		);
		set @end_time = getdate();
		print '>> Load Duration:' + cast(datediff(second, @end_time, @start_time) as nvarchar) + 'seconds';
		print '--------------------------------------';

		set @start_time = getdate();
		print 'Truncating Table: bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101;
		print 'Inserting Data Into: bronze.erp_loc_a101';
		bulk insert bronze.erp_loc_a101
		from 'D:\Data Analytics\Projects\Date Warehouse Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
				firstrow = 2, 
				fieldterminator = ',',
				tablock
		);
		set @end_time = getdate();
		print '>> Load Duration:' + cast(datediff(second, @end_time, @start_time) as nvarchar) + 'seconds';
		print '--------------------------------------';

		set @start_time = getdate();
		print 'Truncating Table: bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2;
		print 'Inserting Data Into: bronze.erp_px_cat_g1v2';
		bulk insert bronze.erp_px_cat_g1v2
		from 'D:\Data Analytics\Projects\Date Warehouse Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
				firstrow = 2, 
				fieldterminator = ',',
				tablock
		);
		set @end_time = getdate();
		print '>> Load Duration:' + cast(datediff(second, @end_time, @start_time) as nvarchar) + 'seconds';
		print '--------------------------------------';

		set @batch_end_time = getdate();
		print '==============================';
		print 'Loading Bronze Layer Completed';
		print 'Total Duration' + cast(datediff(second, @batch_start_time, @batch_end_time) as varchar) + 'seconds';
		print '==============================';
	end try
	begin catch -- if the catch runs, it means there was an error. The error, message, and state are outputted in the catch statement.
		print '==============================';
		print 'ERROR LOADING BRONZE LAYER'
		print 'Error Message' + error_message();
		print 'Error Number' + cast(error_number() as nvarchar);
		print 'Error State' + cast(error_state() as nvarchar);
		print '==============================';
	end catch
end

-- exec bronze.load_bronze
