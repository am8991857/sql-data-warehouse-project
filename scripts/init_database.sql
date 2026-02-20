/*
===============================================================================
 File: 001_create_datawarehouse_and_schemas.sql
 Purpose: Create DataWarehouse database and Bronze/Silver/Gold schemas
===============================================================================
*/

-- Use master context for database creation
USE master;
GO

-- Create database if it does not exist
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    CREATE DATABASE DataWarehouse;
END
GO

-- Switch to DataWarehouse
USE DataWarehouse;
GO

-- Create schemas if they do not exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO
