/*
Purpose:
- Create/recreate GOLD layer views: gold.dim_customer, gold.dim_product, and gold.sales_fact.
- These views standardize reporting-friendly columns by joining SILVER layer CRM/ERP sources.
- Script is re-runnable: it drops each view if it exists, then recreates it.
*/

-- Drop and recreate the customer dimension view (customer attributes with CRM/ERP fallback rules).
IF OBJECT_ID(N'gold.dim_customer', N'V') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO
CREATE VIEW gold.dim_customer
AS
    SELECT
        ROW_NUMBER() OVER (ORDER BY c_info.cst_id)                    AS customer_key, -- Surrogate key
        c_info.cst_id                                                 AS customer_id,
        c_info.cst_key                                                AS customer_number,
        c_info.cst_firstname + ' ' + c_info.cst_lastname              AS customer_name,
        c_info.cst_marital_status                                     AS customer_marital_status,
        CASE
            WHEN c_info.cst_gndr <> 'n/a' THEN c_info.cst_gndr         -- Prefer CRM gender when present
            ELSE COALESCE(c_az.gen, 'n/a')                             -- Fallback to ERP data
        END                                                           AS customer_gender,
        c_az.bdate                                                    AS customer_birth_date,
        loc.cntry                                                     AS customer_country,
        c_info.cst_create_date                                        AS customer_create_date
    FROM [silver].[crm_cust_info] AS c_info
    LEFT JOIN [silver].[erp_cust_az12] AS c_az
        ON c_info.cst_key = c_az.cid  -- Keep all CRM customers, enrich with ERP data
    LEFT JOIN [silver].[erp_loc_a101] AS loc
        ON c_az.cid = loc.cid;        -- Add country when available
GO

-- Drop and recreate the product dimension view (current products only).
IF OBJECT_ID(N'gold.dim_product', N'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO
CREATE VIEW gold.dim_product
AS
    SELECT
        pinfo.prd_id     AS product_id,
        pinfo.prd_key    AS product_number,
        pinfo.prd_nm     AS product_name,
        pinfo.prd_line   AS product_line,
        pinfo.prd_cost   AS product_cost,
        pcat.id          AS category_id,
        pcat.cat         AS category_name,
        pcat.subcat      AS subcategory,
        pcat.maintenance AS maintenance
    FROM [silver].[crm_prd_info] AS pinfo
    LEFT JOIN [silver].[erp_px_cat_g1v2] AS pcat
        ON pinfo.cat_id = pcat.id     -- Map products to ERP categories
    WHERE pinfo.prd_end_dt IS NULL;   -- Keep only active products
GO

-- Drop and recreate the sales fact view (sales lines joined to GOLD dimensions).
IF OBJECT_ID(N'gold.sales_fact', N'V') IS NOT NULL
    DROP VIEW gold.sales_fact;
GO
CREATE VIEW gold.sales_fact
AS
    SELECT
        sls.sls_ord_num         AS order_number,
        dimcust.customer_id     AS customer_number,
        dimprod.product_number  AS product_number,
        sls.sls_order_dt        AS order_date,
        sls.sls_ship_dt         AS order_ship_date,
        sls.sls_due_dt          AS order_due_date,
        sls.sls_price           AS price,
        sls.sls_quantity        AS quantity,
        sls.sls_sales           AS sales_amount
    FROM [silver].[crm_sales_details] AS sls
    LEFT JOIN [gold].[dim_product] AS dimprod
        ON sls.sls_prd_key = dimprod.product_number  -- Attach product attributes
    LEFT JOIN [gold].[dim_customer] AS dimcust
        ON dimcust.customer_id = sls.sls_cust_id;    -- Attach customer attributes
GO

-- Verification query to preview the fact view output.
SELECT TOP (100) *  -- 100 = limit rows for quick preview
FROM [gold].[sales_fact];
GO