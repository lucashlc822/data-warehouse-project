# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project repository!** 🚀
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.
A modern data warehouse with SQL Server, including ETL processes, data modelling, and analytics.

---

## Data Architecture ✏️
The data architecture for this project follows the **Medallion Architecture** (Multi-hop Architecture), which consists of the **bronze**, **silver**, and **gold** layers. This type of structure involves making incremental improvements to the data quality as it flows through each layer of the architecture.
![Data Architecture](documents/data_architecture.png)

**Bronze Layer:** 🥉
- The raw data is stored as-is from the source systems.
- Data is extracted from the CSV files (source object type) into the SQL Server database.

**Silver Layer:** 🥈
- Includes data cleansing, standardization, and normalization processes.
- Preparation phase prior to data analysis.

**Gold Layer:** 🥇
- Holds all of the business-ready data modelled into a star schema for reporting and analytics.
