/*
==================================================
Database Exploration
==================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.
==================================================
*/

-- Retrieve a list of all the tables in the database
select
TABLE_CATALOG,
TABLE_SCHEMA,
TABLE_NAME,
TABLE_TYPE
from INFORMATION_SCHEMA.tables;

-- Retrieve all the columns for a specific table (example: gold.dim_customer)
select
COLUMN_NAME,
DATA_TYPE,
IS_NULLABLE,
CHARACTER_MAXIMUM_LENGTH
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'dim_customer';

