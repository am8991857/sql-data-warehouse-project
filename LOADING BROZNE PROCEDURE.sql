/*
	Load raw CSV data into Bronze tables.
	This procedure truncates each table and bulk loads from local files.
*/

----- INSERT DATA INTO BRONZE LAYER -----

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;

	SET NOCOUNT ON;
	
	PRINT '================================================';
	PRINT 'Loading Bronze Layer';
	PRINT '================================================';
	-- Note: Update file paths if your dataset folder is in a different location.

	SET @start_time = GETDATE();

	-- Reload CRM customer data.
	TRUNCATE TABLE bronze.crm_cust_info;

	BULK INSERT bronze.crm_cust_info
	from 'E:\ITI\Projects\SQL-DataWarehouse-Baraa\datasets\source_crm\cust_info.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- Reload CRM product data.
	TRUNCATE TABLE bronze.crm_prd_info;
	BULK INSERT bronze.crm_prd_info
	from 'E:\ITI\Projects\SQL-DataWarehouse-Baraa\datasets\source_crm\prd_info.csv'
	with
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- Reload CRM sales details.
	TRUNCATE TABLE bronze.crm_sales_details;
	BULK INSERT bronze.crm_sales_details
	from 'E:\ITI\Projects\SQL-DataWarehouse-Baraa\datasets\source_crm\sales_details.csv'
	with
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	set @end_time = GETDATE();

	PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

	-- Reload ERP customer data.
	TRUNCATE TABLE [bronze].[erp_CUST_AZ12];
	bulk insert [bronze].[erp_CUST_AZ12]
	from 'E:\ITI\Projects\SQL-DataWarehouse-Baraa\datasets\source_erp\CUST_AZ12.csv'
	with
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- Reload ERP location data.
	TRUNCATE TABLE [bronze].[erp_LOC_A101];
	bulk insert [bronze].[erp_LOC_A101]
	from 'E:\ITI\Projects\SQL-DataWarehouse-Baraa\datasets\source_erp\LOC_A101.csv'
	with
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	-- Reload ERP product categories.
	TRUNCATE TABLE [bronze].[erp_PX_CAT_G1V2];
	bulk insert [bronze].[erp_PX_CAT_G1V2]
	from 'E:\ITI\Projects\SQL-DataWarehouse-Baraa\datasets\source_erp\PX_CAT_G1V2.csv'
	with
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
END
GO

-- Run the procedure.
EXEC bronze.load_bronze;


-- Row count checks for quick validation.
SELECT COUNT(*) FROM bronze.crm_cust_info;
select COUNT(*) from bronze.crm_prd_info;
select COUNT(*) from bronze.crm_sales_details;

select COUNT(*) from bronze.erp_CUST_AZ12;
select COUNT(*) from bronze.erp_LOC_A101;
select COUNT(*) from bronze.erp_PX_CAT_G1V2;