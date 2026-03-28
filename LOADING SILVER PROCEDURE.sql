-- Transform Bronze data into cleaned Silver tables.
CREATE OR ALTER PROCEDURE silver.load_silver AS
begin
	TRUNCATE TABLE silver.crm_cust_info;
	INSERT INTO silver.crm_cust_info (
		cst_id, 
		cst_key, 
		cst_firstname, 
		cst_lastname, 
		cst_marital_status, 
		cst_gndr,
		cst_create_date
	)
	SELECT 
		cst_id,
		-- Keep source keys, trim names, and standardize codes.
		cst_key,
		--
		TRIM(cst_firstname) AS cst_firstname,
		--
		TRIM(cst_lastname) AS cst_lastname,
		-- Map marital status to readable values.
		CASE
			WHEN UPPER(TRIM(ISNULL(cst_marital_status, ''))) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(ISNULL(cst_marital_status, ''))) = 'M' THEN 'Married'
			ELSE 'n/a'
		END AS cst_marital_status,
		-- Map gender to readable values.
		CASE	
			WHEN UPPER(TRIM(ISNULL(cst_gndr, ''))) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(ISNULL(cst_gndr, ''))) = 'F' THEN 'Female'
			ELSE 'n/a'
		END AS cst_gndr,
		--
		cst_create_date
		--
	FROM (
			SELECT
					*,
					ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM 
					bronze.crm_cust_info
			WHERE 
					cst_id IS NOT NULL
	) t
	WHERE 
		flag_last = 1; -- Keep the latest record per customer

	--=================================================================================================

	-- Clean CRM product data and derive category and end dates.
	TRUNCATE TABLE [silver].[crm_prd_info];
	INSERT INTO [silver].[crm_prd_info](
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	SELECT
		prd_id,
		replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
		substring(prd_key, 7, len(prd_key)) as prd_key,
		TRIM(prd_nm),
		isnull(prd_cost, 0) as prd_cost,
		CASE	
			WHEN upper(trim(prd_line)) = 'R' then 'Road'
			WHEN upper(trim(prd_line)) = 'S' then 'Other Sales'
			WHEN upper(trim(prd_line)) = 'M' then 'Mountain'
			ELSE 'n/a'
		END as prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		CAST(
			DATEADD(
				DAY,
				-1,
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
			) AS DATE
		) AS prd_end_dt -- End date = day before next start date
		
	FROM 
		[bronze].[crm_prd_info]

	--=================================================================================================

	-- Clean CRM sales data and fix dates/amounts.
	TRUNCATE TABLE silver.crm_sales_details;
	insert into silver.crm_sales_details(
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
		-- Convert integer dates (yyyymmdd) to DATE, keep invalid as NULL.
		case 
			when sls_order_dt = 0 or len(sls_order_dt ) != 8 then NULL
			else cast(cast(sls_order_dt as varchar) as date)
		end as sls_ordr_dt,
		--------

		case 
			when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then NULL
			else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt,
		--------

		case
			when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
			else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt,
		--------
		-- Recalculate sales amount when missing or inconsistent.
		case	
			when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
			else sls_sales
		end as sls_sales,
		sls_quantity,
		-- Derive price if missing.
		case	
			when sls_price is null or sls_price <= 0 then sls_sales / nullif(sls_quantity, 0)
			else sls_price
		end as sls_price
	from
		bronze.crm_sales_details

	--=================================================================================================

	-- Clean ERP customer data.
	TRUNCATE TABLE silver.erp_CUST_AZ12;

	INSERT INTO silver.erp_CUST_AZ12
	(
		cid,
		bdate, 
		gen   
	)
	select
		case
			when cid like 'NAS%' then SUBSTRING(cid, 4, len(cid)) -- Remove 'NAS' prefix if present
			else cid
		end as cid,
		case
			when bdate > getdate() then null
			else CAST(CAST(bdate AS VARCHAR) AS DATE)
		end as bdate,
		case
			when trim(upper(gen)) in ('M', 'Male') then 'Male'
			when trim(upper(gen)) in ('F','Female') then 'Female'
			else 'n/a'
		end as gen

	from 
		bronze.erp_CUST_AZ12

	--=================================================================================================

	-- Clean ERP location data and standardize country names.
	TRUNCATE TABLE silver.erp_LOC_A101;
	insert into silver.erp_LOC_A101
	(
		cid,
		cntry
	)
	select	
		replace(cid, '-', ''),
		case
			when trim(cntry) = 'DE' then 'Germany'
			when trim(cntry) = 'US' or cntry = 'USA' then 'United States'
			when trim(cntry) = 'USA' then 'United States'
			when trim(cntry) is null or trim(cntry) = '' then 'n/a'
			else cntry
		end as cntry

	from bronze.erp_LOC_A101

	--=================================================================================================

	-- Load ERP product categories (already clean in source).
	TRUNCATE TABLE [silver].[erp_PX_CAT_G1V2];
	insert into [silver].[erp_PX_CAT_G1V2]
	(
		id,
		cat,
		subcat,
		maintenance
	)
	select
		id,
		cat,
		subcat,
		maintenance
	from bronze.erp_PX_CAT_G1V2




END
--=================================================================================================
