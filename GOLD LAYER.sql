-- Recreate customer dimension view.
IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO

create VIEW gold.dim_customer
AS
	SELECT
		ROW_NUMBER() OVER (ORDER BY cst_id)					AS customer_key, -- Surrogate key
		c_info.cst_id										AS customer_id,
		c_info.cst_key										AS customer_number,
		c_info.cst_firstname + ' ' + c_info.cst_lastname	AS customer_name,
		c_info.cst_marital_status							AS customer_marital_status,
		CASE 
			WHEN c_info.cst_gndr != 'n/a' THEN c_info.cst_gndr -- CRM is the primary source for gender
			ELSE COALESCE(c_az.gen, 'n/a')  			   -- Fallback to ERP data
		END													AS customer_gender,
		c_az.bdate											AS customer_birth_date,
		loc.cntry											AS customer_country,
		c_info.cst_create_date								AS customer_create_date

	from
		[silver].[crm_cust_info] c_info left join [silver].[erp_cust_az12] c_az
		on c_info.cst_key = c_az.cid 
		left join [silver].[erp_loc_a101] loc
		on c_az.cid = loc.cid
		-- Left joins keep all CRM customers and enrich when ERP data exists.

GO

	


-- Recreate product dimension view (active products only).
IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO
CREATE VIEW gold.dim_product 
AS
	select 
		pinfo.prd_id as product_id,
		pinfo.prd_key as product_number,
		pinfo.prd_nm as product_name,
		pinfo.prd_line as product_line,
		pinfo.prd_cost as product_cost,
		pcat.id as category_id,
		pcat.cat as category_name,
		pcat.subcat as subcategory,
		pcat.maintenance as maintenance
	from
		[silver].[crm_prd_info] pinfo 
		left join [silver].[erp_px_cat_g1v2] pcat
		on pinfo.cat_id = pcat.id
	where pinfo.prd_end_dt is null -- Keep only current products

GO


-- Recreate sales fact view (sales lines joined to dimensions).
if OBJECT_ID('gold.sales_fact', 'V') is not null
	drop view gold.sales_fact;
go

CREATE VIEW gold.sales_fact 
AS
	select
		sls.sls_ord_num			AS order_number,
		dimcust.customer_id		AS customer_number,
		dimprod.product_number  AS product_number,
		sls.sls_order_dt		AS order_date,
		sls.sls_ship_dt			AS order_ship_date,
		sls.sls_due_dt			AS order_due_date,
		sls.sls_price			AS price,
		sls.sls_quantity		AS quantity,
		sls.sls_sales			AS sales_amount
	from 
		silver.crm_sales_details sls
		left join gold.dim_product dimprod
		on sls.sls_prd_key = dimprod.product_number
		left join gold.dim_customer dimcust
		on dimcust.customer_id = sls.sls_cust_id

GO

-- Quick preview.
select * from gold.sales_fact




	