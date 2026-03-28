# SQL Data Warehouse (Bronze-Silver-Gold)

A simple SQL Server data warehouse project that loads CRM and ERP CSV files, cleans them, and builds reporting-friendly views.

## Project Overview

This project builds a small data warehouse using the Bronze, Silver, and Gold layers:

-   **Bronze**: raw data loaded from CSV files.
-   **Silver**: cleaned and standardized data.
-   **Gold**: reporting-ready views using a star schema (dimensions + fact).

The business use case is sales analytics: understand customers, products, and sales amounts over time.

## Dataset Description

The dataset comes from two source systems:

-   **CRM** (customer, product, and sales details)
-   **ERP** (customer details, customer location, and product category mapping)

Key CSV files:

-   CRM customers: [datasets/source\_crm/cust\_info.csv](datasets/source_crm/cust_info.csv)
-   CRM products: [datasets/source\_crm/prd\_info.csv](datasets/source_crm/prd_info.csv)
-   CRM sales: [datasets/source\_crm/sales\_details.csv](datasets/source_crm/sales_details.csv)
-   ERP customers: [datasets/source\_erp/CUST\_AZ12.csv](datasets/source_erp/CUST_AZ12.csv)
-   ERP locations: [datasets/source\_erp/LOC\_A101.csv](datasets/source_erp/LOC_A101.csv)
-   ERP product categories: [datasets/source\_erp/PX\_CAT\_G1V2.csv](datasets/source_erp/PX_CAT_G1V2.csv)

### Key Columns (simple meaning)

-   **cust\_info.csv**: customer ID, name, marital status, gender, create date.
-   **prd\_info.csv**: product ID, product key, name, cost, product line, start/end date.
-   **sales\_details.csv**: order number, product key, customer ID, order/ship/due date, sales, quantity, price.
-   **CUST\_AZ12.csv**: customer ID, birth date, gender.
-   **LOC\_A101.csv**: customer ID, country.
-   **PX\_CAT\_G1V2.csv**: category ID, category name, subcategory, maintenance flag.

Assumptions:

-   CRM date fields in sales are integers in `yyyymmdd` format and must be converted to DATE.
-   Some codes (gender, marital status, product line, country) need standardization.

## Data Warehouse Design

-   **Bronze Layer**: raw source tables in the `bronze` schema.
-   **Silver Layer**: cleaned tables in the `silver` schema.
-   **Gold Layer**: reporting views in the `gold` schema.

Gold follows a simple star schema:

-   **Dimensions**: `gold.dim_customer`, `gold.dim_product`
-   **Fact**: `gold.sales_fact`

## Technologies Used

-   SQL Server (T-SQL)
-   CSV files for source data

## Project Structure

-   [CREATING DB - SCHEMAS.sql](CREATING%20DB%20-%20SCHEMAS.sql): create database and schemas.
-   [CREATING TABLES OF BRONZE LAYER.sql](CREATING%20TABLES%20OF%20BRONZE%20LAYER.sql): create raw tables.
-   [LOADING BROZNE PROCEDURE.sql](LOADING%20BROZNE%20PROCEDURE.sql): load CSV data into Bronze.
-   [CREATING TABLES OF SILVER LAYER.sql](CREATING%20TABLES%20OF%20SILVER%20LAYER.sql): create cleaned tables.
-   [LOADING SILVER PROCEDURE.sql](LOADING%20SILVER%20PROCEDURE.sql): transform Bronze to Silver.
-   [CREATING GOLD LAYER.sql](CREATING%20GOLD%20LAYER.sql): create Gold views.
-   [GOLD LAYER.sql](GOLD%20LAYER.sql): alternative Gold view script and preview query.
-   [datasets](datasets): raw CSV files grouped by source system.


## How to Run the Project

1.  Run [CREATING DB - SCHEMAS.sql](CREATING%20DB%20-%20SCHEMAS.sql)
2.  Run [CREATING TABLES OF BRONZE LAYER.sql](CREATING%20TABLES%20OF%20BRONZE%20LAYER.sql)
3.  Update CSV file paths inside [LOADING BROZNE PROCEDURE.sql](LOADING%20BROZNE%20PROCEDURE.sql) if needed, then run it
4.  Run [CREATING TABLES OF SILVER LAYER.sql](CREATING%20TABLES%20OF%20SILVER%20LAYER.sql)
5.  Run [LOADING SILVER PROCEDURE.sql](LOADING%20SILVER%20PROCEDURE.sql)
6.  Run [CREATING GOLD LAYER.sql](CREATING%20GOLD%20LAYER.sql)
