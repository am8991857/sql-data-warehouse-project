/*
	Create the project database and the three warehouse schemas.
	This is safe to re-run because it drops and recreates objects.
*/

-- Create the database for the project (drop first if it already exists).
IF DB_ID('SQL_DataWarehouse_Project') IS NOT NULL
	DROP DATABASE SQL_DataWarehouse_Project;
CREATE DATABASE SQL_DataWarehouse_Project;
------------------------------------------------

-- Switch context to the new database.
use SQL_DataWarehouse_Project;
------------------------------------------------
go
-- Create schemas for Bronze (raw), Silver (cleaned), and Gold (reporting).
IF SCHEMA_ID('bronze') IS NOT NULL
	DROP SCHEMA bronze;
CREATE SCHEMA bronze;
go

IF SCHEMA_ID('silver') IS NOT NULL
	DROP SCHEMA silver;
CREATE SCHEMA silver;
go

IF SCHEMA_ID('gold') IS NOT NULL
	DROP SCHEMA gold;
CREATE SCHEMA gold;
go
------------------------------------------------
