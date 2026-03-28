/*
	Create raw staging (Bronze) tables.
	These tables store data as-is from source CSV files.
*/


----- CREATING TABLES FOR THE BRONZE LAYER -----

-- CRM customer master data (raw).
CREATE TABLE bronze.crm_cust_info(
	cst_id				int,
	cst_key				NVARCHAR(100),
	cst_firstname		NVARCHAR(50),
	cst_lastname		NVARCHAR(50),
	cst_marital_status	NVARCHAR(50),
	cst_gndr			NVARCHAR(50), 
	cst_create_date		date
);

-- CRM product master data (raw).
CREATE TABLE bronze.crm_prd_info(
	prd_id			int,
	prd_key			NVARCHAR(100),
	prd_nm			NVARCHAR(100),
	prd_cost		int,
	prd_line		NVARCHAR(10),
	prd_start_dt	date,
	prd_end_dt		date
);

-- CRM sales line data (raw order lines).
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num		NVARCHAR(100),
	sls_prd_key		NVARCHAR(100),
	sls_cust_id		int,
	sls_order_dt	int,
	sls_ship_dt		int,
	sls_due_dt		int,
	sls_sales		int,
	sls_quantity	int,
	sls_price		int
);

-- ERP customer attributes (raw).
CREATE TABLE bronze.erp_CUST_AZ12(
	cid		NVARCHAR(100),
	bdate	date,
	gen		NVARCHAR(50),
);

-- ERP customer locations (raw).
CREATE TABLE bronze.erp_LOC_A101(
	cid		NVARCHAR(100),
	cntry	NVARCHAR(50)
);	

-- ERP product category mapping (raw).
CREATE TABLE bronze.erp_PX_CAT_G1V2(
	id				NVARCHAR(100),
	cat				NVARCHAR(50),
	subcat			NVARCHAR(50),
	maintenance		NVARCHAR(20)
);

------------------------------------------------

