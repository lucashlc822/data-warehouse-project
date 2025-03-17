/*
===========================
Create Database and Schemas

Script Purpose:
The purpose of this script is to create a new databse titled "DataWarehouse" after checking if it already exists. If the database already exists, then the database is dropped and recreated.
The script also adds schemas related to each stage of the project (bronze, silver, gold). This wil help with organizing files and scripts.

WARNING:
	Running this script will drop the database "DataWarehouse if it already exists. All the data will be permanently deleted. If you already have data within the database, ensure that you have proper backups of the files before running this script.

===========================
*/

-- start by entering the master database.
use master;
go

-- drop the data warehouse database (if any) and recreate it.
if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin
	alter database DataWarehouse set single_user with rollback immediate;
	drop database DataWarehouse;
end;
go

-- Create database DataWarehouse
create database DataWarehouse;
go

-- start using DataWarehoues database
use DataWarehouse;
go

-- create schemas
create schema bronze;
go

create schema silver;
go

create schema gold;
go
